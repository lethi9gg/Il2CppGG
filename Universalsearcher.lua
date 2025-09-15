local AndroidInfo = require "Androidinfo"
local MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD
local pointSize = AndroidInfo.platform and 8 or 4

---@class Searcher
---Universal searcher module for locating Il2Cpp and metadata components in memory
local Searcher = {
    searchWord = ":EnsureCapacity",

    ---Find global metadata in memory using various search strategies
    -- @param self Searcher The Searcher instance
    -- @return number Start address of global metadata
    -- @return number End address of global metadata
    FindGlobalMetaData = function(self)
        gg.clearResults()
        gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS |
                         gg.REGION_OTHER)
        local globalMetadata = gg.getRangesList('global-metadata.dat')
        if not self:IsValidData(globalMetadata) then
            globalMetadata = gg.getRangesList("dev/zero")
        end
        if not self:IsValidData(globalMetadata) then
            globalMetadata = {}
            gg.clearResults()
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE)
            gg.refineNumber(self.searchWord:sub(1, 2), gg.TYPE_BYTE)
            local EnsureCapacity = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for k, v in ipairs(gg.getRangesList()) do
                if (v.state == 'Ca' or v.state == 'A' or v.state == 'Cd' or v.state == 'Cb' or v.state == 'Ch' or
                    v.state == 'O') then
                    for key, val in ipairs(EnsureCapacity) do
                        globalMetadata[#globalMetadata + 1] =
                            (Il2Cpp.FixValue(v.start) <= Il2Cpp.FixValue(val.address) and Il2Cpp.FixValue(val.address) <
                                Il2Cpp.FixValue(v['end'])) and v or nil
                    end
                end
            end
        end
        local value = -89056337
        if gg.getValues({{address = globalMetadata[1].start, flags = 4}})[1].value ~= value then
            gg.searchNumber(value, 4, false, gg.SIGN_EQUAL, globalMetadata[1].start, globalMetadata[#globalMetadata]['end'])
            if gg.getResultsCount() > 0 then
                globalMetadata[1].start = gg.getResults(1)[1].address
            end
        end
        return type(globalMetadata) == "table" and globalMetadata[1].start, globalMetadata[#globalMetadata]['end'] or 0, 0
    end,

    ---Check if global metadata contains valid data by searching for the signature
    -- @param self Searcher The Searcher instance
    -- @param globalMetadata table Table of memory ranges to check
    -- @return boolean True if valid data is found, false otherwise
    IsValidData = function(self, globalMetadata)
        if #globalMetadata ~= 0 then
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, globalMetadata[1].start,
                globalMetadata[#globalMetadata]['end'])
            if gg.getResultsCount() > 0 then
                gg.clearResults()
                return true
            end
        end
        return false
    end,

    ---Find Il2Cpp library in memory using various search strategies
    -- @return number Start address of Il2Cpp library
    -- @return number End address of Il2Cpp library
    FindIl2cpp = function()
        local il2cpp = gg.getRangesList('libil2cpp.so')
        if #il2cpp == 0 then
            il2cpp = gg.getRangesList('split_config.')
            local _il2cpp = {}
            gg.setRanges(gg.REGION_CODE_APP)
            for k, v in ipairs(il2cpp) do
                if (v.state == 'Xa') then
                    gg.searchNumber(':il2cpp', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, v.start, v['end'])
                    if (gg.getResultsCount() > 0) then
                        _il2cpp[#_il2cpp + 1] = v
                        gg.clearResults()
                    end
                end
            end
            il2cpp = _il2cpp
        else
            local _il2cpp = {}
            for k,v in ipairs(il2cpp) do
                local Value = gg.getValues({{address = v.start, flags = 4}})[1].value
                if Value==0x464C457F or Value==263434879 then
                --if (string.find(v.type, "..x.") or v.state == "Xa") then
                    _il2cpp[#_il2cpp + 1] = v
                end
            end
            il2cpp[1] = _il2cpp[#_il2cpp]
            --il2cpp = _il2cpp
        end       
        return il2cpp[1].start, il2cpp[#il2cpp]['end']
    end,

    ---Locate and initialize Il2Cpp metadata registration structures
    -- @return table Table containing metadata registration information
    Il2CppMetadataRegistration = function()
        ---Check if an address points to a valid image name
        -- @param addr number Memory address to check
        -- @return string|boolean Image name if valid, false otherwise
        local function isImage(addr)
            local imageStr = Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(addr))
            local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
            return check and imageStr
        end
        
        -- Set pointer sizes based on version and platform
        Il2Cpp.classPointer = Il2Cpp.Version < 27 and (AndroidInfo.platform and 24 or 12) or (AndroidInfo.platform and 40 or 20);
        Il2Cpp.imagePointer = Il2Cpp.Version < 27 and (AndroidInfo.platform and 72 or 36) or (AndroidInfo.platform and 24 or 12);
        
        -- Get global metadata range
        local gmt = gg.getRangesList("global-metadata.dat");
	    local gmt = ((gmt and #gmt > 0) and gmt[1].start) or Il2Cpp.Meta.metaStart
	    
	    -- Search for global metadata reference in Il2Cpp memory
	    gg.clearResults();
	    gg.setRanges(16 | 32);
	    gg.searchNumber(gmt, Il2Cpp.MainType, nil, nil, Il2Cpp.il2cppStart, -1, 1);
	    
	    -- Handle 64-bit Android SDK 30+ special case
	    if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(gmt | 0xB400000000000000), Il2Cpp.MainType, nil, nil, Il2Cpp.il2cppStart, -1, 1);
        end
        
        
        local t = gg.getResults(1)
        gg.clearResults();
        local address = t[1].address
        
        -- Find the start of the registration structure
        while true do
            local Range = gg.getValuesRange({{address = Il2Cpp.GetPtr(address), flags = MainType}})[1]
            address = address - pointSize
            if Range == 'Cd' then break end
        end
        
        -- Extract registration pointers
        local g_code = Il2Cpp.GetPtr(address)
        local g_meta = Il2Cpp.GetPtr(address + pointSize)
        local classCount = gg.getValues({{address = g_meta + pointSize * 12, flags = MainType}})[1].value
        
        -- Validate class count
        if classCount == 0 or classCount < 0 then
            error("classCount: "..classCount)
        end
        
        -- Find image definitions
        local imgAddr = t[1].address + Il2Cpp.imagePointer
        local results = gg.getValues({
            {address=(Il2Cpp.GetPtr(imgAddr) + 16),flags=Il2Cpp.MainType},
            {address=Il2Cpp.GetPtr(t[1].address + Il2Cpp.classPointer),flags=Il2Cpp.MainType}});
            
        -- Handle special case for empty pointer
        if Il2Cpp.GetPtr(results[1].value) == 0 then
            results[1] = gg.getValues({{address=(Il2Cpp.GetPtr(imgAddr) + 16 + 8),flags=Il2Cpp.MainType}})[1];
        end
        
        -- Set image definitions
        local addr = results[1].address
        if isImage(Il2Cpp.GetPtr(addr)) then
            Il2Cpp.imageDef = Il2Cpp.GetPtr(addr)
            Il2Cpp.imageCount = Il2Cpp.GetPtr(imgAddr - Il2Cpp.pointSize)
        else  
            -- Alternative search for image definitions
            local imgAddr = t[1].address + Il2Cpp.classPointer
            for i = 1, 100 do
                local addr = imgAddr + (i * Il2Cpp.pointSize)
                if isImage(Il2Cpp.GetPtr(addr)) then
                    Il2Cpp.imageDef = Il2Cpp.GetPtr(addr)
                    Il2Cpp.imageCount = Il2Cpp.GetPtr(addr - Il2Cpp.pointSize)
                    break
                end
            end
        end
        
        -- Calculate image size
        for i = 1, 100 do
            local addr = Il2Cpp.imageDef + (i * Il2Cpp.pointSize)
            if isImage(addr) then
                Il2Cpp.imageSize = addr - Il2Cpp.imageDef
                break
            end
        end
        
        -- Set type definition pointer
        Il2Cpp.typeDef = results[2].address
        
        
        -- Set type count and registration pointers
        Il2Cpp.typeCount = classCount or 0
        Il2Cpp.metaReg = g_meta or 0
        Il2Cpp.il2cppReg = g_code or 0
        Il2Cpp.pMetadataRegistration = Il2Cpp.Il2CppMetadataRegistration(Il2Cpp.metaReg)
        Il2Cpp.pCodeRegistration = Il2Cpp.Il2CppCodeRegistration(Il2Cpp.il2cppReg)
        
        return {
            metadataRegistration = g_meta,
            il2cppRegistration = g_code,
            classCount = classCount,
        }
    end
}

return Searcher