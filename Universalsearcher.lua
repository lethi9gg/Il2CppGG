local AndroidInfo = require "Androidinfo"
local MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD
local pointSize = AndroidInfo.platform and 8 or 4

---@class Searcher
---Universal searcher module for locating Il2Cpp and metadata components in memory
local Searcher = {
    searchWord = ":EnsureCapacity",
    tokenParam = 134217729,
    
    ranges = {
        A = gg.REGION_ANONYMOUS,
        Ca = gg.REGION_C_ALLOC,
        O = gg.REGION_OTHER
    },
    
    ---Find global metadata in memory using various search strategies
    -- @param self Searcher The Searcher instance
    -- @return number Start address of global metadata
    -- @return number End address of global metadata
    FindGlobalMetaData = function(self)
        gg.clearResults()
        gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS |
                         gg.REGION_OTHER)
        local globalMetadata = gg.getRangesList('global-metadata.dat')
        if not self:IsValidData(globalMetadata) then
            globalMetadata = gg.getRangesList("dev/zero")
        end
        if not self:IsValidData(globalMetadata) then
            globalMetadata = {}
            for k, v in ipairs({
                gg.REGION_C_ALLOC,
                gg.REGION_ANONYMOUS,
                gg.REGION_OTHER
            }) do
                gg.clearResults()
                gg.setRanges(v)
                gg.searchNumber(self.searchWord, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil,
                    nil, 1)
                if gg.getResultsCount() > 0 then
                    gg.refineNumber(self.searchWord:sub(1, 2), gg.TYPE_BYTE)
                    EnsureCapacity = gg.getResults(gg.getResultsCount())
                    gg.clearResults()
                    break
                end 
            end
            for k, v in ipairs(gg.getRangesList()) do
                if (v.state == 'Ca' or v.state == 'A' or v.state == 'Cd' or v.state == 'Cb' or v.state == 'Ch' or
                    v.state == 'O') then
                    for key, val in ipairs(EnsureCapacity) do
                        globalMetadata[#globalMetadata + 1] =
                            (Il2Cpp.FixValue(v.start) <= Il2Cpp.FixValue(val.address) and Il2Cpp.FixValue(val.address) <
                                Il2Cpp.FixValue(v['end'])) and v or nil
                    end
                end
            end
        end
        local value = -89056337
        if gg.getValues({{address = globalMetadata[1].start, flags = 4}})[1].value ~= value then
            gg.searchNumber(value, 4, false, gg.SIGN_EQUAL, globalMetadata[1].start, globalMetadata[#globalMetadata]['end'])
            if gg.getResultsCount() > 0 then
                globalMetadata[1].start = gg.getResults(1)[1].address
            end
        end
        return type(globalMetadata) == "table" and globalMetadata[1].start, globalMetadata[#globalMetadata]['end'] or 0, 0
    end,

    ---Check if global metadata contains valid data by searching for the signature
    -- @param self Searcher The Searcher instance
    -- @param globalMetadata table Table of memory ranges to check
    -- @return boolean True if valid data is found, false otherwise
    IsValidData = function(self, globalMetadata)
        if #globalMetadata ~= 0 then
            --for k, v in pairs(self.ranges) do
             --   gg.clearResults()
                --gg.setRanges(v)
                gg.searchNumber(self.searchWord, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, globalMetadata[1].start,
                    globalMetadata[#globalMetadata]['end'], 1)
                if gg.getResultsCount() > 0 then
                    gg.clearResults()
                    return true
                end
            --end
        end
        return false
    end,

    ---Find Il2Cpp library in memory using various search strategies
    -- @return number Start address of Il2Cpp library
    -- @return number End address of Il2Cpp library
    FindIl2cpp = function()
        local il2cpp = gg.getRangesList('libil2cpp.so')
        if #il2cpp == 0 then
            il2cpp = gg.getRangesList('split_config.')
            local _il2cpp = {}
            gg.setRanges(gg.REGION_CODE_APP)
            for k, v in ipairs(il2cpp) do
                if (v.state == 'Xa') then
                    gg.searchNumber(':il2cpp', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, v.start, v['end'])
                    if (gg.getResultsCount() > 0) then
                        _il2cpp[#_il2cpp + 1] = v
                        gg.clearResults()
                    end
                end
            end
            il2cpp = _il2cpp
        else
            local _il2cpp = {}
            for k,v in ipairs(il2cpp) do
                local Value = gg.getValues({{address = v.start, flags = 4}})[1].value
                if Value==0x464C457F or Value==263434879 then
                --if (string.find(v.type, "..x.") or v.state == "Xa") then
                    _il2cpp[#_il2cpp + 1] = v
                end
            end
            il2cpp[1] = _il2cpp[#_il2cpp]
            --il2cpp = _il2cpp
        end       
        return il2cpp[1].start, il2cpp[#il2cpp]['end']
    end,
    
    Il2CppSearchPointer = function(config)--address, ranges, endResults, startAddrs, endAddrs)
        local ranges = config.ranges or {gg.REGION_C_BSS, gg.REGION_ANONYMOUS, gg.REGION_OTHER}
        for i, range in ipairs(ranges) do 
            gg.clearResults();
    	    gg.setRanges(range);
    	    gg.searchNumber(config.address, Il2Cpp.MainType, nil, nil, config.startAddrs, config.endAddrs, config.endResults);
    	    
    	    -- Handle 64-bit Android SDK 30+ special case
    	    if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
                gg.searchNumber(tostring(config.address | 0xB400000000000000), Il2Cpp.MainType, nil, nil, config.startAddrs, config.endAddrs, config.endResults);
            end
            
            local t = gg.getResults(gg.getResultsCount())
            gg.clearResults();
            if #t > 0 then
                return t
            end
        end
    end,

    ---Locate and initialize Il2Cpp metadata registration structures
    -- @return table Table containing metadata registration information
    Il2CppMetadataRegistration = function(self)
        ---Check if an address points to a valid image name
        -- @param addr number Memory address to check
        -- @return string|boolean Image name if valid, false otherwise
        local function isImage(addr)
            local imageStr = Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(addr))
            local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
            return check and imageStr
        end
        
        -- Set pointer sizes based on version and platform
        Il2Cpp.classPointer = Il2Cpp.Version < 27 and (AndroidInfo.platform and 24 or 12) or (AndroidInfo.platform and 40 or 20);
        --Il2Cpp.imagePointer = Il2Cpp.Version < 27 and (AndroidInfo.platform and 72 or 36) or (AndroidInfo.platform and 24 or 12);
        
        -- Get global metadata range
        local gmt = gg.getRangesList("global-metadata.dat");
	    local addrs = ((gmt and #gmt > 0) and gmt[1].start) or Il2Cpp.Meta.metaStart
	    
        --[[
        gg.clearResults();
	    gg.setRanges(gg.REGION_C_BSS | gg.REGION_ANONYMOUS | gg.REGION_OTHER);
	    gg.searchNumber(gmt, Il2Cpp.MainType, nil, nil, Il2Cpp.il2cppStart, -1, 1);
	    if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(gmt | 0xB400000000000000), Il2Cpp.MainType, nil, nil, Il2Cpp.il2cppStart, -1, 1);
        end
        local t = gg.getResults(1)
        gg.clearResults();
        ]]
        local startAddrs = Il2Cpp.il2cppStart
	    local config = {
	        address = addrs,
	        ranges = {gg.REGION_C_BSS, gg.REGION_ANONYMOUS, gg.REGION_OTHER},
	        endResults = 1,
	        startAddrs = startAddrs
	    }
	    local t = self.Il2CppSearchPointer(config)
	    if not t then
	        config.startAddrs = nil
	        t = self.Il2CppSearchPointer(config)
	        if not t then
	            error("Il2CppSearchPointer :", config)
	        end
	    end
	    
	    Il2Cpp.metaPtr = t[1].address
	    
	    local i = 1
	    while true do 
	        local addr = Il2Cpp.metaPtr - (i * Il2Cpp.pointSize)
	        local pMetaReg = Il2Cpp.Il2CppMetadataRegistration(Il2Cpp.GetPtr(addr))
	        local Range = gg.getValuesRange({{address = Il2Cpp.GetPtr(addr)}})[1]
            if (Range == "Cd" or Range == "O" or Range == "A") and pMetaReg.typeDefinitionsSizesCount == pMetaReg.fieldOffsetsCount then
                Il2Cpp.metaReg = Il2Cpp.GetPtr(addr)
                Il2Cpp.il2cppReg = Il2Cpp.GetPtr(addr + Il2Cpp.pointSize)
                break
            end 
            i = i + 1
        end
        --Il2Cpp.Il2CppMetadataRegistration(Il2Cpp.metaReg):AddList()
        --Il2Cpp.Il2CppCodeRegistration(Il2Cpp.il2cppReg):AddList()
        --[[os.exit()
        local Range, a = {}, t[1].address - (10 * Il2Cpp.pointSize)
        for i = 1, 20 do
            Range[i] = {address = a + (i * Il2Cpp.pointSize), flags = Il2Cpp.MainType}
        end
        local res = {}
        for i, v in ipairs(gg.getValues(Range)) do
            local addr = Il2Cpp.FixValue(v.value)
            if addr ~= gmt then
                res[#res+1] = {address = addr, value = v.address}
            end
        end
        for i, v in ipairs(gg.getValuesRange(res)) do
            if v == "Cd" or v == "O" then
                local metaRegIndex = i + 1
                local il2cppRegIndex = i
                local pMetaReg = Il2Cpp.Il2CppMetadataRegistration(res[metaRegIndex].address)
                if pMetaReg.typeDefinitionsSizesCount ~= pMetaReg.fieldOffsetsCount then
                    metaRegIndex = i
                    il2cppRegIndex = i+1
                end
                Il2Cpp.il2cppReg = Il2Cpp.il2cppReg or res[il2cppRegIndex].address
                Il2Cpp.il2cppRegPtr = res[il2cppRegIndex].value
                Il2Cpp.metaReg = Il2Cpp.metaReg or res[metaRegIndex].address
                Il2Cpp.metaRegPtr = res[metaRegIndex].value
                break
            end
        end
        ]]
        
        --[[
        local typeDef
        for i = 0, 20 do
            local addrs = Il2Cpp.GetPtr(Il2Cpp.metaPtr + (i * Il2Cpp.pointSize))
            if addrs > 0 then
                local kls = {}
                for key = 0, 10 do
                   local klass = Il2Cpp.GetPtr(addrs + (key * Il2Cpp.pointSize))
                   if isImage(Il2Cpp.GetPtr(klass)) then
                       kls[#kls+1] = {address = klass, flags = Il2Cpp.MainType}
                   end
                end
                if #kls >= 5 then
                    typeDef = addrs
                end
            end
        end 
        ]]
        Il2Cpp.pMetadataRegistration = Il2Cpp.Il2CppMetadataRegistration(Il2Cpp.metaReg)
        Il2Cpp.pCodeRegistration = Il2Cpp.Il2CppCodeRegistration(Il2Cpp.il2cppReg)
        Il2Cpp.typeCount = Il2Cpp.pMetadataRegistration.typesCount
        Il2Cpp.typeSize = Il2Cpp.Il2CppTypeDefinition:GetSize()
        Il2Cpp.stringDef = Il2Cpp.Meta.Header.stringOffset
        
        local i = 1
        while true do 
            local addrs = Il2Cpp.GetPtr(Il2Cpp.metaPtr + (i * Il2Cpp.pointSize))
            if not Il2Cpp.imageCount and addrs < 1000 then 
                Il2Cpp.imageCount = addrs 
            end
            
            if not Il2Cpp.typeDef then 
                local klass = Il2Cpp.GetPtr(addrs)
                if isImage(Il2Cpp.GetPtr(klass)) then
                    Il2Cpp.typeDef = addrs
                end
            end 
            if Il2Cpp.typeDef then
                local klass = Il2Cpp.GetPtr(Il2Cpp.typeDef)
                if Il2Cpp.Meta.Obf then
                    local klass1 = Il2Cpp.Class(klass)
                    local klass2 = Il2Cpp.Class(Il2Cpp.GetPtr(Il2Cpp.typeDef + Il2Cpp.pointSize))
                    local klassEnd = Il2Cpp.Class(Il2Cpp.GetPtr(Il2Cpp.typeDef + ((Il2Cpp.pMetadataRegistration.fieldOffsetsCount - 1) * Il2Cpp.pointSize)))
                    
                    --Il2Cpp.typeSize = klass2:GetTypeDef() - klass1:GetTypeDef()
                    Il2Cpp.Meta.Header.typeDefinitionsOffset = klass1:GetTypeDef()
                    Il2Cpp.Meta.Header.typeDefinitionsSize = (klassEnd:GetTypeDef() + Il2Cpp.typeSize) - Il2Cpp.Meta.Header.typeDefinitionsOffset
                 end
                if not Il2Cpp.imageDef then
                    local imageAddrs = Il2Cpp.GetPtr(Il2Cpp.GetPtr(Il2Cpp.typeDef))
                    if isImage(imageAddrs) then
                        Il2Cpp.imageDef = imageAddrs
                    end
                end
                Il2Cpp.Meta.regionClass = self.ranges[gg.getValuesRange({{address = klass}})[1]]
            end 
            if Il2Cpp.imageDef and not Il2Cpp.imageSize then
                local addr = Il2Cpp.imageDef + (i * Il2Cpp.pointSize)
                if isImage(addr) then
                    Il2Cpp.imageSize = addr - Il2Cpp.imageDef
                end
            end
            if Il2Cpp.imageDef and Il2Cpp.imageCount and Il2Cpp.imageSize and Il2Cpp.typeDef then
                if not Il2Cpp.Utf8ToString(Il2Cpp.stringDef, 100):find(".dll") then
                    local stringDef = Il2Cpp.GetPtr(Il2Cpp.imageDef)
                    if Il2Cpp.Utf8ToString(stringDef, 100):find(".dll") then
                        local stringDef = Il2Cpp.GetPtr(Il2Cpp.GetPtr(Il2Cpp.imageDef + (AndroidInfo.platform and 0x10 or 0x8)) + (AndroidInfo.platform and 0x18 or 0x10))
                        Il2Cpp.stringDef = stringDef
                    else 
                        error("stringDef not found: ", stringDef, Il2Cpp.Meta.Header)
                    end
                end
                break
            end
            i = i + 1
        end
        
        if Il2Cpp.Meta.Obf then
            local param = Il2Cpp.Il2CppParameterDefinition(Il2Cpp.Meta.Header.parametersOffset)
            if param.token ~= self.tokenParam then
                gg.clearResults();
    	        gg.setRanges(-1);
    	        gg.searchNumber(self.tokenParam, 4, nil, nil, t[1].value, -1, 1);
    	        local r = gg.getResults(1)
    	        gg.clearResults();
    	        Il2Cpp.Meta.Header.parametersOffset = r[1].address - 4 
    	    end
	    end
        
        --[[
        for i = 1, 100 do
            if not Il2Cpp.imageCount then
                local count = Il2Cpp.GetPtr(t[1].address + (i * Il2Cpp.pointSize))
                if count < 1000 then
                    Il2Cpp.imageCount = count
                end
            end
            if not Il2Cpp.imageDef then
                local addr = Il2Cpp.GetPtr(Il2Cpp.GetPtr(Il2Cpp.typeDef + (i * Il2Cpp.pointSize)))
                local image = isImage(addr)
                if image then
                    Il2Cpp.imageDef = addr
                end
            end
            if Il2Cpp.imageDef then
                local addr = Il2Cpp.imageDef + (i * Il2Cpp.pointSize)
                if isImage(addr) then
                    Il2Cpp.imageSize = addr - Il2Cpp.imageDef
                    break
                end
            end
        end
        ]]
        
        --[[
        local typeDefList = {}
        for i = 0, Il2Cpp.pMetadataRegistration.fieldOffsetsCount - 1 do 
            typeDefList[i] = {address = Il2Cpp.typeDef + (i * Il2Cpp.pointSize), flags = Il2Cpp.MainType}
        end 
        gg.loadResults({{address = Il2Cpp.typeDef + ((Il2Cpp.pMetadataRegistration.fieldOffsetsCount - 1) * Il2Cpp.pointSize), flags = Il2Cpp.MainType}})
        ]]
        
        --print(Il2Cpp.typeDefSize, Il2Cpp.typeDefSizes, Il2Cpp.typeDefOffset)
        --os.exit()
        
        
        
        
        --[[
        if (Il2Cpp.Version < 27) then
            Il2Cpp.stringDef = Il2Cpp.FixValue(Il2Cpp.GetPtr(Il2Cpp.imageDef + ((AndroidInfo.platform and 8) or 0)));
            return
        else
            address = Il2Cpp.GetPtr(Il2Cpp.GetPtr(Il2Cpp.imageDef) + (AndroidInfo.platform and 16 or 8)) + (AndroidInfo.platform and 24 or 16);
        end
        Il2Cpp.stringDef = Il2Cpp.GetPtr(address);
        ]]
    end
}

return Searcher