local modules = {
   name = "Il2CppGG",
   version = 1.0.2,
   author = "LeThi9GG",
   
   build = {
      input = "init",
      output = "build/Il2CppGG.lua", -- nil then output = Name + build.lua
   }
}

local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("BuildLT9", function(require, _LOADED, __bundle_register, __bundle_modules)
return require("obfLT9.build")(modules)
end)__bundle_register("obfLT9.build", function(require, _LOADED, __bundle_register, __bundle_modules)
local Tokenizer = require('obfLT9.tokenizer')

local modules = "local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)\n\tlocal loadingPlaceholder = {[{}] = true}\n\n\tlocal register\n\tlocal modules = {}\n\n\tlocal require\n\tlocal loaded = {}\n\n\tregister = function(name, body)\n\t\tif not modules[name] then\n\t\t\tmodules[name] = body\n\t\tend\n\tend\n\n\trequire = function(name)\n\t\tlocal loadedModule = loaded[name]\n\n\t\tif loadedModule then\n\t\t\tif loadedModule == loadingPlaceholder then\n\t\t\t\treturn nil\n\t\t\tend\n\t\telse\n\t\t\tif not modules[name] then\n\t\t\t\tif not superRequire then\n\t\t\t\t\tlocal identifier = type(name) == \'string\' and \'\\\"\' .. name .. \'\\\"\' or tostring(name)\n\t\t\t\t\terror(\'Tried to require \' .. identifier .. \', but no such module has been registered\')\n\t\t\t\telse\n\t\t\t\t\treturn superRequire(name)\n\t\t\t\tend\n\t\t\tend\n\n\t\t\tloaded[name] = loadingPlaceholder\n\t\t\tloadedModule = modules[name](require, loaded, register, modules)\n\t\t\tloaded[name] = loadedModule\n\t\tend\n\n\t\treturn loadedModule\n\tend\n\n\treturn require, loaded, register, modules\nend)(require)\n"


local function build(results, args)
    if not args.build.output then
        local dir = args.build.input:match("(.*[/%\\])") or ""
        args.build.output = dir .. args.name .. "." .. args.version .. ".lua"
    end
    local script = {}
    table.insert(script, "--Module: " .. args.name .. "v" .. args.version .. "\n--Author: " .. args.author .. "\n" .. modules)
    results[1].name = args.name or results[1].name
    for i, v in ipairs(results) do
        --v.src = pipe(v.src)
        table.insert(script, '__bundle_register("' .. v.name .. '", function(require, _LOADED, __bundle_register, __bundle_modules)\n' .. v.src .. '\nend)')
        --print(args.build.output or args.Name, "<--", v.name)
    end
    table.insert(script, '\nreturn __bundle_require("' .. results[1].name .. '")')
    local script = table.concat(script);--Parser(table.concat(script))()
    --local script = Pipeline:fromConfig(Config):apply(script)
    
    io.open(args.build.output, "w"):write(script):close()
    print("Done:", args.build.output)
    return script
end


local result, results = {}, {}
FindRequire = function(name)
    if not results[name] then
      local input = name:gsub("%.", "/")
            local dir = input:match("(.*[/%\\])")
            if dir and not package.path:find(dir) then
                package.path = dir .. "?.lua;" .. package.path
            end
            local file = input .. ".lua"
            local src, erro = io.open(file, "r");
            if not src then
                for path in package.path:gmatch('[^;]+') do
                    local _path = path:gsub("%?.lua$", file)
                    src, erro = io.open(_path, "r");
                    if src then
                        file = _path
                       break
                    end
                end;
            end
           
    local code = src:read("a")
    result[#result+1] = {name = name, file = file, src = code}
    print(name)
    local Token = Tokenizer(code)
    for i, v in ipairs(Token) do
        if v.kind == Tokenizer.TokenKind.Ident and v.value == "require" then
            local index = i
            while true do
                 index = index + 1
                 if Token[index].kind == "String" then
                      break
                  end
             end
             local n = Token[index].value
            if not results[n] then
               FindRequire(n)
            end
         end
     end
    results[name] = true
    
end
    return result
end

return setmetatable({},{
    __call = function(self, args)
        return build(FindRequire(args.build.input), args)
end})

end)__bundle_register("obfLT9.tokenizer", function(require, _LOADED, __bundle_register, __bundle_modules)
local Enums = require("obfLT9.enums");
local util = require("obfLT9.util");
local logger = require("logger");
local config = require("config");

local LuaVersion = Enums.LuaVersion;
local lookupify = util.lookupify;
local unlookupify = util.unlookupify;
local escape = util.escape;
local chararray = util.chararray;
local keys = util.keys;
local Tokenizer = {};


Tokenizer.EOF_CHAR = "<EOF>";
Tokenizer.WHITESPACE_CHARS = lookupify{
	" ", "\t", "\n", "\r",
}

Tokenizer.ANNOTATION_CHARS = lookupify(chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"))
Tokenizer.ANNOTATION_START_CHARS = lookupify(chararray("!@"))

Tokenizer.Conventions = Enums.Conventions;

Tokenizer.TokenKind = {
	Eof     = "Eof",
	Keyword = "Keyword",
	Symbol  = "Symbol",
	Ident   = "Identifier",
	Number  = "Number",
	String  = "String",
}

Tokenizer.EOF_TOKEN = {
	kind = Tokenizer.TokenKind.Eof,
	value = "<EOF>",
	startPos = -1,
	endPos = -1,
	source = "<EOF>",
}

local function token(self, startPos, kind, value)
	local line, linePos = self:getPosition(self.index);
	local annotations = self.annotations
	self.annotations = {};
	return {
		kind     = kind,
		value    = value,
		startPos = startPos,
		endPos   = self.index,
		source   = self.source:sub(startPos + 1, self.index),
		line     = line,
		linePos  = linePos,
		annotations = annotations,
	}
end

local function generateError(self, message)
	local line, linePos = self:getPosition(self.index);
	return "Lexing Error at Position " .. tostring(line) .. ":" .. tostring(linePos) .. ", " .. message;
end

local function generateWarning(token, message)
	return "Warning at Position " .. tostring(token.line) .. ":" .. tostring(token.linePos) .. ", " .. message;
end

function Tokenizer:getPosition(i)
	local column = self.columnMap[i]

	if not column then --// `i` is bigger than self.length, this shouldnt happen, but it did. (Theres probably some error in the tokenizer, cant find it.)
		column = self.columnMap[#self.columnMap] 
	end

	return column.id, column.charMap[i]
end

--// Prepare columnMap for getPosition
function Tokenizer:prepareGetPosition()
	local columnMap, column = {}, { charMap = {}, id = 1, length = 0 }

	for index = 1, self.length do
		local character = string.sub(self.source, index, index) -- NOTE_1: this could use table.clone to reduce amount of NEWTABLE (if that causes any performance issues)

		local columnLength = column.length + 1
		column.length = columnLength
		column.charMap[index] = columnLength

		if character == "\n" then
			column = { charMap = {}, id = column.id + 1, length = 0 } -- NOTE_1
		end

		columnMap[index] = column
	end

	self.columnMap = columnMap
end

-- Constructor for Tokenizer
function Tokenizer:new(settings) 
	local luaVersion = (settings and (settings.luaVersion or settings.LuaVersion)) or LuaVersion.Lua53;
	local conventions = Tokenizer.Conventions[luaVersion];
	
	if(conventions == nil) then
		logger:error("The Lua Version \"" .. luaVersion .. "\" is not recognised by the Tokenizer! Please use one of the following: \"" .. table.concat(keys(Tokenizer.Conventions), "\",\"") .. "\"");
	end
	
	local tokenizer = {
		index  = 0,           -- Index where the current char is read
		length = 0,
		source = "", -- Source to Tokenize
		luaVersion = luaVersion, -- LuaVersion to be used while Tokenizing
		conventions = conventions;
		
		NumberChars       = conventions.NumberChars,
		NumberCharsLookup = lookupify(conventions.NumberChars),
		Keywords          = conventions.Keywords,
		KeywordsLookup    = lookupify(conventions.Keywords),
		BinaryNumberChars = conventions.BinaryNumberChars,
		BinaryNumberCharsLookup = lookupify(conventions.BinaryNumberChars);
		BinaryNums        = conventions.BinaryNums,
		HexadecimalNums   = conventions.HexadecimalNums,
		HexNumberChars    = conventions.HexNumberChars,
		HexNumberCharsLookup = lookupify(conventions.HexNumberChars),
		DecimalExponent   = conventions.DecimalExponent,
		DecimalSeperators = conventions.DecimalSeperators,
		
		EscapeSequences   = conventions.EscapeSequences,
		NumericalEscapes  = conventions.NumericalEscapes,
		EscapeZIgnoreNextWhitespace = conventions.EscapeZIgnoreNextWhitespace,
		HexEscapes        = conventions.HexEscapes,
		UnicodeEscapes    = conventions.UnicodeEscapes,

		AllowUnicodeIdentifiers = (settings and settings.allowUnicodeIdentifiers ~= false) and true or false,

  IdentCharsLookup  = lookupify(conventions.IdentChars),
		
		SymbolChars       = conventions.SymbolChars,
		SymbolCharsLookup = lookupify(conventions.SymbolChars),
		MaxSymbolLength   = conventions.MaxSymbolLength,
		Symbols           = conventions.Symbols,
		SymbolsLookup     = lookupify(conventions.Symbols),
		
		StringStartLookup = lookupify({"\"", "\'"}),
		annotations = {},
	};
	
	setmetatable(tokenizer, self);
	self.__index = self;
	
	return tokenizer;
end

-- Reset State of Tokenizer to Tokenize another File
function Tokenizer:reset()
	self.index = 0;
	self.length = 0;
	self.source = "";
	self.annotations = {};
	self.columnMap = {};
end

-- Append String to this Tokenizer
function Tokenizer:append(code)
	self.source = self.source .. code
	self.length = self.length + code:len();
	self:prepareGetPosition();
end


-- Function to peek the n'th char in the source of the tokenizer
local function peek(self, n)
	n = n or 0;
	local i = self.index + n + 1;
	if i > self.length then
		return Tokenizer.EOF_CHAR
	end
	return self.source:sub(i, i);
end

-- Function to get the next char in the source
local function get(self)
	local i = self.index + 1;
	if i > self.length then
		logger:error(generateError(self, "Unexpected end of Input"));
	end
	self.index = self.index + 1;
	return self.source:sub(i, i);
end

-- The same as get except it throws an Error if the char is not contained in charOrLookup
local function expect(self, charOrLookup)
	if(type(charOrLookup) == "string") then
		charOrLookup = {[charOrLookup] = true};
	end
	
	local char = peek(self);
	if charOrLookup[char] ~= true then
		local etb = unlookupify(charOrLookup);
		for i, v in ipairs(etb) do
			etb[i] = v:escape();
		end
		local errorMessage = "Unexpected char \"" .. char:escape() .. "\"! Expected one of \"" .. table.concat(etb, "\",\"") .. "\"";
		logger:error(generateError(self, errorMessage));
	end
	
	self.index = self.index + 1;
	return char;
end

-- Returns wether the n'th char is in the lookup
local function is(self, charOrLookup, n)
	local char = peek(self, n);
	if(type(charOrLookup) == "string") then
		return char == charOrLookup;
	end
	return charOrLookup[char];
end

local function peekUtf8(self)
    local ch = peek(self)
    if ch == Tokenizer.EOF_CHAR then return ch end
    local byte = string.byte(ch)
    if byte < 0x80 then
        return ch, 1
    end
    -- determine utf-8 length from lead byte
    local len = 1
    if byte >= 0xF0 then len = 4
    elseif byte >= 0xE0 then len = 3
    elseif byte >= 0xC0 then len = 2
    else
        -- invalid lead - treat as single byte to keep tokenizer robust
        return ch, 1
    end
    -- if not enough bytes left, fallback to single bytes (robustness)
    local i = self.index + 1
    if i + len - 1 > self.length then
        -- return as many bytes as available
        local remain = self.length - i + 1
        return self.source:sub(i, i + remain - 1), remain
    end
    return self.source:sub(i, i + len - 1), len
end

-- Consume one UTF-8 character (advances index by character length)
local function getUtf8(self)
    local ch, len = peekUtf8(self)
    if ch == Tokenizer.EOF_CHAR then
        logger:error(generateError(self, "Unexpected end of Input"));
    end
    -- advance index by len
    self.index = self.index + len
    return ch
end

-- Check whether a character (single-byte ASCII or multi-byte utf8 string) is a valid identifier start
local function isIdentStartChar(self, ch)
    if not ch or ch == Tokenizer.EOF_CHAR then return false end
    local b = string.byte(ch, 1)
    if b <= 127 then
        -- ASCII: letter or underscore
        return not not ch:match("^[A-Za-z_]$")
    end
    -- Non-ASCII UTF-8 sequence: accept as letter (best-effort)
    return true
end

-- Check whether a character is valid as identifier continuation (letters, digits, underscore, unicode)
local function isIdentChar(self, ch)
    if not ch or ch == Tokenizer.EOF_CHAR then return false end
    local b = string.byte(ch, 1)
    if b <= 127 then
        return not not ch:match("^[A-Za-z0-9_]$")
    end
    -- Non-ASCII UTF-8 sequence: accept (best-effort)
    return true
end

function Tokenizer:parseAnnotation()
	if is(self, Tokenizer.ANNOTATION_START_CHARS) then
		self.index = self.index + 1;
		local source, length = {}, 0;
		while(is(self, Tokenizer.ANNOTATION_CHARS)) do
			source[length + 1] = get(self)
			length = #source
		end
		if length > 0 then
			self.annotations[string.lower(table.concat(source))] = true;
		end
		return nil;
	end
	return get(self);
end

-- skip one or 0 Comments and return wether one was found
function Tokenizer:skipComment()
	if(is(self, "-", 0) and is(self, "-", 1)) then
		self.index = self.index + 2;
		if(is(self, "[")) then
			self.index = self.index + 1;
			local eqCount = 0;
			while(is(self, "=")) do
				self.index = self.index + 1;
				eqCount = eqCount + 1;
			end
			if(is(self, "[")) then
				-- Multiline Comment
				-- Get all Chars to Closing bracket but also consider that the count of equal signs must be the same
				while true do
                    -- Check for EOF before parsing annotation
                    if peek(self) == Tokenizer.EOF_CHAR then
                        logger:error(generateError(self, "Unterminated multi-line comment"));
                    end
					if(self:parseAnnotation() == ']') then
						local eqCount2 = 0;
						while(is(self, "=")) do
							self.index = self.index + 1;
							eqCount2 = eqCount2 + 1;
						end
						if(is(self, "]")) then
							if(eqCount2 == eqCount) then
								self.index = self.index + 1;
								return true
							end
						end
					end
				end
			end
		end
		-- Single Line Comment
		-- Get all Chars to next Newline
		while(self.index < self.length and self:parseAnnotation() ~= "\n") do end
		return true;
	end
	return false;
end

-- skip All Whitespace and Comments to next Token
function Tokenizer:skipWhitespaceAndComments()
	while self:skipComment() do end
	while is(self, Tokenizer.WHITESPACE_CHARS) do
		self.index = self.index + 1;
		while self:skipComment() do end
	end
end

local function int(self, chars, seperators)
	local buffer = {};
	while true do
		if (is(self, chars)) then
			buffer[#buffer + 1] = get(self)
		elseif (is(self, seperators)) then
			self.index = self.index + 1;
		else
			break
		end
	end
	return table.concat(buffer);
end

-- Lex the next token as a Number
function Tokenizer:number()
	local startPos = self.index;
	local source   = expect(self, setmetatable({["."] = true}, {__index = self.NumberCharsLookup}));
	
	if source == "0" then
		if self.BinaryNums and is(self, lookupify(self.BinaryNums)) then
			self.index = self.index + 1;
			source = int(self, self.BinaryNumberCharsLookup, lookupify(self.DecimalSeperators or {}));
			local value = tonumber(source, 2);
			return token(self, startPos, Tokenizer.TokenKind.Number, value);
		end
		
		if self.HexadecimalNums and is(self, lookupify(self.HexadecimalNums)) then
			self.index = self.index + 1;
			source = int(self, self.HexNumberCharsLookup, lookupify(self.DecimalSeperators or {}));
			local value = tonumber("0x" .. source); -- Prepend 0x for tonumber to work correctly
			return token(self, startPos, Tokenizer.TokenKind.Number, value);
		end
	end
	
	if source == "." then
		source = source .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}));
	else
		source = source .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}));
		if(is(self, ".")) then
			source = source .. get(self) .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}));
		end
	end
	
	if(self.DecimalExponent and is(self, lookupify(self.DecimalExponent))) then
		source = source .. get(self);
		if(is(self, lookupify({"+","-"}))) then
			source = source .. get(self);
		end
		local v = int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}));
		if(v:len() < 1) then
			logger:error(generateError(self, "Expected a Valid Exponent!"));
		end
		source = source .. v;
	end
	
	local value = tonumber(source);
	return token(self, startPos, Tokenizer.TokenKind.Number, value);
