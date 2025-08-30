---@class Class
---Module for handling Il2Cpp class operations and metadata
local Class = {}

---Get the name of a class, handling generic classes with type parameters
-- @param klass table The class object
-- @return string The class name with generic parameters if applicable
function Class.GetName(klass)
    local Name = klass.name
    local index = Name:find("`")
    if index then
        Name = Name:sub(1, index - 1)
        local index = klass.genericContainerIndex or klass.genericContainerHandle
        local genericContainer = Il2Cpp.Meta:GetGenericContainer(index)
        local genericParameterStart = genericContainer.genericParameterStart
        local type_argc = {}
        for i = 0, genericContainer.type_argc - 1 do
            local genericParameter = Il2Cpp.Meta:GetGenericParameter(genericParameterStart + i)
            type_argc[#type_argc+1] = Il2Cpp.Meta:GetStringFromIndex(genericParameter.nameIndex)
        end
        Name = Name .. "<" ..table.concat(type_argc, ", ") .. ">"
    end
    return Name
end

---Get the namespace of a class
-- @param klass table The class object
-- @return string The class namespace
function Class.GetNamespace(klass)
    return klass.namespaze
end

---Get the image (assembly) of a class
-- @param klass table The class object
-- @return string The image name containing the class
function Class.GetImage(klass)
    return Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(klass.image))
end

---Get the parent class of a class
-- @param klass table The class object
-- @return table Parent class object
function Class.GetParent(klass)
    return Class(klass.parent)
end

