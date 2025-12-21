---@class Meta
---Module for handling metadata operations in Il2Cpp
local Meta = {
    dataPath = Il2Cpp.Info.path .. "-Il2CppGG.lua",
    ranges = {
        A = gg.REGION_ANONYMOUS,
        Ca = gg.REGION_C_ALLOC,
        O = gg.REGION_OTHER
    }
}

---Check if an address points to a valid image name
-- @param addr number Memory address to check
-- @return string|boolean Image name if valid, false otherwise
local function isImage(addr)
    local imageStr = Il2Cpp.Utf8ToString(Il2Cpp.GetPtr(addr))
    local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
    return check and imageStr
end

function Meta:init(globalMetadataHeader, Version)
    local globalMetadataHeader = globalMetadataHeader or Il2Cpp.Meta.metaStart
    -- Validate metadata file
    local sanity = Il2Cpp.gV(globalMetadataHeader, 4)
    if sanity ~= -89056337 then
        Il2Cpp.log:warn("Metadata file supplied is not valid metadata file.")
    end

    local version = Il2Cpp.gV(globalMetadataHeader + 4, 4)
    if version < 0 or version > 1000 then
        Il2Cpp.log:warn("Metadata file supplied is not valid metadata file.")
    end
    if version < 16 or version > 31 then
        Il2Cpp.log:warn("Metadata file supplied is not a supported version[" .. version .. "].")
    end
    self.Version = version
    
    -- Obfuscator
    if sanity ~= -89056337 and (version < 0 or version > 1000) then
        self.Obf = true
        self.Version = Version
        Il2Cpp.log:warn("Metadata Obfuscator.")
        Il2Cpp.log:warn("Metadata version[" .. Version .. "].")
    end
    
    
    if os.rename(self.dataPath, self.dataPath) then
        local data = loadfile(self.dataPath)()
        for k, v in pairs(data) do
            self[k] = v
        end 
    end
    

    -- Read header
    self.Header = Il2Cpp.Il2CppGlobalMetadataHeader(globalMetadataHeader)
    
    -- Adjust metadata header offsets by adding the globalMetadataHeader address
    if not self.Obf then
        for k, v in pairs(self.Header) do
            local _, __ = k:find("Offset")
            if __ == #k then
                self.Header[k] = globalMetadataHeader + v
            end
        end
    end
    
    Il2Cpp.typeCount = Il2Cpp.pMetadataRegistration.typesCount
    Il2Cpp.typeSize = Il2Cpp.Il2CppTypeDefinition:GetSize()
    Il2Cpp.stringDef = self.Header.stringOffset
    
    if self.Obf then
        local param = Il2Cpp.Il2CppParameterDefinition(self.Header.parametersOffset)
        if param.token ~= 134217729 then
            gg.clearResults();
	        gg.setRanges(-1);
	        gg.searchNumber(134217729, 4, nil, nil, globalMetadataHeader, -1, 1);
	        local r = gg.getResults(1)
	        gg.clearResults();
	        self.Header.parametersOffset = r[1].address - 4 
			Il2Cpp.log:warn("Il2Cpp.Meta.Header.parametersOffset: " .. Il2Cpp.ToHex(self.Header.parametersOffset))
	    end
	    for i = 0, Il2Cpp.pMetadataRegistration.typeDefinitionsSizesCount - 1 do 
            local klass = Il2Cpp.Class(i)
            klass:Dump()
            local genericContainer = klass.genericContainerIndex or klass.genericContainerHandle
            if genericContainer > 0 then 
                self.Header.genericContainers = genericContainer
                break
            end
        end
        self.Header.genericContainersOffset = self.Header.genericContainers or self.Header.genericContainersOffset
        self.Header.genericParametersOffset = self.Header.genericParameters or self.Header.genericParametersOffset
        Il2Cpp.log:warn("Il2Cpp.Meta.Header.genericContainersOffset: " .. Il2Cpp.ToHex(self.Header.genericContainersOffset))
        Il2Cpp.log:warn("Il2Cpp.Meta.Header.genericParametersOffset: " .. Il2Cpp.ToHex(self.Header.genericParametersOffset))
    end
    
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
            else
                local kls = {}
                for key = 0, 10 do
                   local klass = Il2Cpp.GetPtr(addrs + (key * Il2Cpp.pointSize))
                   if isImage(Il2Cpp.GetPtr(klass)) then
                       kls[#kls+1] = {address = klass, flags = Il2Cpp.MainType}
                   end
                end
                if #kls >= 5 then
                    Il2Cpp.typeDef = addrs
                    local imageAddrs = Il2Cpp.GetPtr(kls[1].address)
                    if isImage(imageAddrs) then
                        Il2Cpp.imageDef = imageAddrs
                    end
                end
            end
        end 
        if Il2Cpp.typeDef then
            local klass = Il2Cpp.GetPtr(Il2Cpp.typeDef)
            if self.Obf then
                local klass1 = Il2Cpp.Class(klass)
                local klass2 = Il2Cpp.Class(Il2Cpp.GetPtr(Il2Cpp.typeDef + Il2Cpp.pointSize))
                local klassEnd = Il2Cpp.Class(Il2Cpp.GetPtr(Il2Cpp.typeDef + ((Il2Cpp.pMetadataRegistration.fieldOffsetsCount - 1) * Il2Cpp.pointSize)))
                
                --Il2Cpp.typeSize = klass2:GetTypeDef() - klass1:GetTypeDef()
                self.Header.typeDefinitionsOffset = klass1:GetTypeDef()
                self.Header.typeDefinitionsSize = (klassEnd:GetTypeDef() + Il2Cpp.typeSize) - self.Header.typeDefinitionsOffset
				Il2Cpp.log:warn("Il2Cpp.Meta.Header.typeDefinitionsOffset: " .. Il2Cpp.ToHex(self.Header.typeDefinitionsOffset))
				Il2Cpp.log:warn("Il2Cpp.Meta.Header.typeDefinitionsSize: " .. self.Header.typeDefinitionsSize)
             end
            if not Il2Cpp.imageDef then
                local imageAddrs = Il2Cpp.GetPtr(Il2Cpp.GetPtr(Il2Cpp.typeDef))
                if isImage(imageAddrs) then
                    Il2Cpp.imageDef = imageAddrs
                end
            end
            self.regionClass = self.ranges[gg.getValuesRange({{address = klass}})[1]]
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
                    local stringDef = Il2Cpp.GetPtr(Il2Cpp.GetPtr(Il2Cpp.imageDef + (Il2Cpp.Info.platform and 0x10 or 0x8)) + (Il2Cpp.Info.platform and 0x18 or 0x10))
                    Il2Cpp.stringDef = stringDef
                else 
                    Il2Cpp.log:error("stringDef not found: ", stringDef, self.Header)
                end
            end
            break
        end
        i = i + 1
    end
    Il2Cpp.log:info("Il2Cpp.stringDef: " .. Il2Cpp.ToHex(Il2Cpp.stringDef))
	Il2Cpp.log:info("Il2Cpp.typeDef: " .. Il2Cpp.ToHex(Il2Cpp.typeDef))
	Il2Cpp.log:info("Il2Cpp.imageDef: " .. Il2Cpp.ToHex(Il2Cpp.imageDef))
	
	
    
    -- Version-specific logic
    self.imageDefs = Il2Cpp.Image()--Il2Cpp.classArray(globalMetadataHeader + self.Header.imagesOffset, self.Header.imagesSize / Il2Cpp.Il2CppImageDefinition.size, Il2Cpp.Il2CppImageDefinition)
    if version == 24 then
        if self.Header.stringLiteralOffset == 264 then
            self.Version = 24.2
            Il2Cpp.Il2CppGlobalMetadataHeader = Il2Cpp.classGG(Il2Cpp._Il2CppGlobalMetadataHeader, self.Version)
            self.Header = Il2Cpp.Il2CppGlobalMetadataHeader(globalMetadataHeader)
        else
            if not table.all(self.imageDefs, function(x) return x.token == 1 end) then
                self.Version = 24.1
            end
        end
    end
    

    
    local v241Plus = false
    if self.Version == 24.1 and self.Header.assembliesSize / 64 == #self.imageDefs then
        v241Plus = true
    end
    if v241Plus then
        self.Version = 24.4
    end
    
    --self.assemblyDefs = Il2Cpp.classArray(globalMetadataHeader + self.Header.assembliesOffset, self.Header.assembliesOffset / self.Header.assembliesSize, Il2Cpp.Il2CppAssemblyDefinition)
    if v241Plus then
        self.Version = 24.1
    end
    
    if self.Version == 31 then
        Il2Cpp.Il2CppMethodDefinition = Il2Cpp.classGG(Il2Cpp._Il2CppMethodDefinition, self.Version)
    end
    
    return self
end

Meta.behaviorForTypes = {
    [2] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_BYTE)
    end,
    [3] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_BYTE)
    end,
    [4] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_BYTE)
    end,
    [5] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_BYTE)
    end,
    [6] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_WORD)
    end,
    [7] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_WORD)
    end,
    [8] = function(blob)
        local self = Il2Cpp.Meta
        return Il2Cpp.Version < 29 and self.ReadNumberConst(blob, gg.TYPE_DWORD) or self.ReadCompressedInt32(blob)
    end,
    [9] = function(blob)
        local self = Il2Cpp.Meta
        return Il2Cpp.Version < 29 and Il2Cpp.FixValue(self.ReadNumberConst(blob, gg.TYPE_DWORD)) or self.ReadCompressedUInt32(blob)
    end,
    [10] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_QWORD)
    end,
    [11] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_QWORD)
    end,
    [12] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_FLOAT)
    end,
    [13] = function(blob)
        return Il2Cpp.Meta.ReadNumberConst(blob, gg.TYPE_DOUBLE)
    end,
    [14] = function(blob)
        local self = Il2Cpp.Meta
        local length, offset = 0, 0
        if Il2Cpp.Version >= 29 then
            length, offset = self.ReadCompressedInt32(blob)
        else
            length = self.ReadNumberConst(blob, gg.TYPE_DWORD) 
            offset = 4
        end

        if length ~= -1 then
            return Il2Cpp.Utf8ToString(blob + offset, length)
        end
        return ""
    end
}