end

-- Lex the Next Token as Identifier or Keyword
function Tokenizer:ident()
    local startPos = self.index;

    -- If Unicode identifiers disabled, fallback to old behavior
    if not self.AllowUnicodeIdentifiers then
        local source = expect(self, self.IdentCharsLookup)
        local sourceAddContent = {source}
        while(is(self, self.IdentCharsLookup)) do
            table.insert(sourceAddContent, get(self))
        end
        source = table.concat(sourceAddContent)
        if(self.KeywordsLookup[source]) then
            return token(self, startPos, Tokenizer.TokenKind.Keyword, source);
        end
        local tk = token(self, startPos, Tokenizer.TokenKind.Ident, source);
        if(string.sub(source, 1, string.len(config.IdentPrefix)) == config.IdentPrefix) then
            logger:warn(generateWarning(tk, string.format("identifiers should not start with \"%s\" as this may break the program", config.IdentPrefix)));
        end
        return tk;
    end

    -- Unicode-aware: read first character (must be letter/_ or non-ascii)
    local ch = peekUtf8(self)
    if ch == Tokenizer.EOF_CHAR then
        logger:error(generateError(self, "Unexpected end of Input"));
    end

    if not isIdentStartChar(self, ch) then
        logger:error(generateError(self, "Unexpected char when starting identifier: " .. escape(ch)));
    end

    -- consume first utf8 char
    local parts = { getUtf8(self) }

    -- read continuation chars (ascii alnum/_ or unicode)
    while true do
        local nextCh = peekUtf8(self)
        if nextCh == Tokenizer.EOF_CHAR then break end
        if not isIdentChar(self, nextCh) then break end
        table.insert(parts, getUtf8(self))
    end

    local source = table.concat(parts)
    if(self.KeywordsLookup[source]) then
        return token(self, startPos, Tokenizer.TokenKind.Keyword, source);
    end

    local tk = token(self, startPos, Tokenizer.TokenKind.Ident, source);
    if(string.sub(source, 1, string.len(config.IdentPrefix)) == config.IdentPrefix) then
        logger:warn(generateWarning(tk, string.format("identifiers should not start with \"%s\" as this may break the program", config.IdentPrefix)));
    end
    return tk;
