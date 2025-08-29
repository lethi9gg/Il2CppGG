local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("Il2CppGG", function(require, _LOADED, __bundle_register, __bundle_modules)
Il2Cpp = require "Il2Cpp"()

--setup
local metaStart, metaEnd = Il2Cpp.Universalsearcher:FindGlobalMetaData()
Il2Cpp.Meta.metaStart = metaStart
Il2Cpp.Meta.metaEnd = metaEnd
Il2Cpp.Meta.Header = Il2Cpp.Il2CppGlobalMetadataHeader(metaStart)
Il2Cpp.Meta.regionClass = Il2Cpp.Version >= 29.1 and gg.REGION_ANONYMOUS or gg.REGION_C_ALLOC
Il2Cpp.Universalsearcher.Il2CppMetadataRegistration()


for k, v in pairs(Il2Cpp.Meta.Header) do
    local _, __ = k:find("Offset")
    if __ == #k then
        Il2Cpp.Meta.Header[k] = metaStart + v
    end
end
Il2Cpp.typeSize = Il2Cpp.Meta.Header.typeDefinitionsSize / Il2Cpp.typeCount
        
Il2Cpp.Type.typeCount = Il2Cpp.gV(Il2Cpp.metaReg + ( 6 * Il2Cpp.pointSize), Il2Cpp.pointer)
Il2Cpp.Type.type = Il2Cpp.gV(Il2Cpp.metaReg + ( 7 * Il2Cpp.pointSize), Il2Cpp.pointer)

return Il2Cpp
end)__bundle_register("Il2Cpp", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Gameguardian
local x64 = gg.getTargetInfo().x64
local pointer = x64 and gg.TYPE_QWORD or gg.TYPE_DWORD
local MainType = pointer
local pointSize = x64 and 8 or 4
local Struct = require "Struct"
local Version = require "Version"
--local Universalsearcher = require "Universalsearcher"

Il2Cpp = {
    x64 = x64,
    pointer = pointer,
    MainType = MainType,
    pointSize = pointSize
}


Il2Cpp.type = {
    Boolean = { size = 1, flags = 1 },
    Byte    = { size = 1, flags = 1 },
    SByte   = { size = 1, flags = 1 },
    Int8    = { size = 1, flags = 1 },
    UInt8   = { size = 1, flags = 1 },
    Int16   = { size = 2, flags = 2 },
    UInt16  = { size = 2, flags = 2 },
    Int32   = { size = 4, flags = 4 },
    UInt32  = { size = 4, flags = 4 },
    Int64   = { size = 8, flags = 32 },
    UInt64  = { size = 8, flags = 32 },
    Float   = { size = 4, flags = 16 },
    Double  = { size = 8, flags = 64 },
    Pointer = { size = pointSize, flags = pointer },
    Size_t  = { size = pointSize, flags = pointer },
    Object = { size = (Il2Cpp.x64 and 0x10 or 0x8), flags = pointer}
}

function Il2Cpp.GetPtr(address)
    return Il2Cpp.FixValue(gg.getValues({{address = Il2Cpp.FixValue(address), flags = Il2Cpp.MainType}})[1].value)
end
function Il2Cpp.FixValue(val)
	return (x64 and (val & 0x00FFFFFFFFFFFFFF)) or (val & 0xFFFFFFFF);
end

function Il2Cpp.gV(address, flags)
	return (type(address) == "table" and gg.getValues(address)) or gg.getValues({{address=address,flags=flags or Il2Cpp.MainType}})[1].value;
end

function Il2Cpp.align(offset, align_to)
    return ((offset + align_to - 1) / align_to) * align_to
end

local Utf8ToStringCache = {}
Il2Cpp.Utf8ToString = function(Address, length)
    if Utf8ToStringCache[Address] then
        return Utf8ToStringCache[Address]
    end
    local chars, char = {}, {
        address = Address,
        flags = gg.TYPE_BYTE
    }
    if not length then
        while true do
            _char = string.char(gg.getValues({char})[1].value & 0xFF)
            chars[#chars + 1] = _char
            char.address = char.address + 0x1
            if string.find(_char, "[%z%s]") then break end
        end
        local Text = table.concat(chars, "", 1, #chars - 1)
        Utf8ToStringCache[Address] = Text
        return Text
    else
        for i = 1, length do
            local _char = gg.getValues({char})[1].value
            chars[i] = string.char(_char & 0xFF)
            char.address = char.address + 0x1
        end
        local Text = table.concat(chars)
        Utf8ToStringCache[Address] = Text
        return Text
    end
end

function Il2Cpp.classGG(fields, version)
    local offset = 0
    local klass = {}
    for _, field in ipairs(fields) do
        local includeField = true
        if field.version then
            local v = field.version
            if v.min and version < v.min then
                includeField = false
            end
            if v.max and version > v.max then
                includeField = false
            end
        end
        if includeField then
            local field = {
                name = field[1],
                type = field[2]
            }
            if type(field.type) == "table" and not field.type.size then
                field.type = Il2Cpp.classGG(field.type, version)
            end
            local tInfo = Il2Cpp.type[field.type]
            
            offset = Il2Cpp.align(offset, 
                math.min(tInfo and tInfo.size or field.type.size, Il2Cpp.pointSize)
            )
            if not tInfo then
                klass[field.name] = field.type
                field.type.address = offset
                offset = offset + field.type.size
            else
                klass[#klass+1] = {
                    address = offset,
                    flags = tInfo.flags,
                    name = field.name
                }
                offset = offset + tInfo.size
            end
        end
    end
    klass.size = offset
    return setmetatable(klass, {
        __call = function(self, addr, addList, prefix)
            local res, t, prefix = {}, {}, prefix or ''
            for i, v in pairs(self) do
                if type(v) == "table" then
                    if v.size then
                        t[i] = v(v.address + addr, addList, prefix .. i .. ".")
                    else
                        local address = v.address + addr
                        res[#res+1] = {address = address, flags = v.flags, name = prefix .. v.name}
                    end
                end
            end
            if addList then
                gg.addListItems(res)
            end
            for i, v in ipairs(gg.getValues(res)) do
                t[self[i].name] = v.flags == Il2Cpp.pointer and Il2Cpp.FixValue(v.value) or v.value
                if v.flags == Il2Cpp.pointer and (self[i].name == "name" or self[i].name == "namespaze") then
                    t[self[i].name] = Il2Cpp.Utf8ToString(t[self[i].name])
                end
            end
            return setmetatable(t, {
                __index = fields,
                __name = fields.name
            })
        end
    })
end

Il2Cpp.Il2CppFlags = {
    Method = {
        METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- METHOD_ATTRIBUTE_PRIVATE
            "internal", -- METHOD_ATTRIBUTE_FAM_AND_ASSEM
            "internal", -- METHOD_ATTRIBUTE_ASSEM
            "protected", -- METHOD_ATTRIBUTE_FAMILY
            "protected internal", -- METHOD_ATTRIBUTE_FAM_OR_ASSEM
            "public", -- METHOD_ATTRIBUTE_PUBLIC
        },
        METHOD_ATTRIBUTE_STATIC = 0x0010,
        METHOD_ATTRIBUTE_ABSTRACT = 0x0400,
    },
    Field = {
        FIELD_ATTRIBUTE_FIELD_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- FIELD_ATTRIBUTE_PRIVATE
            "internal", -- FIELD_ATTRIBUTE_FAM_AND_ASSEM
            "internal", -- FIELD_ATTRIBUTE_ASSEMBLY
            "protected", -- FIELD_ATTRIBUTE_FAMILY
            "protected internal", -- FIELD_ATTRIBUTE_FAM_OR_ASSEM
            "public", -- FIELD_ATTRIBUTE_PUBLIC
        },
        FIELD_ATTRIBUTE_STATIC = 0x0010,
        FIELD_ATTRIBUTE_LITERAL = 0x0040,
    }
}


-- Il2CppTypeEnum
Il2Cpp.Il2CppTypeEnum = {
    IL2CPP_TYPE_END = 0x00,
    IL2CPP_TYPE_VOID = 0x01,
    IL2CPP_TYPE_BOOLEAN = 0x02,
    IL2CPP_TYPE_CHAR = 0x03,
    IL2CPP_TYPE_I1 = 0x04,
    IL2CPP_TYPE_U1 = 0x05,
    IL2CPP_TYPE_I2 = 0x06,
    IL2CPP_TYPE_U2 = 0x07,
    IL2CPP_TYPE_I4 = 0x08,
    IL2CPP_TYPE_U4 = 0x09,
    IL2CPP_TYPE_I8 = 0x0a,
    IL2CPP_TYPE_U8 = 0x0b,
    IL2CPP_TYPE_R4 = 0x0c,
    IL2CPP_TYPE_R8 = 0x0d,
    IL2CPP_TYPE_STRING = 0x0e,
    IL2CPP_TYPE_PTR = 0x0f,
    IL2CPP_TYPE_BYREF = 0x10,
    IL2CPP_TYPE_VALUETYPE = 0x11,
    IL2CPP_TYPE_CLASS = 0x12,
    IL2CPP_TYPE_VAR = 0x13,
    IL2CPP_TYPE_ARRAY = 0x14,
    IL2CPP_TYPE_GENERICINST = 0x15,
    IL2CPP_TYPE_TYPEDBYREF = 0x16,
    IL2CPP_TYPE_I = 0x18,
    IL2CPP_TYPE_U = 0x19,
    IL2CPP_TYPE_FNPTR = 0x1b,
    IL2CPP_TYPE_OBJECT = 0x1c,
    IL2CPP_TYPE_SZARRAY = 0x1d,
    IL2CPP_TYPE_MVAR = 0x1e,
    IL2CPP_TYPE_CMOD_REQD = 0x1f,
    IL2CPP_TYPE_CMOD_OPT = 0x20,
    IL2CPP_TYPE_INTERNAL = 0x21,
    IL2CPP_TYPE_MODIFIER = 0x40,
    IL2CPP_TYPE_SENTINEL = 0x41,
    IL2CPP_TYPE_PINNED = 0x45,
    IL2CPP_TYPE_ENUM = 0x55,
    IL2CPP_TYPE_IL2CPP_TYPE_INDEX = 0xff,
}

return setmetatable(Struct, {
    __call = function(self)
        Il2Cpp.Version = Version()
        local default = Il2Cpp.Version
        
        if default == 22 then
          default = 22
        elseif default == 23 or default == 24 then
          default = 24.0
        elseif default == 24.1 then
          default = 24.1
        elseif default == 24.2 or default == 24.3 or default == 24.4 or default == 24.5 then
          default = 24.2
        elseif default == 27 or default == 27.1 or default == 27.2 then
          default = 27
        elseif default == 29 then
          default = 29
        elseif default == 31 or default == 29.1 then
            default = 29.1
        end
        
        -- Truyền version vào các struct để lọc field
        for k, v in pairs(self) do
            v.name = k
            Il2Cpp[k] = Il2Cpp.classGG(v, default)
        end
      
        
        local api = {
            Meta = require "Meta",
            Class = require "Class",
            Field = require "Field",
            Method = require "Method",
            Object = require "Object",
            Image = require "Image",
            Type = require "Type",
            Universalsearcher = require "Universalsearcher"
        }
        
        
        return setmetatable(api, {
            __index = Il2Cpp
        })
    end
})
end)__bundle_register("Struct", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)__bundle_register("Version", function(require, _LOADED, __bundle_register, __bundle_modules)
local osUV = 0x11

local function compareVersions(v1, v2)
    if v1.major ~= v2.major then
        return v1.major < v2.major and -1 or 1
    end
    if v1.minor ~= v2.minor then
        return v1.minor < v2.minor and -1 or 1
    end
    if v1.patch ~= v2.patch then
        return v1.patch < v2.patch and -1 or 1
    end
    return 0
end


---@class VersionEngine
local VersionEngine = {
    ConstSemVer = {
        ['2018_3'] = { major = 2018, minor = 3, patch = 0 },
        ['2019_4_21'] = { major = 2019, minor = 4, patch = 21 },
        ['2019_4_15'] = { major = 2019, minor = 4, patch = 15 },
        ['2019_3_7'] = { major = 2019, minor = 3, patch = 7 },
        ['2020_2_4'] = { major = 2020, minor = 2, patch = 4 },
        ['2020_2'] = { major = 2020, minor = 2, patch = 0 },
        ['2020_1_11'] = { major = 2020, minor = 1, patch = 11 },
        ['2021_2'] = { major = 2021, minor = 2, patch = 0 },
        ['2022_2'] = { major = 2022, minor = 2, patch = 0 },
        ['2022_3_41'] = { major = 2022, minor = 3, patch = 41 },
    },
    Year = {
        [2017] = function(self, unityVersion)
            return 24
        end,
        [2018] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2018_3']) >= 0 and 24.1 or 24
        end,
        [2019] = function(self, unityVersion)
            local version = 24.2
            if compareVersions(unityVersion, self.ConstSemVer['2019_4_21']) >= 0 then
                version = 24.5
            elseif compareVersions(unityVersion, self.ConstSemVer['2019_4_15']) >= 0 then
                version = 24.4
            elseif compareVersions(unityVersion, self.ConstSemVer['2019_3_7']) >= 0 then
                version = 24.3
            end
            return version
        end,
        [2020] = function(self, unityVersion)
            local version = 24.3
            if compareVersions(unityVersion, self.ConstSemVer['2020_2_4']) >= 0 then
                version = 27.1
            elseif compareVersions(unityVersion, self.ConstSemVer['2020_2']) >= 0 then
                version = 27
            elseif compareVersions(unityVersion, self.ConstSemVer['2020_1_11']) >= 0 then
                version = 24.4
            end
            return version
        end,
        [2021] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2021_2']) >= 0 and 29 or 27.2
        end,
        [2022] = function(self, unityVersion)
            local version = 29
            if compareVersions(unityVersion, self.ConstSemVer['2022_3_41']) >= 0 then
                version = 31
            elseif compareVersions(unityVersion, self.ConstSemVer['2022_2']) >= 0 then
                version = 29.1
            end
            return version
        end,
        [2023] = function(self, unityVersion)
            return 30
        end,
    },
    ReadUnityVersion = function()
        local version = {2018, 2019, 2020, 2021, 2022, 2023, 2024}
        local lm = gg.getRangesList('libmain.so')
        if #lm > 0 then
            local libMain = io.open(lm[1].name, "rb"):read("*a")
            for i, v in pairs(version) do
                if libMain:find(v) then
                    local versionName = v .. libMain:gmatch(v .. "(.-)_")()
                    local major, minor, patch = string.gmatch(versionName, "(%d+)%p(%d+)%p(%d+)")()
                    return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
                end
            end
        else
            gg.setRanges(gg.REGION_C_ALLOC)
            gg.clearResults()
            gg.searchNumber("Q 'X-Unity-Version:'", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
            if gg.getResultsCount() == 0 then
               gg.setRanges(gg.REGION_JAVA_HEAP)
               gg.searchNumber("Q 'SDK_UnityVersion'", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
               osUV = 0x20
            end
            local result = gg.getResultsCount() > 0 and gg.getResults(1)[1].address + osUV or 0
            if gg.getResultsCount() == 0 then
                gg.setRanges(gg.REGION_ANONYMOUS)
                gg.clearResults()
                gg.searchNumber("00h;32h;30h;0~~0;0~~0;2Eh;0~~0;2Eh::9", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
                result = gg.getResultsCount() > 0 and gg.getResults(3)[3].address or 0
                gg.clearResults()
            end
            gg.clearResults()
            local major, minor, patch = string.gmatch(Il2Cpp.Utf8ToString(result), "(%d+)%p(%d+)%p(%d+)")()
            return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
        end
    end,
    ChooseVersion = function(self, version, globalMetadataHeader)
        if not version then
            local unityVersion = self.ReadUnityVersion()
            if not unityVersion then
                gg.alert("Cannot determine Unity version", "", "")
                version = 31
            else
                version = self.Year[unityVersion.major] or 31
                if type(version) == 'function' then
                    version = version(self, unityVersion)
                end
            end
        end
        if version > 31 then
            gg.alert("Not support this il2cpp version", "", "")
            version = 31
        end
        return version
    end,
}

return setmetatable(VersionEngine, {
    __call = function(self)
        return self:ChooseVersion()
    end
})
end)__bundle_register("Meta", function(require, _LOADED, __bundle_register, __bundle_modules)
local Meta = {}
    

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
end)__bundle_register("Class", function(require, _LOADED, __bundle_register, __bundle_modules)
local Class = {}

-- Lấy tên của class
function Class.GetName(klass)
    local Name = klass.name--Il2Cpp.Utf8ToString(klass.name)
    local index = Name:find("`")
    if index then
        Name = Name:sub(1, index - 1)
        local index = klass.genericContainerIndex or klass.genericContainerHandle
        local genericContainer = Il2Cpp.Meta:GetGenericContainer(index)
        local genericParameterStart = genericContainer.genericParameterStart
        local type_argc = {}
        for i = 0, genericContainer.type_argc - 1 do
            local genericParameter = Il2Cpp.Meta:GetGenericParameter(genericParameterStart + i)
            type_argc[#type_argc+1] = Il2Cpp.Meta:GetStringFromIndex(genericParameter.nameIndex)
        end
        Name = Name .. "<" ..table.concat(type_argc, ", ") .. ">"
    end
    return Name--Il2Cpp.Utf8ToString(klass.name):gsub("`%d+", "")
end

-- Lấy namespace của class
function Class.GetNamespace(klass)
    return klass.namespaze--Il2Cpp.Utf8ToString(klass.namespaze)
end

-- Lấy image của class
function Class.GetImage(klass)
    return Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(klass.image))
end

-- Lấy parent class
function Class.GetParent(klass)
    return Class(klass.parent)
end

-- Lấy danh sách field của class
function Class.GetFields(klass)
    if type(klass.fields) == "table" then return klass.fields end
    local fields = {}
    local iter = 0
    local field
    while iter < klass.field_count do
        field = Il2Cpp.Field(klass.fields + iter * Il2Cpp.FieldInfo.size)
        field.type = field:GetType()
        fields[#fields + 1] = field
        iter = iter + 1
    end
    klass.fields = fields
    return fields
end

-- Tìm field theo tên
function Class.GetField(klass, name)
    for _, field in ipairs(klass:GetFields()) do
        if field:GetName() == name then
            return field
        end
    end
    return nil
end

-- Lấy danh sách method của class
function Class.GetMethods(klass)
    if type(klass.methods) == "table" then return klass.methods end
    local methods = {}
    local iter = 0
    local method
    while iter < klass.method_count do
        method = Il2Cpp.Method(Il2Cpp.gV(klass.methods + iter * Il2Cpp.pointSize, Il2Cpp.pointer))
        method.parameters = method:GetParam()
        method.return_type = method:GetReturnType()
        methods[#methods + 1] = method
        iter = iter + 1
    end
    klass.methods = methods
    return methods
end

-- Tìm method theo tên và số lượng tham số
function Class.GetMethod(klass, name, paramCount)
    for _, method in ipairs(klass:GetMethods()) do
        if method:GetName() == name and (not paramCount or method.parameters_count == paramCount) then
            return method
        end
    end
    return nil
end

-- Kiểm tra xem class có phải là generic
function Class.IsGeneric(klass)
    return klass.is_generic ~= 0
end

-- Kiểm tra xem class có phải là instance của generic
function Class.IsInflated(klass)
    return klass.generic_class ~= 0
end

function Class.IsNested(klass)
    return klass.nested_type_count ~= 0
end

-- Lấy kích thước instance của class
function Class.GetInstanceSize(klass)
    return klass.instance_size
end

function Class.GetInstance(klass)
    return Il2Cpp.Object:FindObjects(klass.address)
end

-- Lấy danh sách interface của class
function Class.GetInterfaces(klass)
    local interfaces = {}
    local iter = 0
    local interface
    while true do
        interface = Il2Cpp.gV(klass.implementedInterfaces + iter * Il2Cpp.pointSize, Il2Cpp.pointer)
        if interface == 0 then break end
        interfaces[#interfaces + 1] = Il2Cpp.Il2CppClass(interface)
        iter = iter + 1
    end
    return interfaces
end

function Class.GetIndex(klass)
    local index = klass.byval_arg.data
    if Il2Cpp.Meta.Header.typeDefinitionsOffset <= index and (Il2Cpp.Meta.Header.typeDefinitionsOffset + Il2Cpp.Meta.Header.typeDefinitionsSize) >= index then
        return (index - Il2Cpp.Meta.Header.typeDefinitionsOffset) / Il2Cpp.typeSize
    elseif index <= Il2Cpp.typeCount then
        return index
    end
end

function Class.GetPointersToIndex(index)
    if Il2Cpp.Meta.Header.typeDefinitionsOffset <= index and (Il2Cpp.Meta.Header.typeDefinitionsOffset + Il2Cpp.Meta.Header.typeDefinitionsSize) >= index then
        index = (index - Il2Cpp.Meta.Header.typeDefinitionsOffset) / Il2Cpp.typeSize
    elseif index > Il2Cpp.typeCount then
        return index
    end
    return Il2Cpp.GetPtr(Il2Cpp.typeDef + (index * Il2Cpp.pointSize))
end

Class.IsClassCache = {}
function Class.IsClassInfo(Address)
    if Class.IsClassCache[Address] then
        return Class.IsClassCache[Address]
    end
    local imageAddress = Il2Cpp.FixValue(gg.getValues(
        {
            {
                address = Il2Cpp.FixValue(Address),
                flags = Il2Cpp.pointer
            }
        }
    )[1].value)
    local imageStr = Il2Cpp.Utf8ToString(Il2Cpp.FixValue(gg.getValues(
        {
            {
                address = imageAddress,
                flags = Il2Cpp.pointer
            }
        }
    )[1].value))
    local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
    Class.IsClassCache[Address] = check and imageStr or nil
    return Class.IsClassCache[Address]
end

Class.NameOffset = (Il2Cpp.x64 and 0x10 or 0x8)

Class.__cache = {}
function Class:From(addr_name_index, add)
    if self.__cache[addr_name_index] then return self.__cache[addr_name_index] end
    
    local klass = {}
    if type(addr_name_index) == "string" then
        local res = Il2Cpp.Meta.GetPointersToString(addr_name_index)
        for i, v in ipairs(res) do
            local addr = v.address - Class.NameOffset
            local imageName = Class.IsClassInfo(addr)
            if imageName then
                local kls = Il2Cpp.Il2CppClass(addr, add)
                kls.address = addr
                kls.class_index = Class.GetIndex(kls)
                local res = setmetatable(kls, {
                    __index = Class,
                    __name = (kls.namespaze ~= "" and kls.namespaze .. "." or "") .. kls.name
                })
                klass[#klass+1] = res
            end
        end
    else
        local addr = Class.GetPointersToIndex(addr_name_index)
        local kls = Il2Cpp.Il2CppClass(addr, add)
        kls.address = addr
        kls.class_index = Class.GetIndex(kls)
        klass = setmetatable(kls, {
            __index = Class,
            __name = (kls.namespaze ~= "" and kls.namespaze .. "." or "") .. kls.name
        })
    end
    self.__cache[addr_name_index] = #klass == 1 and klass[1] or klass
    return self.__cache[addr_name_index]
end


return setmetatable(Class, {
    __call = Class.From
})
end)__bundle_register("Field", function(require, _LOADED, __bundle_register, __bundle_modules)
--local Il2Cpp = require("Il2Cpp")()

local Field = {}

-- Lấy tên của field
function Field.GetName(field)
    return field.name--Il2Cpp.Utf8ToString(field.name)
end

-- Lấy parent class của field
function Field.GetParent(field)
    return Il2Cpp.Class(field.parent)
end

-- Lấy offset của field
function Field.GetOffset(field)
    return field.offset
end

-- Lấy type của field
function Field.GetType(field)
    return Il2Cpp.Type(field.type)
end

-- Kiểm tra xem field có phải là instance field
function Field.IsInstance(field)
    local attrs = Field.GetType(field).attrs
    return bit32.band(attrs, 0x0010) == 0 -- FIELD_ATTRIBUTE_STATIC = 0x0010
end

-- Kiểm tra xem field có phải là static field
function Field.IsNormalStatic(field)
    if not bit32.band(field.type.attrs, 0x0010) then -- FIELD_ATTRIBUTE_STATIC
        return false
    end
    if field.offset == -1 then -- THREAD_STATIC_FIELD_OFFSET
        return false
    end
    if bit32.band(field.type.attrs, 0x0040) ~= 0 then -- FIELD_ATTRIBUTE_LITERAL
        return false
    end
    return true
end

-- Lấy giá trị của instance field
function Field.GetValue(field, obj)
    if not Field.IsInstance(field) then
        error("Field must be an instance field")
    end
    local address = obj + field.offset
    local tInfo = Il2Cpp.type[field.type.type]
    return Il2Cpp.gV(address, tInfo and tInfo.flags or Il2Cpp.MainType)
end

-- Đặt giá trị cho instance field
function Field.SetValue(field, obj, value)
    if not Field.IsInstance(field) then
        error("Field must be an instance field")
    end
    local address = obj + field.offset
    local tInfo = Il2Cpp.type[field.type.type]
    gg.setValues({{address = address, flags = tInfo and tInfo.flags or Il2Cpp.MainType, value = value}})
end

-- Lấy giá trị của static field
function Field.StaticGetValue(field)
    if not Field.IsNormalStatic(field) then
        error("Field must be a normal static field")
    end
    local address = Il2Cpp.gV(field.parent.static_fields) + field.offset
    local tInfo = Il2Cpp.type[field.type.type]
    return Il2Cpp.gV(address, tInfo and tInfo.flags or Il2Cpp.MainType)
end

-- Đặt giá trị cho static field
function Field.StaticSetValue(field, value)
    if not Field.IsNormalStatic(field) then
        error("Field must be a normal static field")
    end
    local address = Il2Cpp.gV(field.parent.static_fields) + field.offset
    local tInfo = Il2Cpp.type[field.type.type]
    gg.setValues({{address = address, flags = tInfo and tInfo.flags or Il2Cpp.MainType, value = value}})
end

function Field:From(addr_name)
    
    local field = {}
    if type(addr_name) == "string" then
        local res = Il2Cpp.Meta.GetPointersToString(addr_name)
        for i, v in ipairs(res) do
            local addr = Il2Cpp.GetPtr(v.address + (Il2Cpp.pointSize * 2))
            local imageName = Il2Cpp.Class.IsClassInfo(addr)
            if imageName then
                local kls = Il2Cpp.FieldInfo(v.address)
                kls.address = v.address
                local res = setmetatable(kls, {
                    __index = Field,
                    __name = kls.name
                })
                field[#field+1] = res
            end
        end
    else
        field = Il2Cpp.FieldInfo(addr_name)
        field.address = addr_name
        return setmetatable(field, {
            __index = Field,
            __name = field.name
        })
    end
    return #field == 1 and field[1] or field
end

return setmetatable(Field, {__call = Field.From})
end)__bundle_register("Method", function(require, _LOADED, __bundle_register, __bundle_modules)
local Method = {}

Method.parameterStart = Il2Cpp.Version >= 31 and 16 or 12
Method.parameterSize = Il2Cpp.Version <= 24 and 16 or 12

-- Lấy tên của method
function Method.GetName(method)
    return method.name
end

-- Lấy class khai báo method
function Method.GetDeclaringType(method)
    return Il2Cpp.Class(method.klass)
end

-- Lấy return type của method
function Method.GetReturnType(method)
    return Il2Cpp.Type(method.return_type)
end

-- Lấy số lượng tham số
function Method.GetParamCount(method)
    return method.parameters_count
end


-- Lấy tên tham số
function Method.GetParam(method)
    if type(method.parameters) == "table" then
        return method.parameters
    end
    local methodDef = method.methodMetadataHandle or method.methodDefinition
    local paramStart = Il2Cpp.Meta.Header.parametersOffset + Il2Cpp.gV(methodDef + Method.parameterStart, 4) * Method.parameterSize
    method.parameters = {}
    for index = 0, Method.GetParamCount(method) - 1 do
        paramStart = paramStart + (index * Method.parameterSize)
        local token = paramStart + 4
        local paramType = paramStart + Method.parameterSize - 4
        local paramInfo = Il2Cpp.gV({{address = paramStart, flags = 4}, {address = paramType, flags = 4},{address = token, flags = 4}})
        method.parameters[index + 1] = {
            type = Il2Cpp.Type(paramInfo[2].value),
            name = Il2Cpp.Meta:GetStringFromIndex(paramInfo[1].value),
            token = paramInfo[3].value
        }
    end
    return method.parameters
end

-- Kiểm tra xem method có phải là instance method
function Method.IsInstance(method)
    return bit32.band(method.flags, 0x0010) == 0 -- METHOD_ATTRIBUTE_STATIC = 0x0010
end

function Method.IsAbstract(method)
    return (method.flags & Il2Cpp.Il2CppFlags.Method.METHOD_ATTRIBUTE_ABSTRACT) ~= 0
end

function Method.IsStatic(method)
    return (method.flags & Il2Cpp.Il2CppFlags.Method.METHOD_ATTRIBUTE_STATIC) ~= 0
end

function Method.GetAccess(method)
    return Il2Cpp.Il2CppFlags.Method.Access[method.flags & Il2Cpp.Il2CppFlags.Method.METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK] or ""
end

-- Kiểm tra xem method có phải là generic
function Method.IsGeneric(method)
    return method.is_generic ~= 0
end

-- Kiểm tra xem method có phải là instance của generic
function Method.IsGenericInstance(method)
    return method.is_inflated ~= 0 and method.is_generic == 0
end

function Method:From(addrMethodInfo, addList)
    local method = Il2Cpp.MethodInfo(addrMethodInfo, addList)
    method.address = addrMethodInfo
    return setmetatable(method, {
        __index = Method,
        __name = method.name
    })
end

return setmetatable(Method, {__call = Method.From})
end)__bundle_register("Object", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("Androidinfo")

---@class ObjectApi
local ObjectApi = {

    regionObject = gg.REGION_ANONYMOUS,

    ---@param self ObjectApi
    ---@param Objects table
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


    ---@param self ObjectApi
    ---@param ClassAddress string
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

    
    ---@param self ObjectApi
    ---@param ClassesInfo ClassInfo[]
    Find = function(self, ClassesInfo)
        local Objects = {}
        for j = 1, #ClassesInfo do
            local FindResult = self:FindObjects(ClassesInfo[j].ClassAddress)
            table.move(FindResult, 1, #FindResult, #Objects + 1, Objects)
        end
        return Objects
    end,


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

return ObjectApi
end)__bundle_register("Androidinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
local info = gg.getTargetInfo()
local AndroidInfo = {
    platform = info.x64,
    sdk = info.targetSdkVersion,
    pkg = gg.getTargetPackage(),
    path = gg.EXT_CACHE_DIR .. "/" .. info.packageName .. "-" .. info.versionCode .. "-" .. (info.x64 and "64" or "32")
}

return AndroidInfo
end)__bundle_register("Image", function(require, _LOADED, __bundle_register, __bundle_modules)
local Image = {}

function Image:From(name)
    if not self.__cache then
        if not Il2Cpp.imageSize then
            Il2Cpp.Universalsearcher.Il2CppMetadataRegistration()
        end
        local typeStart = 0
        local addr = Il2Cpp.imageDef
        local typeCountOffset = gg.getValues({{address = addr + (Il2Cpp.pointSize * 3), flags = 4}})[1].value == 0 and (Il2Cpp.pointSize * 3) + 4 or Il2Cpp.pointSize * 3
        self.__cache = {}
        for i = 1, Il2Cpp.imageCount do
            local imageInfo = gg.getValues({
                {address = addr, flags = Il2Cpp.MainType},
                {address = addr + typeCountOffset, flags = 4},
                {address = addr + (Il2Cpp.pointSize * 2), flags = Il2Cpp.MainType}
            })
            local name = Il2Cpp.Utf8ToString(Il2Cpp.FixValue(imageInfo[1].value))
            self.__cache[i] = setmetatable({
                index = i,
                typeCount = imageInfo[2].value,
                typeStart = typeStart,
                name = name,
                assembly = imageInfo[3].value
            }, {__index = Image})
            typeStart = typeStart + imageInfo[2].value
            addr = addr + Il2Cpp.imageSize
        end
    end
    if name then
        for i, v in ipairs(self.__cache) do
            if v.name == name or v.name == (name .. ".dll") then
                return v
            end
        end
    else
        return self.__cache
    end
end

-- Lấy tên image, kiểu "nickname" của image
function Image.GetName(image)
    return image.name
end

-- Lấy tên file của image, như "địa chỉ nhà" của image
function Image.GetFileName(image)
    return image.name
end

-- Lấy assembly của image, tìm "gia đình" của image
function Image.GetAssembly(image)
    return image.assembly
end

-- Lấy entry point, kiểu "cửa chính" của image
function Image.GetEntryPoint(image)
    local method = Il2Cpp.il2cpp_image_get_entry_point(image)
    return method ~= 0 and Il2Cpp.MethodInfo(method) or nil
end

-- Lấy corlib image, image "ông trùm" của hệ thống
function Image.GetCorlib()
    return Il2Cpp.il2cpp_get_corlib()
end

-- Lấy số lượng type trong image, đếm "dân số" class
function Image.GetNumTypes(image)
    return image.typeCount
end

-- Lấy class theo index, lấy "cư dân" thứ i
function Image.GetType(image, index)
    if index >= image.typeCount then
        return nil
    end
    local handle = Il2Cpp.GetPtr(Il2Cpp.typeDef + (image.typeStart + index) * Il2Cpp.pointSize)
    return handle ~= 0 and Il2Cpp.Class(handle) or nil
end

-- Lấy danh sách type, gom hết "dân chúng" trong image
function Image.GetTypes(image, exportedOnly)
    local types = {}
    for i = 0, image.typeCount - 1 do
        local type = Image.GetType(image, i)
        if type and type.name ~= "<Module>" then
            if not exportedOnly or Image.IsExported(type) then
                types[#types + 1] = type
            end
        end
    end
    return types
end

-- Check type có phải exported, kiểu "public figure" không
function Image.IsExported(type)
    local flags = Class.GetFlags(type)
    local visibility = bit32.band(flags, 0x0007) -- TYPE_ATTRIBUTE_VISIBILITY_MASK
    if visibility == 0x0001 then -- TYPE_ATTRIBUTE_PUBLIC
        return true
    elseif visibility == 0x0004 then -- TYPE_ATTRIBUTE_NESTED_PUBLIC
        local parent = Class.GetParent(type)
        return parent and Image.IsExported(parent)
    end
    return false
end

-- Tìm class theo namespace và name, như "search Google" trong image
function Image.Class(image, namespace, name)
    local key = (namespace or "") .. "." .. name
    if not image.nameToClassHashTable or image.typeCount > image.countHashTable then
        image.nameToClassHashTable = image.nameToClassHashTable or {}
        image.countHashTable = image.countHashTable or 0
        Image.InitNameToClassHashTable(image, key)
    end
    
    return Il2Cpp.Class(image.nameToClassHashTable[key])
end

-- Tìm class theo thông tin parse, kiểu "search pro" với nested type
function Image.FromTypeNameParseInfo(image, parseInfo, ignoreCase)
    local ns = parseInfo.ns or ""
    local name = parseInfo.name or ""
    local klass = Image.Class(image, ns, name)
    if not klass then
        -- Tìm trong exported types nếu không thấy
        for i = 0, image.exportedTypeCount - 1 do
            local handle = Il2Cpp.il2cpp_assembly_get_exported_type_handle(image, i)
            if handle ~= 0 then
                local typeNs, typeName = Il2Cpp.il2cpp_type_get_namespace_and_name(handle)
                if (ignoreCase and string.lower(typeNs) == string.lower(ns) and string.lower(typeName) == string.lower(name)) or
                   (typeNs == ns and typeName == name) then
                    klass = Il2Cpp.Il2CppClass(handle)
                    break
                end
            end
        end
    end
    if not klass then
        return nil
    end

    local nested = parseInfo.nested or {}
    for _, nestedName in ipairs(nested) do
        local found = false
        for _, nestedType in ipairs(Class.GetNestedTypes(klass)) do
            local typeName = nestedType.name
            if (ignoreCase and string.lower(typeName) == string.lower(nestedName)) or typeName == nestedName then
                klass = nestedType
                found = true
                break
            end
        end
        if not found then
            return nil
        end
    end
    return klass
end

-- Lấy executing image, tìm image đang "chạy show"
function Image.GetExecutingImage()
    local stack = Il2Cpp.il2cpp_stack_frames()
    for _, frame in ipairs(stack) do
        local klass = frame.method.klass
        if klass.image and not Image.IsSystemType(klass) and not Image.IsSystemReflectionAssembly(klass) then
            return klass.image
        end
    end
    return Image.GetCorlib()
end

-- Lấy calling image, tìm image "gọi điện" cho executing image
function Image.GetCallingImage()
    local stack = Il2Cpp.il2cpp_stack_frames()
    local foundFirst = false
    for _, frame in ipairs(stack) do
        local klass = frame.method.klass
        if klass.image and not Image.IsSystemType(klass) and not Image.IsSystemReflectionAssembly(klass) then
            if foundFirst then
                return klass.image
            end
            foundFirst = true
        end
    end
    return Image.GetCorlib()
end

-- Check class có phải System.Type, kiểu "meta class"
function Image.IsSystemType(klass)
    return klass.namespaze == "System" and klass.name == "Type"
end

-- Check class có phải System.Reflection.Assembly
function Image.IsSystemReflectionAssembly(klass)
    return klass.namespaze == "System.Reflection" and klass.name == "Assembly"
end

-- Khởi tạo nameToClassHashTable, chuẩn bị "danh bạ" class
function Image.InitNameToClassHashTable(image, key)
    if image.nameToClassHashTable[key] then
        return
    end
    for i = image.countHashTable, image.typeCount - 1 do
        local index = Il2Cpp.typeDef + (image.typeStart + i) * Il2Cpp.pointSize
        local klass = Il2Cpp.GetPtr(index)
        if klass ~= 0 then
            local ns, name = Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(klass + (Il2Cpp.pointSize * 3))), Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(klass + (Il2Cpp.pointSize * 2))):gsub("<.*", "")
            image.nameToClassHashTable[ns .. "." .. name] = klass
            image.countHashTable = i + 1
            if image.nameToClassHashTable[key] then
                --print((index - Il2Cpp.typeDef) / Il2Cpp.pointSize)
                return klass
            end
            --Image.AddNestedTypesToHashTable(image, klass, ns, name)
        end
    end
    --[[
    for i = 0, image.exportedTypeCount - 1 do
        local handle = Il2Cpp.il2cpp_assembly_get_exported_type_handle(image, i)
        if handle ~= 0 and not Il2Cpp.il2cpp_type_is_nested(handle) then
            local ns, name = Il2Cpp.il2cpp_type_get_namespace_and_name(handle)
            image.nameToClassHashTable[ns .. "." .. name] = handle
            Image.AddNestedTypesToHashTable(image, handle, ns, name)
        end
    end
    ]]
end

-- Thêm nested types vào hash table, như "đăng ký hộ khẩu" cho nested class
function Image.AddNestedTypesToHashTable(image, handle, namespaze, parentName)
    local iter = 0
    while true do
        local nested = Il2Cpp.il2cpp_get_nested_types(handle, iter)
        if nested == 0 then break end
        local ns, name = Il2Cpp.il2cpp_type_get_namespace_and_name(nested)
        local fullName = parentName .. "/" .. name
        image.nameToClassHashTable[ns .. "." .. fullName] = nested
        Image.AddNestedTypesToHashTable(image, nested, ns, fullName)
        iter = iter + 1
    end
end

-- Khởi tạo nested types, chuẩn bị "gia phả" cho nested class
function Image.InitNestedTypes(image)
    for i = 0, image.typeCount - 1 do
        local handle = Il2Cpp.il2cpp_assembly_get_type_handle(image, i)
        if handle ~= 0 and not Il2Cpp.il2cpp_type_is_nested(handle) then
            Image.AddNestedTypesToHashTable(image, handle, Il2Cpp.il2cpp_type_get_namespace_and_name(handle))
        end
    end
    for i = 0, image.exportedTypeCount - 1 do
        local handle = Il2Cpp.il2cpp_assembly_get_exported_type_handle(image, i)
        if handle ~= 0 and not Il2Cpp.il2cpp_type_is_nested(handle) then
            Image.AddNestedTypesToHashTable(image, handle, Il2Cpp.il2cpp_type_get_namespace_and_name(handle))
        end
    end
end

-- Lấy cached resource data, tìm "kho báu" của image
function Image.GetCachedResourceData(image, name)
    -- Giả định Il2Cpp.il2cpp_get_cached_resource_data trả về dữ liệu
    local data = Il2Cpp.il2cpp_get_cached_resource_data(image, name)
    return data or nil
end

-- Xóa cached resource data, dọn dẹp "kho báu"
function Image.ClearCachedResourceData()
    Il2Cpp.il2cpp_clear_cached_resource_data()
end

return setmetatable(Image, {__call = Image.From})
end)__bundle_register("Type", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Type.lua
local Type = {}

-- Đọc Il2CppType từ bộ nhớ
function Type:From(address)
    if Type.typeCount >= address then -- nếu là index
        address = Il2Cpp.gV(Type.type + (address * Il2Cpp.pointSize), Il2Cpp.pointer)
    end
    local typeStruct = Il2Cpp.Il2CppType(address)
    typeStruct:Init()
    return setmetatable(typeStruct, {
        __index = Type,
        __tostring = Type.ToString,
        __name = "Type"
    })
end

-- Kiểm tra kiểu có phải là reference type
function Type.IsReference(typeStruct)
    local t = typeStruct.type
    return t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_STRING or
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_SZARRAY or
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_CLASS or
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_OBJECT or
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_ARRAY
end

-- Kiểm tra kiểu có phải là struct (value type nhưng không phải enum)
function Type.IsStruct(typeStruct)
    if typeStruct.byref == 1 then return false end
    
    local t = typeStruct.type
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_TYPEDBYREF then
        return true
    end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VALUETYPE then
        return not Type.IsEnum(typeStruct)
    end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_GENERICINST then
        local genericType = Type:From(typeStruct.data)
        return genericType.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VALUETYPE and 
               not Type.IsEnum(genericType)
    end
    
    return false
end

-- Kiểm tra kiểu có phải là enum
function Type.IsEnum(typeStruct)
    local t = typeStruct.type
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VALUETYPE then
        local typeDef = Il2Cpp.Meta.GetTypeDefinition(typeStruct.data)
        return typeDef.bitfield:And(0x1 << (Il2Cpp.Meta.kBitIsEnum - 1)) ~= 0
    end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_GENERICINST then
        return Type.IsEnum(Type:From(typeStruct.data))
    end
    
    return false
end

-- Kiểm tra kiểu có phải là value type
function Type.IsValueType(typeStruct)
    return typeStruct.valuetype == 1
end

-- Kiểm tra kiểu có phải là array
function Type.IsArray(typeStruct)
    local t = typeStruct.type
    return t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_SZARRAY or 
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_ARRAY
end

-- Kiểm tra kiểu có phải là pointer
function Type.IsPointer(typeStruct)
    return typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_PTR
end

-- Lấy Il2CppClass tương ứng với kiểu
function Type.GetClass(typeStruct, add)
    if typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_CLASS or
       typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VALUETYPE then
        return Il2Cpp.Class(typeStruct.data, add)
    end
    return nil
end

-- Lấy tên kiểu đơn giản (cho các kiểu cơ bản)
function Type.GetSimpleName(typeStruct)
    local basicTypes = {
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VOID] = "Void",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_BOOLEAN] = "Boolean",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_CHAR] = "Char",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_I1] = "SByte",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_U1] = "Byte",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_I2] = "Int16",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_U2] = "UInt16",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_I4] = "Int32",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_U4] = "UInt32",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_I8] = "Int64",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_U8] = "UInt64",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_R4] = "Single",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_R8] = "Double",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_STRING] = "String",
        [Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_OBJECT] = "Object",
    }
    
    return basicTypes[typeStruct.type] or "Unknown"
