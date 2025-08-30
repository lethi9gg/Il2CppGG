---@class Structs
---Table containing all Il2Cpp structure definitions for different versions
local Structs = {
    ---@class Il2CppGlobalMetadataHeader
    ---Global metadata header structure containing offsets and sizes of various metadata sections
    Il2CppGlobalMetadataHeader = {
        { "sanity", "UInt32", version = {max = 24.1} }, -- Sanity check value
        { "version", "Int32" }, -- Metadata version
        { "stringLiteralOffset", "UInt32" }, -- Offset to string literals
        { "stringLiteralSize", "Int32" }, -- Size of string literals section
        { "stringLiteralDataOffset", "UInt32" }, -- Offset to string literal data
        { "stringLiteralDataSize", "Int32" }, -- Size of string literal data
        { "stringOffset", "UInt32" }, -- Offset to string table
        { "stringSize", "Int32" }, -- Size of string table
        { "eventsOffset", "UInt32" }, -- Offset to events table
        { "eventsSize", "Int32" }, -- Size of events table
        { "propertiesOffset", "UInt32" }, -- Offset to properties table
        { "propertiesSize", "Int32" }, -- Size of properties table
        { "methodsOffset", "UInt32" }, -- Offset to methods table
        { "methodsSize", "Int32" }, -- Size of methods table
        { "parameterDefaultValuesOffset", "UInt32" }, -- Offset to parameter default values
        { "parameterDefaultValuesSize", "Int32" }, -- Size of parameter default values
        { "fieldDefaultValuesOffset", "UInt32" }, -- Offset to field default values
        { "fieldDefaultValuesSize", "Int32" }, -- Size of field default values
        { "fieldAndParameterDefaultValueDataOffset", "UInt32" }, -- Offset to default value data
        { "fieldAndParameterDefaultValueDataSize", "Int32" }, -- Size of default value data
        { "fieldMarshaledSizesOffset", "UInt32" }, -- Offset to field marshaled sizes
        { "fieldMarshaledSizesSize", "Int32" }, -- Size of field marshaled sizes
        { "parametersOffset", "UInt32" }, -- Offset to parameters table
        { "parametersSize", "Int32" }, -- Size of parameters table
        { "fieldsOffset", "UInt32" }, -- Offset to fields table
        { "fieldsSize", "Int32" }, -- Size of fields table
        { "genericParametersOffset", "UInt32" }, -- Offset to generic parameters
        { "genericParametersSize", "Int32" }, -- Size of generic parameters
        { "genericParameterConstraintsOffset", "UInt32" }, -- Offset to generic parameter constraints
        { "genericParameterConstraintsSize", "Int32" }, -- Size of generic parameter constraints
        { "genericContainersOffset", "UInt32" }, -- Offset to generic containers
        { "genericContainersSize", "Int32" }, -- Size of generic containers
        { "nestedTypesOffset", "UInt32" }, -- Offset to nested types
        { "nestedTypesSize", "Int32" }, -- Size of nested types
        { "interfacesOffset", "UInt32" }, -- Offset to interfaces
        { "interfacesSize", "Int32" }, -- Size of interfaces
        { "vtableMethodsOffset", "UInt32" }, -- Offset to vtable methods
        { "vtableMethodsSize", "Int32" }, -- Size of vtable methods
        { "interfaceOffsetsOffset", "UInt32" }, -- Offset to interface offsets
        { "interfaceOffsetsSize", "Int32" }, -- Size of interface offsets
        { "typeDefinitionsOffset", "UInt32" }, -- Offset to type definitions
        { "typeDefinitionsSize", "Int32" }, -- Size of type definitions
        { "rgctxEntriesOffset", "UInt32", version = {max = 24.1} }, -- Offset to RGCTX entries (≤ v24.1)
        { "rgctxEntriesCount", "Int32", version = {max = 24.1} }, -- Count of RGCTX entries (≤ v24.1)
        { "imagesOffset", "UInt32" }, -- Offset to images table
        { "imagesSize", "Int32" }, -- Size of images table
        { "assembliesOffset", "UInt32" }, -- Offset to assemblies table
        { "assembliesSize", "Int32" }, -- Size of assemblies table
        { "metadataUsageListsOffset", "UInt32", version = {min = 19, max = 24.5} }, -- Offset to metadata usage lists (v19-v24.5)
        { "metadataUsageListsCount", "Int32", version = {min = 19, max = 24.5} }, -- Count of metadata usage lists (v19-v24.5)
        { "metadataUsagePairsOffset", "UInt32", version = {min = 19, max = 24.5} }, -- Offset to metadata usage pairs (v19-v24.5)
        { "metadataUsagePairsCount", "Int32", version = {min = 19, max = 24.5} }, -- Count of metadata usage pairs (v19-v24.5)
        { "fieldRefsOffset", "UInt32", version = {min = 19} }, -- Offset to field references (≥ v19)
        { "fieldRefsSize", "Int32", version = {min = 19} }, -- Size of field references (≥ v19)
        { "referencedAssembliesOffset", "UInt32", version = {min = 20} }, -- Offset to referenced assemblies (≥ v20)
        { "referencedAssembliesSize", "Int32", version = {min = 20} }, -- Size of referenced assemblies (≥ v20)
        { "attributesInfoOffset", "UInt32", version = {min = 21, max = 27.2} }, -- Offset to attributes info (v21-v27.2)
        { "attributesInfoCount", "Int32", version = {min = 21, max = 27.2} }, -- Count of attributes info (v21-v27.2)
        { "attributeTypesOffset", "UInt32", version = {min = 21, max = 27.2} }, -- Offset to attribute types (v21-v27.2)
        { "attributeTypesCount", "Int32", version = {min = 21, max = 27.2} }, -- Count of attribute types (v21-v27.2)
        { "attributeDataOffset", "UInt32", version = {min = 29} }, -- Offset to attribute data (≥ v29)
        { "attributeDataSize", "Int32", version = {min = 29} }, -- Size of attribute data (≥ v29)
        { "attributeDataRangeOffset", "UInt32", version = {min = 29} }, -- Offset to attribute data ranges (≥ v29)
        { "attributeDataRangeSize", "Int32", version = {min = 29} }, -- Size of attribute data ranges (≥ v29)
        { "unresolvedVirtualCallParameterTypesOffset", "UInt32", version = {min = 22} }, -- Offset to unresolved virtual call parameter types (≥ v22)
        { "unresolvedVirtualCallParameterTypesSize", "Int32", version = {min = 22} }, -- Size of unresolved virtual call parameter types (≥ v22)
        { "unresolvedVirtualCallParameterRangesOffset", "UInt32", version = {min = 22} }, -- Offset to unresolved virtual call parameter ranges (≥ v22)
        { "unresolvedVirtualCallParameterRangesSize", "Int32", version = {min = 22} }, -- Size of unresolved virtual call parameter ranges (≥ v22)
        { "windowsRuntimeTypeNamesOffset", "UInt32", version = {min = 23} }, -- Offset to Windows Runtime type names (≥ v23)
        { "windowsRuntimeTypeNamesSize", "Int32", version = {min = 23} }, -- Size of Windows Runtime type names (≥ v23)
        { "windowsRuntimeStringsOffset", "UInt32", version = {min = 27} }, -- Offset to Windows Runtime strings (≥ v27)
        { "windowsRuntimeStringsSize", "Int32", version = {min = 27} }, -- Size of Windows Runtime strings (≥ v27)
        { "exportedTypeDefinitionsOffset", "UInt32", version = {min = 24} }, -- Offset to exported type definitions (≥ v24)
        { "exportedTypeDefinitionsSize", "Int32", version = {min = 24} }, -- Size of exported type definitions (≥ v24)
    },

    ---@class VirtualInvokeData
    ---Virtual invocation data structure
    VirtualInvokeData = {
        { "methodPtr", "Pointer" }, -- Pointer to method
        { "method", "Pointer" } -- Method pointer
    },

    ---@class Il2CppType
    ---Il2Cpp type representation with bitfield decoding
    Il2CppType = {
        { "data", "Pointer" }, -- Type data pointer
        { "bits", "UInt32" }, -- Bitfield containing type attributes
        ---Initialize and decode type attributes from bitfield
        -- @return self Initialized type object
        Init = function(self)
            self.attrs = bit32.band(self.bits, 0xffff)
            self.type = bit32.rshift(bit32.band(self.bits, 0xff0000), 16)
            if Il2Cpp.Version >= 27.2 then
                self.num_mods = bit32.band(bit32.rshift(self.bits, 24), 0x1f)
                self.byref = bit32.band(bit32.rshift(self.bits, 29), 1)
                self.pinned = bit32.band(bit32.rshift(self.bits, 30), 1)
                self.valuetype = bit32.rshift(self.bits, 31)
            else
                self.num_mods = bit32.band(bit32.rshift(self.bits, 24), 0x3f)
                self.byref = bit32.band(bit32.rshift(self.bits, 30), 1)
                self.pinned = bit32.rshift(self.bits, 31)
            end
            
            return self
        end
    },
    
    ---@class Il2CppObject
    ---Base Il2Cpp object structure
    Il2CppObject = {
        { "klass", "Pointer" }, -- Class pointer
        { "monitor", "Pointer" } -- Monitor pointer for synchronization
    },

    ---@class Il2CppRGCTXData
    ---Runtime Generic Context Data structure
    Il2CppRGCTXData = {
        { "rgctxDataDummy", "Pointer" } -- Dummy RGCTX data pointer
    },

    ---@class Il2CppRuntimeInterfaceOffsetPair
    ---Runtime interface offset pair structure
    Il2CppRuntimeInterfaceOffsetPair = {
        { "interfaceType", "Pointer" }, -- Interface type pointer
        { "offset", "Int32" } -- Interface offset
    },

    ---@class FieldInfo
    ---Field information structure
    FieldInfo = {
        { "name", "Pointer" }, -- Field name pointer
        { "type", "Pointer" }, -- Field type pointer
        { "parent", "Pointer" }, -- Parent type pointer
        { "offset", "Int32" }, -- Field offset
        { "token", "UInt32" } -- Field token
    },

    ---@class Il2CppArrayBounds
    ---Array bounds information structure
    Il2CppArrayBounds = {
        { "length", "Int32", version = { max = 24.0 } }, -- Array length (≤ v24.0)
        { "length", "Size_t", version = { min = 24.1 } }, -- Array length (≥ v24.1)
        { "lower_bound", "Int32" } -- Array lower bound
    }
}

