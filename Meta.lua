---@class Meta
---Module for handling metadata operations in Il2Cpp
local Meta = {}
    

---Get pointers to a string in memory by searching for the string pattern
-- @param name string The string name to search for
-- @param addList any Additional list parameter (unused in current implementation)
-- @return table Table of search results containing addresses pointing to the string
-- @error Throws an error if the class is not found in global-metadata
function Meta.GetPointersToString(name, addList)
    gg.clearResults()
    gg.setRanges(-1)
    gg.searchNumber(string.format("Q 00 '%s' 00", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,
        metaStart, metaEnd)
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

return Meta