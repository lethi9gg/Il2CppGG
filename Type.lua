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