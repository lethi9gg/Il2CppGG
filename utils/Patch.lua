local x64 = Il2Cpp.x64


local asmLT9 = {
    type = {
        [2] = 4,
        [4] = 4,
        [5] = 4,
        [6] = 4,
        [7] = 4,
        [8] = 4,
        [9] = 4,
        [12] = 16,
        [13] = 64,
    },
    op_int = x64 and "~A8 MOV W0, #" or "~A MOVT R0, #",
    op_return = (x64 and "~A8 RET" or "~A BX	 LR"),
    
    gV = function(self, value, flags)
        -- Xử lý giá trị bằng bit32 thay vì sử dụng bộ nhớ
        if flags == gg.TYPE_DWORD then
            -- Xử lý giá trị DWORD
            local high16 = bit32.rshift(value, 16)
            high16 = bit32.band(high16, 0xFFFF)
            high16 = high16 + 1
            return bit32.band(bit32.lshift(high16, 16), 0xFFFFFFFF)
        elseif flags == gg.TYPE_FLOAT then
            -- Xử lý giá trị FLOAT
            local int_val = self:floatToInt(value)
            local high16 = bit32.rshift(int_val, 16)
            high16 = bit32.band(high16, 0xFFFF)
            high16 = high16 + 1
            int_val = bit32.band(bit32.lshift(high16, 16), 0xFFFFFFFF)
            if x64 then
                return int_val
            else
                return high16
            end
        else
            -- Xử lý các loại dữ liệu khác
            error("Unsupported flags type in gV")
        end
    end,
    
    floatToInt = function(self, f)
        -- Chuyển đổi float sang integer representation
        local sign = 0
        if f < 0 then
            sign = 0x80000000
            f = -f
        end
        
        local mantissa, exponent = math.frexp(f)
        
        if f == 0 then
            return 0
        elseif f == math.huge then
            return bit32.bor(sign, 0x7F800000)
        end
        
        mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, 24)
        exponent = exponent + 126
        
        if exponent <= 0 then
            mantissa = math.ldexp(mantissa, exponent - 1)
            exponent = 0
        elseif exponent >= 0xFF then
            return bit32.bor(sign, 0x7F800000)
        end
        
        mantissa = math.floor(mantissa + 0.5)
        
        return bit32.bor(sign, bit32.lshift(bit32.band(exponent, 0xFF), 23), 
                         bit32.band(mantissa, 0x7FFFFF))
    end,
    
    getInt = function(self, value, param)
        local param = (param and self.op_int:gsub(0, param) or self.op_int)
        if value > 0 and value < 65535 and not x64 then
            return param:gsub("T", "W") .. value
        elseif x64 and value > -65535 and value < 65535 then
            return param .. value
        end
        local value = self:gV(value, gg.TYPE_DWORD)
        return param .. (x64 and value or math.floor(value / 65535))
    end,
    
    getFloat = function(self, value, param)
        local param = (param and self.op_int:gsub(0, param) or self.op_int)
        if x64 then
            return param .. self:gV(value, gg.TYPE_FLOAT)
        else
            local high16 = self:gV(value, gg.TYPE_FLOAT)
            return param .. high16
        end
    end,
    
    setValues = function(self, address, value, types, flags)
        local results, result = self:init(address, value, types, flags)
        result = gg.getValues(result)
        gg.setValues(results)
        return function() gg.setValues(result) end
    end,
    
    init = function(self, address, value, types, flags)
        local value = value or 0
        local fix
        for i = 0, 4 do
            if gg.disasm(Il2Cpp.armType, 0, Il2Cpp.gV(address + (i * 4), gg.TYPE_DWORD)):find(x64 and "RET" or "BX	 LR") then
                fix = true
                break
            end
        end
        local Flags = {[gg.TYPE_DWORD] = "X",[gg.TYPE_FLOAT] = "S",[gg.TYPE_DOUBLE] = "D"}
        local flags = flags or (self.type[types] or gg.TYPE_DWORD)
        local results
        if x64 and (value == 0 or not value) then
            results = {{address = address, flags = gg.TYPE_DWORD, value = "~A8 MOV W0, WZR"}, {address = address + 4, flags = gg.TYPE_DWORD, value = self.op_return}}
        else
            results = fix and {{address = address, flags = gg.TYPE_DWORD, value = flags == gg.TYPE_DWORD and self:getInt(value) or self:getFloat(value)}, {address = address + 4, flags = gg.TYPE_DWORD, value = self.op_return}} 
            or {{address = address, flags = gg.TYPE_DWORD, value = (x64 and "~A8 LDR	 "..(Flags[flags]).."0, [PC,#0x8]" or "~A LDR	 R0, [PC]")},
                {address = address + 4, flags = gg.TYPE_DWORD, value = (x64 and "~A8 RET" or "~A BX	 LR")},
                {address = address + 8, flags = flags, value = value}}
        end
        local result = {}
        for i = 0, 4 do
            result[i+1] = {address = address + (i * 4), flags = gg.TYPE_DWORD}
        end
        return results, gg.getValues(result)
    end
}





return setmetatable({}, {
    __index = asmLT9,
    __call = asmLT9.init 
})
