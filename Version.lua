---@class VersionEngine
---Module for detecting and handling Unity engine version compatibility with Il2Cpp

---Compare two semantic version numbers
-- @param v1 table First version table with major, minor, patch fields
-- @param v2 table Second version table with major, minor, patch fields
-- @return number -1 if v1 < v2, 1 if v1 > v2, 0 if equal
local function compareVersions(v1, v2)
    if v1.major ~= v2.major then
        return v1.major < v2.major and -1 or 1
    end
    if v1.minor ~= v2.minor then
        return v1.minor < v2.minor and -1 or 1
    end
    if v1.patch ~= v2.patch then
        return v1.patch < v2.patch and -1 or 1
    end
    return 0
end

-- OS-specific Unity version string offset
local osUV = 0x11

local VersionEngine = {
    ---@class ConstSemVer
    ---Table of constant semantic version numbers for known Unity versions
    ConstSemVer = {
        ['2018_3'] = { major = 2018, minor = 3, patch = 0 },
        ['2019_4_21'] = { major = 2019, minor = 4, patch = 21 },
        ['2019_4_15'] = { major = 2019, minor = 4, patch = 15 },
        ['2019_3_7'] = { major = 2019, minor = 3, patch = 7 },
        ['2020_2_4'] = { major = 2020, minor = 2, patch = 4 },
        ['2020_2'] = { major = 2020, minor = 2, patch = 0 },
        ['2020_1_11'] = { major = 2020, minor = 1, patch = 11 },
        ['2021_2'] = { major = 2021, minor = 2, patch = 0 },
        ['2022_2'] = { major = 2022, minor = 2, patch = 0 },
        ['2022_3_41'] = { major = 2022, minor = 3, patch = 41 },
    },
    
    ---@class YearMapping
    ---Mapping of Unity release years to Il2Cpp versions with conditional logic
    Year = {
        ---Get Il2Cpp version for Unity 2017
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (24)
        [2017] = function(self, unityVersion)
            return 24
        end,
        ---Get Il2Cpp version for Unity 2018
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (24 or 24.1)
        [2018] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2018_3']) >= 0 and 24.1 or 24
        end,
        ---Get Il2Cpp version for Unity 2019
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (24.2 to 24.5)
        [2019] = function(self, unityVersion)
            local version = 24.2
            if compareVersions(unityVersion, self.ConstSemVer['2019_4_21']) >= 0 then
                version = 24.5
            elseif compareVersions(unityVersion, self.ConstSemVer['2019_4_15']) >= 0 then
                version = 24.4
            elseif compareVersions(unityVersion, self.ConstSemVer['2019_3_7']) >= 0 then
                version = 24.3
            end
            return version
        end,
        ---Get Il2Cpp version for Unity 2020
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (24.3 to 27.1)
        [2020] = function(self, unityVersion)
            local version = 24.3
            if compareVersions(unityVersion, self.ConstSemVer['2020_2_4']) >= 0 then
                version = 27.1
            elseif compareVersions(unityVersion, self.ConstSemVer['2020_2']) >= 0 then
                version = 27
            elseif compareVersions(unityVersion, self.ConstSemVer['2020_1_11']) >= 0 then
                version = 24.4
            end
            return version
        end,
        ---Get Il2Cpp version for Unity 2021
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (27.2 or 29)
        [2021] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2021_2']) >= 0 and 29 or 27.2
        end,
        ---Get Il2Cpp version for Unity 2022
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (29, 29.1 or 31)
        [2022] = function(self, unityVersion)
            local version = 29
            if compareVersions(unityVersion, self.ConstSemVer['2022_3_41']) >= 0 then
                version = 31
            elseif compareVersions(unityVersion, self.ConstSemVer['2022_2']) >= 0 then
                version = 29.1
            end
            return version
        end,
        ---Get Il2Cpp version for Unity 2023
        -- @param unityVersion table The Unity version table
        -- @return number Il2Cpp version (30)
        [2023] = function(self, unityVersion)
            return 31
        end,
    },
    
    ---Read Unity version from memory or libmain.so
    -- Attempts to detect the Unity version using multiple methods
    -- @return table|nil Table with major, minor, patch version numbers or nil if not found
    ReadUnityVersion = function()
        local version = {2018, 2019, 2020, 2021, 2022, 2023, 2024}
        local lm = gg.getRangesList('libmain.so')
        if #lm > 0 then
            local libMain = io.open(lm[1].name, "rb"):read("*a")
            for i, v in pairs(version) do
                if libMain:find(v) then
                    local versionName = v .. libMain:gmatch(v .. "(.-)_")()
                    local major, minor, patch = string.gmatch(versionName, "(%d+)%p(%d+)%p(%d+)")()
                    return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch), name = versionName}
                end
            end
        else
            gg.setRanges(gg.REGION_C_ALLOC)
            gg.clearResults()
            gg.searchNumber("Q 'X-Unity-Version:'", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
            if gg.getResultsCount() == 0 then
               gg.setRanges(gg.REGION_JAVA_HEAP)
               gg.searchNumber("Q 'SDK_UnityVersion'", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
               osUV = 0x20
            end
            local result = gg.getResultsCount() > 0 and gg.getResults(1)[1].address + osUV or 0
            if gg.getResultsCount() == 0 then
                gg.setRanges(gg.REGION_ANONYMOUS)
                gg.clearResults()
                gg.searchNumber("00h;32h;30h;0~~0;0~~0;2Eh;0~~0;2Eh::9", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
                result = gg.getResultsCount() > 0 and gg.getResults(3)[3].address or 0
                gg.clearResults()
            end
            gg.clearResults()
            local major, minor, patch = string.gmatch(Il2Cpp.Utf8ToString(result), "(%d+)%p(%d+)%p(%d+)")()
            return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
        end
    end,
    
    ---Choose appropriate Il2Cpp version based on Unity version
    -- @param version number|nil Optional forced version number
    -- @param globalMetadataHeader table|nil Optional global metadata header
    -- @return number Selected Il2Cpp version
    ChooseVersion = function(self, version, globalMetadataHeader)
        if not version then
            local unityVersion = self.ReadUnityVersion()
            if not unityVersion then
                gg.alert("Cannot determine Unity version", "", "")
                version = 31
            else
                version = self.Year[unityVersion.major] or 31
                if type(version) == 'function' then
                    version = version(self, unityVersion)
                end
            end
        end
        if version > 31 then
            gg.alert("Not support this il2cpp version", "", "")
            version = 31
        end
        return version
    end,
}


return setmetatable(VersionEngine, {
    ---Metatable call handler for VersionEngine
    -- Allows VersionEngine to be called as a function
    -- @return number Selected Il2Cpp version
    __call = function(self, ...)
        return self:ChooseVersion(...)
    end
})