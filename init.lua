---@module Il2Cpp
Il2Cpp = function(config)
    local _path, config = package.path, config or {}
    package.path = gg.getFile():match("(.*[/%\\])") .. "?.lua;" .. package.path;
    
    ---Main initialization module for Il2Cpp framework
    Il2Cpp = require "Il2Cpp"()
    
    package.path = _path
    
    -- Setup global metadata and Il2Cpp registration
    local metaStart, metaEnd = config.metaStart, config.metaEnd
    if not metaStart and not metaEnd then
        metaStart, metaEnd = Il2Cpp.Universalsearcher:FindGlobalMetaData()
    end
    Il2Cpp.Meta.metaStart = metaStart
    Il2Cpp.Meta.metaEnd = metaEnd
    Il2Cpp.Meta.Header = Il2Cpp.Il2CppGlobalMetadataHeader(metaStart)
    
    if (Il2Cpp.Meta.Header.version >= 31 or Il2Cpp.Meta.Header.version <= 0) or not Il2Cpp.Utf8ToString(metaStart + Il2Cpp.Meta.Header.stringOffset, 100):find(".dll") then 
        Il2Cpp.Meta.Obf = true
        Il2Cpp.log:info("Il2Cpp.Meta.Obf", true)
    end
    
    Il2Cpp.Meta.Header.version = Il2Cpp.Meta.Obf and Il2Cpp.Version or Il2Cpp.Meta.Header.version
    Il2Cpp.log:info("Il2Cpp.Meta.Header.version", Il2Cpp.Meta.Header.version)
    --Il2Cpp.Meta.regionClass = (Il2Cpp.Version >= 29.1 and Il2Cpp.Meta.Header.version >= 29) and gg.REGION_ANONYMOUS or gg.REGION_C_ALLOC

    if Il2Cpp.Meta.Header.version == 31 then
        Il2Cpp.Il2CppMethodDefinition = Il2Cpp.classGG(Il2Cpp._Il2CppMethodDefinition, Il2Cpp.Meta.Header.version)
    end
    
    local il2cppStart, il2cppEnd = config.il2cppStart, config.il2cppEnd
    if not il2cppStart and not il2cppEnd then
        il2cppStart, il2cppEnd = Il2Cpp.Universalsearcher:FindIl2cpp()
    end
    Il2Cpp.il2cppStart = il2cppStart
    Il2Cpp.il2cppEnd = il2cppEnd
    
    -- Adjust metadata header offsets by adding the metaStart address
    if not Il2Cpp.Meta.Obf then
        for k, v in pairs(Il2Cpp.Meta.Header) do
            local _, __ = k:find("Offset")
            if __ == #k then
                Il2Cpp.Meta.Header[k] = metaStart + v
            end
        end
    end
    Il2Cpp.Universalsearcher:Il2CppMetadataRegistration()
    
    -- Calculate type size and initialize Type module properties
    --Il2Cpp.typeSize = Il2Cpp.Meta.Header.typeDefinitionsSize / Il2Cpp.typeCount
    Il2Cpp.Type.typeCount = Il2Cpp.typeCount--Il2Cpp.gV(Il2Cpp.metaReg + ( 6 * Il2Cpp.pointSize), Il2Cpp.pointer)
    Il2Cpp.Type.type = Il2Cpp.pMetadataRegistration.types--Il2Cpp.gV(Il2Cpp.metaReg + ( 7 * Il2Cpp.pointSize), Il2Cpp.pointer)
    --Il2Cpp.Type.typeSize = Il2Cpp.Type.type + ((Il2Cpp.Type.typeCount - 1) * Il2Cpp.pointSize)
    
    if Il2Cpp.Meta.Obf then
        for i = 0, Il2Cpp.pMetadataRegistration.typeDefinitionsSizesCount - 1 do 
            local klass = Il2Cpp.Class(i)
            klass:Dump()
            local genericContainer = klass.genericContainerIndex or klass.genericContainerHandle
            if genericContainer > 0 then 
                Il2Cpp.Meta.Header.genericContainers = genericContainer
                break
            end
        end
        Il2Cpp.Meta.Header.genericContainersOffset = Il2Cpp.Meta.Header.genericContainers or Il2Cpp.Meta.Header.genericContainersOffset
        Il2Cpp.Meta.Header.genericParametersOffset = Il2Cpp.Meta.Header.genericParameters or Il2Cpp.Meta.Header.genericParametersOffset
        Il2Cpp.log:info("Il2Cpp.Meta.Header.genericContainersOffset", Il2Cpp.Meta.Header.genericContainersOffset)
        Il2Cpp.log:info("Il2Cpp.Meta.Header.genericParametersOffset", Il2Cpp.Meta.Header.genericParametersOffset)
    end
    
    
    --[[
    Il2Cpp.genericMethodPointers = Il2Cpp.classArray(Il2Cpp.pCodeRegistration.genericMethodPointers, Il2Cpp.pCodeRegistration.genericMethodPointersCount, "Pointer")
    Il2Cpp.genericMethodTable = Il2Cpp.classArray(Il2Cpp.pMetadataRegistration.genericMethodTable, Il2Cpp.pMetadataRegistration.genericMethodTableCount, Il2Cpp.Il2CppGenericMethodFunctionsDefinitions)
    Il2Cpp.methodSpecs = Il2Cpp.classArray(Il2Cpp.pMetadataRegistration.methodSpecs, Il2Cpp.pMetadataRegistration.methodSpecsCount, Il2Cpp.Il2CppMethodSpec)
    
    for _, tab in ipairs(Il2Cpp.genericMethodTable) do
        local methodSpec = Il2Cpp.methodSpecs[tab.genericMethodIndex + 1]
        local methodDefinitionIndex = methodSpec.methodDefinitionIndex
        if not Il2Cpp.methodDefinitionMethodSpecs[methodDefinitionIndex] then
            Il2Cpp.methodDefinitionMethodSpecs[methodDefinitionIndex] = {}
        end
        table.insert(Il2Cpp.methodDefinitionMethodSpecs[methodDefinitionIndex], methodSpec)
        Il2Cpp.methodSpecGenericMethodPointers[methodSpec] = Il2Cpp.genericMethodPointers[tab.indices.methodIndex + 1]
    end
    ]]
    
    
    return Il2Cpp
end