end

-- Lấy tên đầy đủ của kiểu
function Type.GetName(typeStruct, addNamespaze)
    local t = typeStruct.type
    local name = Type.GetSimpleName(typeStruct)
    
    if name ~= "Unknown" then
        return name
    end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_PTR then
        local elementType = Type:From(typeStruct.data)
        return Type.GetName(elementType) .. "*"
    end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_SZARRAY then
        local elementType = Type:From(typeStruct.data)
        return Type.GetName(elementType) .. "[]"
    end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_ARRAY then
        local arrayType = Il2Cpp.Il2CppArrayType(typeStruct.data)
        local elementType = Type:From(arrayType.etype)
        return Type.GetName(elementType) .. "[" .. string.rep(",", arrayType.rank - 1) .. "]"
    end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_CLASS or 
       t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VALUETYPE then
        local klass = Type.GetClass(typeStruct)
        if klass then
            local namespaze = addNamespaze and klass:GetNamespace()
            local ns = namespaze and namespaze ~= '' and (namespaze .. ".") or ""
            return ns .. klass:GetName()
        end
    end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VAR or 
       t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_MVAR then
       local param = Il2Cpp.Il2CppGenericParameter(typeStruct.data)
       local name = Il2Cpp.Meta:GetStringFromIndex(param.nameIndex)
       return name--Il2Cpp.Meta:GetStringFromIndex(param.nameIndex)
   end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_GENERICINST then
        -- Đọc generic class
        local genericClass = Il2Cpp.Il2CppGenericClass(typeStruct.data)
        if genericClass then
            local typeDef = Il2Cpp.Class(genericClass.type and Il2Cpp.GetPtr(genericClass.type) or genericClass.typeDefinitionIndex)--genericClass.type and Il2Cpp.Type(genericClass.type) or Il2Cpp.Class(genericClass.typeDefinitionIndex);--Il2Cpp.Class(genericClass.type and Il2Cpp.GetPtr(genericClass.type) or genericClass.typeDefinitionIndex)
            local baseName = typeDef.name:gsub("`.*", "")
            
            -- Đọc generic context
            local context = genericClass.context
            if context then
                local classInst = context.class_inst
                if classInst then
                    local genericInst = Il2Cpp.Il2CppGenericInst(classInst)
                    if genericInst then
                        local argc = genericInst.type_argc
                        local argv = {}
                        for i=0, argc-1 do
                            local argType = Type:From(Il2Cpp.GetPtr(genericInst.type_argv + (i * Il2Cpp.pointSize)))
                            table.insert(argv, tostring(argType))
                        end
                        return baseName .. "<" .. table.concat(argv, ", ") .. ">"
                    end
                end
            end
            return baseName
        end
    end
    error(typeStruct)
    return "Unknown"