---Get all fields of a class
-- @param klass table The class object
-- @return table Array of field objects
function Class.GetFields(klass)
    if type(klass.fields) == "table" then return klass.fields end
    local fields = {}
    local iter = 0
    local field
    while iter < klass.field_count do
        field = Il2Cpp.Field(klass.fields + iter * Il2Cpp.FieldInfo.size)
        field.type = field:GetType()
        fields[#fields + 1] = field
        iter = iter + 1
    end
    klass.fields = fields
    return fields
end

---Find a field by name in a class
-- @param klass table The class object
-- @param name string The field name to search for
-- @return table|nil Field object if found, nil otherwise
function Class.GetField(klass, name)
    for _, field in ipairs(klass:GetFields()) do
        if field:GetName() == name then
            return field
        end
    end
    return nil
end

---Get all methods of a class
-- @param klass table The class object
-- @return table Array of method objects
function Class.GetMethods(klass)
    if type(klass.methods) == "table" then return klass.methods end
    local methods = {}
    local iter = 0
    local method
    while iter < klass.method_count do
        method = Il2Cpp.Method(Il2Cpp.gV(klass.methods + iter * Il2Cpp.pointSize, Il2Cpp.pointer))
        method.parameters = method:GetParam()
        method.return_type = method:GetReturnType()
        methods[#methods + 1] = method
        iter = iter + 1
    end
    klass.methods = methods
    return methods
end

---Find a method by name and parameter count in a class
-- @param klass table The class object
-- @param name string The method name to search for
-- @param paramCount number|nil The number of parameters (optional)
-- @return table|nil Method object if found, nil otherwise
function Class.GetMethod(klass, name, paramCount)
    for _, method in ipairs(klass:GetMethods()) do
        if method:GetName() == name and (not paramCount or method.parameters_count == paramCount) then
            return method
        end
    end
    return nil
end

---Check if a class is generic
-- @param klass table The class object
-- @return boolean True if the class is generic
function Class.IsGeneric(klass)
    return klass.is_generic ~= 0
end

---Check if a class is an inflated generic instance
-- @param klass table The class object
-- @return boolean True if the class is an inflated generic
function Class.IsInflated(klass)
    return klass.generic_class ~= 0
end

---Check if a class is a nested type
-- @param klass table The class object
-- @return boolean True if the class is nested
function Class.IsNested(klass)
    return klass.nested_type_count ~= 0
end

---Get the instance size of a class
-- @param klass table The class object
-- @return number The size of class instances in bytes
function Class.GetInstanceSize(klass)
    return klass.instance_size
end

---Find all instances of a class in memory
-- @param klass table The class object
-- @return table Array of object instances
function Class.GetInstance(klass)
    return Il2Cpp.Object:FindObjects(klass.address)
end

---Get all interfaces implemented by a class
-- @param klass table The class object
-- @return table Array of interface class objects
function Class.GetInterfaces(klass)
    local interfaces = {}
    local iter = 0
    local interface
    while true do
        interface = Il2Cpp.gV(klass.implementedInterfaces + iter * Il2Cpp.pointSize, Il2Cpp.pointer)
        if interface == 0 then break end
        interfaces[#interfaces + 1] = Il2Cpp.Il2CppClass(interface)
        iter = iter + 1
    end
    return interfaces
end

---Get the type definition index of a class
-- @param klass table The class object
-- @return number|nil The type definition index if found, nil otherwise
function Class.GetIndex(klass)
    local index = klass.byval_arg.data
    if Il2Cpp.Meta.Header.typeDefinitionsOffset <= index and (Il2Cpp.Meta.Header.typeDefinitionsOffset + Il2Cpp.Meta.Header.typeDefinitionsSize) >= index then
        return (index - Il2Cpp.Meta.Header.typeDefinitionsOffset) / Il2Cpp.typeSize
    elseif index <= Il2Cpp.typeCount then
        return index
    end
end

---Get pointers to a class by its index
-- @param index number The class index
-- @return number|nil The class pointer if found, nil otherwise
function Class.GetPointersToIndex(index)
    if Il2Cpp.Meta.Header.typeDefinitionsOffset <= index and (Il2Cpp.Meta.Header.typeDefinitionsOffset + Il2Cpp.Meta.Header.typeDefinitionsSize) >= index then
        index = (index - Il2Cpp.Meta.Header.typeDefinitionsOffset) / Il2Cpp.typeSize
    elseif index > Il2Cpp.typeCount then
        return index
    end
    return Il2Cpp.GetPtr(Il2Cpp.typeDef + (index * Il2Cpp.pointSize))
end

---Cache for class information checks
Class.IsClassCache = {}

---Check if an address points to valid class information
-- @param Address number Memory address to check
-- @return string|nil Image name if valid class, nil otherwise
function Class.IsClassInfo(Address)
    if Class.IsClassCache[Address] then
        return Class.IsClassCache[Address]
    end
    local imageAddress = Il2Cpp.FixValue(gg.getValues(
        {
            {
                address = Il2Cpp.FixValue(Address),
                flags = Il2Cpp.pointer
            }
        }
    )[1].value)
    local imageStr = Il2Cpp.Utf8ToString(Il2Cpp.FixValue(gg.getValues(
        {
            {
                address = imageAddress,
                flags = Il2Cpp.pointer
            }
        }
    )[1].value))
    local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
    Class.IsClassCache[Address] = check and imageStr or nil
    return Class.IsClassCache[Address]
end

---Name offset based on platform architecture
Class.NameOffset = (Il2Cpp.x64 and 0x10 or 0x8)

---Cache for class objects
Class.__cache = {}

---Create a class object from address, name, or index
-- @param addr_name_index string|number Address, name, or index of the class
-- @param add any Additional parameter (unused in current implementation)
-- @return table Class object or array of class objects
function Class:From(addr_name_index, add)
    if self.__cache[addr_name_index] then return self.__cache[addr_name_index] end
    
    local klass = {}
    if type(addr_name_index) == "string" then
        local res = Il2Cpp.Meta.GetPointersToString(addr_name_index)
        for i, v in ipairs(res) do
            local addr = v.address - Class.NameOffset
            local imageName = Class.IsClassInfo(addr)
            if imageName then
                local kls = Il2Cpp.Il2CppClass(addr, add)
                kls.address = addr
                kls.class_index = Class.GetIndex(kls)
                local res = setmetatable(kls, {
                    __index = Class,
                    __name = (kls.namespaze ~= "" and kls.namespaze .. "." or "") .. kls.name
                })
                klass[#klass+1] = res
            end
        end
    else
        local addr = Class.GetPointersToIndex(addr_name_index)
        local kls = Il2Cpp.Il2CppClass(addr, add)
        kls.address = addr
        kls.class_index = Class.GetIndex(kls)
        klass = setmetatable(kls, {
            __index = Class,
            __name = (kls.namespaze ~= "" and kls.namespaze .. "." or "") .. kls.name
        })
    end
    self.__cache[addr_name_index] = #klass == 1 and klass[1] or klass
    return self.__cache[addr_name_index]
end

return setmetatable(Class, {
    ---Metatable call handler for Class
    -- Allows Class to be called as a function
    -- @param ... any Arguments passed to Class.From
    -- @return table Class object or array of class objects
    __call = Class.From
})