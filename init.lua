---@module Il2Cpp
---Main initialization module for Il2Cpp framework
Il2Cpp = require "Il2Cpp"()

-- Setup global metadata and Il2Cpp registration
local metaStart, metaEnd = Il2Cpp.Universalsearcher:FindGlobalMetaData()
Il2Cpp.Meta.metaStart = metaStart
Il2Cpp.Meta.metaEnd = metaEnd
Il2Cpp.Meta.Header = Il2Cpp.Il2CppGlobalMetadataHeader(metaStart)
Il2Cpp.Meta.regionClass = Il2Cpp.Version >= 29.1 and gg.REGION_ANONYMOUS or gg.REGION_C_ALLOC
Il2Cpp.Universalsearcher.Il2CppMetadataRegistration()

-- Adjust metadata header offsets by adding the metaStart address
for k, v in pairs(Il2Cpp.Meta.Header) do
    local _, __ = k:find("Offset")
    if __ == #k then
        Il2Cpp.Meta.Header[k] = metaStart + v
    end
end

-- Calculate type size and initialize Type module properties
Il2Cpp.typeSize = Il2Cpp.Meta.Header.typeDefinitionsSize / Il2Cpp.typeCount
Il2Cpp.Type.typeCount = Il2Cpp.gV(Il2Cpp.metaReg + ( 6 * Il2Cpp.pointSize), Il2Cpp.pointer)
Il2Cpp.Type.type = Il2Cpp.gV(Il2Cpp.metaReg + ( 7 * Il2Cpp.pointSize), Il2Cpp.pointer)

return Il2Cpp