---@class Il2CppClass
---Il2Cpp class structure with version-specific fields
Structs.Il2CppClass = {
    { "image", "Pointer" }, -- Image pointer
    { "gc_desc", "Pointer" }, -- GC descriptor pointer
    { "name", "Pointer"}, -- Class name pointer
    { "namespaze", "Pointer" }, -- Class namespace pointer
    { "byval_arg", "Pointer", version = { max = 24.0 } }, -- ByVal argument pointer (≤ v24.0)
    { "byval_arg", Structs.Il2CppType, version = { min = 24.1 } }, -- ByVal argument type (≥ v24.1)
    { "this_arg", "Pointer", version = { max = 24.0 } }, -- This argument pointer (≤ v24.0)
    { "this_arg", Structs.Il2CppType, version = { min = 24.1 } }, -- This argument type (≥ v24.1)
    { "element_class", "Pointer" }, -- Element class pointer
    { "castClass", "Pointer" }, -- Cast class pointer
    { "declaringType", "Pointer" }, -- Declaring type pointer
    { "parent", "Pointer" }, -- Parent class pointer
    { "generic_class", "Pointer" }, -- Generic class pointer
    { "typeDefinition", "Pointer", version = { min = 24.1, max = 24.5 } }, -- Type definition pointer (v24.1-v24.5)
    { "typeMetadataHandle", "Pointer", version = { min = 27 } }, -- Type metadata handle (≥ v27)
    { "interopData", "Pointer" }, -- Interop data pointer
    { "klass", "Pointer", version = { min = 24.1 } }, -- Class pointer (≥ v24.1)
    
    { "fields", "Pointer" }, -- Fields pointer
    { "events", "Pointer" }, -- Events pointer
    { "properties", "Pointer" }, -- Properties pointer
    { "methods", "Pointer" }, -- Methods pointer
    { "nestedTypes", "Pointer" }, -- Nested types pointer
    { "implementedInterfaces", "Pointer" }, -- Implemented interfaces pointer
    { "interfaceOffsets", "Pointer" }, -- Interface offsets pointer
    { "static_fields", "Pointer" }, -- Static fields pointer
    { "rgctx_data", "Pointer" }, -- RGCTX data pointer
    
    { "typeHierarchy", "Pointer" }, -- Type hierarchy pointer
    
    { "unity_user_data", "Pointer", version = { min = 24.2 } }, -- Unity user data pointer (≥ v24.2)
    
    { "initializationExceptionGCHandle", "UInt32", version = { min = 24.1 } }, -- Initialization exception GC handle (≥ v24.1)
    
    { "cctor_started", "UInt32" }, -- Static constructor started flag
    { "cctor_finished", "UInt32" }, -- Static constructor finished flag
    { "cctor_thread", "UInt64", version = { max = 24.1 } }, -- Static constructor thread ID (≤ v24.1)
    { "cctor_thread", "Size_t", version = { min = 24.2 } }, -- Static constructor thread ID (≥ v24.2)
    
    { "genericContainerIndex", "Int32", version = { max = 24.5 } }, -- Generic container index (≤ v24.5)
    { "genericContainerHandle", "Pointer", version = { min = 27 } }, -- Generic container handle (≥ v27)
    { "customAttributeIndex", "Int32", version = { max = 24.0 } }, -- Custom attribute index (≤ v24.0)
    { "instance_size", "UInt32" }, -- Instance size
    { "stack_slot_size", "UInt32" , version = { min = 29.1 } }, -- Stack slot size (≥ v29.1)
    { "actualSize", "UInt32" }, -- Actual size
    { "element_size", "UInt32" }, -- Element size
    { "native_size", "Int32" }, -- Native size
    { "static_fields_size", "UInt32" }, -- Static fields size
    { "thread_static_fields_size", "UInt32" }, -- Thread static fields size
    { "thread_static_fields_offset", "Int32" }, -- Thread static fields offset
    { "flags", "UInt32" }, -- Class flags
    { "token", "UInt32" }, -- Class token
    
    { "method_count", "UInt16" }, -- Method count
    { "property_count", "UInt16" }, -- Property count
    { "field_count", "UInt16" }, -- Field count
    { "event_count", "UInt16" }, -- Event count
    { "nested_type_count", "UInt16" }, -- Nested type count
    { "vtable_count", "UInt16" }, -- VTable count
    { "interfaces_count", "UInt16" }, -- Interfaces count
    { "interface_offsets_count", "UInt16" }, -- Interface offsets count
    
    { "typeHierarchyDepth", "UInt8" }, -- Type hierarchy depth
    { "genericRecursionDepth", "UInt8" }, -- Generic recursion depth
    { "rank", "UInt8" }, -- Array rank
    { "minimumAlignment", "UInt8" }, -- Minimum alignment
    { "naturalAligment", "UInt8" }, -- Natural alignment
    { "packingSize", "UInt8" }, -- Packing size
    
    { "bitflags1", "UInt8" }, -- Bitflags 1
    { "bitflags2", "UInt8" } -- Bitflags 2
}

