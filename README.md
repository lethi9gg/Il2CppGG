# Il2CppGG

A comprehensive toolkit for inspecting and manipulating Il2Cpp structures within GameGuardian, implemented in Lua.

[![GameGuardian](https://img.shields.io/badge/GameGuardian-7c36b1)](https://gameguardian.net/forum/files/file/4316-il2cppgg) ![Lua](https://img.shields.io/badge/Lua-5.2-blue) ![Il2Cpp](https://img.shields.io/badge/Il2Cpp-Reverse%20Engineering-green) ![Version](https://img.shields.io/badge/Version-1.1.0-brightgreen) [![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?&logo=telegram&logoColor=white)](https://t.me/lethi9ggg)

## Description

Il2CppGG is an advanced Lua-based toolkit designed for GameGuardian, enabling detailed analysis and modification of Il2Cpp metadata, classes, methods, fields, types, and objects. It now includes memory hooking capabilities for game modification and reverse engineering, as well as class dumping to C# format.  
**Author**: [LeThi9GG](https://github.com/lethi9gg)

## Features

- **Automatic Il2Cpp Version Detection**: Supports versions from v22 to v31 with seamless adaptation.
- **Comprehensive Metadata Support**: Parse global metadata, including strings, generics, and parameters.
- **Class Inspection**: Retrieve class details, fields, methods, and properties; search by name for efficiency.
- **Type System Analysis**: Detailed handling of types, including generics, arrays, and value types.
- **Object Manipulation**: Locate and modify Il2Cpp objects in memory, with filtering for accuracy.
- **Safe Memory Operations**: Read and write memory via GameGuardian for secure interactions.
- **Intelligent Caching**: Optimized performance through caching mechanisms.
- **Name-Based Search**: Easily locate fields and classes by name without requiring addresses.
- **Memory Hooking**: Hook methods, parameters, fields, and calls for real-time modifications (from Hook.lua). Supports 32-bit and 64-bit architectures with jump opcodes.
- **Class Dumping**: Export classes to C# format, including field offsets, method RVAs, and attributes (from Dump.lua).
- **Parameter Handling**: Manage Il2Cpp parameters with names, tokens, and types (from Param.lua).

## Requirements

- GameGuardian installed on an Android device.
- A target application utilizing the Il2Cpp framework.
- Basic proficiency in Lua programming.

## Installation

1. Download the [build/Il2CppGG.lua](/build/) file from the repository.
2. Place it in GameGuardian's scripts directory.
3. Load the `Il2CppGG.lua` script within GameGuardian.

## Build

- Execute the `buildLT9.lua` script in GameGuardian to generate `build/Il2CppGG.lua`.

## Project Structure

```
Il2CppGG/
├── Androidinfo.lua (Android device information helper)
├── buildLT9.lua (Module bundling build script)
├── Class.lua (Il2Cpp class module)
├── Field.lua (Il2Cpp field module)
├── Il2Cpp.lua (Core module for versioning and utilities)
├── Image.lua (Il2Cpp image/assembly module)
├── init.lua (Development entry point)
├── Meta.lua (Il2Cpp metadata module)
├── Method.lua (Il2Cpp method module)
├── Object.lua (Memory object manipulation)
├── Struct.lua (Version-specific Il2Cpp structures)
├── Type.lua (Il2Cpp type module)
├── Universalsearcher.lua (Metadata and pointer locator)
├── Version.lua (Version detection and structure selection)
├── Param.lua (Parameter operations module)
├── Hook.lua (Memory hooking for modification and reverse engineering)
├── Dump.lua (Class dumping to C# format)
├── test.lua (Usage examples for hooking and dumping)
└── build/
    └── Il2CppGG.lua (Bundled production script)
```

For general usage, only `build/Il2CppGG.lua` is required. The remaining files support development and contributions.

## Detailed API Documentation

### Core Module (Il2Cpp.lua)

Handles initialization, versioning, and core utilities.

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
local text = Il2Cpp.Utf8ToString(0x12345678)
print("String value:", text)
```

### Class Module (Class.lua)

Represents an Il2Cpp class.

```lua
-- Find class by name
local playerClass = Il2Cpp.Class("Player")

-- Retrieve information
print("Class name:", playerClass:GetName())
print("Namespace:", playerClass:GetNamespace())
print("Instance size:", playerClass:GetInstanceSize())

-- Fields
local fields = playerClass:GetFields()
print("Number of fields:", #fields)
local healthField = playerClass:GetField("health")

-- Methods
local methods = playerClass:GetMethods()
local updateMethod = playerClass:GetMethod("Update", 0)  -- 0 parameters

-- Instances
local instances = playerClass:GetInstance()
print("Number of instances:", #instances)
```

### Field Module (Field.lua)

Represents a field in an Il2Cpp class.

```lua
-- Find field
local health = Il2Cpp.Field("health")

-- Information
print("Field name:", health:GetName())
print("Offset:", health:GetOffset())
print("Type:", health:GetType():GetName())

-- Get/Set value
local objAddress = 0x12345678
local val = health:GetValue(objAddress)
health:SetValue(objAddress, 100)

-- Static fields
if health:IsNormalStatic() then
    health:StaticSetValue(9999)
end
```

### Method Module (Method.lua)

Represents an Il2Cpp method.

```lua
local method = Il2Cpp.Method("methodName")

print("Method name:", method:GetName())
print("Return type:", method:GetReturnType():GetName())
print("Parameter count:", method:GetParamCount())

local params = method:GetParam()
for i, param in ipairs(params) do
    print("Parameter " .. i .. ":", param.name, param.type:GetName())
end
```

### Type Module (Type.lua)

Represents an Il2Cpp type.

```lua
local typeObj = Il2Cpp.Type(0x12345678)

print("Type name:", typeObj:GetName())
print("Is value type:", typeObj:IsValueType())
print("Is generic instance:", typeObj:IsGenericInstance())
```

### Object Module (Object.lua)

Locates and manipulates objects in memory.

```lua
local players = Il2Cpp.Object:FindObjects(playerClass.address)
print("Number of players:", #players)
```

### Image Module (Image.lua)

Represents an Il2Cpp assembly.

```lua
local image = Il2Cpp.Image("Assembly-CSharp")

print("Image name:", image:GetName())
local types = image:GetTypes()
local player = image:Class("", "Player")
```

### Meta Module (Meta.lua)

Handles global Il2Cpp metadata.

```lua
local str = Il2Cpp.Meta:GetStringFromIndex(123)
print("String:", str)
```

### Hook Module (Hook.lua)

Enables memory hooking for modifications.

```lua
-- Get method and field via class
local lateUpdate = playerClass:GetMethod("LateUpdate")
local points = playerClass:GetField("points")
local addPoints = playerClass:GetMethod("addPoints")

-- Hook field via method
local _lateUpdate = lateUpdate:field()
_lateUpdate:setValues({{offset = points.offset, flags = "int", value = 9999}})
gg.sleep(10000)
_lateUpdate:off()

-- Hook method parameters
local _addPoints = addPoints:method()
_addPoints:param({{param = 1, flags = "int", value = 999999}})
gg.sleep(10000)
_addPoints:off()

-- Hook call addPoints via lateUpdate
local _addPoints = lateUpdate:call()(addPoints)
_addPoints:setValues({{param = 1, flags = "int", value = 999}})
gg.sleep(10000)
_addPoints:off()
```

### Dump Module (Dump.lua)

Dumps classes to C# format.

```lua
print(playerClass:Dump())  -- Outputs C# class representation
```

## Advanced Examples

From test.lua:

```lua
-- Retrieve image
local Assembly = Il2Cpp.Image("Assembly-CSharp")

-- Class retrieval
local PlayerScript = Assembly:Class(nil, "PlayerScript")

-- Method/Field
local LateUpdate = PlayerScript:GetMethod("LateUpdate")
local points = PlayerScript:GetField("points")

-- Set field value
local obj = PlayerScript:GetInstance()
points:SetValue(obj, 1000)

-- Dump class
print(PlayerScript:Dump())

-- Hooking examples as above
```

## Notes

- This toolkit is intended for educational and research purposes only. Use it responsibly.
- Certain features may depend on specific Il2Cpp versions.
- Exercise caution when modifying memory, as it may lead to application instability.

## Author

**LeThi9GG** – Specialist in Il2Cpp reverse engineering.

## Contributing

Contributions, bug reports, and feature requests are welcome. Please refer to the issues page.

## License

This project is licensed for educational and research use. Respect the terms of service for any analyzed applications.

---

Full documentation is available on the [wiki](../../wiki/).