end

-- Lấy token của type (dùng trong metadata)
function Type.GetToken(typeStruct)
    if Type.IsGenericInstance(typeStruct) then
        local genericClass = Il2Cpp.Il2CppGenericClass(typeStruct.data)
        local typeDef = genericClass.typeDefinitionIndex or genericClass.type
        local typeDefStruct = Il2Cpp.Meta.GetTypeDefinition(typeDef)
        return typeDefStruct.token
    end
    local klass = Type.GetClass(typeStruct)
    return klass.token
end

-- Kiểm tra có phải generic instance (IL2CPP_TYPE_GENERICINST)
function Type.IsGenericInstance(typeStruct)
    return typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_GENERICINST
end

-- Kiểm tra có phải generic parameter (IL2CPP_TYPE_VAR hoặc IL2CPP_TYPE_MVAR)
function Type.IsGenericParameter(typeStruct)
    return typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VAR or 
           typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_MVAR
end

-- Lấy generic parameter handle (chỉ dành cho generic parameter)
function Type.GetGenericParameterHandle(typeStruct)
    if not Type.IsGenericParameter(typeStruct) then
        return nil
    end
    return Il2Cpp.Meta.GetGenericParameterFromType(typeStruct)
end

-- Lấy thông tin generic parameter
function Type.GetGenericParameterInfo(typeStruct)
    local handle = Type.GetGenericParameterHandle(typeStruct)
    if not handle then
        return nil
    end
    return Il2Cpp.Meta.GetGenericParameterInfo(handle)
