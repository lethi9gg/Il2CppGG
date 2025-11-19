---@class Image
---Module for handling Il2Cpp image operations and metadata
local Image = {}

---Create an Image object from name or get all images
-- @param name string|nil Image name to search for (optional)
-- @return table Image object or table of all images
function Image:From(name)
    if not self.__cache then
        if not Il2Cpp.imageSize then
            Il2Cpp.Universalsearcher.Il2CppMetadataRegistration()
        end
        local typeStart = 0
        local addr = Il2Cpp.imageDef
        local typeCountOffset = gg.getValues({{address = addr + (Il2Cpp.pointSize * 3), flags = 4}})[1].value == 0 and (Il2Cpp.pointSize * 3) + 4 or Il2Cpp.pointSize * 3
        self.__cache = {}
        for i = 1, Il2Cpp.imageCount do
            local imageInfo = gg.getValues({
                {address = addr, flags = Il2Cpp.MainType},
                {address = addr + typeCountOffset, flags = 4},
                {address = addr + (Il2Cpp.pointSize * 2), flags = Il2Cpp.MainType}
            })
            local name = Il2Cpp.Utf8ToString(Il2Cpp.FixValue(imageInfo[1].value))
            local check = string.find(name, ".-%.dll") or string.find(name, "__Generated")
            if not check then
                Il2Cpp.imageCount = i 
                break
            end
            self.__cache[i] = setmetatable({
                index = i,
                typeCount = imageInfo[2].value,
                typeStart = typeStart,
                name = name,
                assembly = imageInfo[3].value
            }, {__index = Image})
            typeStart = typeStart + imageInfo[2].value
            addr = addr + Il2Cpp.imageSize
        end
    end
    if name then
        for i, v in ipairs(self.__cache) do
            if v.name == name or v.name == (name .. ".dll") then
                return v
            end
        end
    else
        return self.__cache
    end
end

---Get the name of an image
-- @param image table The image object
-- @return string Image name
function Image.GetName(image)
    return image.name
end

---Get the file name of an image
-- @param image table The image object
-- @return string Image file name
function Image.GetFileName(image)
    return image.name
end

---Get the assembly of an image
-- @param image table The image object
-- @return number Assembly pointer
function Image.GetAssembly(image)
    return image.assembly
end

---Get the entry point of an image
-- @param image table The image object
-- @return table|nil Method object if entry point exists, nil otherwise
function Image.GetEntryPoint(image)
    local method = Il2Cpp.il2cpp_image_get_entry_point(image)
    return method ~= 0 and Il2Cpp.MethodInfo(method) or nil
end

---Get the corlib image
-- @return table Corlib image object
function Image.GetCorlib()
    return Il2Cpp.il2cpp_get_corlib()
end

---Get the number of types in an image
-- @param image table The image object
-- @return number Number of types
function Image.GetNumTypes(image)
    return image.typeCount
end

---Get a type by index from an image
-- @param image table The image object
-- @param index number Type index
-- @return table|nil Class object if found, nil otherwise
function Image.GetType(image, index)
    if index >= image.typeCount then
        return nil
    end
    local handle = Il2Cpp.GetPtr(Il2Cpp.typeDef + (image.typeStart + index) * Il2Cpp.pointSize)
    return handle ~= 0 and Il2Cpp.Class(handle) or nil
end

