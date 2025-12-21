---@module Il2Cpp
--[[
Il2CppGG/
├── core/
│   ├── Il2Cpp.lua (Core module, handles versioning and utilities)
│   ├── Struct.lua (Defines version-specific Il2Cpp structures)
│   ├── Version.lua (Version detection and structure selection)
│   ├── Universalsearcher.lua (Module for locating metadata and key pointers)
│   └── Meta.lua (Module for Il2Cpp metadata)
├── api/
│   ├── Class.lua (Module for Il2Cpp classes)
│   ├── Field.lua (Module for Il2Cpp fields)
│   ├── Method.lua (Module for Il2Cpp methods)
│   ├── Type.lua (Module for Il2Cpp types)
│   ├── Image.lua (Module for Il2Cpp images/assemblies)
│   ├── Object.lua (Module for memory object manipulation)
│   └── Param.lua (Parameter operations module)
├── utils/
│   ├── Androidinfo.lua (Helper for Android device information)
│   ├── Hook.lua (Memory hooking for modification and reverse engineering)
│   ├── Patch.lua (Memory Patch)
│   └── Dump.lua (Class dumping to C# format)
├── build/
│   └── Il2CppGG.lua (Bundled, production-ready script)
├── buildLT9.lua (Build script to bundle modules)
├── init.lua (Entry point for development)
└── test.lua (Usage examples for hooking and dumping)
]]

Il2Cpp = function(config)
    local _path, config = package.path, config or {}
    package.path = gg.getFile():match("(.*[/%\\])") .. "?.lua;" .. package.path;
    
    ---Main initialization module for Il2Cpp framework
    Il2Cpp = require "core.Il2Cpp"()
    
    package.path = _path
    
    Il2Cpp.log.level = config.log or Il2Cpp.log.level
    
    
    -- Setup global metadata and Il2Cpp registration
    Il2Cpp.log:info("Initializing il2cpp ...")
    local il2cppStart, il2cppEnd = config.il2cppStart, config.il2cppEnd
    if not il2cppStart and not il2cppEnd then
        il2cppStart, il2cppEnd = Il2Cpp.Searcher.FindIl2cpp()
    end
    Il2Cpp.il2cppStart = il2cppStart
    Il2Cpp.il2cppEnd = il2cppEnd
    
    Il2Cpp.log:info("Il2Cpp Version: " .. Il2Cpp.Version)
    Il2Cpp.log:info("Il2Cpp Start Address: " .. Il2Cpp.ToHex(Il2Cpp.il2cppStart))
    
    
    Il2Cpp.log:info("Initializing metadata...")
    local metaStart, metaEnd = config.metaStart, config.metaEnd
    if not metaStart and not metaEnd then
        metaStart, metaEnd = Il2Cpp.Searcher:FindGlobalMetaData()
    end
    Il2Cpp.Searcher:Il2CppMetadataRegistration(metaStart)
    Il2Cpp.Meta.metaStart = metaStart
    Il2Cpp.Meta.metaEnd = metaEnd
    Il2Cpp.Meta(metaStart, Il2Cpp.Version)
    Il2Cpp.log:info("Metadata Version: " .. Il2Cpp.Meta.Version)
    Il2Cpp.log:info("Metadata Start Address: " .. Il2Cpp.ToHex(metaStart))
    
    local il2cppStart, il2cppEnd = Il2Cpp.Searcher.FindIl2cpp(Il2Cpp.metaReg)
    Il2Cpp.il2cppStart = il2cppStart
    Il2Cpp.il2cppEnd = il2cppEnd
    
    Il2Cpp.log:info("Change Il2Cpp Start Address to: " .. Il2Cpp.ToHex(Il2Cpp.il2cppStart))
    
    --[[
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
    ]]
    
    
    -- Calculate type size and initialize Type module properties
    --Il2Cpp.typeSize = Il2Cpp.Meta.Header.typeDefinitionsSize / Il2Cpp.typeCount
    Il2Cpp.Type.typeCount = Il2Cpp.typeCount--Il2Cpp.gV(Il2Cpp.metaReg + ( 6 * Il2Cpp.pointSize), Il2Cpp.pointer)
    Il2Cpp.Type.type = Il2Cpp.pMetadataRegistration.types--Il2Cpp.gV(Il2Cpp.metaReg + ( 7 * Il2Cpp.pointSize), Il2Cpp.pointer)
    --Il2Cpp.Type.typeSize = Il2Cpp.Type.type + ((Il2Cpp.Type.typeCount - 1) * Il2Cpp.pointSize)
    
    
    
    
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