Meta.ReadCompressedUInt32 = function(Address)
    local val, offset = 0, 0
    local read = gg.getValues({
        { -- [1]
            address = Address, 
            flags = gg.TYPE_BYTE
        },
        { -- [2]
            address = Address + 1, 
            flags = gg.TYPE_BYTE
        },
        { -- [3]
            address = Address + 2, 
            flags = gg.TYPE_BYTE
        },
        { -- [4]
            address = Address + 3, 
            flags = gg.TYPE_BYTE
        }
    })
    local read1 = read[1].value & 0xFF
    offset = 1
    if (read1 & 0x80) == 0 then
        val = read1
    elseif (read1 & 0xC0) == 0x80 then
        val = (read1 & ~0x80) << 8
        val = val | (read[2].value & 0xFF)
        offset = offset + 1
    elseif (read1 & 0xE0) == 0xC0 then
        val = (read1 & ~0xC0) << 24
        val = val | ((read[2].value & 0xFF) << 16)
        val = val | ((read[3].value & 0xFF) << 8)
        val = val | (read[4].value & 0xFF)
        offset = offset + 3
    elseif read1 == 0xF0 then
        val = gg.getValues({{address = Address + 1, flags = gg.TYPE_DWORD}})[1].value
        offset = offset + 4
    elseif read1 == 0xFE then
        val = 0xffffffff - 1
    elseif read1 == 0xFF then
        val = 0xffffffff
    end
    return val, offset
