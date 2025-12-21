# Il2CppGG

[![Version](https://img.shields.io/badge/version-1.0.4-blue.svg)](https://github.com/lethi9gg/Il2CppGG)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/lethi9gg/Il2CppGG/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/platform-GameGuardian-orange.svg)](https://gameguardian.net/)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?&logo=telegram&logoColor=white)](https://t.me/lethi9ggg)
[![GameGuardian](https://img.shields.io/badge/GameGuardian-7c36b1)](https://gameguardian.net/forum/files/file/4316-il2cppgg)

**Il2CppGG** is a powerful Lua-based framework designed specifically for GameGuardian, tailored for working with Unity games that utilize the Il2Cpp backend. The framework offers comprehensive tools for metadata analysis, class/field/method searching, memory modification, advanced hooking, and dumping code in C# format.

It automatically detects Il2Cpp versions from v22 to v31 and supports both ARM32 and ARM64 architectures.








## Key Features

- **Automatic Il2Cpp version detection** and location of metadata/code regions
- **User-friendly API** for accessing Image, Class, Field, Method, Type, Parameter, and Object
- **Instance object finding** in memory (supports Android SDK 30+ with pointer obfuscation)
- **Simple memory patching** (e.g., forcing method return values)
- **Advanced hooking**:
  - Hook fields within methods
  - Hook method parameters
  - Hook method calls from another method
- **Class/full assembly dumping** to C# format with detailed offsets
- **Support for obfuscated metadata** (detection and warnings)
- **Customizable detailed logging**




## Requirements

- GameGuardian (latest version recommended)
- Unity game using Il2Cpp (Mono backend not supported)
- Rooted Android device

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/lethi9gg/Il2CppGG.git
   ```

2. Two usage modes:
   - **Development**: Use the full folder with separate module files. Place the entire folder alongside your script.
   - **Production**: Use the bundled file `build/Il2CppGG.lua` (generated via `buildLT9.lua`).

## Basic Usage

```lua
-- Development mode
require("init") -- or require("build.Il2CppGG") for bundled file

Il2Cpp({
    log = {
        INFO = true     -- Enable detailed logging (optional)
    }
})

-- Example: Find and modify
local assembly = Il2Cpp.Image("Assembly-CSharp")
local PlayerClass = assembly:Class(nil, "PlayerScript")

local pointsField = PlayerClass:GetField("points")
local addPointsMethod = PlayerClass:GetMethod("addPoints")

-- Modify field on all instances
local instances = PlayerClass:GetInstance()
pointsField:SetValue(instances, 999999)

-- Patch method to always return false
addPointsMethod:SetValue(false)
gg.sleep(5000)
addPointsMethod:RestoreValue()  -- Restore original
```

## Detailed Documentation

Full API reference and examples available in the Wiki:  
[wiki](../../wiki/)

The `test.lua` file in the repository provides a complete example covering:
- Finding classes/images
- Field modification
- Method patching
- Various hook types
- Class dumping

## Supported Versions

- Unity Il2Cpp: v22 → v31 (including 24.x, 27.x, 29.x, 31)
- Architectures: ARM32 & ARM64
- Android: 8 → 14 (SDK 26 → 34)

## Notes & Troubleshooting

- "Metadata file not valid" error: May indicate obfuscated metadata or incorrect region → The framework handles it where possible.
- No classes found: Ensure the game uses Il2Cpp.
- Crashes on hook: Verify valid method pointer and executable memory region.
- Obfuscated metadata: Framework warns and attempts to proceed with specified version.

## Author

**LeThi9GG**  
Report issues or contact via GitHub Issues.

## License

MIT License - See [LICENSE](LICENSE) for details.

---

⭐ If this project is useful, please star the repository to show support!  
Contributions are welcome via Pull Requests.