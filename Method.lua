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