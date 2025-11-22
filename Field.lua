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
    local tInfo = Il2Cpp.type[tostring(field:GetType())]
    local results = {}
    for i, v in ipairs(obj) do
        results[#results+1] = {address = v.address + field.offset, flags = tInfo and tInfo.flags or Il2Cpp.MainType, name = field.name}
    end
    return gg.getValues(results), results
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
