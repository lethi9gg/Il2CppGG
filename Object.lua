local AndroidInfo = require("Androidinfo")

---@class ObjectApi
---Module for handling Il2Cpp object operations and memory management
local ObjectApi = {

    ---@field regionObject number Memory region to search for objects (default: gg.REGION_ANONYMOUS)
    regionObject = gg.REGION_ANONYMOUS,

    ---Filter objects to remove invalid references and handle 64-bit Android SDK 30+ special cases
    -- @param self ObjectApi The ObjectApi instance
    -- @param Objects table Table of objects to filter
    -- @return table Filtered objects with valid references
    FilterObjects = function(self, Objects)
        local FilterObjects = {}
        for k, v in ipairs(gg.getValuesRange(Objects)) do
            if v == 'A' then
                FilterObjects[#FilterObjects + 1] = Objects[k]
            end
        end
        Objects = FilterObjects
        gg.loadResults(Objects)
        gg.searchPointer(0)
        if gg.getResultsCount() <= 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            local FixRefToObjects = {}
            for k, v in ipairs(Objects) do
                gg.searchNumber(tostring(v.address | 0xB400000000000000), gg.TYPE_QWORD)
                ---@type tablelib
                local RefToObject = gg.getResults(gg.getResultsCount())
                table.move(RefToObject, 1, #RefToObject, #FixRefToObjects + 1, FixRefToObjects)
                gg.clearResults()
            end
            gg.loadResults(FixRefToObjects)
        end
        local RefToObjects, FilterObjects = gg.getResults(gg.getResultsCount()), {}
        gg.clearResults()
        for k, v in ipairs(gg.getValuesRange(RefToObjects)) do
            if v == 'A' then
                FilterObjects[#FilterObjects + 1] = {
                    address = Il2Cpp.FixValue(RefToObjects[k].value),
                    flags = RefToObjects[k].flags
                }
            end
        end
        gg.loadResults(FilterObjects)
        local _FilterObjects = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        return _FilterObjects
    end,

    ---Find objects of a specific class in memory
    -- @param self ObjectApi The ObjectApi instance
    -- @param ClassAddress string|number Address of the class to search for
    -- @return table Table of found objects
    FindObjects = function(self, ClassAddress)
        gg.clearResults()
        gg.setRanges(0)
        --gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_C_ALLOC)
        gg.setRanges(self.regionObject)
        gg.loadResults({{
            address = tonumber(ClassAddress),
            flags = Il2Cpp.MainType
        }})
        gg.searchPointer(0)
        if gg.getResultsCount() <= 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(tonumber(ClassAddress) | 0xB400000000000000), gg.TYPE_QWORD)
        end
        local FindsResult = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        local t = {}
        for i, v in ipairs(FindsResult) do
            if Il2Cpp.gV(v.address + Il2Cpp.pointSize) == 0 and Il2Cpp.gV(v.address + Il2Cpp.Il2CppObject.size, 4) ~= 75 then
                t[#t+1]=v
            end
        end
        return self:FilterObjects(t);--self:FilterObjects(FindsResult)
    end,

    ---Find objects from multiple class information structures
    -- @param self ObjectApi The ObjectApi instance
    -- @param ClassesInfo ClassInfo[] Array of class information tables
    -- @return table Table of found objects
    From = function(self, ClassesInfo)
        local Objects = {}
        for j = 1, #ClassesInfo do
            local FindResult = self:FindObjects(ClassesInfo[j].address)
            table.move(FindResult, 1, #FindResult, #Objects + 1, Objects)
        end
        return Objects
    end,

    ---Find the class head (start address) for a given object address
    -- @param Address number Memory address of an object
    -- @return table Table containing address and value of the class head
    FindHead = function(Address)
        local validAddress = Address
        local mayBeHead = {}
        for i = 1, 1000 do
            mayBeHead[i] = {
                address = validAddress - (4 * (i - 1)),
                flags = Il2Cpp.MainType
            } 
        end
        mayBeHead = gg.getValues(mayBeHead)
        for i = 1, #mayBeHead do
            local mayBeClass = Il2Cpp.FixValue(mayBeHead[i].value)
            if Class.IsClassInfo(mayBeClass) then
                return mayBeHead[i]
            end
        end
        return {value = 0, address = 0}
    end,
}

return setmetatable(ObjectApi, {
    ---Metatable call handler for ObjectApi
    -- Allows ObjectApi to be called as a function
    -- @param ... any Arguments passed to ObjectApi.From
    -- @return table Table of found objects
    __call = ObjectApi.From
})