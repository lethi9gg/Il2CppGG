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
---@module Il2Cpp
---Main initialization module for Il2Cpp framework
Il2Cpp = require "Il2Cpp"()

-- Setup global metadata and Il2Cpp registration
local metaStart, metaEnd = Il2Cpp.Universalsearcher:FindGlobalMetaData()
Il2Cpp.Meta.metaStart = metaStart
Il2Cpp.Meta.metaEnd = metaEnd
Il2Cpp.Meta.Header = Il2Cpp.Il2CppGlobalMetadataHeader(metaStart)
Il2Cpp.Meta.regionClass = Il2Cpp.Version >= 29.1 and gg.REGION_ANONYMOUS or gg.REGION_C_ALLOC

local il2cppStart, il2cppEnd = Il2Cpp.Universalsearcher:FindIl2cpp()
Il2Cpp.il2cppStart = il2cppStart
Il2Cpp.il2cppEnd = il2cppEnd

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
end)__bundle_register("Il2Cpp", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Il2Cpp
---Main Il2Cpp module providing core functionality and type definitions
local AndroidInfo = require "Androidinfo"
local x64 = AndroidInfo.platform
local pointer = x64 and gg.TYPE_QWORD or gg.TYPE_DWORD
local MainType = pointer
local pointSize = x64 and 8 or 4
local Struct = require "Struct"
local Version = require "Version"

---@class Il2CppTable
---Main Il2Cpp table containing platform information and core functionality
Il2Cpp = {
    x64 = x64,
    pointer = pointer,
    MainType = MainType,
    pointSize = pointSize,
    methodSpecGenericMethodPointers = {},
    methodDefinitionMethodSpecs = {},
    genericMethodPointers = {}
}

---@class TypeInfo
---Table containing type information for various data types
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

---Get pointer value from memory address
-- @param address number Memory address to read from
-- @return number Pointer value
function Il2Cpp.GetPtr(address)
    return Il2Cpp.FixValue(gg.getValues({{address = Il2Cpp.FixValue(address), flags = Il2Cpp.MainType}})[1].value)
end

---Fix value by masking platform-specific bits
-- @param val number Value to fix
-- @return number Fixed value
function Il2Cpp.FixValue(val)
	return (x64 and (val & 0x00FFFFFFFFFFFFFF)) or (val & 0xFFFFFFFF);
end

---Get value from memory address with optional flags
-- @param address number|table Memory address or table of addresses
-- @param flags number|nil Memory flags (optional)
-- @return any Value or table of values
function Il2Cpp.gV(address, flags)
	return (type(address) == "table" and gg.getValues(address)) or gg.getValues({{address=address,flags=flags or Il2Cpp.MainType}})[1].value;
end

---Align offset to specified alignment
-- @param offset number Offset to align
-- @param align_to number Alignment value
-- @return number Aligned offset
function Il2Cpp.align(offset, align_to)
    return ((offset + align_to - 1) / align_to) * align_to
end

---Cache for UTF-8 string conversion
local Utf8ToStringCache = {}

---Convert UTF-8 encoded memory to string
-- @param Address number Memory address of UTF-8 string
-- @param length number|nil Length of string (optional, if not provided reads until null terminator)
-- @return string Decoded string
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

function Il2Cpp.classArray(addr, count, class)
    local results = {}
    if Il2Cpp.type[class] then
        class = Il2Cpp.type[class]
    end
    for i = 0, count - 1 do
        table.insert(results, class.flags and {address = addr + (i * class.size), flags = class.flags} or class(addr + (i * class.size)))
    end
    if class.flags then
        for i, v in ipairs(gg.getValues(results)) do
            results[i] = v.value
        end
    end
    return results
end
            

---Create a class structure for GameGuardian with proper field alignment
-- @param fields table Table of field definitions
-- @param version number Il2Cpp version
-- @return table Class structure with proper alignment
function Il2Cpp.classGG(fields, version)
    local offset = 0
    local klass = {}
    for _, field in ipairs(fields) do
        local includeField = true
        if field.version then
            --[[
            local v = field.version
            if v.min and version < v.min then
                includeField = false
            end
            if v.max and version > v.max then
                includeField = false
            end
            ]]
            local v = field.version
            if (v and #v == 0) and (version < (v.min or 0) or version > (v.max or 99)) then
                includeField = false
            elseif v and #v > 0 then
                for _, attr in ipairs(v) do
                    if (version < (attr.min or 0) or version > (attr.max or 99)) then
                        includeField = false
                    end
                end
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

---@class Il2CppFlags
---Il2Cpp flags and attributes for methods and fields
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

---@class Il2CppTypeEnum
---Enumeration of Il2Cpp type values
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
    IL2Cpp_TYPE_BYREF = 0x10,
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

-- Il2CppConstants
Il2Cpp.Il2CppConstants = {
    -- Field Attributes
    FIELD_ATTRIBUTE_FIELD_ACCESS_MASK = 0x0007,
    FIELD_ATTRIBUTE_COMPILER_CONTROLLED = 0x0000,
    FIELD_ATTRIBUTE_PRIVATE = 0x0001,
    FIELD_ATTRIBUTE_FAM_AND_ASSEM = 0x0002,
    FIELD_ATTRIBUTE_ASSEMBLY = 0x0003,
    FIELD_ATTRIBUTE_FAMILY = 0x0004,
    FIELD_ATTRIBUTE_FAM_OR_ASSEM = 0x0005,
    FIELD_ATTRIBUTE_PUBLIC = 0x0006,
    FIELD_ATTRIBUTE_STATIC = 0x0010,
    FIELD_ATTRIBUTE_INIT_ONLY = 0x0020,
    FIELD_ATTRIBUTE_LITERAL = 0x0040,

    -- Method Attributes
    METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK = 0x0007,
    METHOD_ATTRIBUTE_COMPILER_CONTROLLED = 0x0000,
    METHOD_ATTRIBUTE_PRIVATE = 0x0001,
    METHOD_ATTRIBUTE_FAM_AND_ASSEM = 0x0002,
    METHOD_ATTRIBUTE_ASSEM = 0x0003,
    METHOD_ATTRIBUTE_FAMILY = 0x0004,
    METHOD_ATTRIBUTE_FAM_OR_ASSEM = 0x0005,
    METHOD_ATTRIBUTE_PUBLIC = 0x0006,
    METHOD_ATTRIBUTE_STATIC = 0x0010,
    METHOD_ATTRIBUTE_FINAL = 0x0020,
    METHOD_ATTRIBUTE_VIRTUAL = 0x0040,
    METHOD_ATTRIBUTE_VTABLE_LAYOUT_MASK = 0x0100,
    METHOD_ATTRIBUTE_REUSE_SLOT = 0x0000,
    METHOD_ATTRIBUTE_NEW_SLOT = 0x0100,
    METHOD_ATTRIBUTE_ABSTRACT = 0x0400,
    METHOD_ATTRIBUTE_PINVOKE_IMPL = 0x2000,

    -- Type Attributes
    TYPE_ATTRIBUTE_VISIBILITY_MASK = 0x00000007,
    TYPE_ATTRIBUTE_NOT_PUBLIC = 0x00000000,
    TYPE_ATTRIBUTE_PUBLIC = 0x00000001,
    TYPE_ATTRIBUTE_NESTED_PUBLIC = 0x00000002,
    TYPE_ATTRIBUTE_NESTED_PRIVATE = 0x00000003,
    TYPE_ATTRIBUTE_NESTED_FAMILY = 0x00000004,
    TYPE_ATTRIBUTE_NESTED_ASSEMBLY = 0x00000005,
    TYPE_ATTRIBUTE_NESTED_FAM_AND_ASSEM = 0x00000006,
    TYPE_ATTRIBUTE_NESTED_FAM_OR_ASSEM = 0x00000007,
    TYPE_ATTRIBUTE_INTERFACE = 0x00000020,
    TYPE_ATTRIBUTE_ABSTRACT = 0x00000080,
    TYPE_ATTRIBUTE_SEALED = 0x00000100,
    TYPE_ATTRIBUTE_SERIALIZABLE = 0x00002000,

    -- Param Flags
    PARAM_ATTRIBUTE_IN = 0x0001,
    PARAM_ATTRIBUTE_OUT = 0x0002,
    PARAM_ATTRIBUTE_OPTIONAL = 0x0010,
}

Il2Cpp.methodModifiers = {}
function Il2Cpp:GetModifiers(methodDef)
    if self.methodModifiers[methodDef] then
        return self.methodModifiers[methodDef]
    end
    local str = ""
    local access = bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK)
    if access == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_PRIVATE then
        str = str .. "private "
    elseif access == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_PUBLIC then
        str = str .. "public "
    elseif access == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_FAMILY then
        str = str .. "protected "
    elseif access == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_ASSEM or access == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_FAM_AND_ASSEM then
        str = str .. "internal "
    elseif access == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_FAM_OR_ASSEM then
        str = str .. "protected internal "
    end
    if bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_STATIC) ~= 0 then
        str = str .. "static "
    end
    if bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_ABSTRACT) ~= 0 then
        str = str .. "abstract "
        if bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_VTABLE_LAYOUT_MASK) == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_REUSE_SLOT then
            str = str .. "override "
        end
    elseif bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_FINAL) ~= 0 then
        if bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_VTABLE_LAYOUT_MASK) == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_REUSE_SLOT then
            str = str .. "sealed override "
        end
    elseif bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_VIRTUAL) ~= 0 then
        if bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_VTABLE_LAYOUT_MASK) == Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_NEW_SLOT then
            str = str .. "virtual "
        else
            str = str .. "override "
        end
    end
    if bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_PINVOKE_IMPL) ~= 0 then
        str = str .. "extern "
    end
    self.methodModifiers[methodDef] = str
    return str
end


