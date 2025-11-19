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
    armType = x64 and 6 or 4,
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

function Il2Cpp.aL(address, name, flags)
	return (type(address) == "table" and gg.addListItems(address)) or gg.addListItems({{address=address,flags=flags or Il2Cpp.MainType, name = name}})
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
    klass.GetSize = function(self)
        return self.size 
    end
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
            fields.AddList = function(self, name)
                local name, list = (name or self.name) .. ":\n", {}
                for i, v in ipairs(res) do 
                    list[i] = {address = v.address, flags = v.flags, name = name .. v.name}
                end
                Il2Cpp.aL(list)
                return res
            end
            if addList then 
                Il2Cpp.aL(res)
            end
            for i, v in ipairs(gg.getValues(res)) do 
                t[self[i].name] = v.flags == 32 and Il2Cpp.FixValue(v.value) or v.value
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

function Il2Cpp.searchPtr(...)
    local config = {...}
    gg.clearResults();
    gg.searchNumber(...);
    
    -- Handle 64-bit Android SDK 30+ special case
    if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
        local addrs = config[1]
        table.remove(config, 1)
        gg.searchNumber(tostring(addrs | 0xB400000000000000), table.unpack(config));
    end
    
    local t = gg.getResults(gg.getResultsCount())
    if #t > 0 then
        gg.clearResults();
        return t
    end
    error(string.format("Không tìm thấy con trỏ tại địa chỉ: 0x%X", config[1]))
end

function Il2Cpp:Developer(config, list, result)
    if config.addList or config.log then 
        local nameList, list = {"End", "Start", "Def", "Reg", "Count", "Size", "Ptr", "ersion"}, list or self
        local results = result or {}
        for key, value in pairs(list) do 
            if type(value) == "number" then
                for i, v in ipairs(nameList) do
                    if key:find(".*" .. v) then
                        if config.log then 
                            Il2Cpp.log:info(key, value)
                        end
                        local name = key .. ((v == "Count" or v == "Size" or v == "ersion") and (": " .. value) or "")
                        local flags = (v == "End" or v == "Start") and gg.TYPE_DWORD or Il2Cpp.MainType
                        local value = v == "End" and value - 1 or value
                        results[#results+1] = {address = value, name = name, flags = flags}
                    end
                end
            elseif key == "Meta" then
                self:Developer(config, value, results)
            end
        end
        if not result and config.addList then
           gg.addListItems(results)
        end
        return results
    elseif config.setUp then
        for key, value in pairs(config.setUp) do
            self[key] = value
        end
        return self
    end
end

Il2Cpp.log = {
    debug = function(self, ...)
        if self.DEBUG then 
            print("[DEBUG]", ...)
        end 
    end,
    info = function(self, name, ...)
        if self.INFO then 
            print("[INFO]" .. name .. ":", ...)
        end 
    end
}

function Il2Cpp:Dumper(config, target)
    local target = target or {}
    if not target.path then 
        local info = gg.getTargetInfo()
        target.path = gg.EXT_STORAGE .. "/" .. info.packageName .. "-" .. info.versionCode .. "-" .. (info.x64 and "64" or "32") .. ".cs"
    end
    local config = config or {
        DumpAttribute = false,
        DumpField = true,
        DumpProperty = true,
        DumpMethod = true,
        DumpFieldOffset = true,
        DumpMethodOffset = true,
        DumpTypeDefIndex = false,
    }
    local output = io.open(target.path, "w")
    local startTime = os.time();
    -- Dump images
    local imageDefs = target.image or self.Image()
    for i, imageDef in ipairs(imageDefs) do
        output:write(string.format("// Image %d: %s - %d\n", i - 1, imageDef:GetName(), imageDef.typeStart))
    end

    -- Dump types
    for _, imageDef in ipairs(imageDefs) do
        local imageName = imageDef:GetName()
        local typeEnd = imageDef.typeStart + imageDef.typeCount
        for typeDefIndex = imageDef.typeStart, typeEnd do
            output:write(self.Class(typeDefIndex):Dump(config) .. "\n")
        end
    end
    output:close()
    local dumpTimeDiff = os.time() - startTime;
	print(string.format("Dumper Done in %.2f seconds", dumpTimeDiff));
	print("Path:", target.path)
    return path
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
        Il2Cpp._Version = default
        Il2Cpp._Il2CppMethodDefinition = self.Il2CppMethodDefinition
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