end

-- Lấy declaring type của generic parameter
function Type.GetDeclaringType(typeStruct)
    if typeStruct.byref ~= 0 then
        return nil
    end
    if typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VAR or 
       typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_MVAR then
        return Il2Cpp.Meta.GetParameterDeclaringType(Type.GetGenericParameterHandle(typeStruct))
    end
    local klass = Type.GetClass(typeStruct)
    return klass.declaringType
end

-- Lấy declaring method (chỉ dành cho generic parameter MVAR)
function Type.GetDeclaringMethod(typeStruct)
    if typeStruct.byref ~= 0 then
        return nil
    end
    if typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_MVAR then
        return Il2Cpp.Meta.GetParameterDeclaringMethod(Type.GetGenericParameterHandle(typeStruct))
    end
    return nil
end

-- Lấy generic type definition (chỉ dành cho generic instance)
function Type.GetGenericTypeDefinition(typeStruct)
    if not Type.IsGenericInstance(typeStruct) then
        return typeStruct
    end
    local genericClass = Il2Cpp.Il2CppGenericClass(typeStruct.data)
    return Type:From(genericClass.type)
end

-- So sánh hai kiểu có bằng nhau không
function Type.AreEqual(type1, type2)
    -- Đơn giản: so sánh địa chỉ, hoặc so sánh từng trường
    if type1.address == type2.address then
        return true
    end
    -- TODO: Triển khai so sánh chi tiết nếu cần
    return false
