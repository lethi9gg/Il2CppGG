local Universalsearcher = require("universalsearcher")
local metaStart, metaEnd = Universalsearcher:FindGlobalMetaData()
Universalsearcher.Il2CppMetadataRegistration()
local Meta = {
    metaStart = metaStart,
    metaEnd = metaEnd,
    Universalsearcher = Universalsearcher,
    Header = Il2Cpp.Il2CppGlobalMetadataHeader(metaStart),
    regionClass = Il2Cpp.Version >= 29.1 and gg.REGION_ANONYMOUS or gg.REGION_C_ALLOC
}

for k, v in pairs(Meta.Header) do
    local _, __ = k:find("Offset")
    if __ == #k then
        Meta.Header[k] = metaStart + v
    end
end
       
Il2Cpp.typeSize = Meta.Header.typeDefinitionsSize / Il2Cpp.typeCount


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

function Meta:GetStringFromIndex(index)
    local stringDefinitions = Meta.Header.stringOffset
    return Il2Cpp.Utf8ToString(stringDefinitions + index)
end

function Meta:GetGenericContainer(index)
    local index = index
    if Meta.Header.genericContainersSize > index then
        index = Meta.Header.genericContainersOffset + (index * Il2Cpp.Il2CppGenericContainer.size)
    end
    return Il2Cpp.Il2CppGenericContainer(index)
end

function Meta:GetGenericParameter(index)
    local index = index
    if Meta.Header.genericParametersSize > index then
        index = Meta.Header.genericParametersOffset + (index * Il2Cpp.Il2CppGenericParameter.size)
    end
    return Il2Cpp.Il2CppGenericParameter(index)
end

function Meta:GetMethodDefinition(index)
    local index = Meta.Header.methodsOffset + (index * Il2Cpp.Il2CppMethodDefinition.size)
    return Il2Cpp.Il2CppMethodDefinition(index)
end

function Meta:GetParameterDefinition(index)
    local index = Meta.Header.parametersOffset + (index * Il2Cpp.Il2CppParameterDefinition.size)
    return Il2Cpp.Il2CppParameterDefinition(index)
end



return Meta