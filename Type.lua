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