end

-- Lấy kích thước của kiểu trong bộ nhớ
function Type.GetSize(typeStruct)
    if Type.IsValueType(typeStruct) then
        local klass = Type.GetClass(typeStruct)
        return klass.instance_size
    end
    
    -- Kiểu tham chiếu có kích thước bằng kích thước con trỏ
    return Il2Cpp.pointSize
end

-- Lấy thông tin mảng nếu là kiểu mảng
function Type.GetArrayInfo(typeStruct)
    if not Type.IsArray(typeStruct) then
        return nil
    end
    
    if typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_SZARRAY then
        return {
            elementType = Type:From(typeStruct.data),
            rank = 1,
            isSzArray = true
        }
    end
    
    if typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_ARRAY then
        local arrayType = Il2Cpp.Il2CppArrayType(typeStruct.data)
        return {
            elementType = Type:From(arrayType.etype),
            rank = arrayType.rank,
            sizes = arrayType.sizes,
            lobounds = arrayType.lobounds,
            isSzArray = false
        }
    end
    
    return nil
end

-- Chuyển đổi Il2CppType thành chuỗi mô tả
function Type.ToString(typeStruct)
    local name = Type.GetName(typeStruct)
    local flags = {}
    
    if typeStruct.byref == 1 then
        table.insert(flags, "byref")
    end
    
    if typeStruct.pinned == 1 then
        table.insert(flags, "pinned")
    end
    
    if #flags > 0 then
        return string.format("%s (%s)", name, table.concat(flags, ", "))
    end
    
    return name
