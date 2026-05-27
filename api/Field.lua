---@class Field
---Module for handling Il2Cpp field operations and metadata
local Field = {
    DumpFieldValues = true
}

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
    if type(field.parent) == "table" then
        return field.parent
    end
    field.parent = Il2Cpp.Class(field.parent)
    return field.parent
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
    if type(field.type) == "table" then
        return field.type
    end
    field.type = Il2Cpp.Type(field.type)
    return field.type
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
    if bit32.band(field.type.attrs, 0x0010) == 0 then -- FIELD_ATTRIBUTE_STATIC
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
    local address = field:GetParent().static_fields + field.offset
    local tInfo = Il2Cpp.type[tostring(field:GetType())]
    local result = {{address = address, flags = tInfo and tInfo.flags or Il2Cpp.MainType, name = field:GetName()}}
    return Il2Cpp.gV(result), result
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


function Field.GetIndex(field, typeDefs)
    local typeDef = field:GetParent()
    local _, i = typeDef:GetField(field:GetName())
    local typeDefs = typeDefs or Il2Cpp.Il2CppTypeDefinition(typeDef:GetTypeDef())
    return typeDefs.fieldStart + i
end

function Field.AddList(field)
   Il2Cpp.aL(field.address, field:ToString())
end


function Field.ToString(field, fieldIndex)
    local output = {}
    local fieldDef = field
    local fieldType = fieldDef:GetType()
    local isStatic = false
    local isConst = false
    local access = bit32.band(fieldType.attrs, Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_FIELD_ACCESS_MASK)
    local accessStr = ""
    if access == Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_PRIVATE then
        accessStr = "private "
    elseif access == Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_PUBLIC then
        accessStr = "public "
    elseif access == Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_FAMILY then
        accessStr = "protected "
    elseif access == Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_ASSEMBLY or access == Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_FAM_AND_ASSEM then
        accessStr = "internal "
    elseif access == Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_FAM_OR_ASSEM then
        accessStr = "protected internal "
    end
    if bit32.band(fieldType.attrs, Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_LITERAL) ~= 0 then
        isConst = true
        accessStr = accessStr .. "const "
    else
        if bit32.band(fieldType.attrs, Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_STATIC) ~= 0 then
            isStatic = true
            accessStr = accessStr .. "static "
        end
        if bit32.band(fieldType.attrs, Il2Cpp.Il2CppConstants.FIELD_ATTRIBUTE_INIT_ONLY) ~= 0 then
            accessStr = accessStr .. "readonly "
        end
    end
    local fieldName = fieldDef:GetName()
    local fieldTypeName = tostring(fieldType)
    local defaultValueStr = ""
    
    if Il2Cpp.Field.DumpFieldValues and isConst then
        if not fieldIndex then
            local typeDefs = Il2Cpp.Il2CppTypeDefinition(fieldDef:GetParent():GetTypeDef())
            fieldIndex = fieldDef:GetIndex(typeDefs)
        end
        local fieldDefaultValue = Il2Cpp.Meta:GetFieldDefaultValueFromIndex(fieldIndex)
        if fieldDefaultValue and fieldDefaultValue.dataIndex ~= -1 then
            local success, value = Il2Cpp.Meta:TryGetDefaultValue(fieldDefaultValue.typeIndex, fieldDefaultValue.dataIndex)
            if success then
                defaultValueStr = " = "
                if type(value) == "string" then
                    defaultValueStr = defaultValueStr .. string.format("\"%s\"", value:gsub("[\"\\]", "\\%0"))
                elseif type(value) == "number" and math.floor(value) == value then
                    defaultValueStr = defaultValueStr .. value--string.format("\\x%x", value)
                elseif value ~= nil then
                    defaultValueStr = defaultValueStr .. tostring(value)
                else
                    defaultValueStr = defaultValueStr .. "null"
                end
            else
                defaultValueStr = string.format(" /*Metadata offset 0x%x*/", value)
            end
        end
    end
    local offsetStr = ""
    if not isConst then
        offsetStr = string.format("; // 0x%x", fieldDef:GetOffset())
    else
        offsetStr = ";"
    end
    table.insert(output, string.format("\t%s%s %s%s%s", accessStr, fieldTypeName, fieldName, defaultValueStr, offsetStr))
    return table.concat(output, "\n")
end


---Create a Field object from address or name
-- @param searchParams string|number|table Field name or address or table address
-- @return table Field object or array of field objects
function Field:From(searchParams)
    if Il2Cpp.__cache.Field[searchParams] then return Il2Cpp.__cache.Field[searchParams] end
    local field = {}
    local typeSearchParams = type(searchParams)
    if typeSearchParams == "string" or typeSearchParams == "table" then
        local res = typeSearchParams == "table" and searchParams or Il2Cpp.Meta.GetPointersToString(searchParams)
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
    elseif typeSearchParams == "number" then
        field = Il2Cpp.FieldInfo(searchParams)
        field.address = searchParams
        return setmetatable(field, {
            __index = Field,
            __name = field.name
        })
    else
        Il2Cpp.log:error("Il2Cpp.Field(searchParams): param searchParams string|number|table Field name or address or table address")
    end
    Il2Cpp.__cache.Field[searchParams] = field
    return field--#field == 1 and field[1] or field
end

return setmetatable(Field, {
    ---Metatable call handler for Field
    -- Allows Field to be called as a function
    -- @param ... any Arguments passed to Field.From
    -- @return table Field object or array of field objects
    __call = Field.From
})
