function Dump(typeDef, config)
    local Il2CppConstants = Il2Cpp.Il2CppConstants
    local config = config or {
        DumpAttribute = false,
        DumpField = true,
        DumpProperty = true,
        DumpMethod = true,
        DumpFieldOffset = true,
        DumpMethodOffset = true,
        DumpTypeDefIndex = true,
    }
    local output = {}
    local extends = {}
    
    local typeDefs = Il2Cpp.Il2CppTypeDefinition(typeDef.typeMetadataHandle or typeDef.typeDefinition)
    local typeDefIndex = typeDef:GetIndex()
    
    if typeDef.parent >= 0 then
        local parent = typeDef:GetParent()
        local parentName = parent:GetName()
        if not typeDef:IsValueType() and not typeDef:IsEnum() and parentName ~= "object" then
            table.insert(extends, parentName)
        end
    end
    if typeDef.interfaces_count > 0 then
        for i, interface in ipairs(typeDef:GetInterfaces()) do
            table.insert(extends, interface:GetName())
        end
    end
    table.insert(output, string.format("\n// Namespace: %s", typeDef:GetNamespace()))
    
    
    local visibility = bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_VISIBILITY_MASK)
    local visibilityStr = ""
    if visibility == Il2CppConstants.TYPE_ATTRIBUTE_PUBLIC or visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_PUBLIC then
        visibilityStr = "public "
    elseif visibility == Il2CppConstants.TYPE_ATTRIBUTE_NOT_PUBLIC or visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAM_AND_ASSEM or visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_ASSEMBLY then
        visibilityStr = "internal "
    elseif visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_PRIVATE then
        visibilityStr = "private "
    elseif visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAMILY then
        visibilityStr = "protected "
    elseif visibility == Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAM_OR_ASSEM then
        visibilityStr = "protected internal "
    end
    if bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_ABSTRACT) ~= 0 and bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_SEALED) ~= 0 then
        visibilityStr = visibilityStr .. "static "
    elseif bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_INTERFACE) == 0 and bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_ABSTRACT) ~= 0 then
        visibilityStr = visibilityStr .. "abstract "
    elseif not typeDef:IsValueType() and not typeDef:IsEnum() and bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_SEALED) ~= 0 then
        visibilityStr = visibilityStr .. "sealed "
    end
    local typeKind = ""
    if bit32.band(typeDef.flags, Il2CppConstants.TYPE_ATTRIBUTE_INTERFACE) ~= 0 then
        typeKind = "interface "
    elseif typeDef:IsEnum() then
        typeKind = "enum "
    elseif typeDef:IsValueType() then
        typeKind = "struct "
    else
        typeKind = "class "
    end
    local typeName = typeDef:GetName()
    local extendsStr = #extends > 0 and string.format(" : %s", table.concat(extends, ", ")) or ""
    local typeDefIndexStr = config.DumpTypeDefIndex and string.format(" // TypeDefIndex: %d", typeDefIndex - 1) or ""
    table.insert(output, string.format("%s%s%s%s%s\n{", visibilityStr, typeKind, typeName, extendsStr, typeDefIndexStr))
    
    
    -- Dump fields
    if config.DumpField and typeDef.field_count > 0 then
        table.insert(output, "\t// Fields")
        for i, fieldDef in ipairs(typeDef:GetFields()) do
            local fieldType = fieldDef:GetType()
            local isStatic = false
            local isConst = false
            if config.DumpAttribute then
                table.insert(output, self:getCustomAttribute(imageDef, fieldDef.customAttributeIndex, fieldDef.token, "\t"))
            end
            local access = bit32.band(fieldType.attrs, Il2CppConstants.FIELD_ATTRIBUTE_FIELD_ACCESS_MASK)
            local accessStr = ""
            if access == Il2CppConstants.FIELD_ATTRIBUTE_PRIVATE then
                accessStr = "private "
            elseif access == Il2CppConstants.FIELD_ATTRIBUTE_PUBLIC then
                accessStr = "public "
            elseif access == Il2CppConstants.FIELD_ATTRIBUTE_FAMILY then
                accessStr = "protected "
            elseif access == Il2CppConstants.FIELD_ATTRIBUTE_ASSEMBLY or access == Il2CppConstants.FIELD_ATTRIBUTE_FAM_AND_ASSEM then
                accessStr = "internal "
            elseif access == Il2CppConstants.FIELD_ATTRIBUTE_FAM_OR_ASSEM then
                accessStr = "protected internal "
            end
            if bit32.band(fieldType.attrs, Il2CppConstants.FIELD_ATTRIBUTE_LITERAL) ~= 0 then
                isConst = true
                accessStr = accessStr .. "const "
            else
                if bit32.band(fieldType.attrs, Il2CppConstants.FIELD_ATTRIBUTE_STATIC) ~= 0 then
                    isStatic = true
                    accessStr = accessStr .. "static "
                end
                if bit32.band(fieldType.attrs, Il2CppConstants.FIELD_ATTRIBUTE_INIT_ONLY) ~= 0 then
                    accessStr = accessStr .. "readonly "
                end
            end
            local fieldName = fieldDef:GetName()
            local fieldTypeName = tostring(fieldType)
            local defaultValueStr = ""
            
            
            local fieldDefaultValue = Il2Cpp.Meta:GetFieldDefaultValueFromIndex(typeDefs.fieldStart + (i - 1))
            if fieldDefaultValue and fieldDefaultValue.dataIndex ~= -1 then
                local success, value = Il2Cpp.Meta:TryGetDefaultValue(fieldDefaultValue.typeIndex, fieldDefaultValue.dataIndex)
                if success then
                    defaultValueStr = " = "
                    if type(value) == "string" then
                        defaultValueStr = defaultValueStr .. string.format("\"%s\"", value:gsub("[\"\\]", "\\%0"))
                    elseif type(value) == "number" and math.floor(value) == value then
                        defaultValueStr = defaultValueStr .. string.format("\\x%x", value)
                    elseif value ~= nil then
                        defaultValueStr = defaultValueStr .. tostring(value)
                    else
                        defaultValueStr = defaultValueStr .. "null"
                    end
                else
                    defaultValueStr = string.format(" /*Metadata offset 0x%x*/", value)
                end
            end
            local offsetStr = ""
            if config.DumpFieldOffset and not isConst then
                offsetStr = string.format("; // 0x%x", fieldDef:GetOffset())
            else
                offsetStr = ";"
            end
            table.insert(output, string.format("\t%s%s %s%s%s", accessStr, fieldTypeName, fieldName, defaultValueStr, offsetStr))
        end
    end

    -- Dump properties
    if config.DumpProperty and typeDef.property_count > 0 then
        table.insert(output, "\n\t// Properties")
        for i, propertyDef in ipairs(typeDef:GetPropertys()) do
            if config.DumpAttribute then
                table.insert(output, self:getCustomAttribute(imageDef, propertyDef.customAttributeIndex, propertyDef.token, "\t"))
            end
            local propertyType, modifiers
            if propertyDef.get >= 0 then
                local methodDef = Il2Cpp.Method(propertyDef.get)
                modifiers = Il2Cpp:GetModifiers(methodDef)
                propertyType = methodDef:GetReturnType()
            elseif propertyDef.set >= 0 then
                local methodDef = Il2Cpp.Method(propertyDef.set)
                modifiers = Il2Cpp:GetModifiers(methodDef)
                local parameterDef = methodDef:GetParam()
                propertyType = parameterDef:GetType()
            end
            local propertyName = propertyDef.name
            local propertyTypeName = tostring(propertyType)
            local accessors = {}
            if propertyDef.get >= 0 then
                table.insert(accessors, "get; ")
            end
            if propertyDef.set >= 0 then
                table.insert(accessors, "set; ")
            end
            table.insert(output, string.format("\t%s%s %s { %s}", modifiers, propertyTypeName, propertyName, table.concat(accessors)))
        end
    end

    -- Dump methods
    if config.DumpMethod and typeDef.method_count > 0 then
        table.insert(output, "\n\t// Methods")
        for i, methodDef in ipairs(typeDef:GetMethods()) do
            table.insert(output, "")
            local methodDefs = Il2Cpp.Il2CppMethodDefinition(methodDef.methodMetadataHandle or methodDef.methodDefinition)
            local isAbstract = bit32.band(methodDef.flags, Il2CppConstants.METHOD_ATTRIBUTE_ABSTRACT) ~= 0
            if config.DumpAttribute then
                table.insert(output, self:getCustomAttribute(imageDef, methodDef.customAttributeIndex, methodDef.token, "\t"))
            end
            if config.DumpMethodOffset then
                local methodPointer = methodDef.methodPointer
                if not isAbstract and methodPointer > 0 then
                    local fixedMethodPointer = methodDef.address
                    table.insert(output, string.format("\t// RVA: 0x%x Offset: 0x%x VA: 0x%x", fixedMethodPointer, methodPointer  - Il2Cpp.il2cppStart, methodPointer))
                else
                    table.insert(output, "\t// RVA: -1 Offset: -1")
                end
                if methodDef.slot ~= -1 then
                    table.insert(output, string.format(" Slot: %d", methodDef.slot))
                end
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
            for j, parameterDef in ipairs(methodDef:GetParam()) do
                local parameterName = parameterDef:GetName()
                local parameterType = parameterDef:GetType()
                local parameterTypeName = parameterType:GetName()
                local paramPrefix = ""
                if parameterType.byref == 1 then
                    if bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_OUT) ~= 0 and bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_IN) == 0 then
                        paramPrefix = "out "
                    elseif bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_OUT) == 0 and bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_IN) ~= 0 then
                        paramPrefix = "in "
                    else
                        paramPrefix = "ref "
                    end
                else
                    if bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_IN) ~= 0 then
                        paramPrefix = paramPrefix .. "[In] "
                    end
                    if bit32.band(parameterType.attrs, Il2CppConstants.PARAM_ATTRIBUTE_OUT) ~= 0 then
                        paramPrefix = paramPrefix .. "[Out] "
                    end
                end
                local paramStr = paramPrefix .. parameterTypeName .. " " .. parameterName
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
                table.insert(parameterStrs, paramStr)
            end
            local methodBody = isAbstract and ";" or " { }"
            table.insert(output, string.format("\t%s%s%s %s(%s)%s", modifiers, returnPrefix, tostring(methodReturnType), methodName, table.concat(parameterStrs, ", "), methodBody))
            
            -- Dump generic method specs
            -- tạm thời bỏ qua vì tốn nhiều thời gian 
            local methodIndex = methodDef:GetIndex()
            if Il2Cpp.methodDefinitionMethodSpecs[methodIndex] then
                table.insert(output, "\t/* GenericInstMethod :")
                local groups = {}
                for _, methodSpec in ipairs(Il2Cpp.methodDefinitionMethodSpecs[methodIndex]) do
                    local ptr = Il2Cpp.methodSpecGenericMethodPointers[methodSpec.methodDefinitionIndex .. ":" .. methodSpec.classIndexIndex .. ":" .. methodSpec.methodIndexIndex] or 0
                    if not groups[ptr] then
                        groups[ptr] = {}
                    end
                    table.insert(groups[ptr], methodSpec)
                end
                for ptr, group in pairs(groups) do
                    table.insert(output, "\t|")
                    if ptr > 0 then
                        local fixedPointer = ptr - Il2Cpp.il2cppStart
                        table.insert(output, string.format("\t|-RVA: 0x%x Offset: 0x%x VA: 0x%x", fixedPointer, fixedPointer, ptr))
                    else
                        table.insert(output, "\t|-RVA: -1 Offset: -1")
                    end
                    for _, methodSpec in ipairs(group) do
                        local typeName, methodName = Il2Cpp.Meta:GetMethodSpecName(methodSpec)
                        table.insert(output, string.format("\t|-%s.%s", typeName, methodName))
                    end
                end
                table.insert(output, "\t*/")
            end-- ]]
        end
    end
    table.insert(output, "}")
    return table.concat(output, "\n")
end

return Dump

