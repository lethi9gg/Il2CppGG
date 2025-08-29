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