local Image = {}

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

-- Lấy tên image, kiểu "nickname" của image
function Image.GetName(image)
    return image.name
end

-- Lấy tên file của image, như "địa chỉ nhà" của image
function Image.GetFileName(image)
    return image.name
end

-- Lấy assembly của image, tìm "gia đình" của image
function Image.GetAssembly(image)
    return image.assembly
end

-- Lấy entry point, kiểu "cửa chính" của image
function Image.GetEntryPoint(image)
    local method = Il2Cpp.il2cpp_image_get_entry_point(image)
    return method ~= 0 and Il2Cpp.MethodInfo(method) or nil
end

-- Lấy corlib image, image "ông trùm" của hệ thống
function Image.GetCorlib()
    return Il2Cpp.il2cpp_get_corlib()
end

-- Lấy số lượng type trong image, đếm "dân số" class
function Image.GetNumTypes(image)
    return image.typeCount
end

-- Lấy class theo index, lấy "cư dân" thứ i
function Image.GetType(image, index)
    if index >= image.typeCount then
        return nil
    end
    local handle = Il2Cpp.GetPtr(Il2Cpp.typeDef + (image.typeStart + index) * Il2Cpp.pointSize)
    return handle ~= 0 and Il2Cpp.Class(handle) or nil
end

-- Lấy danh sách type, gom hết "dân chúng" trong image
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

-- Check type có phải exported, kiểu "public figure" không
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

-- Tìm class theo namespace và name, như "search Google" trong image
function Image.Class(image, namespace, name)
    local key = (namespace or "") .. "." .. name
    if not image.nameToClassHashTable or image.typeCount > image.countHashTable then
        image.nameToClassHashTable = image.nameToClassHashTable or {}
        image.countHashTable = image.countHashTable or 0
        Image.InitNameToClassHashTable(image, key)
    end
    
    return Il2Cpp.Class(image.nameToClassHashTable[key])
end

-- Tìm class theo thông tin parse, kiểu "search pro" với nested type
function Image.FromTypeNameParseInfo(image, parseInfo, ignoreCase)
    local ns = parseInfo.ns or ""
    local name = parseInfo.name or ""
    local klass = Image.Class(image, ns, name)
    if not klass then
        -- Tìm trong exported types nếu không thấy
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

-- Lấy executing image, tìm image đang "chạy show"
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

-- Lấy calling image, tìm image "gọi điện" cho executing image
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

-- Check class có phải System.Type, kiểu "meta class"
function Image.IsSystemType(klass)
    return klass.namespaze == "System" and klass.name == "Type"
end

-- Check class có phải System.Reflection.Assembly
function Image.IsSystemReflectionAssembly(klass)
    return klass.namespaze == "System.Reflection" and klass.name == "Assembly"
end

-- Khởi tạo nameToClassHashTable, chuẩn bị "danh bạ" class
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
                --print((index - Il2Cpp.typeDef) / Il2Cpp.pointSize)
                return klass
            end
            --Image.AddNestedTypesToHashTable(image, klass, ns, name)
        end
    end
    --[[
    for i = 0, image.exportedTypeCount - 1 do
        local handle = Il2Cpp.il2cpp_assembly_get_exported_type_handle(image, i)
        if handle ~= 0 and not Il2Cpp.il2cpp_type_is_nested(handle) then
            local ns, name = Il2Cpp.il2cpp_type_get_namespace_and_name(handle)
            image.nameToClassHashTable[ns .. "." .. name] = handle
            Image.AddNestedTypesToHashTable(image, handle, ns, name)
        end
    end
    ]]
end

-- Thêm nested types vào hash table, như "đăng ký hộ khẩu" cho nested class
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

-- Khởi tạo nested types, chuẩn bị "gia phả" cho nested class
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

-- Lấy cached resource data, tìm "kho báu" của image
function Image.GetCachedResourceData(image, name)
    -- Giả định Il2Cpp.il2cpp_get_cached_resource_data trả về dữ liệu
    local data = Il2Cpp.il2cpp_get_cached_resource_data(image, name)
    return data or nil
end

-- Xóa cached resource data, dọn dẹp "kho báu"
function Image.ClearCachedResourceData()
    Il2Cpp.il2cpp_clear_cached_resource_data()
end

return setmetatable(Image, {__call = Image.From})