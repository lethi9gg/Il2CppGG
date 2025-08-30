---@class AndroidInfo
---Table containing Android target information for the current application
local info = gg.getTargetInfo()

---@class AndroidInfoTable
---Android target information structure containing platform architecture, SDK version, package details and cache path
local AndroidInfo = {
    ---@field platform boolean Whether the target platform is 64-bit (true) or 32-bit (false)
    platform = info.x64,
    
    ---@field sdk number Target SDK version of the application
    sdk = info.targetSdkVersion,
    
    ---@field pkg string Package name of the target application
    pkg = gg.getTargetPackage(),
    
    ---@field path string Cache path for the application with format: 
    -- "/cache/packageName-versionCode-architecture(64/32)"
    path = gg.EXT_CACHE_DIR .. "/" .. info.packageName .. "-" .. info.versionCode .. "-" .. (info.x64 and "64" or "32")
}

return AndroidInfo