---Get all types from an image
-- @param image table The image object
-- @param exportedOnly boolean Whether to return only exported types
-- @return table Array of class objects
function Image.GetTypes(image, exportedOnly)
    local types = {}
    for i = 0, image.typeCount - 1 do
        local type = Image.GetType(image, i)
        if type and type.name ~= "<Module>" then
            if not exportedOnly or Image.IsExported(type) then
                types[#types + 1] = type
            end
        end
    end
    return types
end

---Check if a type is exported
-- @param type table The class object
-- @return boolean True if the type is exported
function Image.IsExported(type)
    local flags = Class.GetFlags(type)
    local visibility = bit32.band(flags, 0x0007) -- TYPE_ATTRIBUTE_VISIBILITY_MASK
    if visibility == 0x0001 then -- TYPE_ATTRIBUTE_PUBLIC
        return true
    elseif visibility == 0x0004 then -- TYPE_ATTRIBUTE_NESTED_PUBLIC
        local parent = Class.GetParent(type)
        return parent and Image.IsExported(parent)
    end
    return false
end

---Find a class by namespace and name in an image
-- @param image table The image object
-- @param namespace string Namespace of the class
-- @param name string Name of the class
-- @return table|nil Class object if found, nil otherwise
function Image.Class(image, namespace, name)
    local key = (namespace or "") .. "." .. name
    if not image.nameToClassHashTable or image.typeCount > image.countHashTable then
        image.nameToClassHashTable = image.nameToClassHashTable or {}
        image.countHashTable = image.countHashTable or 0
        Image.InitNameToClassHashTable(image, key)
    end
    
    return Il2Cpp.Class(image.nameToClassHashTable[key])
end

---Find a class from type name parse info
-- @param image table The image object
-- @param parseInfo table Parsed type information
-- @param ignoreCase boolean Whether to ignore case when matching names
-- @return table|nil Class object if found, nil otherwise
function Image.FromTypeNameParseInfo(image, parseInfo, ignoreCase)
    local ns = parseInfo.ns or ""
    local name = parseInfo.name or ""
    local klass = Image.Class(image, ns, name)
    if not klass then
        -- Search in exported types if not found
        for i = 0, image.exportedTypeCount - 1 do
            local handle = Il2Cpp.il2cpp_assembly_get_exported_type_handle(image, i)
            if handle ~= 0 then
                local typeNs, typeName = Il2Cpp.il2cpp_type_get_namespace_and_name(handle)
                if (ignoreCase and string.lower(typeNs) == string.lower(ns) and string.lower(typeName) == string.lower(name)) or
                   (typeNs == ns and typeName == name) then
                    klass = Il2Cpp.Il2CppClass(handle)
                    break
                end
            end
        end
    end
    if not klass then
        return nil
    end

    local nested = parseInfo.nested or {}
    for _, nestedName in ipairs(nested) do
        local found = false
        for _, nestedType in ipairs(Class.GetNestedTypes(klass)) do
            local typeName = nestedType.name
            if (ignoreCase and string.lower(typeName) == string.lower(nestedName)) or typeName == nestedName then
                klass = nestedType
                found = true
                break
            end
        end
        if not found then
            return nil
        end
    end
    return klass
end

---Get the executing image from the current stack
-- @return table Executing image object
function Image.GetExecutingImage()
    local stack = Il2Cpp.il2cpp_stack_frames()
    for _, frame in ipairs(stack) do
        local klass = frame.method.klass
        if klass.image and not Image.IsSystemType(klass) and not Image.IsSystemReflectionAssembly(klass) then
            return klass.image
        end
    end
    return Image.GetCorlib()
end

---Get the calling image from the current stack
-- @return table Calling image object
function Image.GetCallingImage()
    local stack = Il2Cpp.il2cpp_stack_frames()
    local foundFirst = false
    for _, frame in ipairs(stack) do
        local klass = frame.method.klass
        if klass.image and not Image.IsSystemType(klass) and not Image.IsSystemReflectionAssembly(klass) then
            if foundFirst then
                return klass.image
            end
            foundFirst = true
        end
    end
    return Image.GetCorlib()
end

---Check if a class is System.Type
-- @param klass table The class object
-- @return boolean True if the class is System.Type
function Image.IsSystemType(klass)
    return klass.namespaze == "System" and klass.name == "Type"
end

---Check if a class is System.Reflection.Assembly
-- @param klass table The class object
-- @return boolean True if the class is System.Reflection.Assembly
function Image.IsSystemReflectionAssembly(klass)
    return klass.namespaze == "System.Reflection" and klass.name == "Assembly"
end

---Initialize name to class hash table for an image
-- @param image table The image object
-- @param key string The key to search for
function Image.InitNameToClassHashTable(image, key)
    if image.nameToClassHashTable[key] then
        return
    end
    for i = image.countHashTable, image.typeCount - 1 do
        local index = Il2Cpp.typeDef + (image.typeStart + i) * Il2Cpp.pointSize
        local klass = Il2Cpp.GetPtr(index)
        if klass ~= 0 then
            local ns, name = Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(klass + (Il2Cpp.pointSize * 3))), Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(klass + (Il2Cpp.pointSize * 2))):gsub("<.*", "")
            image.nameToClassHashTable[ns .. "." .. name] = klass
            image.countHashTable = i + 1
            if image.nameToClassHashTable[key] then
                return klass
            end
        end
    end
end

---Add nested types to hash table for an image
-- @param image table The image object
-- @param handle number Class handle
-- @param namespaze string Namespace of the class
-- @param parentName string Name of the parent class
function Image.AddNestedTypesToHashTable(image, handle, namespaze, parentName)
    local iter = 0
    while true do
        local nested = Il2Cpp.il2cpp_get_nested_types(handle, iter)
        if nested == 0 then break end
        local ns, name = Il2Cpp.il2cpp_type_get_namespace_and_name(nested)
        local fullName = parentName .. "/" .. name
        image.nameToClassHashTable[ns .. "." .. fullName] = nested
        Image.AddNestedTypesToHashTable(image, nested, ns, fullName)
        iter = iter + 1
    end
end

---Initialize nested types for an image
-- @param image table The image object
function Image.InitNestedTypes(image)
    for i = 0, image.typeCount - 1 do
        local handle = Il2Cpp.il2cpp_assembly_get_type_handle(image, i)
        if handle ~= 0 and not Il2Cpp.il2cpp_type_is_nested(handle) then
            Image.AddNestedTypesToHashTable(image, handle, Il2Cpp.il2cpp_type_get_namespace_and_name(handle))
        end
    end
    for i = 0, image.exportedTypeCount - 1 do
        local handle = Il2Cpp.il2cpp_assembly_get_exported_type_handle(image, i)
        if handle ~= 0 and not Il2Cpp.il2cpp_type_is_nested(handle) then
            Image.AddNestedTypesToHashTable(image, handle, Il2Cpp.il2cpp_type_get_namespace_and_name(handle))
        end
    end
end

---Get cached resource data from an image
-- @param image table The image object
-- @param name string Resource name
-- @return any|nil Resource data if found, nil otherwise
function Image.GetCachedResourceData(image, name)
    local data = Il2Cpp.il2cpp_get_cached_resource_data(image, name)
    return data or nil
end

---Clear cached resource data
function Image.ClearCachedResourceData()
    Il2Cpp.il2cpp_clear_cached_resource_data()
end

return setmetatable(Image, {
    ---Metatable call handler for Image
    -- Allows Image to be called as a function
    -- @param ... any Arguments passed to Image.From
    -- @return table Image object or table of image objects
    __call = Image.From
})