---@class MethodInfo
---Method information structure with version-specific fields
Structs.MethodInfo = {
    { "methodPointer", "Pointer" }, -- Method pointer
    { "virtualMethodPointer", "Pointer", version = { min = 29 } }, -- Virtual method pointer (≥ v29)
    { "invoker_method", "Pointer" }, -- Invoker method pointer
    { "name", "Pointer" }, -- Method name pointer
    { "klass", "Pointer", version = { min = 24.1 } }, -- Class pointer (≥ v24.1)
    { "declaring_type", "Pointer", version = { max = 24.0 } }, -- Declaring type pointer (≤ v24.0)
    { "return_type", "Pointer" }, -- Return type pointer
    { "parameters", "Pointer" }, -- Parameters pointer
    { "methodDefinition", "Pointer", version = { max = 24.5 } }, -- Method definition pointer (≤ v24.5)
    { "genericContainer", "Pointer", version = { max = 24.5 } }, -- Generic container pointer (≤ v24.5)
    { "methodMetadataHandle", "Pointer", version = { min = 27 } }, -- Method metadata handle (≥ v27)
    { "genericContainerHandle", "Pointer", version = { min = 27 } }, -- Generic container handle (≥ v27)
    { "customAttributeIndex", "Int32", version = { max = 24.0 } }, -- Custom attribute index (≤ v24.0)
    { "token", "UInt32" }, -- Method token
    { "flags", "UInt16" }, -- Method flags
    { "iflags", "UInt16" }, -- Method interface flags
    { "slot", "UInt16" }, -- Method slot
    { "parameters_count", "UInt8" }, -- Parameters count
    { "bitflags", "UInt8" } -- Method bitflags
}