end

return setmetatable(Type, {
    __call = Type.From
})
end)__bundle_register("Universalsearcher", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require "Androidinfo"
local MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD
local pointSize = AndroidInfo.platform and 8 or 4
    
---@class Searcher
local Searcher = {
    searchWord = ":EnsureCapacity",

    ---@param self Searcher
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
        return type(globalMetadata) == "table" and globalMetadata[1].start, globalMetadata[#globalMetadata]['end'] or 0, 0
    end,

    ---@param self Searcher
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

    Il2CppMetadataRegistration = function()
        local function isImage(addr)
            local imageStr = Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(addr))
            local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
            return check and imageStr
        end
        Il2Cpp.classPointer = Il2Cpp.Version < 27 and (AndroidInfo.platform and 24 or 12) or (AndroidInfo.platform and 40 or 20);
        Il2Cpp.imagePointer = Il2Cpp.Version < 27 and (AndroidInfo.platform and 72 or 36) or (AndroidInfo.platform and 24 or 12);
        local gmt = gg.getRangesList("global-metadata.dat");
	    local gmt = ((gmt and #gmt > 0) and gmt[1].start) or Il2Cpp.Meta.metaStart
	    gg.clearResults();
	    gg.setRanges(16 | 32);
	    gg.searchNumber(gmt, Il2Cpp.MainType, nil, nil, Il2Cpp.il2cppStart, -1, 1);
	    if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(gmt | 0xB400000000000000), Il2Cpp.MainType, nil, nil, Il2Cpp.il2cppStart, -1, 1);
        end
        if gg.getResultsCount() > 0 then
            local t = gg.getResults(1)
            gg.clearResults();
            local address = t[1].address
            while true do
                local Range = gg.getValuesRange({{address = Il2Cpp.GetPtr(address), flags = MainType}})[1]
                address = address - pointSize
                if Range == 'Cd' then break end
            end
            local g_code = Il2Cpp.GetPtr(address)
            local g_meta = Il2Cpp.GetPtr(address + pointSize)
            local classCount = gg.getValues({{address = g_meta + pointSize * 12, flags = MainType}})[1].value
            if classCount == 0 or classCount < 0 then
                error("classCount: "..classCount)
            end
            
            local imgAddr = t[1].address + Il2Cpp.imagePointer
            local results = gg.getValues({
                {address=(Il2Cpp.GetPtr(imgAddr) + 16),flags=Il2Cpp.MainType},
                {address=Il2Cpp.GetPtr(t[1].address + Il2Cpp.classPointer),flags=Il2Cpp.MainType}});
            if Il2Cpp.GetPtr(results[1].value) == 0 then
                results[1] = gg.getValues({{address=(Il2Cpp.GetPtr(imgAddr) + 16 + 8),flags=Il2Cpp.MainType}})[1];
            end
            local addr = results[1].address
            if isImage(Il2Cpp.GetPtr(addr)) then
                Il2Cpp.imageDef = Il2Cpp.GetPtr(addr)
                Il2Cpp.imageCount = Il2Cpp.GetPtr(imgAddr - Il2Cpp.pointSize)
            else  
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
            for i = 1, 100 do
                local addr = Il2Cpp.imageDef + (i * Il2Cpp.pointSize)
                if isImage(addr) then
                    Il2Cpp.imageSize = addr - Il2Cpp.imageDef
                    break
                end
            end
            Il2Cpp.typeDef = results[2].address
        end
        
        
        Il2Cpp.typeCount = classCount or 0
        
        Il2Cpp.metaReg = g_meta or 0
        Il2Cpp.il2cppReg = g_code or 0
        
        return {
            metadataRegistration = g_meta,
            il2cppRegistration = g_code,
            classCount = classCount,
        }
    end
}

return Searcher

end)
return __bundle_require("Il2CppGG")