return setmetatable(Struct, {
    ---Metatable call handler for Struct
    -- Initializes Il2Cpp structures based on version
    -- @return table Il2Cpp API with all modules loaded
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
        
        -- Pass version to structs to filter fields
        for k, v in pairs(self) do
            v.name = k
            Il2Cpp[k] = Il2Cpp.classGG(v, default)
        end
      
        -- Load all Il2Cpp API modules
        local api = {
            Meta = require "Meta",
            Class = require "Class",
            Field = require "Field",
            Method = require "Method",
            Param = require "Param",
            Object = require "Object",
            Image = require "Image",
            Type = require "Type",
            Dump = require "Dump",
            Universalsearcher = require "Universalsearcher"
        }
        
        return setmetatable(api, {
            __index = Il2Cpp
        })
    end
})
end)__bundle_register("Androidinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class AndroidInfo
---Table containing Android target information for the current application
local info = gg.getTargetInfo()

---@class AndroidInfoTable
---Android target information structure containing platform architecture, SDK version, package details and cache path
local AndroidInfo = {
    ---@field platform boolean Whether the target platform is 64-bit (true) or 32-bit (false)
    platform = info.x64,
    
    ---@field sdk number Target SDK version of the application
    sdk = info.targetSdkVersion,
    
    ---@field pkg string Package name of the target application
    pkg = gg.getTargetPackage(),
    
    ---@field path string Cache path for the application with format: 
    -- "/cache/packageName-versionCode-architecture(64/32)"
    path = gg.EXT_CACHE_DIR .. "/" .. info.packageName .. "-" .. info.versionCode .. "-" .. (info.x64 and "64" or "32")
}

return AndroidInfo
end)__bundle_register("Struct", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Structs
---Table containing all Il2Cpp structure definitions for different versions
local Structs = {
    ---@class Il2CppGlobalMetadataHeader
    ---Global metadata header structure containing offsets and sizes of various metadata sections
    Il2CppGlobalMetadataHeader = {
        { "sanity", "UInt32"}, -- Sanity check value
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
    
    Il2CppMetadataRegistration = {
        { "genericClassesCount", "Pointer" },
        { "genericClasses", "Pointer" },
        { "genericInstsCount", "Pointer" },
        { "genericInsts", "Pointer" },
        { "genericMethodTableCount", "Pointer" },
        { "genericMethodTable", "Pointer" },
        { "typesCount", "Pointer" },
        { "types", "Pointer" },
        { "methodSpecsCount", "Pointer" },
        { "methodSpecs", "Pointer" },
        { "methodReferencesCount", "Pointer", version = { max = 16 } },
        { "methodReferences", "Pointer", version = { max = 16 } },
        { "fieldOffsetsCount", "Pointer" },
        { "fieldOffsets", "Pointer" },
        { "typeDefinitionsSizesCount", "Pointer" },
        { "typeDefinitionsSizes", "Pointer" },
        { "metadataUsagesCount", "Pointer", version = { min = 19 } },
        { "metadataUsages", "Pointer", version = { min = 19 } }
    },
    
    -- Il2CppCodeRegistration
    Il2CppCodeRegistration = {
        { "methodPointersCount", "Pointer", version = { max = 24.1} },
        { "methodPointers", "Pointer", version = { max = 24.1} },
        { "delegateWrappersFromNativeToManagedCount", "Pointer", version = { max = 21}},
        { "delegateWrappersFromNativeToManaged", "Pointer", version = { max = 21} },
        { "reversePInvokeWrapperCount", "Pointer", version = { min = 22}},
        { "reversePInvokeWrappers", "Pointer", version = { min = 22}},
        { "delegateWrappersFromManagedToNativeCount", "Pointer", version = { max = 22} },
        { "delegateWrappersFromManagedToNative", "Pointer", version = { max = 22} },
        { "marshalingFunctionsCount", "Pointer", version = { max = 22} },
        { "marshalingFunctions", "Pointer", version = { max = 22} },
        { "ccwMarshalingFunctionsCount", "Pointer", version = { min = 21, max = 22} },
        { "ccwMarshalingFunctions", "Pointer", version = { min = 21, max = 22} },
        { "genericMethodPointersCount", "Pointer" },
        { "genericMethodPointers", "Pointer" },
        { "genericAdjustorThunks", "Pointer", version = {{ min = 24.5, max = 24.5}, { min = 27.1}} },
        { "invokerPointersCount", "Pointer" },
        { "invokerPointers", "Pointer" },
        { "customAttributeCount", "Pointer", version = { max = 24.5}},
        { "customAttributeGenerators", "Pointer", version = { max = 24.5}},
        { "guidCount", "Pointer", version = { min = 21, max = 22}},
        { "guids", "Pointer", version = { min = 21, max = 22}},
        { "unresolvedVirtualCallCount", "Pointer", version = { min = 22}},
        { "unresolvedVirtualCallPointers", "Pointer", version = { min = 22}},
        { "unresolvedInstanceCallPointers", "Pointer", version = { min = 29.1} },
        { "unresolvedStaticCallPointers", "Pointer", version = { min = 29.1} },
        { "interopDataCount", "Pointer", version = { min = 23} },
        { "interopData", "Pointer", version = { min = 23}},
        { "windowsRuntimeFactoryCount", "Pointer", version = { min = 24.3}},
        { "windowsRuntimeFactoryTable", "Pointer", version = { min = 24.3} },
        { "codeGenModulesCount", "Pointer", version = { min = 24.2 }},
        { "codeGenModules", "Pointer", version = { min = 24.2 } }
    },
    
    -- Il2CppTypeDefinition
    Il2CppTypeDefinition = {
        { "nameIndex", "UInt32" },
        { "namespaceIndex", "UInt32" },
        { "customAttributeIndex", "Int32", version = { max = 24}},
        { "byvalTypeIndex", "Int32" },
        { "byrefTypeIndex", "Int32", version = { max = 24.5} },
        { "declaringTypeIndex", "Int32" },
        { "parentIndex", "Int32" },
        { "elementTypeIndex", "Int32" },
        { "rgctxStartIndex", "Int32", version = { max = 24.1} },
        { "rgctxCount", "Int32", version = { max = 24.1} },
        { "genericContainerIndex", "Int32" },
        { "delegateWrapperFromManagedToNativeIndex", "Int32", version = { max = 22} },
        { "marshalingFunctionsIndex", "Int32", version = { max = 22 }},
        { "ccwFunctionIndex", "Int32", version = { min = 21, max = 22} },
        { "guidIndex", "Int32", version = { min = 21, max = 22} },
        { "flags", "UInt32" },
        { "fieldStart", "Int32" },
        { "methodStart", "Int32" },
        { "eventStart", "Int32" },
        { "propertyStart", "Int32" },
        { "nestedTypesStart", "Int32" },
        { "interfacesStart", "Int32" },
        { "vtableStart", "Int32" },
        { "interfaceOffsetsStart", "Int32" },
        { "method_count", "UInt16" },
        { "property_count", "UInt16" },
        { "field_count", "UInt16" },
        { "event_count", "UInt16" },
        { "nested_type_count", "UInt16" },
        { "vtable_count", "UInt16" },
        { "interfaces_count", "UInt16" },
        { "interface_offsets_count", "UInt16" },
        { "bitfield", "UInt32" },
        { "token", "UInt32", version = { min = 19 } },
        
        IsValueType = function(this) return bit32.band(this.bitfield, 0x1) == 1 end,
        IsEnum = function(this) return bit32.band(bit32.rshift(this.bitfield, 1), 0x1) == 1 end
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

Structs.PropertyInfo = {
    { "parent", "Pointer" },
    { "name", "Pointer" },
    { "get", "Pointer" },
    { "set", "Pointer" },
    { "attrs", "UInt32" },
    { "token", "UInt32" }
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


-- Il2CppGenericMethodIndices
Structs.Il2CppGenericMethodIndices = {
    { "methodIndex", "Int32" },
    { "invokerIndex", "Int32" },
    { "adjustorThunk", "Int32", version = {{ min = 24.5, max = 24.5 }, { min = 27.1 }} }
}

-- Il2CppGenericMethodFunctionsDefinitions
Structs.Il2CppGenericMethodFunctionsDefinitions = {
    { "genericMethodIndex", "Int32" },
    { "indices", Structs.Il2CppGenericMethodIndices }
}


-- Il2CppMethodSpec
Structs.Il2CppMethodSpec = {
    { "methodDefinitionIndex", "Int32" },
    { "classIndexIndex", "Int32" },
    { "methodIndexIndex", "Int32" }
}


Structs.Il2CppParameterDefaultValue = {
    { "parameterIndex", "Int32" },
    { "typeIndex", "Int32" },
    { "dataIndex", "Int32" }
}

Structs.Il2CppFieldDefaultValue = {
    { "fieldIndex", "Int32" },
    { "typeIndex", "Int32" },
    { "dataIndex", "Int32" }
    
}


return Structs
end)__bundle_register("Version", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class VersionEngine
---Module for detecting and handling Unity engine version compatibility with Il2Cpp

---Compare two semantic version numbers
-- @param v1 table First version table with major, minor, patch fields
-- @param v2 table Second version table with major, minor, patch fields
-- @return number -1 if v1 < v2, 1 if v1 > v2, 0 if equal
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

-- OS-specific Unity version string offset
local osUV = 0x11

local VersionEngine = {
    ---@class ConstSemVer
    ---Table of constant semantic version numbers for known Unity versions
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
    
    ---@class YearMapping
    ---Mapping of Unity release years to Il2Cpp versions with conditional logic
    Year = {
        ---Get Il2Cpp version for Unity 2017
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (24)
        [2017] = function(self, unityVersion)
            return 24
        end,
        ---Get Il2Cpp version for Unity 2018
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (24 or 24.1)
        [2018] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2018_3']) >= 0 and 24.1 or 24
        end,
        ---Get Il2Cpp version for Unity 2019
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (24.2 to 24.5)
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
        ---Get Il2Cpp version for Unity 2020
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (24.3 to 27.1)
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
        ---Get Il2Cpp version for Unity 2021
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (27.2 or 29)
        [2021] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2021_2']) >= 0 and 29 or 27.2
        end,
        ---Get Il2Cpp version for Unity 2022
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (29, 29.1 or 31)
        [2022] = function(self, unityVersion)
            local version = 29
            if compareVersions(unityVersion, self.ConstSemVer['2022_3_41']) >= 0 then
                version = 31
            elseif compareVersions(unityVersion, self.ConstSemVer['2022_2']) >= 0 then
                version = 29.1
            end
            return version
        end,
        ---Get Il2Cpp version for Unity 2023
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (30)
        [2023] = function(self, unityVersion)
            return 30
        end,
    },
    
    ---Read Unity version from memory or libmain.so
    -- Attempts to detect the Unity version using multiple methods
    -- @return table|nil Table with major, minor, patch version numbers or nil if not found
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
    
    ---Choose appropriate Il2Cpp version based on Unity version
    -- @param version number|nil Optional forced version number
    -- @param globalMetadataHeader table|nil Optional global metadata header
    -- @return number Selected Il2Cpp version
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
    ---Metatable call handler for VersionEngine
    -- Allows VersionEngine to be called as a function
    -- @return number Selected Il2Cpp version
    __call = function(self)
        return self:ChooseVersion()
    end
})
end)__bundle_register("Meta", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)__bundle_register("Class", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Class
---Module for handling Il2Cpp class operations and metadata
local Class = {}

---Get the name of a class, handling generic classes with type parameters
-- @param klass table The class object
-- @return string The class name with generic parameters if applicable
function Class.GetName(klass)
    local Name = klass.name
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
    return Name
end

---Get the namespace of a class
-- @param klass table The class object
-- @return string The class namespace
function Class.GetNamespace(klass)
    return klass.namespaze
end

---Get the image (assembly) of a class
-- @param klass table The class object
-- @return string The image name containing the class
function Class.GetImage(klass)
    return Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(klass.image))
end

---Get the parent class of a class
-- @param klass table The class object
-- @return table Parent class object
function Class.GetParent(klass)
    return Class(klass.parent)
end

function Class.IsValueType(klass)
    return klass:GetParent():GetName() == "ValueType"
end

function Class.IsEnum(klass)
    return klass:GetParent():GetName() == "Enum"
end

---Get all fields of a class
-- @param klass table The class object
-- @return table Array of field objects
function Class.GetFields(klass)
    if type(klass.fields) == "table" then return klass.fields end
    local fields = {}
    local iter = 0
    local field
    while iter < klass.field_count do
        field = Il2Cpp.Field(klass.fields + iter * Il2Cpp.FieldInfo.size)
        --field.type = field:GetType()
        fields[#fields + 1] = field
        iter = iter + 1
    end
    klass.fields = fields
    return fields
end

---Find a field by name in a class
-- @param klass table The class object
-- @param name string The field name to search for
-- @return table|nil Field object if found, nil otherwise
function Class.GetField(klass, name)
    for _, field in ipairs(klass:GetFields()) do
        if field:GetName() == name then
            return field
        end
    end
    return nil
end

---Get all methods of a class
-- @param klass table The class object
-- @return table Array of method objects
function Class.GetMethods(klass)
    if type(klass.methods) == "table" then return klass.methods end
    local methods = {}
    local iter = 0
    local method
    while iter < klass.method_count do
        method = Il2Cpp.Method(Il2Cpp.GetPtr(klass.methods + iter * Il2Cpp.pointSize))
        --method.parameters = method:GetParam()
        --method.return_type = method:GetReturnType()
        methods[#methods + 1] = method
        iter = iter + 1
    end
    klass.methods = methods
    return methods
end

---Find a method by name and parameter count in a class
-- @param klass table The class object
-- @param name string The method name to search for
-- @param paramCount number|nil The number of parameters (optional)
-- @return table|nil Method object if found, nil otherwise
function Class.GetMethod(klass, name, paramCount)
    for _, method in ipairs(klass:GetMethods()) do
        if method:GetName() == name and (not paramCount or method.parameters_count == paramCount) then
            return method
        end
    end
    return nil
end

---Check if a class is generic
-- @param klass table The class object
-- @return boolean True if the class is generic
function Class.IsGeneric(klass)
    return klass.is_generic ~= 0
end

---Check if a class is an inflated generic instance
-- @param klass table The class object
-- @return boolean True if the class is an inflated generic
function Class.IsInflated(klass)
    return klass.generic_class ~= 0
end

---Check if a class is a nested type
-- @param klass table The class object
-- @return boolean True if the class is nested
function Class.IsNested(klass)
    return klass.nested_type_count ~= 0
end

---Get the instance size of a class
-- @param klass table The class object
-- @return number The size of class instances in bytes
function Class.GetInstanceSize(klass)
    return klass.instance_size
end

---Find all instances of a class in memory
-- @param klass table The class object
-- @return table Array of object instances
function Class.GetInstance(klass)
    return Il2Cpp.Object:FindObjects(klass.address)
end

---Get all interfaces implemented by a class
-- @param klass table The class object
-- @return table Array of interface class objects
function Class.GetInterfaces(klass)
    if type(klass.implementedInterfaces) == "table" then return klass.implementedInterfaces end
    local interfaces = {}
    local iter = 0
    local interface
    while iter < klass.interfaces_count do
        interface = Il2Cpp.GetPtr(klass.implementedInterfaces + iter * Il2Cpp.pointSize)
        interfaces[#interfaces + 1] = Class(interface)
        iter = iter + 1
    end
    klass.implementedInterfaces = interfaces
    return interfaces
end

-- PropertyInfo

function Class.GetPropertys(klass)
    if type(klass.properties) == "table" then return klass.properties end
    local properties = {}
    local iter = 0
    local propertie
    while iter < klass.property_count do
        propertie = Il2Cpp.PropertyInfo(klass.properties + iter * Il2Cpp.PropertyInfo.size)
        properties[#properties + 1] = propertie
        iter = iter + 1
    end
    klass.properties = properties
    return properties
end

---Get the type definition index of a class
-- @param klass table The class object
-- @return number|nil The type definition index if found, nil otherwise
function Class.GetIndex(klass)
    local index = klass.byval_arg.data
    if Il2Cpp.Meta.Header.typeDefinitionsOffset <= index and (Il2Cpp.Meta.Header.typeDefinitionsOffset + Il2Cpp.Meta.Header.typeDefinitionsSize) >= index then
        return (index - Il2Cpp.Meta.Header.typeDefinitionsOffset) / Il2Cpp.typeSize
    elseif index <= Il2Cpp.typeCount then
        return index
    end
end

---Get pointers to a class by its index
-- @param index number The class index
-- @return number|nil The class pointer if found, nil otherwise
function Class.GetPointersToIndex(index)
    if Il2Cpp.Meta.Header.typeDefinitionsOffset <= index and (Il2Cpp.Meta.Header.typeDefinitionsOffset + Il2Cpp.Meta.Header.typeDefinitionsSize) >= index then
        index = (index - Il2Cpp.Meta.Header.typeDefinitionsOffset) / Il2Cpp.typeSize
    elseif index > Il2Cpp.typeCount then
        return index
    end
    return Il2Cpp.GetPtr(Il2Cpp.typeDef + (index * Il2Cpp.pointSize))
end

---Cache for class information checks
Class.IsClassCache = {}

---Check if an address points to valid class information
-- @param Address number Memory address to check
-- @return string|nil Image name if valid class, nil otherwise
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

---Name offset based on platform architecture
Class.NameOffset = (Il2Cpp.x64 and 0x10 or 0x8)

---Cache for class objects
Class.__cache = {}

---Create a class object from address, name, or index
-- @param addr_name_index string|number Address, name, or index of the class
-- @param add any Additional parameter (unused in current implementation)
-- @return table Class object or array of class objects
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

function Class.Dump(klass, config)
    return Il2Cpp.Dump(klass, config)
end

return setmetatable(Class, {
    ---Metatable call handler for Class
    -- Allows Class to be called as a function
    -- @param ... any Arguments passed to Class.From
    -- @return table Class object or array of class objects
    __call = Class.From
})
end)__bundle_register("Field", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Field
---Module for handling Il2Cpp field operations and metadata
local Field = {}

---Get the name of a field
-- @param field table The field object
-- @return string Field name
function Field.GetName(field)
    return field.name
end

---Get the parent class of a field
-- @param field table The field object
-- @return table Parent class object
function Field.GetParent(field)
    return Il2Cpp.Class(field.parent)
end

---Get the offset of a field
-- @param field table The field object
-- @return number Field offset
function Field.GetOffset(field)
    return field.offset
end

---Get the type of a field
-- @param field table The field object
-- @return table Type object
function Field.GetType(field)
    return Il2Cpp.Type(field.type)
end

---Check if a field is an instance field
-- @param field table The field object
-- @return boolean True if the field is an instance field
function Field.IsInstance(field)
    local attrs = Field.GetType(field).attrs
    return bit32.band(attrs, 0x0010) == 0 -- FIELD_ATTRIBUTE_STATIC = 0x0010
end

---Check if a field is a normal static field
-- @param field table The field object
-- @return boolean True if the field is a normal static field
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

---Get the value of an instance field
-- @param field table The field object
-- @param obj number Object address
-- @return any Field value
-- @error Throws an error if the field is not an instance field
function Field.GetValue(field, obj)
    if not Field.IsInstance(field) then
        error("Field must be an instance field")
    end
    local address = obj + field.offset
    local tInfo = Il2Cpp.type[field.type.type]
    return Il2Cpp.gV(address, tInfo and tInfo.flags or Il2Cpp.MainType)
end

---Set the value of an instance field
-- @param field table The field object
-- @param obj table Object address
-- @param value any New value to set
-- @error Throws an error if the field is not an instance field
function Field.SetValue(field, obj, value)
    if not Field.IsInstance(field) then
        error("Field must be an instance field")
    end
    local tInfo = Il2Cpp.type[tostring(field:GetType())]
    local results = {}
    for i, v in ipairs(obj) do
        results[#results+1] = {address = v.address + field.offset, flags = tInfo and tInfo.flags or Il2Cpp.MainType, value = value}
    end
    gg.setValues(results)
    return results
end

---Get the value of a static field
-- @param field table The field object
-- @return any Static field value
-- @error Throws an error if the field is not a normal static field
function Field.StaticGetValue(field)
    if not Field.IsNormalStatic(field) then
        error("Field must be a normal static field")
    end
    local address = Il2Cpp.gV(field.parent.static_fields) + field.offset
    local tInfo = Il2Cpp.type[field.type.type]
    return Il2Cpp.gV(address, tInfo and tInfo.flags or Il2Cpp.MainType)
end

---Set the value of a static field
-- @param field table The field object
-- @param value any New value to set
-- @error Throws an error if the field is not a normal static field
function Field.StaticSetValue(field, value)
    if not Field.IsNormalStatic(field) then
        error("Field must be a normal static field")
    end
    local address = Il2Cpp.gV(field.parent.static_fields) + field.offset
    local tInfo = Il2Cpp.type[field.type.type]
    gg.setValues({{address = address, flags = tInfo and tInfo.flags or Il2Cpp.MainType, value = value}})
end

---Create a Field object from address or name
-- @param addr_name string|number Field name or address
-- @return table Field object or array of field objects
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

return setmetatable(Field, {
    ---Metatable call handler for Field
    -- Allows Field to be called as a function
    -- @param ... any Arguments passed to Field.From
    -- @return table Field object or array of field objects
    __call = Field.From
})
end)__bundle_register("Method", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Method
---Module for handling Il2Cpp method operations and metadata
local Method = require "Hook"

-- Version-specific constants for method parameter handling
Method.parameterStart = Il2Cpp.Version >= 31 and 16 or 12
Method.parameterSize = Il2Cpp.Version <= 24 and 16 or 12

---Get the name of a method
-- @param method table The method object
-- @return string Method name
function Method.GetName(method)
    return method.name
end

---Get the declaring class of a method
-- @param method table The method object
-- @return table Declaring class object
function Method.GetDeclaringType(method)
    return Il2Cpp.Class(method.klass)
end

---Get the return type of a method
-- @param method table The method object
-- @return table Return type object
function Method.GetReturnType(method)
    return Il2Cpp.Type(method.return_type)
end

---Get the parameter count of a method
-- @param method table The method object
-- @return number Number of parameters
function Method.GetParamCount(method)
    return method.parameters_count
end

---Get the parameters of a method
-- @param method table The method object
-- @return table Array of parameter information
function Method.GetParam(method, dump)
    if type(method.parameters) == "table" then
        return method.parameters
    end
    --local methodDef = method.methodMetadataHandle or method.methodDefinition
    --local paramStart = Il2Cpp.Meta.Header.parametersOffset + Il2Cpp.gV(methodDef + Method.parameterStart, 4) * Method.parameterSize
    local methodDef = Il2Cpp.Il2CppMethodDefinition(method.methodMetadataHandle or method.methodDefinition)
    
    method.parameters = {}
    for index = 0, Method.GetParamCount(method) - 1 do
        --[[
        paramStart = paramStart + (index * Method.parameterSize)
        local token = paramStart + 4
        local paramType = paramStart + Method.parameterSize - 4
        local paramInfo = Il2Cpp.gV({{address = paramStart, flags = 4}, {address = paramType, flags = 4},{address = token, flags = 4}})
        method.parameters[index + 1] = {
            type = Il2Cpp.Type(paramInfo[2].value),
            name = Il2Cpp.Meta:GetStringFromIndex(paramInfo[1].value),
            token = paramInfo[3].value
        }
        ]]
        local paramDef = Il2Cpp.Param(methodDef.parameterStart + index)
        method.parameters[index + 1] = dump and tostring(paramDef) or paramDef
    end
    return dump and ("(" .. table.concat(method.parameters, ", ") .. ")") or method.parameters
end

---Check if a method is an instance method
-- @param method table The method object
-- @return boolean True if the method is an instance method
function Method.IsInstance(method)
    return bit32.band(method.flags, 0x0010) == 0 -- METHOD_ATTRIBUTE_STATIC = 0x0010
end

---Check if a method is abstract
-- @param method table The method object
-- @return boolean True if the method is abstract
function Method.IsAbstract(method)
    return (method.flags & Il2Cpp.Il2CppFlags.Method.METHOD_ATTRIBUTE_ABSTRACT) ~= 0
end

---Check if a method is static
-- @param method table The method object
-- @return boolean True if the method is static
function Method.IsStatic(method)
    return (method.flags & Il2Cpp.Il2CppFlags.Method.METHOD_ATTRIBUTE_STATIC) ~= 0
end

---Get the access level of a method
-- @param method table The method object
-- @return string Access level description
function Method.GetAccess(method)
    return Il2Cpp.Il2CppFlags.Method.Access[method.flags & Il2Cpp.Il2CppFlags.Method.METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK] or ""
end

---Check if a method is generic
-- @param method table The method object
-- @return boolean True if the method is generic
function Method.IsGeneric(method)
    return method.is_generic ~= 0
end

---Check if a method is a generic instance
-- @param method table The method object
-- @return boolean True if the method is a generic instance
function Method.IsGenericInstance(method)
    return method.is_inflated ~= 0 and method.is_generic == 0
end

function Method.GetIndex(method)  
    return ((method.methodMetadataHandle or method.methodDefinition) - Il2Cpp.Meta.Header.methodsOffset) / Il2Cpp.Il2CppMethodDefinition.size
end  

function Method.GetClass(method)
    if type(method.klass) == "number" then
        method.klass = Il2Cpp.Class(method.klass)
    end
    return method.klass
end  

---Create a Method object from address or name
-- @param addrMethodInfo number Address of the method info or name
-- @param addList any Additional parameter (unused in current implementation)
-- @return table Method object
function Method:From(addr_name)
    local method = {}
    if type(addr_name) == "string" then
        local res = Il2Cpp.Meta.GetPointersToString(addr_name)
        for i, v in ipairs(res) do
            local addr = Il2Cpp.GetPtr(v.address + (Il2Cpp.pointSize * 1))
            local IsClass = Il2Cpp.Class.IsClassInfo(addr)
            local addr = Il2Cpp.GetPtr(v.address + (Il2Cpp.pointSize * 2))
            local IsType = Il2Cpp.Type(addr)
            if IsClass and IsType then
                v.address = v.address - (Il2Cpp.Version < 29 and Il2Cpp.pointSize * 2 or Il2Cpp.pointSize * 3)
                local kls = Il2Cpp.MethodInfo(v.address)
                kls.address = v.address
                local res = setmetatable(kls, {
                    __index = Method,
                    __name = kls.name
                })
                method[#method+1] = res
            end
        end
    else
        method = Il2Cpp.MethodInfo(addr_name)
        method.address = addr_name
        return setmetatable(method, {
            __index = Method,
            __name = method.name
        })
    end
    return #method == 1 and method[1] or method
end




return setmetatable(Method, {
    ---Metatable call handler for Method
    -- Allows Method to be called as a function
    -- @param ... any Arguments passed to Method.From
    -- @return table Method object
    __call = Method.From
})
end)__bundle_register("Hook", function(require, _LOADED, __bundle_register, __bundle_modules)
--- @module hook
--- @brief Script Lua để hook memory, hỗ trợ mod game và reverse engineering với GameGuardian.
--- @details Hỗ trợ cả kiến trúc 32-bit và 64-bit, cho phép hook method, param, field, và call.

local gg = gg
--local malloc = require "malloc"
local info = gg.getTargetInfo()
local x64 = info.x64

--- @var pointerFlagsType number Loại flags cho con trỏ (32 cho 64-bit, 4 cho 32-bit)
local pointerFlagsType = x64 and 32 or 4
--- @var pointerSize number Kích thước con trỏ (8 cho 64-bit, 4 cho 32-bit)
local pointerSize = x64 and 8 or 4
--- @var armType number Loại ARM (6 cho 64-bit, 4 cho 32-bit)
local armType = x64 and 6 or 4
--- @var returnType number Kiểu trả về (0x10 cho 64-bit, 0x8 cho 32-bit)
local returnType = x64 and 0x10 or 0x8
--- @var jumpOpcode string Opcode để nhảy (jump) trong memory
local jumpOpcode = x64 and "h5100005820021FD6" or "h04F01FE5"
--- @var nullOpcode string|number Opcode rỗng (null) để điền mặc định
local nullOpcode = x64 and "B4000000h" or 0

--- @function table:union
--- @brief Gộp nhiều bảng vào bảng hiện tại.
--- @param ... table Các bảng cần gộp
--- @return table Bảng hiện tại sau khi gộp
table.__index = table
setmetatable(table, {
    __call = function(t, ...)
        return setmetatable({}, table):union(...)
    end
})
function table:union(...)
    for i = 1, select('#', ...) do
        local o = select(i, ...)
        if o then
            for k, v in pairs(o) do
                self[k] = v
            end
        end
    end
    return self
end

--- @function getValue
--- @brief Lấy giá trị từ memory tại địa chỉ cho trước.
--- @param address number Địa chỉ memory
--- @param flags number|nil Loại flags (nếu nil, dùng mặc định)
--- @return table|number Giá trị từ memory
--- @throws Nếu địa chỉ rỗng
function getValue(address, flags)
    if not address then
        error("địa chỉ rỗng là sao?")
    end
    return not flags and gg.getValues(address) or gg.getValues({{address = address, flags = flags}})[1].value
end

--- @function setValues
--- @brief Set giá trị vào memory và thêm vào danh sách GameGuardian.
--- @param results table Bảng chứa các giá trị {address, flags, value, freeze}
--- @param freeze boolean|nil Nếu true, giữ giá trị trong danh sách
--- @return table Danh sách các giá trị đã set
--- @throws Nếu bảng results rỗng
function setValues(results, freeze)
    if not results or next(results) == nil then
        error("Bảng giá trị rỗng")
    end
    local t = {}
    for i, v in pairs(results) do
        t[#t + 1] = {address = v.address, flags = v.flags, value = v.value, freeze = true}
    end
    gg.addListItems(t)
    gg.removeListItems(freeze and {} or t)
    return t
end

--- @module opcode
--- @brief Module xử lý opcode cho hook.
local opcode = {}

--- @function opcode.generateLDR
--- @brief Tạo opcode LDR để load giá trị từ memory.
--- @param param number Tham số (register index)
--- @param index number Offset trong memory
--- @param flags string Loại flags (int, float, double, string)
--- @param x64 boolean Kiến trúc 64-bit hay không
--- @return string Opcode LDR
function opcode.generateLDR(param, index, flags, x64)
    local iP = string.format("0x%X", index)
    local opR = x64 and flags or "R" .. param
    return x64 and "~A8 LDR " .. opR .. ", [PC,#" .. iP .. "]" or "~A LDR " .. opR .. ", [PC,#" .. (iP - 8) .. "]"
end

--- @function opcode.generateSTR
--- @brief Tạo opcode STR để store giá trị vào memory.
--- @param param number Tham số (register index)
--- @param offset number Offset trong memory
--- @param flags string Loại flags (int, float, double, string)
--- @param x64 boolean Kiến trúc 64-bit hay không
--- @return string Opcode STR
function opcode.generateSTR(param, offset, flags, x64)
    local opR = (x64 and flags or "R") .. param
    return x64 and "~A8 STR " .. opR .. ", [X0,#" .. offset .. "]" or "~A STR " .. opR .. ", [R0,#" .. offset .. "]"
end

--- @table hook
--- @brief Đối tượng chính để hook memory.
local hook = {}

--- @field flags table Ánh xạ loại dữ liệu (int, float, double, string) sang ký hiệu register
hook.flags = {int = "X", float = "S", double = "D", string = "X"}
--- @field type table Ánh xạ loại dữ liệu sang flags của GameGuardian
hook.type = {int = 4, float = 16, double = 64, string = pointerFlagsType}

--- @function hook.addToResults
--- @brief Thêm giá trị vào danh sách kết quả.
--- @param res table Danh sách kết quả
--- @param address number Địa chỉ memory
--- @param flags number Loại flags
--- @param value any Giá trị cần set
function hook.addToResults(res, address, flags, value)
    res[#res + 1] = {address = address, flags = flags, value = value}
end

--- @function hook:searchPointer
--- @brief Tìm kiếm con trỏ trong memory.
--- @param address number Địa chỉ cần tìm
--- @param ranges number|nil Vùng memory để tìm (mặc định: 4 | 32 | -2080896)
--- @return table Danh sách kết quả tìm kiếm
--- @throws Nếu địa chỉ rỗng
function hook:searchPointer(address, ranges)
    if not address then
        error("Địa chỉ rỗng")
    end
    gg.setRanges(ranges or (4 | 32 | -2080896))
    gg.clearResults()
    gg.searchNumber(address, pointerFlagsType)
    local count = gg.getResultsCount()
    if count == 0 and x64 then
        gg.searchNumber(tostring(address | 0xB400000000000000), pointerFlagsType)
        count = gg.getResultsCount()
    end
    if count == 0 then
        print("Không tìm thấy con trỏ nào tại địa chỉ: " .. tostring(address))
        return {}
    end
    local results = gg.getResults(count) or {}
    gg.clearResults()
    return results
end

--- @function hook:off
--- @brief Tắt hook và khôi phục giá trị gốc.
function hook:off()
    if self.on then
        setValues({self.methodInfo})
        self.on = false
        --print("Hook đã off")
    end
end

setmetatable(hook, {
    __call = function(self, ...)
        return setmetatable({...}, {
            __index = self,
            __call = function(self, ...)
                return self:init(...)
            end
        })
    end
})

--- @field hook.call table Instance để hook call
hook.call = hook()
--- @field hook.method table Instance để hook method
hook.method = hook()
--- @field hook.field table Instance để hook field
hook.field = hook()
--- @field hook.param table Instance để hook param
hook.param = hook()

--- @var PARAM_OFFSET number Offset cho param (0x38 cho 64-bit, 0x30 cho 32-bit)
local PARAM_OFFSET = x64 and 0x38 or 0x30
--- @var FIELD_OFFSET number Offset cho field (gấp đôi PARAM_OFFSET)
local FIELD_OFFSET = PARAM_OFFSET * 2
hook.param.offset = { value = PARAM_OFFSET }
hook.field.offset = { value = FIELD_OFFSET }

--- @function hook.method:init
--- @brief Khởi tạo hook cho method.
--- @param methodInfoAddress number Địa chỉ của hàm
--- @return table Instance hook.method
--- @throws Nếu địa chỉ rỗng hoặc không hợp lệ
function hook.method:init(methodInfo)
    if not methodInfo then
        error("Địa chỉ hàm rỗng")
    end
    self.methodInfo = {address = methodInfo.address, value = methodInfo.methodPointer, flags = pointerFlagsType}
    self.methodPointer = self.methodInfo.value
    if self.methodPointer == 0 then
        error("địa chỉ " .. string.format("%X", self.methodPointer) .. " fail")
    end
    self.on = false
    return self
end

--- @function hook.method:call
--- @brief Gọi hàm với địa chỉ con trỏ mới.
--- @param methodPointerAddress number Địa chỉ con trỏ mới
--- @return table Instance hook.call
function hook.method:call(methodInfo)
    return hook.call(self.methodInfo.address)(methodInfo)
end

--- @function hook.method:param
--- @brief Set tham số cho method hook.
--- @param table table Bảng chứa tham số {param, flags, value}
--- @return table Instance hook.method
--- @throws Nếu bảng tham số rỗng hoặc không hợp lệ
function hook.method:param(table)
    if not table or next(table) == nil then
        error("Bảng tham số rỗng")
    end
    if not self.on then
        local values = {
            {address = self.methodPointer, flags = pointerFlagsType},
            {address = self.methodPointer + pointerSize, flags = pointerFlagsType}
        }
        self.results = gg.getValues(values)
        self.alloc = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE | gg.PROT_EXEC)

        local result = {}
        hook.addToResults(result, self.alloc, pointerFlagsType, self.results[1].value)
        hook.addToResults(result, self.alloc + pointerSize, pointerFlagsType, self.results[2].value)
        hook.addToResults(result, self.methodPointer, pointerFlagsType, jumpOpcode)
        hook.addToResults(result, self.methodPointer + pointerSize, pointerFlagsType, self.alloc)

        setValues(result)
        self.param = hook.param(self.methodPointer + (pointerSize * 2), self.alloc + (pointerSize * 2))
        setValues(self.param:setValues(table))
        self.on = true
        return self
    end
    setValues(self.param:setValues(table))
    self.on = true
    return self
end

--- @function hook.method:off
--- @brief Tắt hook method và khôi phục giá trị gốc.
function hook.method:off()
    if self.on then
        setValues(self.results)
        self.on = false
        --print("Method hook off")
    end
end

--- @function hook.param:init
--- @brief Khởi tạo hook cho tham số.
--- @param methodPointerAddress number Địa chỉ hàm
--- @param allocAddress number|nil Địa chỉ phân bổ memory (nếu nil, tự động phân bổ)
--- @return table Instance hook.param
--- @throws Nếu địa chỉ rỗng hoặc không hợp lệ
function hook.param:init(methodPointerAddress, allocAddress)
    if not methodPointerAddress then
        error("Địa chỉ hàm rỗng")
    end
    self.methodPointer = methodPointerAddress
    if self.methodPointer == 0 then
        error("Địa chỉ " .. string.format("%X", self.methodPointer) .. " fail")
    end
    self.alloc = allocAddress or gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE | gg.PROT_EXEC)
    local res = {}
    for i = 0, 9 do
        hook.addToResults(res, self.alloc + (i * 4), 4, nullOpcode)
    end
    hook.addToResults(res, self.alloc + (10 * 4), pointerFlagsType, jumpOpcode)
    hook.addToResults(res, self.alloc + (10 * 4) + (x64 and 8 or 4), pointerFlagsType, methodPointerAddress)
    setValues(res)
    return self
end

--- @function hook.param:setValues
--- @brief Set giá trị cho tham số hook.
--- @param table table Bảng chứa tham số {param, flags, value}
--- @return table Danh sách giá trị để set vào memory
--- @throws Nếu flags không hợp lệ
function hook.param:setValues(table)
    local res = {}
    for i, v in pairs(table) do
        if not v.flags or not self.type[v.flags] then
            error("Loại flags không hợp lệ: " .. tostring(v.flags))
        end
        local param = v.param or i
        local index = (param - 1) * 4
        local iP = self.offset.value + index
        local opLDR = v.flags and opcode.generateLDR(param, iP, self.flags[v.flags], x64) or nullOpcode
        hook.addToResults(res, self.alloc + index, 4, opLDR)
        hook.addToResults(res, self.alloc + index + iP, self.type[v.flags] or 32, v.flags and v.value or 0)
    end
    return res
end

--- @function hook.call:init
--- @brief Khởi tạo hook cho call.
--- @param methodInfoAddress number Địa chỉ hàm
--- @return function Hàm để set địa chỉ con trỏ mới
--- @throws Nếu địa chỉ rỗng hoặc không hợp lệ
function hook.call:init(methodInfo)
    if not methodInfo then
        error("Địa chỉ hàm rỗng")
    end
    self.methodInfo = {address = methodInfo.address, value = methodInfo.methodPointer, flags = pointerFlagsType}
    self.methodPointer = self.methodInfo.value
    if self.methodPointer == 0 then
        error("Địa chỉ " .. string.format("%X", self.methodPointer) .. " fail")
    end
    self.on = false
    return function(methodInfo)
        self.to = methodInfo.methodPointer
        self.param = hook.param(methodInfo.methodPointer)
        self.alloc = self.param.alloc
        return self
    end
end

--- @function hook.call:setValues
--- @brief Set giá trị cho call hook.
--- @param table table Bảng chứa tham số {param, flags, value}
--- @return table Instance hook.call
function hook.call:setValues(table)
    local res = self.param:setValues(table)
    if not self.on then
        hook.addToResults(res, self.methodInfo.address, self.methodInfo.flags, self.alloc)
        self.on = true
    end
    setValues(res)
    return self
end

--- @function hook.field:init
--- @brief Khởi tạo hook cho field.
--- @param methodInfoAddress number Địa chỉ field
--- @return table Instance hook.field
--- @throws Nếu địa chỉ rỗng hoặc không hợp lệ
function hook.field:init(methodInfo)
    if not methodInfo then
        error("Địa chỉ hàm rỗng")
    end
    self.methodInfo = {address = methodInfo.address, value = methodInfo.methodPointer, flags = pointerFlagsType}
    self.methodPointer = self.methodInfo.value
    if self.methodPointer == 0 then
        error("Địa chỉ " .. string.format("%X", self.methodPointer) .. " fail")
    end
    self.on = false
    self.alloc = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE | gg.PROT_EXEC)
    local res = {}
    for i = 0, 18 do
        hook.addToResults(res, self.alloc + (i * 4), 4, nullOpcode)
    end
    hook.addToResults(res, self.alloc + (22 * 4), pointerFlagsType, jumpOpcode)
    hook.addToResults(res, self.alloc + (22 * 4) + (x64 and 8 or 4), pointerFlagsType, self.methodPointer)
    setValues(res)
    return self
end

--- @function hook.field:setValues
--- @brief Set giá trị cho field hook.
--- @param table table Bảng chứa {offset, flags, value}
--- @return table Instance hook.field
--- @throws Nếu offset hoặc flags không hợp lệ
function hook.field:setValues(table)
    local res = {}
    for i, v in pairs(table) do
        if not v.offset or not v.flags or not self.type[v.flags] then
            error("Offset hoặc flags không hợp lệ: " .. tostring(v.flags))
        end
        local offset = v.offset
        local index = (i - 1) * 4
        local iP = self.offset.value + index
        local opR = (x64 and self.flags[v.flags] or "R") .. i
        local opLDR = v.flags and opcode.generateLDR(i, iP, self.flags[v.flags], x64) or nullOpcode
        local opSTR = v.flags and opcode.generateSTR(i, offset, self.flags[v.flags], x64) or nullOpcode
        hook.addToResults(res, self.alloc + index, 4, opLDR)
        hook.addToResults(res, self.alloc + index + 8, 4, opSTR)
        hook.addToResults(res, self.alloc + index + iP, self.type[v.flags] or 32, v.flags and v.value or 0)
    end
    if not self.on then
        hook.addToResults(res, self.methodInfo.address, self.methodInfo.flags, self.alloc)
        self.on = true
    end
    setValues(res)
    return self
end


return hook
end)__bundle_register("Param", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Param
---Module for handling Il2Cpp param operations and metadata
local Param = {}

---Get the name of a param
-- @param param table The param object
-- @return string Param name
function Param.GetName(param)
    if not param.name then
        param.name = Il2Cpp.Meta:GetStringFromIndex(param.nameIndex)
    end
    return param.name 
end

---Get the offset of a param
-- @param param table The param object
-- @return number Param offset
function Param.GetToken(param)
    return param.token
end

---Get the type of a param
-- @param param table The param object
-- @return table Type object
function Param.GetType(param)
    if not param.type then
        param.type = Il2Cpp.Type(param.typeIndex)
    end
    return param.type
end

function Param:From(param_index, add)
    local param = Il2Cpp.Meta:GetParameterDefinition(param_index, add)
    --param.index = param_index
    return setmetatable(param, {
        __index = Param,
        __name = 'Param[' .. param_index .. ']',
        __tostring = Param.ToString
    })
end

function Param.ToString(param)
    return tostring(Param.GetType(param)) .. " " .. Param.GetName(param)
end

return setmetatable(Param, {
    __call = Param.From
})
end)__bundle_register("Object", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("Androidinfo")

---@class ObjectApi
---Module for handling Il2Cpp object operations and memory management
local ObjectApi = {

    ---@field regionObject number Memory region to search for objects (default: gg.REGION_ANONYMOUS)
    regionObject = gg.REGION_ANONYMOUS,

    ---Filter objects to remove invalid references and handle 64-bit Android SDK 30+ special cases
    -- @param self ObjectApi The ObjectApi instance
    -- @param Objects table Table of objects to filter
    -- @return table Filtered objects with valid references
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

    ---Find objects of a specific class in memory
    -- @param self ObjectApi The ObjectApi instance
    -- @param ClassAddress string|number Address of the class to search for
    -- @return table Table of found objects
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

    ---Find objects from multiple class information structures
    -- @param self ObjectApi The ObjectApi instance
    -- @param ClassesInfo ClassInfo[] Array of class information tables
    -- @return table Table of found objects
    From = function(self, ClassesInfo)
        local Objects = {}
        for j = 1, #ClassesInfo do
            local FindResult = self:FindObjects(ClassesInfo[j].address)
            table.move(FindResult, 1, #FindResult, #Objects + 1, Objects)
        end
        return Objects
    end,

    ---Find the class head (start address) for a given object address
    -- @param Address number Memory address of an object
    -- @return table Table containing address and value of the class head
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

return setmetatable(ObjectApi, {
    ---Metatable call handler for ObjectApi
    -- Allows ObjectApi to be called as a function
    -- @param ... any Arguments passed to ObjectApi.From
    -- @return table Table of found objects
    __call = ObjectApi.From
})
end)__bundle_register("Image", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Image
---Module for handling Il2Cpp image operations and metadata
local Image = {}

---Create an Image object from name or get all images
-- @param name string|nil Image name to search for (optional)
-- @return table Image object or table of all images
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

---Get the name of an image
-- @param image table The image object
-- @return string Image name
function Image.GetName(image)
    return image.name
end

---Get the file name of an image
-- @param image table The image object
-- @return string Image file name
function Image.GetFileName(image)
    return image.name
end

---Get the assembly of an image
-- @param image table The image object
-- @return number Assembly pointer
function Image.GetAssembly(image)
    return image.assembly
end

---Get the entry point of an image
-- @param image table The image object
-- @return table|nil Method object if entry point exists, nil otherwise
function Image.GetEntryPoint(image)
    local method = Il2Cpp.il2cpp_image_get_entry_point(image)
    return method ~= 0 and Il2Cpp.MethodInfo(method) or nil
end

---Get the corlib image
-- @return table Corlib image object
function Image.GetCorlib()
    return Il2Cpp.il2cpp_get_corlib()
end

---Get the number of types in an image
-- @param image table The image object
-- @return number Number of types
function Image.GetNumTypes(image)
    return image.typeCount
end

---Get a type by index from an image
-- @param image table The image object
-- @param index number Type index
-- @return table|nil Class object if found, nil otherwise
function Image.GetType(image, index)
    if index >= image.typeCount then
        return nil
    end
    local handle = Il2Cpp.GetPtr(Il2Cpp.typeDef + (image.typeStart + index) * Il2Cpp.pointSize)
    return handle ~= 0 and Il2Cpp.Class(handle) or nil
end

---Get all types from an image
-- @param image table The image object
-- @param exportedOnly boolean Whether to return only exported types
-- @return table Array of class objects
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

---Check if a type is exported
-- @param type table The class object
-- @return boolean True if the type is exported
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

---Find a class by namespace and name in an image
-- @param image table The image object
-- @param namespace string Namespace of the class
-- @param name string Name of the class
-- @return table|nil Class object if found, nil otherwise
function Image.Class(image, namespace, name)
    local key = (namespace or "") .. "." .. name
    if not image.nameToClassHashTable or image.typeCount > image.countHashTable then
        image.nameToClassHashTable = image.nameToClassHashTable or {}
        image.countHashTable = image.countHashTable or 0
        Image.InitNameToClassHashTable(image, key)
    end
    
    return Il2Cpp.Class(image.nameToClassHashTable[key])
end

---Find a class from type name parse info
-- @param image table The image object
-- @param parseInfo table Parsed type information
-- @param ignoreCase boolean Whether to ignore case when matching names
-- @return table|nil Class object if found, nil otherwise
function Image.FromTypeNameParseInfo(image, parseInfo, ignoreCase)
    local ns = parseInfo.ns or ""
    local name = parseInfo.name or ""
    local klass = Image.Class(image, ns, name)
    if not klass then
        -- Search in exported types if not found
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

---Get the executing image from the current stack
-- @return table Executing image object
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

---Get the calling image from the current stack
-- @return table Calling image object
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

---Check if a class is System.Type
-- @param klass table The class object
-- @return boolean True if the class is System.Type
function Image.IsSystemType(klass)
    return klass.namespaze == "System" and klass.name == "Type"
end

---Check if a class is System.Reflection.Assembly
-- @param klass table The class object
-- @return boolean True if the class is System.Reflection.Assembly
function Image.IsSystemReflectionAssembly(klass)
    return klass.namespaze == "System.Reflection" and klass.name == "Assembly"
end

---Initialize name to class hash table for an image
-- @param image table The image object
-- @param key string The key to search for
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
                return klass
            end
        end
    end
end

---Add nested types to hash table for an image
-- @param image table The image object
-- @param handle number Class handle
-- @param namespaze string Namespace of the class
-- @param parentName string Name of the parent class
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

---Initialize nested types for an image
-- @param image table The image object
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

---Get cached resource data from an image
-- @param image table The image object
-- @param name string Resource name
-- @return any|nil Resource data if found, nil otherwise
function Image.GetCachedResourceData(image, name)
    local data = Il2Cpp.il2cpp_get_cached_resource_data(image, name)
    return data or nil
end

---Clear cached resource data
function Image.ClearCachedResourceData()
    Il2Cpp.il2cpp_clear_cached_resource_data()
end

return setmetatable(Image, {
    ---Metatable call handler for Image
    -- Allows Image to be called as a function
    -- @param ... any Arguments passed to Image.From
    -- @return table Image object or table of image objects
    __call = Image.From
})
end)__bundle_register("Type", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Type
---Module for handling Il2Cpp type operations and metadata
local Type = {}

---Create a Type object from memory address or index
-- @param address number Memory address or type index
-- @return table Type object with metadata
function Type:From(address)
    if Type.typeCount >= address then -- if it's an index
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

---Check if a type is a reference type
-- @param typeStruct table Type object to check
-- @return boolean True if the type is a reference type
function Type.IsReference(typeStruct)
    local t = typeStruct.type
    return t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_STRING or
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_SZARRAY or
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_CLASS or
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_OBJECT or
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_ARRAY
end

---Check if a type is a struct (value type but not enum)
-- @param typeStruct table Type object to check
-- @return boolean True if the type is a struct
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

---Check if a type is an enum
-- @param typeStruct table Type object to check
-- @return boolean True if the type is an enum
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

---Check if a type is a value type
-- @param typeStruct table Type object to check
-- @return boolean True if the type is a value type
function Type.IsValueType(typeStruct)
    return typeStruct.valuetype == 1
end

---Check if a type is an array
-- @param typeStruct table Type object to check
-- @return boolean True if the type is an array
function Type.IsArray(typeStruct)
    local t = typeStruct.type
    return t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_SZARRAY or 
           t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_ARRAY
end

---Check if a type is a pointer
-- @param typeStruct table Type object to check
-- @return boolean True if the type is a pointer
function Type.IsPointer(typeStruct)
    return typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_PTR
end

---Get the Il2CppClass corresponding to a type
-- @param typeStruct table Type object
-- @param add any Additional parameter (unused in current implementation)
-- @return table|nil Class object if found, nil otherwise
function Type.GetClass(typeStruct, add)
    if typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_CLASS or
       typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VALUETYPE then
        return Il2Cpp.Class(typeStruct.data, add)
    end
    return nil
end

---Get the simple name of a type (for basic types)
-- @param typeStruct table Type object
-- @return string Simple type name

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
    local TypeString = {
        [1] = "void",
        [2] = "bool",
        [3] = "char",
        [4] = "sbyte",
        [5] = "byte",
        [6] = "short",
        [7] = "ushort",
        [8] = "int",
        [9] = "uint",
        [10] = "long",
        [11] = "ulong",
        [12] = "float",
        [13] = "double",
        [14] = "string",
        [22] = "TypedReference",
        [24] = "IntPtr",
        [25] = "UIntPtr",
        [28] = "object",
    }
    
    return TypeString[typeStruct.type] or "Unknown"
end

---Get the full name of a type
-- @param typeStruct table Type object
-- @param addNamespaze boolean Whether to include namespace in the name
-- @return string Full type name
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
       return name
   end
    
    if t == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_GENERICINST then
        -- Read generic class
        local genericClass = Il2Cpp.Il2CppGenericClass(typeStruct.data)
        if genericClass then
            local typeDef = Il2Cpp.Class(genericClass.type and Il2Cpp.GetPtr(genericClass.type) or genericClass.typeDefinitionIndex)
            local baseName = typeDef.name:gsub("`.*", "")
            
            -- Read generic context
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

---Get the token of a type (used in metadata)
-- @param typeStruct table Type object
-- @return number Type token
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

---Check if a type is a generic instance (IL2CPP_TYPE_GENERICINST)
-- @param typeStruct table Type object
-- @return boolean True if the type is a generic instance
function Type.IsGenericInstance(typeStruct)
    return typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_GENERICINST
end

---Check if a type is a generic parameter (IL2CPP_TYPE_VAR or IL2CPP_TYPE_MVAR)
-- @param typeStruct table Type object
-- @return boolean True if the type is a generic parameter
function Type.IsGenericParameter(typeStruct)
    return typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_VAR or 
           typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_MVAR
end

---Get generic parameter handle (only for generic parameters)
-- @param typeStruct table Type object
-- @return table|nil Generic parameter handle if found, nil otherwise
function Type.GetGenericParameterHandle(typeStruct)
    if not Type.IsGenericParameter(typeStruct) then
        return nil
    end
    return Il2Cpp.Meta.GetGenericParameterFromType(typeStruct)
end

---Get generic parameter information
-- @param typeStruct table Type object
-- @return table|nil Generic parameter information if found, nil otherwise
function Type.GetGenericParameterInfo(typeStruct)
    local handle = Type.GetGenericParameterHandle(typeStruct)
    if not handle then
        return nil
    end
    return Il2Cpp.Meta.GetGenericParameterInfo(handle)
end

---Get the declaring type of a generic parameter
-- @param typeStruct table Type object
-- @return table|nil Declaring type if found, nil otherwise
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

---Get the declaring method (only for MVAR generic parameters)
-- @param typeStruct table Type object
-- @return table|nil Declaring method if found, nil otherwise
function Type.GetDeclaringMethod(typeStruct)
    if typeStruct.byref ~= 0 then
        return nil
    end
    if typeStruct.type == Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_MVAR then
        return Il2Cpp.Meta.GetParameterDeclaringMethod(Type.GetGenericParameterHandle(typeStruct))
    end
    return nil
end

---Get the generic type definition (only for generic instances)
-- @param typeStruct table Type object
-- @return table Generic type definition
function Type.GetGenericTypeDefinition(typeStruct)
    if not Type.IsGenericInstance(typeStruct) then
        return typeStruct
    end
    local genericClass = Il2Cpp.Il2CppGenericClass(typeStruct.data)
    return Type:From(genericClass.type)
end

---Compare if two types are equal
-- @param type1 table First type object
-- @param type2 table Second type object
-- @return boolean True if types are equal
function Type.AreEqual(type1, type2)
    if type1.address == type2.address then
        return true
    end
    -- TODO: Implement detailed comparison if needed
    return false
end

---Get the size of a type in memory
-- @param typeStruct table Type object
-- @return number Size in bytes
function Type.GetSize(typeStruct)
    if Type.IsValueType(typeStruct) then
        local klass = Type.GetClass(typeStruct)
        return klass.instance_size
    end
    
    -- Reference types have pointer size
    return Il2Cpp.pointSize
end

---Get array information if the type is an array
-- @param typeStruct table Type object
-- @return table|nil Array information if type is an array, nil otherwise
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

function Type.GetTypeEnum(self, Il2CppType)
    return gg.getValues({{address = Il2CppType + (Il2Cpp.x64 and 0xA or 0x6), flags = gg.TYPE_BYTE}})[1].value
end

---Convert Il2CppType to a descriptive string
-- @param typeStruct table Type object
-- @return string Descriptive string representation
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
    ---Metatable call handler for Type
    -- Allows Type to be called as a function
    -- @param ... any Arguments passed to Type.From
    -- @return table Type object
    __call = Type.From
})
end)__bundle_register("Dump", function(require, _LOADED, __bundle_register, __bundle_modules)
function Dump(typeDef, config)
    local Il2CppConstants = Il2Cpp.Il2CppConstants
    local config = config or {
        DumpAttribute = false,
        DumpField = true,
        DumpProperty = true,
        DumpMethod = true,
        DumpFieldOffset = true,
        DumpMethodOffset = true,
        DumpTypeDefIndex = true,
    }
    local output = {}
    local extends = {}
    
    local typeDefs = Il2Cpp.Il2CppTypeDefinition(typeDef.typeMetadataHandle or typeDef.typeDefinition)
    local typeDefIndex = typeDef:GetIndex()
    
    if typeDef.parent >= 0 then
        local parent = typeDef:GetParent()
        local parentName = parent:GetName()
        if not typeDef:IsValueType() and not typeDef:IsEnum() and parentName ~= "object" then
            table.insert(extends, parentName)
        end
    end
    if typeDef.interfaces_count > 0 then
        for i, interface in ipairs(typeDef:GetInterfaces()) do
            table.insert(extends, interface:GetName())
        end
    end
    table.insert(output, string.format("\n// Namespace: %s", typeDef:GetNamespace()))
    
    
    local visibility = bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_VISIBILITY_MASK)
    local visibilityStr = ""
    if visibility == Il2CppConstants.TYPE_ATTRIBUTE_PUBLIC or visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_PUBLIC then
        visibilityStr = "public "
    elseif visibility == Il2CppConstants.TYPE_ATTRIBUTE_NOT_PUBLIC or visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAM_AND_ASSEM or visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_ASSEMBLY then
        visibilityStr = "internal "
    elseif visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_PRIVATE then
        visibilityStr = "private "
    elseif visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAMILY then
        visibilityStr = "protected "
    elseif visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAM_OR_ASSEM then
        visibilityStr = "protected internal "
    end
    if bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_ABSTRACT) ~= 0 and bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_SEALED) ~= 0 then
        visibilityStr = visibilityStr .. "static "
    elseif bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_INTERFACE) == 0 and bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_ABSTRACT) ~= 0 then
        visibilityStr = visibilityStr .. "abstract "
    elseif not typeDef:IsValueType() and not typeDef:IsEnum() and bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_SEALED) ~= 0 then
        visibilityStr = visibilityStr .. "sealed "
    end
    local typeKind = ""
    if bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_INTERFACE) ~= 0 then
        typeKind = "interface "
    elseif typeDef:IsEnum() then
        typeKind = "enum "
    elseif typeDef:IsValueType() then
        typeKind = "struct "
    else
        typeKind = "class "
    end
    local typeName = typeDef:GetName()
    local extendsStr = #extends > 0 and string.format(" : %s", table.concat(extends, ", ")) or ""
    local typeDefIndexStr = config.DumpTypeDefIndex and string.format(" // TypeDefIndex: %d", typeDefIndex - 1) or ""
    table.insert(output, string.format("%s%s%s%s%s\n{", visibilityStr, typeKind, typeName, extendsStr, typeDefIndexStr))
    
    
    -- Dump fields
    if config.DumpField and typeDef.field_count > 0 then
        table.insert(output, "\t// Fields")
        for i, fieldDef in ipairs(typeDef:GetFields()) do
            local fieldType = fieldDef:GetType()
            local isStatic = false
            local isConst = false
            if config.DumpAttribute then
                table.insert(output, self:getCustomAttribute(imageDef, fieldDef.customAttributeIndex, fieldDef.token, "\t"))
            end
            local access = bit32.band(fieldType.attrs, Il2CppConstants.FIELD_ATTRIBUTE_FIELD_ACCESS_MASK)
            local accessStr = ""
            if access == Il2CppConstants.FIELD_ATTRIBUTE_PRIVATE then
                accessStr = "private "
            elseif access == Il2CppConstants.FIELD_ATTRIBUTE_PUBLIC then
                accessStr = "public "
            elseif access == Il2CppConstants.FIELD_ATTRIBUTE_FAMILY then
                accessStr = "protected "
            elseif access == Il2CppConstants.FIELD_ATTRIBUTE_ASSEMBLY or access == Il2CppConstants.FIELD_ATTRIBUTE_FAM_AND_ASSEM then
                accessStr = "internal "
            elseif access == Il2CppConstants.FIELD_ATTRIBUTE_FAM_OR_ASSEM then
                accessStr = "protected internal "
            end
            if bit32.band(fieldType.attrs, Il2CppConstants.FIELD_ATTRIBUTE_LITERAL) ~= 0 then
                isConst = true
                accessStr = accessStr .. "const "
            else
                if bit32.band(fieldType.attrs, Il2CppConstants.FIELD_ATTRIBUTE_STATIC) ~= 0 then
                    isStatic = true
                    accessStr = accessStr .. "static "
                end
                if bit32.band(fieldType.attrs, Il2CppConstants.FIELD_ATTRIBUTE_INIT_ONLY) ~= 0 then
                    accessStr = accessStr .. "readonly "
                end
            end
            local fieldName = fieldDef:GetName()
            local fieldTypeName = tostring(fieldType)
            local defaultValueStr = ""
            
            
            local fieldDefaultValue = Il2Cpp.Meta:GetFieldDefaultValueFromIndex(typeDefs.fieldStart + (i - 1))
            if fieldDefaultValue and fieldDefaultValue.dataIndex ~= -1 then
                local success, value = Il2Cpp.Meta:TryGetDefaultValue(fieldDefaultValue.typeIndex, fieldDefaultValue.dataIndex)
                if success then
                    defaultValueStr = " = "
                    if type(value) == "string" then
                        defaultValueStr = defaultValueStr .. string.format("\"%s\"", value:gsub("[\"\\]", "\\%0"))
                    elseif type(value) == "number" and math.floor(value) == value then
                        defaultValueStr = defaultValueStr .. string.format("\\x%x", value)
                    elseif value ~= nil then
                        defaultValueStr = defaultValueStr .. tostring(value)
                    else
                        defaultValueStr = defaultValueStr .. "null"
                    end
                else
                    defaultValueStr = string.format(" /*Metadata offset 0x%x*/", value)
                end
            end
            local offsetStr = ""
            if config.DumpFieldOffset and not isConst then
                offsetStr = string.format("; // 0x%x", fieldDef:GetOffset())
            else
                offsetStr = ";"
            end
            table.insert(output, string.format("\t%s%s %s%s%s", accessStr, fieldTypeName, fieldName, defaultValueStr, offsetStr))
        end
    end

    -- Dump properties
    if config.DumpProperty and typeDef.property_count > 0 then
        table.insert(output, "\n\t// Properties")
        for i, propertyDef in ipairs(typeDef:GetPropertys()) do
            if config.DumpAttribute then
                table.insert(output, self:getCustomAttribute(imageDef, propertyDef.customAttributeIndex, propertyDef.token, "\t"))
            end
            local propertyType, modifiers
            if propertyDef.get >= 0 then
                local methodDef = Il2Cpp.Method(propertyDef.get)
                modifiers = Il2Cpp:GetModifiers(methodDef)
                propertyType = methodDef:GetReturnType()
            elseif propertyDef.set >= 0 then
                local methodDef = Il2Cpp.Method(propertyDef.set)
                modifiers = Il2Cpp:GetModifiers(methodDef)
                local parameterDef = methodDef:GetParam()
                propertyType = parameterDef:GetType()
            end
            local propertyName = propertyDef.name
            local propertyTypeName = tostring(propertyType)
            local accessors = {}
            if propertyDef.get >= 0 then
                table.insert(accessors, "get; ")
            end
            if propertyDef.set >= 0 then
                table.insert(accessors, "set; ")
            end
            table.insert(output, string.format("\t%s%s %s { %s}", modifiers, propertyTypeName, propertyName, table.concat(accessors)))
        end
    end

    -- Dump methods
    if config.DumpMethod and typeDef.method_count > 0 then
        table.insert(output, "\n\t// Methods")
        for i, methodDef in ipairs(typeDef:GetMethods()) do
            table.insert(output, "")
            local methodDefs = Il2Cpp.Il2CppMethodDefinition(methodDef.methodMetadataHandle or methodDef.methodDefinition)
            local isAbstract = bit32.band(methodDef.flags, Il2CppConstants.METHOD_ATTRIBUTE_ABSTRACT) ~= 0
            if config.DumpAttribute then
                table.insert(output, self:getCustomAttribute(imageDef, methodDef.customAttributeIndex, methodDef.token, "\t"))
            end
            if config.DumpMethodOffset then
                local methodPointer = methodDef.methodPointer
                if not isAbstract and methodPointer > 0 then
                    local fixedMethodPointer = methodDef.address
                    table.insert(output, string.format("\t// RVA: 0x%x Offset: 0x%x VA: 0x%x", fixedMethodPointer, methodPointer  - Il2Cpp.il2cppStart, methodPointer))
                else
                    table.insert(output, "\t// RVA: -1 Offset: -1")
                end
                if methodDef.slot ~= -1 then
                    table.insert(output, string.format(" Slot: %d", methodDef.slot))
                end
            end
            local modifiers = Il2Cpp:GetModifiers(methodDef)
            local methodReturnType = methodDef:GetReturnType()
            local methodName = methodDef:GetName()
            local genericContainers = methodDef.genericContainerHandle or methodDef.genericContainer
            if genericContainers ~= 0 then
                local genericContainer = Il2Cpp.Meta:GetGenericContainer(genericContainers)
                methodName = methodName .. Il2Cpp.Meta:GetGenericContainerParams(genericContainer)
            end
            local returnPrefix = methodReturnType.byref == 1 and "ref " or ""
            local parameterStrs = {}
            for j, parameterDef in ipairs(methodDef:GetParam()) do
                local parameterName = parameterDef:GetName()
                local parameterType = parameterDef:GetType()
                local parameterTypeName = parameterType:GetName()
                local paramPrefix = ""
                if parameterType.byref == 1 then
                    if bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_OUT) ~= 0 and bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_IN) == 0 then
                        paramPrefix = "out "
                    elseif bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_OUT) == 0 and bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_IN) ~= 0 then
                        paramPrefix = "in "
                    else
                        paramPrefix = "ref "
                    end
                else
                    if bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_IN) ~= 0 then
                        paramPrefix = paramPrefix .. "[In] "
                    end
                    if bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_OUT) ~= 0 then
                        paramPrefix = paramPrefix .. "[Out] "
                    end
                end
                local paramStr = paramPrefix .. parameterTypeName .. " " .. parameterName
                local paramDefault = Il2Cpp.Meta:GetParameterDefaultValueFromIndex(methodDefs.parameterStart + j - 1)
                if paramDefault and paramDefault.dataIndex ~= -1 then
                    local success, value = Il2Cpp.Meta:TryGetDefaultValue(paramDefault.typeIndex, paramDefault.dataIndex)
                    if success then
                        paramStr = paramStr .. " = "
                        if type(value) == "string" then
                            paramStr = paramStr .. string.format("\"%s\"", value:gsub("[\"\\]", "\\%0"))
                        elseif type(value) == "number" and math.floor(value) == value then
                            paramStr = paramStr .. string.format("\\x%x", value)
                        elseif value ~= nil then
                            paramStr = paramStr .. tostring(value)
                        else
                            paramStr = paramStr .. "null"
                        end
                    else
                        paramStr = paramStr .. string.format(" /*Metadata offset 0x%x*/", value)
                    end
                end
                table.insert(parameterStrs, paramStr)
            end
            local methodBody = isAbstract and ";" or " { }"
            table.insert(output, string.format("\t%s%s%s %s(%s)%s", modifiers, returnPrefix, tostring(methodReturnType), methodName, table.concat(parameterStrs, ", "), methodBody))
            
            -- Dump generic method specs
            -- tạm thời bỏ qua vì tốn nhiều thời gian 
            local methodIndex = methodDef:GetIndex()
            if Il2Cpp.methodDefinitionMethodSpecs[methodIndex] then
                table.insert(output, "\t/* GenericInstMethod :")
                local groups = {}
                for _, methodSpec in ipairs(Il2Cpp.methodDefinitionMethodSpecs[methodIndex]) do
                    local ptr = Il2Cpp.methodSpecGenericMethodPointers[methodSpec.methodDefinitionIndex .. ":" .. methodSpec.classIndexIndex .. ":" .. methodSpec.methodIndexIndex] or 0
                    if not groups[ptr] then
                        groups[ptr] = {}
                    end
                    table.insert(groups[ptr], methodSpec)
                end
                for ptr, group in pairs(groups) do
                    table.insert(output, "\t|")
                    if ptr > 0 then
                        local fixedPointer = ptr - Il2Cpp.il2cppStart
                        table.insert(output, string.format("\t|-RVA: 0x%x Offset: 0x%x VA: 0x%x", fixedPointer, fixedPointer, ptr))
                    else
                        table.insert(output, "\t|-RVA: -1 Offset: -1")
                    end
                    for _, methodSpec in ipairs(group) do
                        local typeName, methodName = Il2Cpp.Meta:GetMethodSpecName(methodSpec)
                        table.insert(output, string.format("\t|-%s.%s", typeName, methodName))
                    end
                end
                table.insert(output, "\t*/")
            end-- ]]
        end
    end
    table.insert(output, "}")
    return table.concat(output, "\n")
end

return Dump


end)__bundle_register("Universalsearcher", function(require, _LOADED, __bundle_register, __bundle_modules)
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
        local gmt =Il2Cpp.Meta.metaStart--gg.getRangesList("global-metadata.dat");
	    --local gmt = ((gmt and #gmt > 0) and gmt[1].start) or Il2Cpp.Meta.metaStart
	    
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
end)
return __bundle_require("Il2CppGG")