---@class Il2CppGenericContext
---Generic context structure
Structs.Il2CppGenericContext = {
    { "class_inst", "Pointer"}, -- Class instance pointer
    { "method_inst", "Pointer"}, -- Method instance pointer
}

---@class Il2CppGenericClass
---Generic class structure with version-specific fields
Structs.Il2CppGenericClass = {
    { "typeDefinitionIndex", "Pointer", version = {max = 24.5}}, -- Type definition index (≤ v24.5)
    { "type", "Pointer", version = {min = 27}}, -- Type pointer (≥ v27)
    { "context", Structs.Il2CppGenericContext}, -- Generic context
    { "cached_class", "Pointer"}, -- Cached class pointer
}

---@class Il2CppGenericInst
---Generic instance structure
Structs.Il2CppGenericInst = {
    { "type_argc", "Pointer"}, -- Type argument count
    { "type_argv", "Pointer"}, -- Type argument values
}

---@class Il2CppArrayType
---Array type structure
Structs.Il2CppArrayType = {
    { "etype", "Pointer"}, -- Element type pointer
    { "rank", "Int8"}, -- Array rank
    { "numsizes", "Int8"}, -- Number of sizes
    { "numlobounds", "Int8"}, -- Number of lower bounds
    { "sizes", "Pointer"}, -- Sizes pointer
    { "lobounds", "Pointer"}, -- Lower bounds pointer
}

