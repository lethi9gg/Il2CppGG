# Il2CppGG - GameGuardian Il2Cpp Integration

Il2CppGG is a Lua-based library designed to interact with Il2Cpp applications, specifically tailored for use with GameGuardian. It provides a comprehensive set of tools to manipulate and inspect Il2Cpp metadata, classes, fields, methods, objects, and more, enabling advanced memory manipulation and analysis in Android applications.

## Overview

This library facilitates working with Il2Cpp-based games or applications by providing an interface to access and modify their internal structures, such as classes, methods, fields, and objects, directly from memory using GameGuardian's API. It is particularly useful for reverse engineering, debugging, and modding purposes.

## Features

- **Metadata Parsing**: Access and parse Il2Cpp global metadata to retrieve information about types, classes, methods, and fields.
- **Class Management**: Retrieve and manipulate class information, including fields, methods, and generic types.
- **Field Operations**: Get and set values for both instance and static fields.
- **Method Inspection**: Analyze method details, including parameters, return types, and access modifiers.
- **Object Finding**: Locate instances of classes in memory, supporting both 32-bit and 64-bit architectures.
- **Type Handling**: Work with Il2Cpp types, including reference types, value types, arrays, and generic instances.
- **Image Management**: Access assembly images and their associated types and entry points.
- **Memory Utilities**: Handle memory operations like pointer fixing and UTF-8 string conversion.

## Files

- **Il2Cpp.lua**: Core module that initializes the Il2Cpp environment, defines types, and provides utility functions for memory operations.
- **Class.lua**: Manages Il2Cpp class operations, including retrieving class names, namespaces, fields, methods, and instances.
- **Field.lua**: Handles field-related operations, such as getting/setting values for instance and static fields.
- **Method.lua**: Provides functionality to inspect and manipulate method metadata, including parameters and return types.
- **Object.lua**: Implements object searching and filtering in memory using GameGuardian.
- **Type.lua**: Manages Il2Cpp type information, including type checking, naming, and generic type handling.
- **Image.lua**: Handles assembly image operations, such as retrieving types and entry points.
- **Meta.lua**: Interfaces with Il2Cpp global metadata for low-level access to strings, generic containers, and definitions.
- **Struct.lua**: Defines Il2Cpp data structures and their memory layouts for various Il2Cpp versions.
- **init.lua**: Entry point that initializes the Il2Cpp library.

## Installation

1. Ensure GameGuardian is installed on your Android device.
2. Place the provided Lua scripts in a directory accessible to GameGuardian.
3. Load the `init.lua` script in GameGuardian to initialize the Il2Cpp library.

```lua
Il2Cpp = require "Il2Cpp"()
```

## Usage Examples

### Initialize the Library

Load the Il2CppGG library to access its functionality.

```lua
require("init")
```

### List All Images

Retrieve and print all available assembly images in the application.

```lua
local images = Il2Cpp.Image()
for _, img in ipairs(images) do
    print("Image: " .. img:GetName())
end
```

### Access a Specific Class and Method

Find a class in an assembly and inspect a specific method, including its parameters and return type.

```lua
local assembly = Il2Cpp.Image("Assembly-CSharp.dll")
if assembly then
    local playerScript = assembly:Class(nil, "PlayerScript")
    if playerScript then
        print("Class: " .. playerScript:GetName())
        local method = playerScript:GetMethod("addPoints")
        if method then
            print("Method: " .. method:GetName() .. ", Return Type: " .. method:GetReturnType():GetName())
            for i, param in ipairs(method:GetParam()) do
                print("Param " .. i .. ": " .. param.name .. " (" .. param.type:GetName() .. ")")
            end
        end
    end
end
```

### Find Class Instances in Memory

Locate all instances of a class in memory and print their addresses.

```lua
local assembly = Il2Cpp.Image("Assembly-CSharp.dll")
if assembly then
    local playerScript = assembly:Class(nil, "PlayerScript")
    if playerScript then
        local objects = Il2Cpp.Object:Find({{ClassAddress = playerScript.address}})
        for i, obj in ipairs(objects) do
            print("Object " .. i .. " at: " .. tostring(obj.address))
        end
    end
end
```

### Access and Manipulate Fields

Retrieve a field from a class and get or set its value for a specific object instance.

```lua
local assembly = Il2Cpp.Image("Assembly-CSharp.dll")
if assembly then
    local playerScript = assembly:Class(nil, "PlayerScript")
    if playerScript then
        local field = playerScript:GetField("myField")
        if field then
            local objects = Il2Cpp.Object:Find({{ClassAddress = playerScript.address}})
            if #objects > 0 then
                local value = field:GetValue(objects[1].address)
                print("Field value: " .. tostring(value))
                field:SetValue(objects[1].address, newValue) -- Replace newValue with desired value
            end
        end
    end
end
```

### Inspect Class Types in an Image

List all types (classes) within a specific image.

```lua
local project = Il2Cpp.Image("Project.Game")
if project then
    local types = project:GetTypes()
    for _, type in ipairs(types) do
        print("Type: " .. type:GetName())
    end
end
```

## Requirements

- **GameGuardian**: Required for memory manipulation and search operations.
- **Android Device**: Compatible with Android applications using Il2Cpp.
- **Lua Environment**: GameGuardian's Lua scripting environment.

## Notes

- The library supports multiple Il2Cpp versions (e.g., 22, 24, 27, 29, 31) with version-specific field handling in `Struct.lua`.
- Ensure proper memory ranges are set in GameGuardian for accurate object searching (`Object.lua`).
- Handle 64-bit architecture considerations, as the library adjusts pointer sizes and memory operations accordingly.
- Use with caution, as improper memory manipulation can crash the target application.
- There are many methods that are not yet perfect.

## Contributing

Contributions are welcome! Please submit pull requests or issues for bug fixes, improvements, or new features.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
