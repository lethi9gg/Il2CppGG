# Il2CppGG

A powerful Il2Cpp inspection and manipulation toolkit for GameGuardian, written in Lua.

[![GameGuardian](https://img.shields.io/badge/GameGuardian-7c36b1)](https://gameguardian.net/forum/files/file/3056-ggil2cpp) ![Lua](https://img.shields.io/badge/Lua-5.2-blue) ![Il2Cpp](https://img.shields.io/badge/Il2Cpp-Reverse%20Engineering-green) ![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen) [![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?&logo=telegram&logoColor=white)](https://t.me/lethi9gg)

## 📖 Description

Il2CppGG is a comprehensive toolkit written in Lua for working with Il2Cpp structures within the GameGuardian environment. It provides a full-fledged API to parse and manipulate metadata, classes, methods, fields, types, and objects in memory.

**Author**: [LeThi9GG](https://github.com/lethi9gg)

## ✨ Features

- **Dynamic Il2Cpp Versioning**: Automatically detects and adapts to Il2Cpp versions from v22 to v31
- **Full Il2Cpp Metadata Support**: Access and parse global Il2Cpp metadata
- **Class Inspection**: Retrieve class information, including fields, methods, and properties
- **Type System**: Detailed type analysis with support for generics, arrays, and value types
- **Object Manipulation**: Find and manipulate Il2Cpp objects in memory
- **Memory Management**: Safely access and manipulate memory through GameGuardian
- **Caching System**: Optimized performance through intelligent caching
- **Name-based Search**: Easily find fields and classes by name

## 📋 Requirements

- GameGuardian installed on an Android device
- A target application using the Il2Cpp framework
- Basic knowledge of Lua programming

## 🚀 Installation

1. Download the [build/Il2CppGG.lua](https://github.com/lethi9gg/Il2CppGG/blob/main/build/Il2CppGG.lua) file from the repository
2. Place it in GameGuardian's scripts folder
3. In GameGuardian, load the `Il2CppGG.lua` script

## ⚒️ Build

- In GameGuardian, run the `buildLT9.lua` script --> build/Il2CppGG.lua

## 📂 Project Structure

```
Il2CppGG/
├── Androidinfo.lua (Helper for Android device information)
├── buildLT9.lua (Build script to bundle modules)
├── Class.lua (Module for Il2Cpp classes)
├── Field.lua (Module for Il2Cpp fields)
├── Il2Cpp.lua (Core module, handles versioning and utilities)
├── Image.lua (Module for Il2Cpp images/assemblies)
├── init.lua (Entry point for development)
├── Meta.lua (Module for Il2Cpp metadata)
├── Method.lua (Module for Il2Cpp methods)
├── Object.lua (Module for memory object manipulation)
├── Struct.lua (Defines version-specific Il2Cpp structures)
├── Type.lua (Module for Il2Cpp types)
├── Universalsearcher.lua (Module for locating metadata and key pointers)
├── Version.lua (Version detection and structure selection)
└── build/
    └── Il2CppGG.lua (Bundled, production-ready script)
```

For general use, you only need the `build/Il2CppGG.lua` file. The other files are for development and contribution purposes.

## 📚 Detailed API Documentation

### Core Module (Il2Cpp.lua)

The main module that handles initialization, versioning, and provides essential utilities.

```lua
require("Il2CppGG")

-- Check architecture
print("64-bit:", Il2Cpp.x64)
print("Pointer size:", Il2Cpp.pointSize)

-- Read value from memory
local value = Il2Cpp.gV(0x12345678, Il2Cpp.pointer)
print("Value at address:", value)

-- Read pointer
local ptr = Il2Cpp.GetPtr(0x12345678)
print("Pointer value:", string.format("0x%X", ptr))

-- Convert UTF-8 string
local strAddress = 0x12345678
local text = Il2Cpp.Utf8ToString(strAddress)
print("String value:", text)
```

### Class Module (Class.lua)

Represents an Il2Cpp class.

```lua
-- Find class by name
local playerClass = Il2Cpp.Class("Player")
local stringClass = Il2Cpp.Class("System.String")

-- Find class by address
local classByAddr = Il2Cpp.Class(0x12345678)

-- Find class by index
local classByIndex = Il2Cpp.Class(123)

-- Get class information
print("Class name:", playerClass:GetName())
print("Namespace:", playerClass:GetNamespace())
print("Instance size:", playerClass:GetInstanceSize())
print("Is generic:", playerClass:IsGeneric())
print("Is nested:", playerClass:IsNested())

-- Get class fields
local fields = playerClass:GetFields()
print("Number of fields:", #fields)

-- Find specific field
local healthField = playerClass:GetField("health")

-- Get class methods
local methods = playerClass:GetMethods()
print("Number of methods:", #methods)

-- Find specific method
local updateMethod = playerClass:GetMethod("Update", 0) -- 0 parameters

-- Find class instances
local instances = playerClass:GetInstance()
print("Number of instances:", #instances)

-- Get class interfaces
local interfaces = playerClass:GetInterfaces()
for _, interface in ipairs(interfaces) do
    print("Interface:", interface:GetName())
end
```

### Field Module (Field.lua)

Represents a field within an Il2Cpp class.

```lua
-- Find field by name
local field = Il2Cpp.Field("score")
local healthField = Il2Cpp.Field("health")

-- Find field by address
local fieldByAddr = Il2Cpp.Field(0x12345678)

-- Get field information
print("Field name:", field:GetName())
print("Parent class:", field:GetParent():GetName())
print("Offset:", field:GetOffset())
print("Type:", field:GetType():GetName())
print("Is instance field:", field:IsInstance())
print("Is static field:", field:IsNormalStatic())

-- Read field value from object
local objectAddress = 0x12345678
local fieldValue = field:GetValue(objectAddress)
print("Field value:", fieldValue)

-- Write field value to object
field:SetValue(objectAddress, 100)

-- Read static field value
if field:IsNormalStatic() then
    local staticValue = field:StaticGetValue()
    print("Static value:", staticValue)
    
    -- Write static field value
    field:StaticSetValue(9999)
end

-- Find all fields with same name
local allScoreFields = Il2Cpp.Field("score")
if type(allScoreFields) == "table" then
    for i, f in ipairs(allScoreFields) do
        print(i, ":", f:GetParent():GetName() .. "." .. f:GetName())
    end
end
```

### Method Module (Method.lua)

Represents an Il2Cpp method.

```lua
-- Create method object from address
local method = Il2Cpp.Method(0x12345678)

-- Get method information
print("Method name:", method:GetName())
print("Declaring type:", method:GetDeclaringType():GetName())
print("Return type:", method:GetReturnType():GetName())
print("Parameter count:", method:GetParamCount())
print("Is instance method:", method:IsInstance())
print("Is static method:", method:IsStatic())
print("Is abstract method:", method:IsAbstract())
print("Access level:", method:GetAccess())

-- Get parameter information
local params = method:GetParam()
for i, param in ipairs(params) do
    print("Parameter", i, ":", param.name, "(", param.type:GetName(), ")")
end

-- Check if method is generic
print("Is generic:", method:IsGeneric())
print("Is generic instance:", method:IsGenericInstance())
```

### Type Module (Type.lua)

Represents an Il2Cpp type.

```lua
-- Create type object from address or index
local typeObj = Il2Cpp.Type(0x12345678)
local stringType = Il2Cpp.Type(Il2Cpp.Il2CppTypeEnum.IL2CPP_TYPE_STRING)

-- Check type properties
print("Is reference type:", typeObj:IsReference())
print("Is value type:", typeObj:IsValueType())
print("Is struct:", typeObj:IsStruct())
print("Is enum:", typeObj:IsEnum())
print("Is array:", typeObj:IsArray())
print("Is pointer:", typeObj:IsPointer())
print("Is generic instance:", typeObj:IsGenericInstance())
print("Is generic parameter:", typeObj:IsGenericParameter())

-- Get type information
print("Type name:", typeObj:GetName())
print("Simple name:", typeObj:GetSimpleName())
print("Size in memory:", typeObj:GetSize())
print("Metadata token:", typeObj:GetToken())

-- Get associated class
local class = typeObj:GetClass()
if class then
    print("Associated class:", class:GetName())
end

-- Get array information (if array)
local arrayInfo = typeObj:GetArrayInfo()
if arrayInfo then
    print("Array element type:", arrayInfo.elementType:GetName())
    print("Array rank:", arrayInfo.rank)
end

-- Get generic type definition (if generic instance)
if typeObj:IsGenericInstance() then
    local genericDef = typeObj:GetGenericTypeDefinition()
    print("Generic definition:", genericDef:GetName())
end

-- Get generic parameter info (if generic parameter)
if typeObj:IsGenericParameter() then
    local paramInfo = typeObj:GetGenericParameterInfo()
    if paramInfo then
        print("Parameter name:", paramInfo.name)
        print("Parameter index:", paramInfo.index)
    end
    
    local declaringType = typeObj:GetDeclaringType()
    if declaringType then
        print("Declaring type:", declaringType:GetName())
    end
    
    local declaringMethod = typeObj:GetDeclaringMethod()
    if declaringMethod then
        print("Declaring method:", declaringMethod:GetName())
    end
end

-- Compare types
local type1 = Il2Cpp.Type(0x12345678)
local type2 = Il2Cpp.Type(0x87654321)
print("Types are equal:", Il2Cpp.Type.AreEqual(type1, type2))
```

### Object Module (Object.lua)

Find and manipulate objects in memory.

```lua
-- Find objects of a class
local playerClass = Il2Cpp.Class("Player")
local players = Il2Cpp.Object:FindObjects(playerClass.address)
print("Found", #players, "player objects")

-- Filter objects
local filteredPlayers = Il2Cpp.Object:FilterObjects(players)
print("After filtering:", #filteredPlayers, "valid players")

-- Find object header from address
local objectHeader = Il2Cpp.Object.FindHead(0x12345678)
print("Object header at:", string.format("0x%X", objectHeader.address))

-- Work with multiple classes
local enemyClasses = {
    Il2Cpp.Class("Enemy"),
    Il2Cpp.Class("Boss"),
    Il2Cpp.Class("Monster")
}

local allEnemies = {}
for _, enemyClass in ipairs(enemyClasses) do
    if enemyClass then
        local enemies = Il2Cpp.Object:FindObjects(enemyClass.address)
        print("Found", #enemies, enemyClass:GetName(), "objects")
        
        for _, enemy in ipairs(enemies) do
            table.insert(allEnemies, enemy)
        end
    end
end

print("Total enemies found:", #allEnemies)
```

### Image Module (Image.lua)

Represents an Il2Cpp assembly (DLL).

```lua
-- Get image by name
local image = Il2Cpp.Image("Assembly-CSharp")
local unityEngine = Il2Cpp.Image("UnityEngine")

-- Get all images
local allImages = Il2Cpp.Image()
print("Number of images:", #allImages)

-- Get image information
print("Image name:", image:GetName())
print("File name:", image:GetFileName())
print("Assembly address:", string.format("0x%X", image:GetAssembly()))
print("Number of types:", image:GetNumTypes())

-- Get entry point
local entryPoint = image:GetEntryPoint()
if entryPoint then
    print("Entry point:", entryPoint:GetName())
end

-- Get types in image
local types = image:GetTypes()
print("Types in image:", #types)

-- Get only exported types
local exportedTypes = image:GetTypes(true)
print("Exported types:", #exportedTypes)

-- Get type by index
local typeAtIndex = image:GetType(0)
if typeAtIndex then
    print("Type at index 0:", typeAtIndex:GetName())
end

-- Find class in image
local playerClass = image:Class("", "Player") -- No namespace
local gameManagerClass = image:Class("GameNamespace", "GameManager") -- With namespace

-- Find class with nested types
local nestedClass = image:FromTypeNameParseInfo({
    ns = "OuterNamespace",
    name = "OuterClass",
    nested = {"InnerClass", "NestedClass"}
})

-- Check system types
print("Is System.Type:", image:IsSystemType(someClass))
print("Is System.Reflection.Assembly:", image:IsSystemReflectionAssembly(someClass))
```

### Meta Module (Meta.lua)

Works with global Il2Cpp metadata.

```lua
-- Get string from metadata by index
local str = Il2Cpp.Meta:GetStringFromIndex(123)
print("String from index:", str)

-- Get generic container by index
local container = Il2Cpp.Meta:GetGenericContainer(456)
if container then
    print("Generic container owner index:", container.ownerIndex)
    print("Generic container type argc:", container.type_argc)
end

-- Get generic parameter by index
local param = Il2Cpp.Meta:GetGenericParameter(789)
if param then
    print("Generic parameter name index:", param.nameIndex)
    print("Generic parameter flags:", param.flags)
end

-- Get method definition by index
local methodDef = Il2Cpp.Meta:GetMethodDefinition(101112)
if methodDef then
    print("Method definition name index:", methodDef.nameIndex)
    print("Method definition token:", methodDef.token)
end

-- Get parameter definition by index
local paramDef = Il2Cpp.Meta:GetParameterDefinition(131415)
if paramDef then
    print("Parameter definition name index:", paramDef.nameIndex)
    print("Parameter definition type index:", paramDef.typeIndex)
end

-- Find pointers to string in metadata
local pointers = Il2Cpp.Meta:GetPointersToString("Player")
print("Found", #pointers, "pointers to 'Player'")
```

## 🧪 Advanced Examples

### Find and Modify Multiple Fields

```lua
local Il2Cpp = require("Il2Cpp")()

-- List of fields to find and modify
local fieldsToModify = {
    {name = "health", value = 100},
    {name = "coins", value = 9999},
    {name = "ammo", value = 50},
    {name = "lives", value = 3}
}

for _, fieldInfo in ipairs(fieldsToModify) do
    local field = Il2Cpp.Field(fieldInfo.name)
    
    if field then
        print("Found", fieldInfo.name, "in class:", field:GetParent():GetName())
        
        -- If static field
        if not field:IsInstance() and field:IsNormalStatic() then
            local currentValue = field:StaticGetValue()
            print("Current value:", currentValue)
            
            -- Modify value
            field:StaticSetValue(fieldInfo.value)
            print("Set to:", fieldInfo.value)
        else
            -- If instance field, find objects
            local parentClass = field:GetParent()
            local objects = Il2Cpp.Object:FindObjects(parentClass.address)
            
            if #objects > 0 then
                print("Found", #objects, "objects, modifying first one")
                
                -- Modify value for first object
                local currentValue = field:GetValue(objects[1].address)
                print("Current value:", currentValue)
                
                field:SetValue(objects[1].address, fieldInfo.value)
                print("Set to:", fieldInfo.value)
            end
        end
    else
        print("Field not found:", fieldInfo.name)
    end
end
```

### Analyze Generic Types

```lua
local Il2Cpp = require("Il2Cpp")()

-- Find generic list
local listClass = Il2Cpp.Class("System.Collections.Generic.List`1")
if listClass then
    print("Found generic list class:", listClass:GetName())
    
    -- Find list instances
    local listObjects = Il2Cpp.Object:FindObjects(listClass.address)
    print("Found", #listObjects, "list instances")
    
    for i, listObject in ipairs(listObjects) do
        -- Get list object type
        local listType = Il2Cpp.Type(Il2Cpp.gV(listObject.address + Il2Cpp.pointSize, Il2Cpp.pointer))
        
        if listType and listType:IsGenericInstance() then
            print("List", i, "is generic instance")
            print("  Type name:", listType:GetName())
            
            -- Get generic arguments
            local genericClass = Il2Cpp.Il2CppGenericClass(listType.data)
            if genericClass then
                local context = genericClass.context
                if context and context.class_inst ~= 0 then
                    local genericInst = Il2Cpp.Il2CppGenericInst(context.class_inst)
                    if genericInst then
                        local argc = genericInst.type_argc
                        print("  Generic arguments count:", argc)
                        
                        for i = 0, argc - 1 do
                            local argAddr = Il2Cpp.GetPtr(genericInst.type_argv + (i * Il2Cpp.pointSize))
                            local argType = Il2Cpp.Type(argAddr)
                            print("  Argument", i + 1, ":", argType:GetName())
                        end
                    end
                end
            end
        end
    end
end
```

### Find Method and Analyze Parameters

```lua
local Il2Cpp = require("Il2Cpp")()

-- Find Player class
local playerClass = Il2Cpp.Class("Player")
if playerClass then
    -- Get all methods
    local methods = playerClass:GetMethods()
    
    -- Find methods containing "Damage" in name
    local damageMethods = {}
    for _, method in ipairs(methods) do
        if method:GetName():lower():find("damage") then
            table.insert(damageMethods, method)
        end
    end
    
    print("Found", #damageMethods, "damage-related methods")
    
    -- Analyze each method
    for _, method in ipairs(damageMethods) do
        print("Method:", method:GetName())
        print("  Parameters:", method:GetParamCount())
        
        -- Get parameter information
        local params = method:GetParam()
        for i, param in ipairs(params) do
            print("  Parameter", i, ":", param.name, "(", param.type:GetName(), ")")
        end
        
        -- Check if method has numeric parameters
        local hasNumericParam = false
        for _, param in ipairs(params) do
            local typeName = param.type:GetName():lower()
            if typeName:find("int") or typeName:find("float") then
                hasNumericParam = true
                break
            end
        end
        
        if hasNumericParam then
            print("  This method has numeric parameters - potential damage method!")
        end
    end
end
```

## 📝 Notes

- This tool is designed for educational and research purposes
- Some features may require specific Il2Cpp versions
- Always be cautious when modifying memory in running applications
- Use features responsibly and only on applications you own or have permission to analyze

## 👤 Author

**LeThi9GG** - Il2Cpp reverse engineering enthusiast

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome! Please check the issues page.

## 📄 License

This project is licensed for educational and research purposes. Please respect the terms of use of any applications you analyze with this tool.

---

**Disclaimer**: This tool is for educational purposes only. Use it responsibly and only on applications you own or have permission to analyze.
