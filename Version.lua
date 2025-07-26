local osUV = 0x11

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


---@class VersionEngine
local VersionEngine = {
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
    Year = {
        [2017] = function(self, unityVersion)
            return 24
        end,
        [2018] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2018_3']) >= 0 and 24.1 or 24
        end,
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
        [2021] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2021_2']) >= 0 and 29 or 27.2
        end,
        [2022] = function(self, unityVersion)
            local version = 29
            if compareVersions(unityVersion, self.ConstSemVer['2022_3_41']) >= 0 then
                version = 31
            elseif compareVersions(unityVersion, self.ConstSemVer['2022_2']) >= 0 then
                version = 29.1
            end
            return version
        end,
        [2023] = function(self, unityVersion)
            return 30
        end,
    },
    ReadUnityVersion = function()
        local version = {2018, 2019, 2020, 2021, 2022, 2023, 2024}
        local lm = gg.getRangesList('libmain.so')
        if #lm > 0 then
            local libMain = io.open(lm[1].name, "rb"):read("*a")
            for i, v in pairs(version) do
                if libMain:find(v) then
                    local versionName = v .. libMain:gmatch(v .. "(.-)_")()
                    local major, minor, patch = string.gmatch(versionName, "(%d+)%p(%d+)%p(%d+)")()
                    return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
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
    __call = function(self)
        return self:ChooseVersion()
    end
})