local info = gg.getTargetInfo()
local AndroidInfo = {
    platform = info.x64,
    sdk = info.targetSdkVersion,
    pkg = gg.getTargetPackage(),
    path = gg.EXT_CACHE_DIR .. "/" .. info.packageName .. "-" .. info.versionCode .. "-" .. (info.x64 and "64" or "32")
}

return AndroidInfo