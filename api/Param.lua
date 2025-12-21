---@class Param
---Module for handling Il2Cpp param operations and metadata
local Param = {}

---Get the name of a param
-- @param param table The param object
-- @return string Param name
function Param.GetName(param)
    if not param.name then
        param.name = Il2Cpp.Meta:GetStringFromIndex(param.nameIndex)
    end
    return param.name 
end

---Get the offset of a param
-- @param param table The param object
-- @return number Param offset
function Param.GetToken(param)
    return param.token
end

---Get the type of a param
-- @param param table The param object
-- @return table Type object
function Param.GetType(param)
    if not param.type then
        param.type = Il2Cpp.Type(param.typeIndex)
    end
    return param.type
end

function Param:From(param_index, add)
    local param = Il2Cpp.Meta:GetParameterDefinition(param_index, add)
    --param.index = param_index
    return setmetatable(param, {
        __index = Param,
        __name = 'Param[' .. param_index .. ']',
        __tostring = Param.ToString
    })
end

function Param.ToString(param)
    return tostring(Param.GetType(param)) .. " " .. Param.GetName(param)
end

return setmetatable(Param, {
    __call = Param.From
})