---@class Method
---Module for handling Il2Cpp method operations and metadata
local Method = require "Hook"
local Patch = require "Patch"
-- Version-specific constants for method parameter handling
--Method.parameterStart = Il2Cpp.Version >= 31 and 16 or 12
--Method.parameterSize = Il2Cpp.Version <= 24 and 16 or 12

Method.DumpParamValues = true

---Get the name of a method
-- @param method table The method object
-- @return string Method name
function Method.GetName(method)
    return method.name
end

function Method.SetValue(method, value)
    local func = Patch:setValues(method.methodPointer, value, method:GetReturnType().type)
    function method.RestoreValue()
        func()
        method.RestoreValue = nil
    end
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
    --[[
    local param = Il2Cpp.classArray(method.parameters, Method.GetParamCount(method), Il2Cpp.Version > 27 and "Pointer" or Il2Cpp.ParameterInfo)
    for i, v in ipairs(param) do
        local il2cppType, name, token
        if Il2Cpp.Version > 27 then
            il2cppType = v--Il2Cpp.Type(v)
            local param = Il2Cpp.Meta:GetParameterDefinition(methodDef.parameterStart + (i - 0))  
            --local addr = Il2Cpp.Meta.Header.parametersOffset + (methodDef.parameterStart + i - 1)
            name = Il2Cpp.Meta:GetStringFromIndex(param.nameIndex)--Il2Cpp.gV(addr, 4))
            token = param.token--Il2Cpp.gV(addr + 4, 4)
        else 
            il2cppType = v.parameter_type--Il2Cpp.Type(v.parameter_type)
            name = v.name
            token = v.token
        end
        method.parameters[i] = setmetatable({
            typeIndex = il2cppType,
            name = name,
            token = token
        }, {
            __index = Il2Cpp.Param
        })
    end
    ]]
    method.parameters = {}
    -- [==[
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
    --]==]
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

function Method.ToString(method)
    local output = {}
    local methodDef = method
    
    local methodDefs = methodDef.parameters_count ~= 0 and Il2Cpp.Il2CppMethodDefinition(methodDef.methodMetadataHandle or methodDef.methodDefinition)
    local isAbstract = bit32.band(methodDef.flags, Il2Cpp.Il2CppConstants.METHOD_ATTRIBUTE_ABSTRACT) ~= 0
    
    
    local methodPointer = Il2Cpp.FixValue(methodDef.methodPointer)
    if not isAbstract and methodPointer > 0 then
        local fixedMethodPointer = methodDef.address
        table.insert(output, string.format("\t// RVA: 0x%x Offset: 0x%x VA: 0x%x", fixedMethodPointer, methodPointer  - Il2Cpp.il2cppStart, methodPointer))
    else
        table.insert(output, "\t// RVA: -1 Offset: -1")
    end
    if methodDef.slot ~= -1 then
        table.insert(output, string.format(" Slot: %d", methodDef.slot))
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
    for j = 0, methodDef.parameters_count - 1 do
        local parameterDef = Il2Cpp.Param(methodDefs.parameterStart + j)
        local parameterName = parameterDef:GetName()
        local parameterType = parameterDef:GetType()
        local parameterTypeName = parameterType:GetName()
        local paramPrefix = ""
        if parameterType.byref == 1 then
            if bit32.band(parameterType.attrs, Il2Cpp.Il2CppConstants.PARAM_ATTRIBUTE_OUT) ~= 0 and bit32.band(parameterType.attrs, Il2Cpp.Il2CppConstants.PARAM_ATTRIBUTE_IN) == 0 then
                paramPrefix = "out "
            elseif bit32.band(parameterType.attrs, Il2Cpp.Il2CppConstants.PARAM_ATTRIBUTE_OUT) == 0 and bit32.band(parameterType.attrs, Il2Cpp.Il2CppConstants.PARAM_ATTRIBUTE_IN) ~= 0 then
                paramPrefix = "in "
            else
                paramPrefix = "ref "
            end
        else
            if bit32.band(parameterType.attrs, Il2Cpp.Il2CppConstants.PARAM_ATTRIBUTE_IN) ~= 0 then
                paramPrefix = paramPrefix .. "[In] "
            end
            if bit32.band(parameterType.attrs, Il2Cpp.Il2CppConstants.PARAM_ATTRIBUTE_OUT) ~= 0 then
                paramPrefix = paramPrefix .. "[Out] "
            end
        end
        local paramStr = paramPrefix .. parameterTypeName .. " " .. parameterName
        if Il2Cpp.Method.DumpParamValues then
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
        end
        table.insert(parameterStrs, paramStr)
    end
    local methodBody = isAbstract and ";" or " { }"
    table.insert(output, string.format("\t%s%s%s %s(%s)%s", modifiers, returnPrefix, tostring(methodReturnType), methodName, table.concat(parameterStrs, ", "), methodBody))
    return table.concat(output, "\n")
end 


function Method:AddList()
    Il2Cpp.aL(self.address, self:ToString())
end

---Create a Method object from address or name
-- @param searchParams number|string|table Address of the method info or name or table address name
-- @param addList any Additional parameter (unused in current implementation)
-- @return table Method object
function Method:From(searchParams, addList)
    local method = {}
    if type(searchParams) == "string" or type(searchParams) == "table" then
        local res = type(searchParams) == "table" and searchParams or Il2Cpp.Meta.GetPointersToString(searchParams)
        for i, v in ipairs(res) do
            local addr = Il2Cpp.GetPtr(v.address + (Il2Cpp.pointSize * 1))
            local IsClass = Il2Cpp.Class.IsClassInfo(addr)
            local addr = Il2Cpp.GetPtr(v.address + (Il2Cpp.pointSize * 2))
            local IsType = Il2Cpp.Type(addr)
            if IsClass and IsType then
                v.address = v.address - (Il2Cpp.Version < 29 and Il2Cpp.pointSize * 2 or Il2Cpp.pointSize * 3)
                local kls = Il2Cpp.MethodInfo(v.address, addList)
                kls.address = v.address
                local res = setmetatable(kls, {
                    __index = Method,
                    __name = kls.name
                })
                method[#method+1] = res
            end
        end
    else
        method = Il2Cpp.MethodInfo(searchParams, addList)
        method.address = searchParams
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