---@class Il2CppGenericParameter
---Generic parameter structure
Structs.Il2CppGenericParameter = {
    { "ownerIndex", "Int32" }, -- Owner index
    { "nameIndex", "UInt32" }, -- Name index
    { "constraintsStart", "Int16" }, -- Constraints start index
    { "constraintsCount", "Int16" }, -- Constraints count
    { "num", "UInt16" }, -- Parameter number
    { "flags", "UInt16" } -- Parameter flags
}

---@class Il2CppGenericContainer
---Generic container structure
Structs.Il2CppGenericContainer = {
    { "ownerIndex", "Int32" }, -- Owner index
    { "type_argc", "Int32" }, -- Type argument count
    { "is_method", "Int32" }, -- Is method flag
    { "genericParameterStart", "Int32" } -- Generic parameter start index
}

---@class Il2CppMethodDefinition
---Method definition structure with version-specific fields
Structs.Il2CppMethodDefinition = {
    { "nameIndex", "UInt32" }, -- Name index
    { "declaringType", "Int32" }, -- Declaring type index
    { "returnType", "Int32" }, -- Return type index
    { "returnParameterToken", "Int32", version = {min = 31} }, -- Return parameter token (≥ v31)
    { "parameterStart", "Int32" }, -- Parameter start index
    { "customAttributeIndex", "Int32", version = {max = 24} }, -- Custom attribute index (≤ v24)
    { "genericContainerIndex", "Int32" }, -- Generic container index
    { "methodIndex", "Int32", version = {max = 24.1} }, -- Method index (≤ v24.1)
    { "invokerIndex", "Int32", version = {max = 24.1} }, -- Invoker index (≤ v24.1)
    { "delegateWrapperIndex", "Int32", version = {max = 24.1} }, -- Delegate wrapper index (≤ v24.1)
    { "rgctxStartIndex", "Int32", version = {max = 24.1} }, -- RGCTX start index (≤ v24.1)
    { "rgctxCount", "Int32", version = {max = 24.1} }, -- RGCTX count (≤ v24.1)
    { "token", "UInt32" }, -- Method token
    { "flags", "UInt16" }, -- Method flags
    { "iflags", "UInt16" }, -- Method interface flags
    { "slot", "UInt16" }, -- Method slot
    { "parameterCount", "UInt16" } -- Parameter count
}

---@class Il2CppParameterDefinition
---Parameter definition structure with version-specific fields
Structs.Il2CppParameterDefinition = {
    { "nameIndex", "UInt32" }, -- Name index
    { "token", "UInt32" }, -- Parameter token
    { "customAttributeIndex", "Int32", version = {max = 24} }, -- Custom attribute index (≤ v24)
    { "typeIndex", "Int32" } -- Type index
}

return Structs