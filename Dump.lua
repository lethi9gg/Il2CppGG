function Dump(typeDef, config)
    local Il2CppConstants = Il2Cpp.Il2CppConstants
    local config = config or {
        DumpAttribute = false,
        DumpField = true,
        DumpProperty = true,
        DumpMethod = true,
        DumpFieldOffset = true,
        DumpMethodOffset = true,
        DumpTypeDefIndex = false,
    }
    local output = {}
    local extends = {}
    
    local typeDefs = Il2Cpp.Il2CppTypeDefinition(typeDef.typeMetadataHandle or typeDef.typeDefinition)
    local typeDefIndex = config.DumpTypeDefIndex and typeDef:GetIndex()
    
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
    
    
    local visibility = bit32.band(typeDefs.flags, Il2CppConstants.TYPE_ATTRIBUTE_VISIBILITY_MASK)
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
    if bit32.band(typeDefs.flags, Il2CppConstants.TYPE_ATTRIBUTE_ABSTRACT) ~= 0 and bit32.band(typeDefs.flags, Il2CppConstants.TYPE_ATTRIBUTE_SEALED) ~= 0 then
        visibilityStr = visibilityStr .. "static "
    elseif bit32.band(typeDefs.flags, Il2CppConstants.TYPE_ATTRIBUTE_INTERFACE) == 0 and bit32.band(typeDefs.flags, Il2CppConstants.TYPE_ATTRIBUTE_ABSTRACT) ~= 0 then
        visibilityStr = visibilityStr .. "abstract "
    elseif not typeDef:IsValueType() and not typeDef:IsEnum() and bit32.band(typeDefs.flags, Il2CppConstants.TYPE_ATTRIBUTE_SEALED) ~= 0 then
        visibilityStr = visibilityStr .. "sealed "
    end
    local typeKind = ""
    if bit32.band(typeDefs.flags, Il2CppConstants.TYPE_ATTRIBUTE_INTERFACE) ~= 0 then
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
    local typeDefIndexStr = config.DumpTypeDefIndex and string.format(" // TypeDefIndex: %d", typeDefIndex) or ""
    table.insert(output, string.format("%s%s%s%s%s\n{", visibilityStr, typeKind, typeName, extendsStr, typeDefIndexStr))
    
    
    -- Dump fields
    if config.DumpField and typeDef.field_count > 0 then
        table.insert(output, "\t// Fields")
        for i = 0, typeDef.field_count - 1 do
            local fieldDef = type(typeDef.fields) == "number" and Il2Cpp.Field(typeDef.fields + i * Il2Cpp.FieldInfo.size) or typeDef.fields[i+1]
            table.insert(output, fieldDef:ToString(i))
        end
    end

    -- Dump properties
    if config.DumpProperty and typeDef.property_count > 0 then
        table.insert(output, "\n\t// Properties")
        for i = 0, typeDef.property_count - 1 do
            local propertyDef = Il2Cpp.PropertyInfo(typeDef.properties + i * Il2Cpp.PropertyInfo.size)
            if config.DumpAttribute then
                table.insert(output, self:getCustomAttribute(imageDef, propertyDef.customAttributeIndex, propertyDef.token, "\t"))
            end
            local propertyType, modifiers
            if propertyDef.get ~= 0 then
                local methodDef = Il2Cpp.Method(propertyDef.get)
                modifiers = Il2Cpp:GetModifiers(methodDef)
                propertyType = methodDef:GetReturnType()
            elseif propertyDef.set ~= 0 then
                local methodDef = Il2Cpp.Method(propertyDef.set)
                modifiers = Il2Cpp:GetModifiers(methodDef)
                local parameterDef = methodDef:GetParam()
                propertyType = parameterDef[1]:GetType()
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
        for i = 0, typeDef.method_count - 1 do
            local methodDef = type(typeDef.methods) == "number" and Il2Cpp.Method(Il2Cpp.GetPtr(typeDef.methods + i * Il2Cpp.pointSize)) or typeDef.methods[i+1]
            table.insert(output, "")
            table.insert(output, methodDef:ToString())
            
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