end


---@param Address number
Meta.ReadCompressedInt32 = function(Address)
    local encoded, offset = Il2Cpp.Meta.ReadCompressedUInt32(Address)

    if encoded == 0xffffffff then
        return -2147483647 - 1
    end

    local isNegative = (encoded & 1) == 1
    encoded = encoded >> 1
    if isNegative then
        return -(encoded + 1)
    end
    return encoded, offset
end


---@param Address number
---@param ggType number @gg.TYPE_
Meta.ReadNumberConst = function(Address, ggType)
    return gg.getValues({{
        address = Address,
        flags = ggType
    }})[1].value
end


Meta.StringCacheApi = {}
function Meta:FindStringApi(Name)
	if self.StringCacheApi[Name] then
	    return self.StringCacheApi[Name]
	end
	local result, chars = {}, {};
	for key, name in pairs({string.lower(Name), string.upper(Name), string.upper(Name:sub(1, 1)) .. Name:sub(2, #Name), Name}) do
		local Name = ":" .. name;
		gg.setRanges(-1);
		gg.clearResults();
		gg.searchNumber(Name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, Il2Cpp.stringDef, self.metaEnd);
    	gg.refineNumber(Name:sub(1, 2), gg.TYPE_BYTE);
		local t = gg.getResults(gg.getResultsCount());
		gg.clearResults();
		for k, v in pairs(t) do
    		local char = {address=(v.address + 1),flags=1};
			while true do
			    _value = gg.getValues({char})[1].value;
				_char = string.char(_value & 255);
				char.address = char.address - 1;
				if string.find(_char, "[%z%s]") then break end
			end
			local address = char.address + 2;
			local name = Il2Cpp.Utf8ToString(address);
			chars[#chars + 1] = name;
			result[#result + 1] = {address=address,flags=1,name=name};
		end
	end
	self.StringCacheApi[Name] = {chars,result};
	return {
	    chars = chars,
	    results = result
	}
end

Meta.PointerStringApiCache = {}
function Meta:GetPointersToStringApi(name)
    local Result = self:FindStringApi(name)
    local Results = Result.results
    if self.PointerStringApiCache[tostring(Results)] then
	    return self.PointerStringApiCache[tostring(Results)]
	end
	local pointerString = pointerString or {}
	local ResultsPointer = {}
    gg.clearResults()
    gg.setRanges(self.regionClass)
    gg.loadResults(Results)
    gg.searchPointer(0);
    if gg.getResultsCount() == 0 and Il2Cpp.Info.platform and Il2Cpp.Info.sdk >= 30 then
        for i, v in pairs(Results) do
            gg.clearResults()
            gg.searchNumber(tostring(v.address | 0xB400000000000000), Il2Cpp.MainType, nil, nil, #pointerString ~= 0 and pointerString[1].start or nil, #pointerString ~= 0 and pointerString[#pointerString]["end"] or nil)
            local results = gg.getResults(gg.getResultsCount());
            gg.clearResults()
            if #results ~= 0 then
                if #pointerString == 0 then
                    for k, v in ipairs(gg.getRangesList()) do
                        if (v.state == 'Ca' or v.state == 'A' or v.state == 'O') then
                            pointerString[#pointerString + 1] = (Il2Cpp.FixValue(v.start) <= Il2Cpp.FixValue(results[1].address) and Il2Cpp.FixValue(results[1].address) < Il2Cpp.FixValue(v['end'])) and v or nil
                        end
                    end
                    gg.setRanges(#pointerString ~= 0 and -1 or self.regionClass)
                end
                
                for ii, vv in ipairs(results) do
                    ResultsPointer[#ResultsPointer+1] = vv
                end
            end
        end
    end
    local ResultsPointer = #ResultsPointer > 0 and ResultsPointer or gg.getResults(gg.getResultsCount())
    gg.clearResults()
    if #ResultsPointer == 0 then
        return false
    end
    gg.loadResults(ResultsPointer)
    local ResultsPointer = gg.getResults(gg.getResultsCount())
    gg.clearResults()
    self.PointerStringApiCache[tostring(Results)] = ResultsPointer
    return ResultsPointer, Result
end


---Get pointers to a string in memory by searching for the string pattern
-- @param name string The string name to search for
-- @param addList any Additional list parameter (unused in current implementation)
-- @return table Table of search results containing addresses pointing to the string
-- @error Throws an error if the class is not found in global-metadata
function Meta.GetPointersToString(name, ranges)
    local ranges = ranges or Il2Cpp.Meta
    gg.clearResults()
    gg.setRanges(-1)
    gg.searchNumber(string.format("Q 00 '%s' 00", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,
        ranges.metaStart, ranges.metaEnd)
    if gg.getResultsCount() == 0 then
        gg.searchNumber(string.format("Q 00 '%s' ", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,
        ranges.metaStart, ranges.metaEnd)
    end
    local results = gg.getResults(1, 1)
    if #results == 0 then
        error(string.format("Không tìm thấy lớp %s trong global-metadata", name))
    end
    gg.setRanges(Il2Cpp.Meta.regionClass)
    local res = Il2Cpp.searchPtr(results[1].address, Il2Cpp.MainType)
    gg.clearResults()
    if #res == 0 then
        error(string.format("Không tìm thấy con trỏ cho lớp %s %d", name, results[1].address))
    end
    return res
end

---Get string from metadata using string index
-- @param index number String index in metadata
-- @return string Decoded UTF-8 string from metadata
function Meta:GetStringFromIndex(index)
    local stringDefinitions = Il2Cpp.stringDef --Meta.Header.stringOffset
    return Il2Cpp.Utf8ToString(stringDefinitions + index)
end

---Get generic container from metadata by index
-- @param index number Generic container index
-- @return table Il2CppGenericContainer object
function Meta:GetGenericContainer(index)
    local index = index
    if self.Header.genericContainersOffset > index then
        index = self.Header.genericContainersOffset + (index * Il2Cpp.Il2CppGenericContainer.size)
    end
    return Il2Cpp.Il2CppGenericContainer(index)
end

---Get generic parameter from metadata by index
-- @param index number Generic parameter index
-- @return table Il2CppGenericParameter object
function Meta:GetGenericParameter(index)
    local index = index
    if self.Header.genericParametersOffset > index then
        index = self.Header.genericParametersOffset + (index * Il2Cpp.Il2CppGenericParameter.size)
    end
    local genericParameter = Il2Cpp.Il2CppGenericParameter(index)
    return genericParameter
end

function Meta:GetGenericContainerParams(genericContainer)
    local genericParameterNames = {}
    for i = 1, genericContainer.type_argc do
        local genericParameterIndex = genericContainer.genericParameterStart + i
        local genericParameter = self:GetGenericParameter(genericParameterIndex)
        genericParameterNames[i] = self:GetStringFromIndex(genericParameter.nameIndex)
    end
    return "<" .. table.concat(genericParameterNames, ", ") .. ">"
end


function Meta:GetGenericInsts(index)
    local index = Il2Cpp.pMetadataRegistration.genericInsts + (index * Il2Cpp.type.Pointer.size)
    return Il2Cpp.Il2CppGenericInst(index)
end

function Meta:GetTypeDefinition(typeDef)
    return Il2Cpp.Il2CppTypeDefinition(typeDef.typeDefinition or typeDef.typeMetadataHandle)
end

---Get method definition from metadata by index
-- @param index number Method definition index
-- @return table Il2CppMethodDefinition object
function Meta:GetMethodDefinition(index)
    local index = self.Header.methodsOffset + (index * Il2Cpp.Il2CppMethodDefinition.size)
    return Il2Cpp.Il2CppMethodDefinition(index)
end

---Get parameter definition from metadata by index
-- @param index number Parameter definition index
-- @return table Il2CppParameterDefinition object
function Meta:GetParameterDefinition(index)
    local index = self.Header.parametersOffset + (index * Il2Cpp.Il2CppParameterDefinition.size)
    return Il2Cpp.Il2CppParameterDefinition(index)
end


function Meta:GetGenericMethodTable(index)
    local index = index
    if Il2Cpp.pMetadataRegistration.genericMethodTableCount > index then
        index = Il2Cpp.pMetadataRegistration.genericMethodTable + (index * Il2Cpp.Il2CppGenericMethodFunctionsDefinitions.size)
    end
    return Il2Cpp.Il2CppGenericMethodFunctionsDefinitions(index)
end

function Meta:GetMethodSpec(index)
    local index = index
    if Il2Cpp.pMetadataRegistration.methodSpecsCount > index then
        index = Il2Cpp.pMetadataRegistration.methodSpecs + (index * Il2Cpp.Il2CppMethodSpec.size)
    end
    return Il2Cpp.Il2CppMethodSpec(index)
end

function Meta:GetFieldDefaultValueFromIndex(index)
    if not self.fieldDefaultValues then
        self.fieldDefaultValues = {}
        for i, v in ipairs(Il2Cpp.classArray(Il2Cpp.Meta.Header.fieldDefaultValuesOffset, Il2Cpp.Meta.Header.fieldDefaultValuesSize / Il2Cpp.Il2CppFieldDefaultValue.size, Il2Cpp.Il2CppFieldDefaultValue)) do
            self.fieldDefaultValues[v.fieldIndex] = v
        end
        gg.saveVariable({parameterDefaultValues = self.parameterDefaultValues, fieldDefaultValues = self.fieldDefaultValues}, self.dataPath)
    end
    return self.fieldDefaultValues[index]
end

function Meta:GetParameterDefaultValueFromIndex(index)
    if not self.parameterDefaultValues then
        self.parameterDefaultValues = {}
        for i, v in ipairs(Il2Cpp.classArray(Il2Cpp.Meta.Header.parameterDefaultValuesOffset, Il2Cpp.Meta.Header.parameterDefaultValuesSize / Il2Cpp.Il2CppParameterDefaultValue.size, Il2Cpp.Il2CppParameterDefaultValue)) do
            self.parameterDefaultValues[v.parameterIndex] = v
        end
        gg.saveVariable({parameterDefaultValues = self.parameterDefaultValues, fieldDefaultValues = self.fieldDefaultValues}, self.dataPath)
    end
    return self.parameterDefaultValues[index]
end

function Meta:GetDefaultValueFromIndex(index)
    return self.Header.fieldAndParameterDefaultValueDataOffset + index
end


function Meta:TryGetDefaultValue(typeIndex, dataIndex)
    local pointer = self:GetDefaultValueFromIndex(dataIndex)
    local defaultValueType = Il2Cpp.Type(typeIndex)
    
    local behavior = self.behaviorForTypes[defaultValueType.type] or "Not support type"
    if type(behavior) == "function" then
        local ok, res = pcall(behavior, pointer)
        if not ok then 
            error({pointer = pointer, behavior = behavior, defaultValueType = defaultValueType, typeIndex = typeIndex, dataIndex = dataIndex})
        end
        return true, res
    end
    
    return false, pointer
end





return setmetatable({}, {
    __index = Meta,
    __call = Meta.init 
})