end

function Tokenizer:singleLineString()
	local startPos = self.index;
	local startChar = expect(self, self.StringStartLookup);
	local buffer = {};

	while (not is(self, startChar)) do
        if peek(self) == Tokenizer.EOF_CHAR then
            logger:error(generateError(self, "Unterminated String"));
        end
		local char = get(self);
		
		-- Single Line String may not contain Linebreaks except when they are escaped by \
		if(char == '\n') then
			self.index = self.index - 1;
			logger:error(generateError(self, "Unterminated String"));
		end
		
		
		if(char == "\\") then
			char = get(self);
			
			local escape = self.EscapeSequences[char];
			if(type(escape) == "string") then
				char = escape;
				
			elseif(self.NumericalEscapes and self.NumberCharsLookup[char]) then
				local numstr = char;
				
				if(is(self, self.NumberCharsLookup)) then
					char = get(self);
					numstr = numstr .. char;
				end
		
				if(is(self, self.NumberCharsLookup)) then
					char = get(self);
					numstr = numstr .. char;
				end
				
				char = string.char(tonumber(numstr));
				
			elseif(self.UnicodeEscapes and char == "u") then
				expect(self, "{");
				local num = "";
				while (is(self, self.HexNumberCharsLookup)) do
					num = num .. get(self);
				end
				expect(self, "}");
				char = util.utf8char(tonumber(num, 16));
			elseif(self.HexEscapes and char == "x") then
				local hex = expect(self, self.HexNumberCharsLookup) .. expect(self, self.HexNumberCharsLookup);
				char = string.char(tonumber(hex, 16));
			elseif(self.EscapeZIgnoreNextWhitespace and char == "z") then
				char = "";
				while(is(self, Tokenizer.WHITESPACE_CHARS)) do
					self.index = self.index + 1;
				end
			end
		end
		
		--// since table.insert is slower in lua51
		buffer[#buffer + 1] = char
	end
	
	expect(self, startChar);
	
	return token(self, startPos, Tokenizer.TokenKind.String, table.concat(buffer))
end

function Tokenizer:multiLineString()
	local startPos = self.index;
	if(is(self, "[")) then
		self.index = self.index + 1;
		local eqCount = 0;
		while(is(self, "=")) do
			self.index = self.index + 1;
			eqCount = eqCount + 1;
		end
		if(is(self, "[")) then
			-- Multiline String
			-- Parse String to Closing bracket but also consider that the count of equal signs must be the same
			
			-- Skip Leading newline if existing
			self.index = self.index + 1;
			if(is(self, "\n")) then
				self.index = self.index + 1;
			end
			
			local value = "";
			while true do
				local char = get(self);
				if(char == ']') then
					local eqCount2 = 0;
					while(is(self, "=")) do
						char = char .. get(self);
						eqCount2 = eqCount2 + 1;
					end
					if(is(self, "]")) then
						if(eqCount2 == eqCount) then
							self.index = self.index + 1;
							return token(self, startPos, Tokenizer.TokenKind.String, value), true
						end
					end
				end
				value = value .. char;
			end
		end
	end
	self.index = startPos;
	return nil, false -- There was not an actual multiline string at the given Position
end
--[[
function Tokenizer:multiLineString()
	local startPos = self.index;
	if(is(self, "[")) then
		self.index = self.index + 1;
		local eqCount = 0;
		while(is(self, "=")) do
			self.index = self.index + 1;
			eqCount = eqCount + 1;
		end
		if(is(self, "[")) then
			-- Multiline String
			-- Parse String to Closing bracket but also consider that the count of equal signs must be the same
			
			-- Skip Leading newline if existing
			self.index = self.index + 1;
			if(is(self, "\n")) then
				self.index = self.index + 1;
			end
			
			local value = "";
			while true do
                if peek(self) == Tokenizer.EOF_CHAR then
                    logger:error(generateError(self, "Unterminated multi-line string"));
                end

				local char = get(self);
				if(char == ']') then
					local eqCount2 = 0;
					while(is(self, "=")) do
						-- Don't actually consume the chars yet
						char = char .. peek(self, eqCount2);
						eqCount2 = eqCount2 + 1;
					end
					if(is(self, "]", eqCount2)) then
						if(eqCount2 == eqCount) then
                            -- Now consume the characters
                            self.index = self.index + eqCount2 + 1;
							return token(self, startPos, Tokenizer.TokenKind.String, value), true
						end
					end
				end
				value = value .. char;
			end
		end
	end
	self.index = startPos;
	return nil, false -- There was not an actual multiline string at the given Position
end
]]
function Tokenizer:symbol()
	local startPos = self.index;
	for len = self.MaxSymbolLength, 1, -1 do
		local str = self.source:sub(self.index + 1, self.index + len);
		if self.SymbolsLookup[str] then
			self.index = self.index + len;
			return token(self, startPos, Tokenizer.TokenKind.Symbol, str);
		end
	end
	logger:error(generateError(self, "Unknown Symbol"));
end


-- get the Next token
function Tokenizer:next()
	-- Skip All Whitespace before the token
	self:skipWhitespaceAndComments();
	
	local startPos = self.index;
	if startPos >= self.length then
		return token(self, startPos, Tokenizer.TokenKind.Eof);
	end
	
	-- Numbers
	if(is(self, self.NumberCharsLookup)) then
		return self:number();
	end
	
	-- Identifiers and Keywords (Unicode-aware)
	if self.AllowUnicodeIdentifiers then
		-- peekUtf8 and isIdentStartChar are defined above
		local ch = peekUtf8(self)
		if ch ~= Tokenizer.EOF_CHAR and isIdentStartChar(self, ch) then
			return self:ident();
		end
	else
		if(is(self, self.IdentCharsLookup)) then
			return self:ident();
		end
	end
	
	-- Singleline String Literals
	if(is(self, self.StringStartLookup)) then
		return self:singleLineString();
	end
	
	-- Multiline String Literals
	if(is(self, "[", 0)) then
		-- The isString variable is due to the fact that "[" could also be a symbol for indexing
		local value, isString = self:multiLineString();
		if isString then
			return value;
		end
	end

	-- Number starting with dot
	if(is(self, ".") and is(self, self.NumberCharsLookup, 1)) then
		return self:number();
	end
	
	-- Symbols
	if(is(self, self.SymbolCharsLookup)) then
		return self:symbol();
	end
	

	logger:error(generateError(self, "Unexpected char \"" .. escape(peek(self)) .. "\"!"));
end

function Tokenizer:scanAll()
	local tb = {};
	repeat
		local token = self:next();
		table.insert(tb, token);
	until token.kind == Tokenizer.TokenKind.Eof
	return tb
end

return setmetatable(Tokenizer, {
    __call = function(self, code) 
        local tokenizer = Tokenizer:new()
        tokenizer:append(code)
        return tokenizer:scanAll()
    end
})


end)__bundle_register("obfLT9.enums", function(require, _LOADED, __bundle_register, __bundle_modules)
local Enums = {};

local chararray = require("obfLT9.util").chararray;

Enums.LuaVersion = {
	LuaU  = "LuaU" ,
	Lua51 = "Lua51",
	Lua53 = "Lua53",
}

Enums.Conventions = {
	[Enums.LuaVersion.Lua51] = {
		Keywords = {
			"and",    "break",  "do",    "else",     "elseif", 
			"end",    "false",  "for",   "function", "if",   
			"in",     "local",  "nil",   "not",      "or",
			"repeat", "return", "then",  "true",     "until",    "while"
		},
		
		SymbolChars = chararray("+-*/%^#=~<>(){}[];:,."),
		MaxSymbolLength = 3,
		Symbols = {
			"+",  "-",  "*",  "/",  "%",  "^",  "#",
			"==", "~=", "<=", ">=", "<",  ">",  "=",
			"(",  ")",  "{",  "}",  "[",  "]",
			";",  ":",  ",",  ".",  "..", "...",
		},

		IdentChars          = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"),
		NumberChars         = chararray("0123456789"),
		HexNumberChars      = chararray("0123456789abcdefABCDEF"),
		BinaryNumberChars   = {"0", "1"},
		DecimalExponent     = {"e", "E"},
		HexadecimalNums     = {"x", "X"},
		BinaryNums          = {"b", "B"},
		DecimalSeperators   = false,
		
		EscapeSequences     = {
			["a"] = "\a";
			["b"] = "\b";
			["f"] = "\f";
			["n"] = "\n";
			["r"] = "\r";
			["t"] = "\t";
			["v"] = "\v";
			["\\"] = "\\";
			["\""] = "\"";
			["\'"] = "\'";
		},
		NumericalEscapes = true,
		EscapeZIgnoreNextWhitespace = true,
		HexEscapes = true,
		UnicodeEscapes = true,
	},
	
	[Enums.LuaVersion.Lua53] = {
		Keywords = {
			"and",    "break",  "do",    "else",     "elseif", 
			"end",    "false",  "for",   "function", "if",   
			"in",     "local",  "nil",   "not",      "or",
			"repeat", "return", "then",  "true",     "until",    "while",
			"goto",
		},
		
		SymbolChars = chararray("+-*/%&|^#=~<>(){}[];:,."),
		MaxSymbolLength = 3,
		Symbols = {
			"+",  "-",  "*",  "/",  "%",  "^",  "#",
			"==", "~=", "<=", ">=", "<",  ">",  "=",
			"&", "~", "|", "<<", ">>", "//", "::",
			"(",  ")",  "{",  "}",  "[",  "]",
			";",  ":",  ",",  ".",  "..", "...",
		},

		IdentChars          = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"),
		NumberChars         = chararray("0123456789"),
		HexNumberChars      = chararray("0123456789abcdefABCDEF"),
		BinaryNumberChars   = {"0", "1"},
		DecimalExponent     = {"e", "E"},
		HexadecimalNums     = {"x", "X"},
		BinaryNums          = {"b", "B"},
		DecimalSeperators   = false,
		
		EscapeSequences     = {
			["a"] = "\a";
			["b"] = "\b";
			["f"] = "\f";
			["n"] = "\n";
			["r"] = "\r";
			["t"] = "\t";
			["v"] = "\v";
			["\\"] = "\\";
			["\""] = "\"";
			["\'"] = "\'";
		},
		NumericalEscapes = true,
		EscapeZIgnoreNextWhitespace = true,
		HexEscapes = true,
		UnicodeEscapes = true,
	},
	
	[Enums.LuaVersion.LuaU] = {
		Keywords = {
			"and",    "break",  "do",    "else",     "elseif", "continue",
			"end",    "false",  "for",   "function", "if",   
			"in",     "local",  "nil",   "not",      "or",
			"repeat", "return", "then",  "true",     "until",    "while"
		},
		
		SymbolChars = chararray("+-*/%^#=~<>(){}[];:,."),
		MaxSymbolLength = 3,
		Symbols = {
			"+",  "-",  "*",  "/",  "%",  "^",  "#",
			"==", "~=", "<=", ">=", "<",  ">",  "=",
			"+=", "-=", "/=", "%=", "^=", "..=", "*=",
			"(",  ")",  "{",  "}",  "[",  "]",
			";",  ":",  ",",  ".",  "..", "...",
			"::", "->", "?",  "|",  "&", 
		},

		IdentChars          = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"),
		NumberChars         = chararray("0123456789"),
		HexNumberChars      = chararray("0123456789abcdefABCDEF"),
		BinaryNumberChars   = {"0", "1"},
		DecimalExponent     = {"e", "E"},
		HexadecimalNums     = {"x", "X"},
		BinaryNums          = {"b", "B"},
		DecimalSeperators   = {"_"},
		
		EscapeSequences     = {
			["a"] = "\a";
			["b"] = "\b";
			["f"] = "\f";
			["n"] = "\n";
			["r"] = "\r";
			["t"] = "\t";
			["v"] = "\v";
			["\\"] = "\\";
			["\""] = "\"";
			["\'"] = "\'";
		},
		NumericalEscapes = true,
		EscapeZIgnoreNextWhitespace = true,
		HexEscapes = true,
		UnicodeEscapes = true,
	},
}

return Enums;

end)__bundle_register("obfLT9.util", function(require, _LOADED, __bundle_register, __bundle_modules)
local logger = require("logger");
local bit32  = require("obfLT9.bit").bit32;

local MAX_UNPACK_COUNT = 195;

table.__index = table

function table.new(...)
 return setmetatable({}, table):union(...)
end

setmetatable(table, {
 __call = function(t, ...)
  return table.new(...)
 end
})

function table:union(...)
 for i=1,select('#', ...) do
  local o = select(i, ...)
  if o then
   for k,v in pairs(o) do
    self[k] = v
   end
  end
 end
 return self
end

local function lookupify(tb)
	local tb2 = {};
	for _, v in ipairs(tb) do
		tb2[v] = true
	end
	return tb2
end

local function unlookupify(tb)
	local tb2 = {};
	for v, _ in pairs(tb) do
		table.insert(tb2, v);
	end
	return tb2;
end
local function isNumberInRange(n, min, max)
     return n ~= nil and n >= min and n <= max
end
local function escape3(str, outlua)
    if type(str) == "string" then
        local buffer, R, s, doubleCount, singleCount, pos = table(), isNumberInRange, str, str:find('\"') and 1 or 0, str:find('\'') and 1 or 0, outlua and 1 or 0;
		local quote       = singleCount < doubleCount and "'" or '"'
		local quoteByte   = quote:byte()
		
		if outlua then buffer:insert(quote); end
		while pos <= #s do
			local b1, b2, b3, b4 = string.byte(s, pos, pos+3)
			local sz = 1
			
			-- Printable ASCII.
			if R(b1,32,126) then
				if b1 == quoteByte then
				    buffer:insert("\\") ; buffer:insert(quote)
				elseif b1 == 92 then
				    buffer:insert([[\\]])
				else
				    buffer:insert(s:sub(pos, pos))
				end
			
			-- Multi-byte UTF-8 sequence.
			elseif b2 and R(b1,194,223) and R(b2,128,191) then
			    buffer:insert(s:sub(pos, pos+1)) ; sz = 2
			elseif b3 and b1== 224 and R(b2,160,191) and R(b3,128,191) then
			    buffer:insert(s:sub(pos, pos+2)) ; sz = 3
			elseif b3 and R(b1,225,236) and R(b2,128,191) and R(b3,128,191) then
			    buffer:insert(s:sub(pos, pos+2)) ; sz = 3
			elseif b3 and b1== 237 and R(b2,128,159) and R(b3,128,191) then
			    buffer:insert(s:sub(pos, pos+2)) ; sz = 3
			elseif b3 and R(b1,238,239) and R(b2,128,191) and R(b3,128,191) then
			    buffer:insert(s:sub(pos, pos+2)) ; sz = 3
			elseif b4 and b1== 240 and R(b2,144,191) and R(b3,128,191) and R(b4,128,191) then
			    buffer:insert(s:sub(pos, pos+3)) ; sz = 4
			elseif b4 and R(b1,241,243) and R(b2,128,191) and R(b3,128,191) and R(b4,128,191) then
			    buffer:insert(s:sub(pos, pos+3)) ; sz = 4
			elseif b4 and b1== 244 and R(b2,128,143) and R(b3,128,191) and R(b4,128,191) then
			    buffer:insert(s:sub(pos, pos+3)) ; sz = 4
			
			-- Escape sequence.
			elseif b1 == 7  then
			    buffer:insert([[\a]])
			elseif b1 == 8  then
			    buffer:insert([[\b]])
			elseif b1 == 9  then
			    buffer:insert([[\t]])
			elseif b1 == 10 then
			    buffer:insert([[\n]])
			elseif b1 == 11 then
			    buffer:insert([[\v]])
			elseif b1 == 12 then
			    buffer:insert([[\f]])
			elseif b1 == 13 then
			    buffer:insert([[\r]])
			
			-- Other control character or anything else.
			elseif b2 and R(b2,48,57) then
			    buffer:insert(([[\%03d]]):format(b1))
			else
			    buffer:insert(([[\%d]]):format(b1))
			end
			pos = pos + sz
		end
		if outlua then buffer:insert(quote); end
		return buffer:concat()
	else
		return nil, string.format("Error: Failed outputting '%s' value '%s'.", type(str), tostring(str))
	end
end

local function escape(str, out)
    -- Bảng các ký tự đặc biệt và dạng escape tương ứng
    local escapes = {
        ["\\"] = "\\\\",
        ["\a"] = "\\a",
        ["\b"] = "\\b",
        ["\f"] = "\\f",
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t",
        ["\v"] = "\\v",
        ["\""] = "\\\"",
        ["\'"] = "\\\'"
    }
    local result = table()
    local i = 1
    local len = #str
    
    if out then result:insert("\"") end
    while i <= len do
        local byte = str:byte(i)
        local char, char_len

        -- Kiểm tra ký tự UTF-8 dựa trên byte đầu tiên
        if byte >= 0xF0 then
            char_len = 4
        elseif byte >= 0xE0 then
            char_len = 3
        elseif byte >= 0xC0 then
            char_len = 2
        elseif byte < 0x80 then
            char_len = 1
        else
            char_len = 1 -- Ký tự không hợp lệ
        end

        -- Lấy ký tự hiện tại
        char = str:sub(i, i + char_len - 1)
        
        -- Kiểm tra hợp lệ của ký tự
        if utf8.len(char) then
            result:insert(escapes[char] or char) -- Giữ nguyên nếu hợp lệ
        else
            result:insert(("\\%03d"):format(char:byte())) -- "�" Thêm ký tự lỗi nếu không hợp lệ
        end
        
        -- Chuyển đến vị trí tiếp theo
        i = i + char_len
    end
    if out then result:insert("\"") end
    return result:concat()
end


local function escape2(str)
	return str:gsub(".", function(char)
		if char:match("[^ %-~\n\t\a\b\v\r\"\']") then -- Check if non Printable ASCII Character
			return char:gsub("\\", "\\\\")--string.format("\\%03d", string.byte(char))
		end
		if(char == "\\") then
			return "\\\\";
		end
		if(char == "\n") then
			return "\\n";
		end
		if(char == "\r") then
			return "\\r";
		end
		if(char == "\t") then
			return "\\t";
		end
		if(char == "\a") then
			return "\\a";
		end
		if(char == "\b") then
			return "\\b";
		end
		if(char == "\v") then
			return "\\v";
		end
		if(char == "\"") then
			return "\\\"";
		end
		if(char == "\'") then
			return "\\\'";
		end
		return char;
	end)
end

string.escape = escape

local function chararray(str)
	local tb = {};
	for i = 1, str:len(), 1 do
		table.insert(tb, str:sub(i, i));
	end
	return tb;
end

local function keys(tb)
	local keyset={}
	local n=0
	for k,v in pairs(tb) do
		n=n+1
		keyset[n]=k
	end
	return keyset
end

local utf8char;
do
	local string_char = string.char
	function utf8char(cp)
	  if cp < 128 then
		return string_char(cp)
	  end
	  local suffix = cp % 64
	  local c4 = 128 + suffix
	  cp = (cp - suffix) / 64
	  if cp < 32 then
		return string_char(192 + cp, c4)
	  end
	  suffix = cp % 64
	  local c3 = 128 + suffix
	  cp = (cp - suffix) / 64
	  if cp < 16 then
		return string_char(224 + cp, c3, c4)
	  end
	  suffix = cp % 64
	  cp = (cp - suffix) / 64
	  return string_char(240 + cp, 128 + suffix, c3, c4)
	end
  end

local function shuffle(tb)
	for i = #tb, 2, -1 do
		local j = math.random(i)
		tb[i], tb[j] = tb[j], tb[i]
	end
	return tb
end
local function shuffle_string(str)
    local len = #str
    local t = {}
    for i = 1, len do
        t[i] = string.sub(str, i, i)
    end
    for i = 1, len do
        local j = math.random(i, len)
        t[i], t[j] = t[j], t[i]
    end
    return table.concat(t)
end

local function readDouble(bytes) 
	local sign = 1
	local mantissa = bytes[2] % 2^4
	for i = 3, 8 do
		mantissa = mantissa * 256 + bytes[i]
	end
	if bytes[1] > 127 then sign = -1 end
	local exponent = (bytes[1] % 128) * 2^4 + math.floor(bytes[2] / 2^4)

	if exponent == 0 then
		return 0
	end
	mantissa = (math.ldexp(mantissa, -52) + 1) * sign
	return math.ldexp(mantissa, exponent - 1023)
end

local function writeDouble(num)
	local bytes = {0,0,0,0, 0,0,0,0}
	if num == 0 then
		return bytes
	end
	local anum = math.abs(num)

	local mantissa, exponent = math.frexp(anum)
	exponent = exponent - 1
	mantissa = mantissa * 2 - 1
	local sign = num ~= anum and 128 or 0
	exponent = exponent + 1023

	bytes[1] = sign + math.floor(exponent / 2^4)
	mantissa = mantissa * 2^4
	local currentmantissa = math.floor(mantissa)
	mantissa = mantissa - currentmantissa
	bytes[2] = (exponent % 2^4) * 2^4 + currentmantissa
	for i= 3, 8 do
		mantissa = mantissa * 2^8
		currentmantissa = math.floor(mantissa)
		mantissa = mantissa - currentmantissa
		bytes[i] = currentmantissa
	end
	return bytes
end

local function writeU16(u16)
	if (u16 < 0 or u16 > 65535) then
		logger:error(string.format("u16 out of bounds: %d", u16));
	end
	local lower = bit32.band(u16, 255);
	local upper = bit32.rshift(u16, 8);
	return {lower, upper}
end

local function readU16(arr)
	return bit32.bor(arr[1], bit32.lshift(arr[2], 8));
end

local function writeU24(u24)
	if(u24 < 0 or u24 > 16777215) then
		logger:error(string.format("u24 out of bounds: %d", u24));
	end
	
	local arr = {};
	for i = 0, 2 do
		arr[i + 1] = bit32.band(bit32.rshift(u24, 8 * i), 255);
	end
	return arr;
end

local function readU24(arr)
	local val = 0;

	for i = 0, 2 do
		val = bit32.bor(val, bit32.lshift(arr[i + 1], 8 * i));
	end

	return val;
end

local function writeU32(u32)
	if(u32 < 0 or u32 > 4294967295) then
		logger:error(string.format("u32 out of bounds: %d", u32));
	end

	local arr = {};
	for i = 0, 3 do
		arr[i + 1] = bit32.band(bit32.rshift(u32, 8 * i), 255);
	end
	return arr;
end

local function readU32(arr)
	local val = 0;

	for i = 0, 3 do
		val = bit32.bor(val, bit32.lshift(arr[i + 1], 8 * i));
	end

	return val;
end

local function bytesToString(arr)
	local lenght = arr.n or #arr;

	if lenght < MAX_UNPACK_COUNT then
		return string.char(table.unpack(arr))
	end

	local str = "";
	local overflow = lenght % MAX_UNPACK_COUNT;

	for i = 1, (#arr - overflow) / MAX_UNPACK_COUNT do
		str = str .. string.char(table.unpack(arr, (i - 1) * MAX_UNPACK_COUNT + 1, i * MAX_UNPACK_COUNT));
	end

	return str..(overflow > 0 and string.char(table.unpack(arr, lenght - overflow + 1, lenght)) or "");
end

local function isNaN(n)
	return type(n) == "number" and n ~= n;
end

local function isInt(n)
	return math.floor(n) == n;
end

local function isU32(n)
	return n >= 0 and n <= 4294967295 and isInt(n);
end

local function toBits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
	local rest;
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end


local function readonly(obj)
	local r = newproxy(true);
	getmetatable(r).__index = obj;
	return r;
end

return {
	lookupify = lookupify,
	unlookupify = unlookupify,
	escape = escape,
	chararray = chararray,
	keys = keys,
	shuffle = shuffle,
	shuffle_string = shuffle_string,
	readDouble = readDouble,
	writeDouble = writeDouble,
	readU16 = readU16,
	writeU16 = writeU16,
	readU32 = readU32,
	writeU32 = writeU32,
	readU24 = readU24,
	writeU24 = writeU24,
	isNaN = isNaN,
	isU32 = isU32,
	isInt = isInt,
	utf8char = utf8char,
	toBits = toBits,
	bytesToString = bytesToString,
	readonly = readonly,
}

end)__bundle_register("logger", function(require, _LOADED, __bundle_register, __bundle_modules)
local logger = {}
local config = require("config");
logger_results = {}

local pprint = function(...)
    print(...)
	if gg then
        gg.toast(...)
	end
    logger_results[#logger_results+1] = (...)
end

local eerror = function(...)
    if gg and gg.alert("\nError!\n\n" .. ... .. "\n\n", "ok", "copy") == 2 then
        gg.copyText(..., false)
    end
    error(...)
end

logger.LogLevel = {
	Error = 0,
	Warn = 1,
	Log = 2,
	Info = 2,
	Debug = 3,
}

logger.logLevel = logger.LogLevel.Error;

logger.debugCallback = function(...)
	pprint(config.NameUpper .. ": " ..  ...)
end;
function logger:debug(...)
	if self.logLevel >= self.LogLevel.Debug then
		self.debugCallback(...);
	end
end

logger.logCallback = function(...)
	pprint(config.NameUpper .. ": " .. ...);
end;
function logger:log(...)
	if self.logLevel >= self.LogLevel.Log then
		self.logCallback(...);
	end
end

function logger:info(...)
	if self.logLevel >= self.LogLevel.Log then
		self.logCallback(...);
	end
end

logger.warnCallback = function(...)
	pprint(config.NameUpper .. ": " .. ...)
end;
function logger:warn(...)
	if self.logLevel >= self.LogLevel.Warn then
		self.warnCallback(...);
	end
end

logger.errorCallback = function(...)
	pprint(config.NameUpper .. ": " .. ...)
	eerror(...);
end;
function logger:error(...)
	self.errorCallback(...);
	eerror(config.NameUpper .. ": logger.errorCallback did not throw an Error!");
end


return logger;

end)__bundle_register("config", function(require, _LOADED, __bundle_register, __bundle_modules)

local NAME    = "obfLT9";
local REVISION = "Alpha";
local VERSION = "v0.1";
local BY      = "VieGG";

-- Config Starts here
return {
	Name = NAME,
	NameUpper = string.upper(NAME),
	NameAndVersion = string.format("%s %s", NAME, VERSION),
	Version = VERSION;
	Revision = REVISION;
	IdentPrefix = "__viegg_";
	SPACE = " "; -- Khoảng trắng được sử dụng bởi trình giải phân tích cú pháp
	TAB   = "\t"; -- Tab Khoảng trắng được sử dụng bởi trình giải mã để in đẹp
}
end)__bundle_register("obfLT9.bit", function(require, _LOADED, __bundle_register, __bundle_modules)
local M = {_TYPE='module', _NAME='bit.numberlua', _VERSION='0.3.1.20120131'}

local floor = math.floor

local MOD = 2^32
local MODM = MOD-1

local function memoize(f)
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k); t[k] = v
		return v
	end
	return t
end

local function make_bitop_uncached(t, m)
	local function bitop(a, b)
		local res,p = 0,1
		while a ~= 0 and b ~= 0 do
			local am, bm = a%m, b%m
			res = res + t[am][bm]*p
			a = (a - am) / m
			b = (b - bm) / m
			p = p*m
		end
		res = res + (a+b)*p
		return res
	end
	return bitop
end

local function make_bitop(t)
	local op1 = make_bitop_uncached(t,2^1)
	local op2 = memoize(function(a)
		return memoize(function(b)
			return op1(a, b)
		end)
	end)
	return make_bitop_uncached(op2, 2^(t.n or 1))
end

-- ok?  probably not if running on a 32-bit int Lua number type platform
function M.tobit(x)
	return x % 2^32
end

M.bxor = make_bitop {[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0}, n=4}
local bxor = M.bxor

function M.bnot(a)   return MODM - a end
local bnot = M.bnot

function M.band(a,b) return ((a+b) - bxor(a,b))/2 end
local band = M.band

function M.bor(a,b)  return MODM - band(MODM - a, MODM - b) end
local bor = M.bor

local lshift, rshift -- forward declare

function M.rshift(a,disp) -- Lua5.2 insipred
	if disp < 0 then return lshift(a,-disp) end
	return floor(a % 2^32 / 2^disp)
end
rshift = M.rshift

function M.lshift(a,disp) -- Lua5.2 inspired
	if disp < 0 then return rshift(a,-disp) end 
	return (a * 2^disp) % 2^32
end
lshift = M.lshift

function M.tohex(x, n) -- BitOp style
	n = n or 8
	local up
	if n <= 0 then
		if n == 0 then return '' end
		up = true
		n = - n
	end
	x = band(x, 16^n-1)
	return ('%0'..n..(up and 'X' or 'x')):format(x)
end
local tohex = M.tohex

function M.extract(n, field, width) -- Lua5.2 inspired
	width = width or 1
	return band(rshift(n, field), 2^width-1)
end
local extract = M.extract

function M.replace(n, v, field, width) -- Lua5.2 inspired
	width = width or 1
	local mask1 = 2^width-1
	v = band(v, mask1) -- required by spec?
	local mask = bnot(lshift(mask1, field))
	return band(n, mask) + lshift(v, field)
end
local replace = M.replace

function M.bswap(x)  -- BitOp style
	local a = band(x, 0xff); x = rshift(x, 8)
	local b = band(x, 0xff); x = rshift(x, 8)
	local c = band(x, 0xff); x = rshift(x, 8)
	local d = band(x, 0xff)
	return lshift(lshift(lshift(a, 8) + b, 8) + c, 8) + d
end
local bswap = M.bswap

function M.rrotate(x, disp)  -- Lua5.2 inspired
	disp = disp % 32
	local low = band(x, 2^disp-1)
	return rshift(x, disp) + lshift(low, 32-disp)
end
local rrotate = M.rrotate

function M.lrotate(x, disp)  -- Lua5.2 inspired
	return rrotate(x, -disp)
end
local lrotate = M.lrotate

M.rol = M.lrotate  -- LuaOp inspired
M.ror = M.rrotate  -- LuaOp insipred


function M.arshift(x, disp) -- Lua5.2 inspired
	local z = rshift(x, disp)
	if x >= 0x80000000 then z = z + lshift(2^disp-1, 32-disp) end
	return z
end
local arshift = M.arshift

function M.btest(x, y) -- Lua5.2 inspired
	return band(x, y) ~= 0
end

--
-- Start Lua 5.2 "bit32" compat section.
--

M.bit32 = {} -- Lua 5.2 'bit32' compatibility


local function bit32_bnot(x)
	return (-1 - x) % MOD
end
M.bit32.bnot = bit32_bnot

local function bit32_bxor(a, b, c, ...)
	local z
	if b then
		a = a % MOD
		b = b % MOD
		z = bxor(a, b)
		if c then
			z = bit32_bxor(z, c, ...)
		end
		return z
	elseif a then
		return a % MOD
	else
		return 0
	end
end
M.bit32.bxor = bit32_bxor

local function bit32_band(a, b, c, ...)
	local z
	if b then
		a = a % MOD
		b = b % MOD
		z = ((a+b) - bxor(a,b)) / 2
		if c then
			z = bit32_band(z, c, ...)
		end
		return z
	elseif a then
		return a % MOD
	else
		return MODM
	end
end
M.bit32.band = bit32_band

local function bit32_bor(a, b, c, ...)
	local z
	if b then
		a = a % MOD
		b = b % MOD
		z = MODM - band(MODM - a, MODM - b)
		if c then
			z = bit32_bor(z, c, ...)
		end
		return z
	elseif a then
		return a % MOD
	else
		return 0
	end
end
M.bit32.bor = bit32_bor

function M.bit32.btest(...)
	return bit32_band(...) ~= 0
end

function M.bit32.lrotate(x, disp)
	return lrotate(x % MOD, disp)
end

function M.bit32.rrotate(x, disp)
	return rrotate(x % MOD, disp)
end

function M.bit32.lshift(x,disp)
	if disp > 31 or disp < -31 then return 0 end
	return lshift(x % MOD, disp)
end

function M.bit32.rshift(x,disp)
	if disp > 31 or disp < -31 then return 0 end
	return rshift(x % MOD, disp)
end

function M.bit32.arshift(x,disp)
	x = x % MOD
	if disp >= 0 then
		if disp > 31 then
			return (x >= 0x80000000) and MODM or 0
		else
			local z = rshift(x, disp)
			if x >= 0x80000000 then z = z + lshift(2^disp-1, 32-disp) end
			return z
		end
	else
		return lshift(x, -disp)
	end
end

function M.bit32.extract(x, field, ...)
	local width = ... or 1
	if field < 0 or field > 31 or width < 0 or field+width > 32 then error 'out of range' end
	x = x % MOD
	return extract(x, field, ...)
end

function M.bit32.replace(x, v, field, ...)
	local width = ... or 1
	if field < 0 or field > 31 or width < 0 or field+width > 32 then error 'out of range' end
	x = x % MOD
	v = v % MOD
	return replace(x, v, field, ...)
end


--
-- Start LuaBitOp "bit" compat section.
--

M.bit = {} -- LuaBitOp "bit" compatibility

function M.bit.tobit(x)
	x = x % MOD
	if x >= 0x80000000 then x = x - MOD end
	return x
end
local bit_tobit = M.bit.tobit

function M.bit.tohex(x, ...)
	return tohex(x % MOD, ...)
end

function M.bit.bnot(x)
	return bit_tobit(bnot(x % MOD))
end

local function bit_bor(a, b, c, ...)
	if c then
		return bit_bor(bit_bor(a, b), c, ...)
	elseif b then
		return bit_tobit(bor(a % MOD, b % MOD))
	else
		return bit_tobit(a)
	end
end
M.bit.bor = bit_bor

local function bit_band(a, b, c, ...)
	if c then
		return bit_band(bit_band(a, b), c, ...)
	elseif b then
		return bit_tobit(band(a % MOD, b % MOD))
	else
		return bit_tobit(a)
	end
end
M.bit.band = bit_band

local function bit_bxor(a, b, c, ...)
	if c then
		return bit_bxor(bit_bxor(a, b), c, ...)
	elseif b then
		return bit_tobit(bxor(a % MOD, b % MOD))
	else
		return bit_tobit(a)
	end
end
M.bit.bxor = bit_bxor

function M.bit.lshift(x, n)
	return bit_tobit(lshift(x % MOD, n % 32))
end

function M.bit.rshift(x, n)
	return bit_tobit(rshift(x % MOD, n % 32))
end

function M.bit.arshift(x, n)
	return bit_tobit(arshift(x % MOD, n % 32))
end

function M.bit.rol(x, n)
	return bit_tobit(lrotate(x % MOD, n % 32))
end

function M.bit.ror(x, n)
	return bit_tobit(rrotate(x % MOD, n % 32))
end

function M.bit.bswap(x)
	return bit_tobit(bswap(x % MOD))
end

return M
end)
return __bundle_require("BuildLT9")