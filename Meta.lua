---@class Meta
---Module for handling metadata operations in Il2Cpp
local Meta = {}


Meta.behaviorForTypes = {
    [2] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_BYTE)
    end,
    [3] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_BYTE)
    end,
    [4] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_BYTE)
    end,
    [5] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_BYTE)
    end,
    [6] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_WORD)
    end,
    [7] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_WORD)
    end,
    [8] = function(blob)
        local self = Il2Cpp.Meta
        return Il2Cpp.Version < 29 and self.ReadNumberConst(blob, gg.TYPE_DWORD) or self.ReadCompressedInt32(blob)
    end,
    [9] = function(blob)
        local self = Il2Cpp.Meta
        return Il2Cpp.Version < 29 and Il2Cpp.FixValue(self.ReadNumberConst(blob, gg.TYPE_DWORD)) or self.ReadCompressedUInt32(blob)
    end,
    [10] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_QWORD)
    end,
    [11] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_QWORD)
    end,
    [12] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_FLOAT)
    end,
    [13] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_DOUBLE)
    end,
    [14] = function(blob)
        local self = Il2Cpp.Meta
        local length, offset = 0, 0
        if Il2Cpp.Version >= 29 then
            length, offset = self.ReadCompressedInt32(blob)
        else
            length = self.ReadNumberConst(blob, gg.TYPE_DWORD) 
            offset = 4
        end

        if length ~= -1 then
            return Il2Cpp.Utf8ToString(blob + offset, length)
        end
        return ""
    end
}


Meta.ReadCompressedUInt32 = function(Address)
    local val, offset = 0, 0
    local read = gg.getValues({
        { -- [1]
            address = Address, 
            flags = gg.TYPE_BYTE
        },
        { -- [2]
            address = Address + 1, 
            flags = gg.TYPE_BYTE
        },
        { -- [3]
            address = Address + 2, 
            flags = gg.TYPE_BYTE
        },
        { -- [4]
            address = Address + 3, 
            flags = gg.TYPE_BYTE
        }
    })
    local read1 = read[1].value & 0xFF
    offset = 1
    if (read1 & 0x80) == 0 then
        val = read1
    elseif (read1 & 0xC0) == 0x80 then
        val = (read1 & ~0x80) << 8
        val = val | (read[2].value & 0xFF)
        offset = offset + 1
    elseif (read1 & 0xE0) == 0xC0 then
        val = (read1 & ~0xC0) << 24
        val = val | ((read[2].value & 0xFF) << 16)
        val = val | ((read[3].value & 0xFF) << 8)
        val = val | (read[4].value & 0xFF)
        offset = offset + 3
    elseif read1 == 0xF0 then
        val = gg.getValues({{address = Address + 1, flags = gg.TYPE_DWORD}})[1].value
        offset = offset + 4
    elseif read1 == 0xFE then
        val = 0xffffffff - 1
    elseif read1 == 0xFF then
        val = 0xffffffff
    end
    return val, offset
end


---@param Address number
Meta.ReadCompressedInt32 = function(Address)
    local encoded, offset = Il2Cpp.Meta.ReadCompressedUInt32(Address)

    if encoded == 0xffffffff then
        return -2147483647 - 1
    end

    local isNegative = (encoded & 1) == 1
    encoded = encoded >> 1
    if isNegative then
        return -(encoded + 1)
    end
    return encoded, offset
end


---@param Address number
---@param ggType number @gg.TYPE_
Meta.ReadNumberConst = function(Address, ggType)
    return gg.getValues({{
        address = Address,
        flags = ggType
    }})[1].value
end
    

