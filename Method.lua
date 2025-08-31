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