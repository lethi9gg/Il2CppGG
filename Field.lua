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