---Get pointers to a string in memory by searching for the string pattern
-- @param name string The string name to search for
-- @param addList any Additional list parameter (unused in current implementation)
-- @return table Table of search results containing addresses pointing to the string
-- @error Throws an error if the class is not found in global-metadata
function Meta.GetPointersToString(name, addList)
    gg.clearResults()
    gg.setRanges(-1)
    gg.searchNumber(string.format("Q 00 '%s' 00", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,
        Meta.metaStart, Meta.metaEnd)
    if gg.getResultsCount() == 0 then
        gg.searchNumber(string.format("Q 00 '%s' ", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,
        Meta.metaStart, Meta.metaEnd)
    end
    local results = gg.getResults(1, 1)
    if #results == 0 then
        error(string.format("Không tìm thấy lớp %s trong global-metadata", name))
    end
    gg.clearResults()
    gg.setRanges(Meta.regionClass)
    gg.searchNumber(results[1].address, Il2Cpp.MainType)
    if gg.getResultsCount() == 0 and x64 then
        gg.searchNumber(tostring(results[1].address | 0xB400000000000000), Il2Cpp.MainType)
    end
    local res = gg.getResults(gg.getResultsCount())
    gg.clearResults()
    return res
end

---Get string from metadata using string index
-- @param index number String index in metadata
-- @return string Decoded UTF-8 string from metadata
function Meta:GetStringFromIndex(index)
    local stringDefinitions = Meta.Header.stringOffset
    return Il2Cpp.Utf8ToString(stringDefinitions + index)
end

---Get generic container from metadata by index
-- @param index number Generic container index
-- @return table Il2CppGenericContainer object
function Meta:GetGenericContainer(index)
    local index = index
    if Meta.Header.genericContainersSize > index then
        index = Meta.Header.genericContainersOffset + (index * Il2Cpp.Il2CppGenericContainer.size)
    end
    return Il2Cpp.Il2CppGenericContainer(index)
end

---Get generic parameter from metadata by index
-- @param index number Generic parameter index
-- @return table Il2CppGenericParameter object
function Meta:GetGenericParameter(index)
    local index = index
    if Meta.Header.genericParametersSize > index then
        index = Meta.Header.genericParametersOffset + (index * Il2Cpp.Il2CppGenericParameter.size)
    end
    return Il2Cpp.Il2CppGenericParameter(index)
end

function Meta:GetGenericContainerParams(genericContainer)
    local genericParameterNames = {}
    for i = 1, genericContainer.type_argc do
        local genericParameterIndex = genericContainer.genericParameterStart + i
        local genericParameter = self:GetGenericParameter(genericParameterIndex)
        genericParameterNames[i] = self:GetStringFromIndex(genericParameter.nameIndex)
    end
    return "<" .. table.concat(genericParameterNames, ", ") .. ">"
end


function Meta:GetGenericInsts(index)
    local index = Il2Cpp.pMetadataRegistration.genericInsts + (index * Il2Cpp.type.Pointer.size)
    return Il2Cpp.Il2CppGenericInst(index)
end

---Get method definition from metadata by index
-- @param index number Method definition index
-- @return table Il2CppMethodDefinition object
function Meta:GetMethodDefinition(index)
    local index = Meta.Header.methodsOffset + (index * Il2Cpp.Il2CppMethodDefinition.size)
    return Il2Cpp.Il2CppMethodDefinition(index)
end

---Get parameter definition from metadata by index
-- @param index number Parameter definition index
-- @return table Il2CppParameterDefinition object
function Meta:GetParameterDefinition(index)
    local index = Meta.Header.parametersOffset + (index * Il2Cpp.Il2CppParameterDefinition.size)
    return Il2Cpp.Il2CppParameterDefinition(index)
end


function Meta:GetGenericMethodTable(index)
    local index = index
    if Il2Cpp.pMetadataRegistration.genericMethodTableCount > index then
        index = Il2Cpp.pMetadataRegistration.genericMethodTable + (index * Il2Cpp.Il2CppGenericMethodFunctionsDefinitions.size)
    end
    return Il2Cpp.Il2CppGenericMethodFunctionsDefinitions(index)
end

function Meta:GetMethodSpec(index)
    local index = index
    if Il2Cpp.pMetadataRegistration.methodSpecsCount > index then
        index = Il2Cpp.pMetadataRegistration.methodSpecs + (index * Il2Cpp.Il2CppMethodSpec.size)
    end
    return Il2Cpp.Il2CppMethodSpec(index)
end

function Meta:GetFieldDefaultValueFromIndex(index)
    if not self.fieldDefaultValues then
        self.fieldDefaultValues = {}
        for i, v in ipairs(Il2Cpp.classArray(Il2Cpp.Meta.Header.fieldDefaultValuesOffset, Il2Cpp.Meta.Header.fieldDefaultValuesSize / Il2Cpp.Il2CppFieldDefaultValue.size, Il2Cpp.Il2CppFieldDefaultValue)) do
            self.fieldDefaultValues[v.fieldIndex] = v
        end
    end
    return self.fieldDefaultValues[index]
end

function Meta:GetParameterDefaultValueFromIndex(index)
    if not self.parameterDefaultValues then
        self.parameterDefaultValues = {}
        for i, v in ipairs(Il2Cpp.classArray(Il2Cpp.Meta.Header.parameterDefaultValuesOffset, Il2Cpp.Meta.Header.parameterDefaultValuesSize / Il2Cpp.Il2CppParameterDefaultValue.size, Il2Cpp.Il2CppParameterDefaultValue)) do
            self.parameterDefaultValues[v.parameterIndex] = v
        end
    end
    return self.parameterDefaultValues[index]
end

function Meta:GetDefaultValueFromIndex(index)
    return self.Header.fieldAndParameterDefaultValueDataOffset + index
end


function Meta:TryGetDefaultValue(typeIndex, dataIndex)
    local pointer = self:GetDefaultValueFromIndex(dataIndex)
    local defaultValueType = Il2Cpp.Type(typeIndex)
    
    local behavior = self.behaviorForTypes[defaultValueType.type] or "Not support type"
    if type(behavior) == "function" then
        return true, behavior(pointer)
    end
    return false, behavior
end





return Meta