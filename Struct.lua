local Structs = {
    Il2CppGlobalMetadataHeader = {
        { "sanity", "UInt32"},
        { "version", "Int32"},
        { "stringLiteralOffset", "UInt32"},
        { "stringLiteralSize", "Int32"},
        { "stringLiteralDataOffset", "UInt32"},
        { "stringLiteralDataSize", "Int32"},
        { "stringOffset", "UInt32"},
        { "stringSize", "Int32"},
        { "eventsOffset", "UInt32"},
        { "eventsSize", "Int32"},
        { "propertiesOffset", "UInt32"},
        { "propertiesSize", "Int32"},
        { "methodsOffset", "UInt32"},
        { "methodsSize", "Int32"},
        { "parameterDefaultValuesOffset", "UInt32"},
        { "parameterDefaultValuesSize", "Int32"},
        { "fieldDefaultValuesOffset", "UInt32"},
        { "fieldDefaultValuesSize", "Int32"},
        { "fieldAndParameterDefaultValueDataOffset", "UInt32"},
        { "fieldAndParameterDefaultValueDataSize", "Int32"},
        { "fieldMarshaledSizesOffset", "UInt32"},
        { "fieldMarshaledSizesSize", "Int32"},
        { "parametersOffset", "UInt32"},
        { "parametersSize", "Int32"},
        { "fieldsOffset", "UInt32"},
        { "fieldsSize", "Int32"},
        { "genericParametersOffset", "UInt32"},
        { "genericParametersSize", "Int32"},
        { "genericParameterConstraintsOffset", "UInt32"},
        { "genericParameterConstraintsSize", "Int32"},
        { "genericContainersOffset", "UInt32"},
        { "genericContainersSize", "Int32"},
        { "nestedTypesOffset", "UInt32"},
        { "nestedTypesSize", "Int32"},
        { "interfacesOffset", "UInt32"},
        { "interfacesSize", "Int32"},
        { "vtableMethodsOffset", "UInt32"},
        { "vtableMethodsSize", "Int32"},
        { "interfaceOffsetsOffset", "UInt32"},
        { "interfaceOffsetsSize", "Int32"},
        { "typeDefinitionsOffset", "UInt32"},
        { "typeDefinitionsSize", "Int32"},
        { "rgctxEntriesOffset", "UInt32", version = {max = 24.1}},
        { "rgctxEntriesCount", "Int32", version = {max = 24.1}},
        { "imagesOffset", "UInt32"},
        { "imagesSize", "Int32"},
        { "assembliesOffset", "UInt32"},
        { "assembliesSize", "Int32"},
        { "metadataUsageListsOffset", "UInt32", version = {min = 19, max = 24.5}},
        { "metadataUsageListsCount", "Int32", version = {min = 19, max = 24.5}},
        { "metadataUsagePairsOffset", "UInt32", version = {min = 19, max = 24.5}},
        { "metadataUsagePairsCount", "Int32", version = {min = 19, max = 24.5}},
        { "fieldRefsOffset", "UInt32", version = {min = 19}},
        { "fieldRefsSize", "Int32", version = {min = 19}},
        { "referencedAssembliesOffset", "UInt32", version = {min = 20}},
        { "referencedAssembliesSize", "Int32", version = {min = 20}},
        { "attributesInfoOffset", "UInt32", version = {min = 21, max = 27.2}},
        { "attributesInfoCount", "Int32", version = {min = 21, max = 27.2}},
        { "attributeTypesOffset", "UInt32", version = {min = 21, max = 27.2}},
        { "attributeTypesCount", "Int32", version = {min = 21, max = 27.2}},
        { "attributeDataOffset", "UInt32", version = {min = 29}},
        { "attributeDataSize", "Int32", version = {min = 29}},
        { "attributeDataRangeOffset", "UInt32", version = {min = 29}},
        { "attributeDataRangeSize", "Int32", version = {min = 29}},
        { "unresolvedVirtualCallParameterTypesOffset", "UInt32", version = {min = 22}},
        { "unresolvedVirtualCallParameterTypesSize", "Int32", version = {min = 22}},
        { "unresolvedVirtualCallParameterRangesOffset", "UInt32", version = {min = 22}},
        { "unresolvedVirtualCallParameterRangesSize", "Int32", version = {min = 22}},
        { "windowsRuntimeTypeNamesOffset", "UInt32", version = {min = 23}},
        { "windowsRuntimeTypeNamesSize", "Int32", version = {min = 23}},
        { "windowsRuntimeStringsOffset", "UInt32", version = {min = 27}},
        { "windowsRuntimeStringsSize", "Int32", version = {min = 27}},
        { "exportedTypeDefinitionsOffset", "UInt32", version = {min = 24}},
        { "exportedTypeDefinitionsSize", "Int32", version = {min = 24}},
    },
    VirtualInvokeData = {
        { "methodPtr", "Pointer" },
        { "method", "Pointer" }
    },
    Il2CppType = {
        { "data", "Pointer" },
        { "bits", "UInt32" },
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
    
    Il2CppObject = {
        { "klass", "Pointer" },
        { "monitor", "Pointer" }
    },
    Il2CppRGCTXData = {
        { "rgctxDataDummy", "Pointer" }
    },
    Il2CppRuntimeInterfaceOffsetPair = {
        { "interfaceType", "Pointer" },
        { "offset", "Int32" }
    },
    FieldInfo = {
        { "name", "Pointer" },
        { "type", "Pointer" },
        { "parent", "Pointer" },
        { "offset", "Int32" },
        { "token", "UInt32" }
    },
    Il2CppArrayBounds = {
        { "length", "Int32", version = { max = 24.0 } },
        { "length", "Size_t", version = { min = 24.1 } },
        { "lower_bound", "Int32" }
    }
}

local Il2CppType = Structs.Il2CppType

Structs.Il2CppClass = {
    { "image", "Pointer" },
    { "gc_desc", "Pointer" },
    { "name", "Pointer"},
    { "namespaze", "Pointer" },
    { "byval_arg", "Pointer", version = { max = 24.0 } },
    { "byval_arg", Il2CppType, version = { min = 24.1 } },
    { "this_arg", "Pointer", version = { max = 24.0 } },
    { "this_arg", Il2CppType, version = { min = 24.1 } },
    { "element_class", "Pointer" },
    { "castClass", "Pointer" },
    { "declaringType", "Pointer" },
    { "parent", "Pointer" },
    { "generic_class", "Pointer" },
    { "typeDefinition", "Pointer", version = { min = 24.1, max = 24.5 } }, -- Chỉ có ở V241, V242
    { "typeMetadataHandle", "Pointer", version = { min = 27 } }, -- Chỉ có ở V27, V29
    { "interopData", "Pointer" },
    { "klass", "Pointer", version = { min = 24.1 } }, -- Chỉ có từ V241 trở lên
    
    { "fields", "Pointer" },
    { "events", "Pointer" },
    { "properties", "Pointer" },
    { "methods", "Pointer" },
    { "nestedTypes", "Pointer" },
    { "implementedInterfaces", "Pointer" },
    { "interfaceOffsets", "Pointer" },
    { "static_fields", "Pointer" },
    { "rgctx_data", "Pointer" },
    
    { "typeHierarchy", "Pointer" },
    
    { "unity_user_data", "Pointer", version = { min = 24.2 } }, -- Thêm vào V242, V27, V29
    
    { "initializationExceptionGCHandle", "UInt32", version = { min = 24.1 } }, -- Từ V241 trở lên
    
    { "cctor_started", "UInt32" },
    { "cctor_finished", "UInt32" },
    { "cctor_thread", "UInt64", version = { max = 24.1 } },
    { "cctor_thread", "Size_t", version = { min = 24.2 } },
    
    { "genericContainerIndex", "Int32", version = { max = 24.5 } }, -- Chỉ có ở V22, V240, V241, V242
    { "genericContainerHandle", "Pointer", version = { min = 27 } }, -- Chỉ có ở V27, V29
    { "customAttributeIndex", "Int32", version = { max = 24.0 } }, -- Chỉ có ở V22, V240
    { "instance_size", "UInt32" },
    { "stack_slot_size", "UInt32" , version = { min = 29.1 } },
    { "actualSize", "UInt32" },
    { "element_size", "UInt32" },
    { "native_size", "Int32" },
    { "static_fields_size", "UInt32" },
    { "thread_static_fields_size", "UInt32" },
    { "thread_static_fields_offset", "Int32" },
    { "flags", "UInt32" },
    { "token", "UInt32" },
    
    { "method_count", "UInt16" },
    { "property_count", "UInt16" },
    { "field_count", "UInt16" },
    { "event_count", "UInt16" },
    { "nested_type_count", "UInt16" },
    { "vtable_count", "UInt16" },
    { "interfaces_count", "UInt16" },
    { "interface_offsets_count", "UInt16" },
    
    { "typeHierarchyDepth", "UInt8" },
    { "genericRecursionDepth", "UInt8" },
    { "rank", "UInt8" },
    { "minimumAlignment", "UInt8" },
    { "naturalAligment", "UInt8" },
    { "packingSize", "UInt8" },
    
    { "bitflags1", "UInt8" },
    { "bitflags2", "UInt8" }
}

Structs.MethodInfo = {
    { "methodPointer", "Pointer" },
    { "virtualMethodPointer", "Pointer", version = { min = 29 } }, -- Chỉ có ở V29
    { "invoker_method", "Pointer" },
    { "name", "Pointer" },
    { "klass", "Pointer", version = { min = 24.1 } }, -- V241, V242, V27, V29
    { "declaring_type", "Pointer", version = { max = 24.0 } }, -- V22, V240
    { "return_type", "Pointer" },
    { "parameters", "Pointer" },
    { "methodDefinition", "Pointer", version = { max = 24.5 } }, -- V22, V240, V241, V242
    { "genericContainer", "Pointer", version = { max = 24.5 } }, -- V22, V240, V241, V242
    { "methodMetadataHandle", "Pointer", version = { min = 27 } }, -- V27, V29
    { "genericContainerHandle", "Pointer", version = { min = 27 } }, -- V27, V29
    { "customAttributeIndex", "Int32", version = { max = 24.0 } }, -- V22, V240
    { "token", "UInt32" },
    { "flags", "UInt16" },
    { "iflags", "UInt16" },
    { "slot", "UInt16" },
    { "parameters_count", "UInt8" },
    { "bitflags", "UInt8" }
}

-- Il2CppGenericContext
Structs.Il2CppGenericContext = {
    { "class_inst", "Pointer"},
    { "method_inst", "Pointer"},
}

-- Il2CppGenericClass
Structs.Il2CppGenericClass = {
    { "typeDefinitionIndex", "Pointer", version = {max = 24.5}},
    { "type", "Pointer", version = {min = 27}},
    { "context", Structs.Il2CppGenericContext},
    { "cached_class", "Pointer"},
}

-- Il2CppGenericInst
Structs.Il2CppGenericInst = {
    { "type_argc", "Pointer"},
    { "type_argv", "Pointer"},
}

-- Il2CppArrayType
Structs.Il2CppArrayType = {
    { "etype", "Pointer"},
    { "rank", "Int8"},
    { "numsizes", "Int8"},
    { "numlobounds", "Int8"},
    { "sizes", "Pointer"},
    { "lobounds", "Pointer"},
}

Structs.Il2CppGenericParameter = {
    { "ownerIndex", "Int32" },
    { "nameIndex", "UInt32" },
    { "constraintsStart", "Int16" },
    { "constraintsCount", "Int16" },
    { "num", "UInt16" },
    { "flags", "UInt16" }
}

Structs.Il2CppGenericContainer = {
    { "ownerIndex", "Int32" },
    { "type_argc", "Int32" },
    { "is_method", "Int32" },
    { "genericParameterStart", "Int32" }
}

Structs.Il2CppMethodDefinition = {
    { "nameIndex", "UInt32" },
    { "declaringType", "Int32" },
    { "returnType", "Int32" },
    { "returnParameterToken", "Int32", version = {min = 31} },
    { "parameterStart", "Int32" },
    { "customAttributeIndex", "Int32", version = {max = 24} },
    { "genericContainerIndex", "Int32" },
    { "methodIndex", "Int32", version = {max = 24.1} },
    { "invokerIndex", "Int32", version = {max = 24.1} },
    { "delegateWrapperIndex", "Int32", version = {max = 24.1} },
    { "rgctxStartIndex", "Int32", version = {max = 24.1} },
    { "rgctxCount", "Int32", version = {max = 24.1} },
    { "token", "UInt32" },
    { "flags", "UInt16" },
    { "iflags", "UInt16" },
    { "slot", "UInt16" },
    { "parameterCount", "UInt16" }
}

-- Il2CppParameterDefinition
Structs.Il2CppParameterDefinition = {
        { "nameIndex", "UInt32" },
        { "token", "UInt32" },
        { "customAttributeIndex", "Int32", version = {max = 24} },
        { "typeIndex", "Int32" }
}

return Structs