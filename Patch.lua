local x64 = Il2Cpp.x64
local asmLT9 = {
    op = gg.allocatePage(1|2|4),
    op_int = x64 and "~A8 MOV W0, #" or "~A MOVT R0, #",
    op_return = (x64 and "~A8 RET" or "~A BX	 LR"),
    
    gV = function(self, value, flags)
        gg.setValues({
        {address = self.op, flags = 32, value = 0},
        {address = self.op, flags = flags, value = value},
        {address = self.op, flags = 2, value = 0},
        })
        gg.setValues({{address = self.op+2, flags = 2, value = gg.getValues({{address = self.op+2, flags = 2}})[1].value+1}})
        return gg.getValues({{address = self.op, flags = 4}})[1].value
    end,
    getInt = function(self, value, param)
        local param = (param and self.op_int:gsub(0, param) or self.op_int)
        if value > 0 and value < 65535 and not x64 then
            return param:gsub("T", "W") .. value
        elseif x64 and value > -65535 and value < 65535 then
            return param .. value
        end
        local value = self:gV(value, 4)
        return param .. (x64 and value or value / 65535)
    end,
    getFloat = function(self, value, param)
        local param = (param and self.op_int:gsub(0, param) or self.op_int)
        if x64 then
            return param .. self:gV(value, 16)
        else
            self:gV(value, 16)
            return param .. gg.getValues({{address = self.op+2, flags = 2}})[1].value
        end
    end,
    setValues = function(self, address, value, flags)
        local fix
        for i = 0, 4 do
            if gg.disasm(Il2Cpp.armType, 0, Il2Cpp.gV(address + (i * 4), 4)):find(x64 and "RET" or "BX	 LR") then
                fix = true
                break
            end
        end
        local Flags = {[4] = "X",[16] = "S",[64] = "D"}
        local results
        results = fix and {{address = address, flags = 4, value = flags == 4 and self:getInt(value) or self:getFloat(value)}, {address = address + 4, flags = 4, value = self.op_return}} or {[1] = {address = address, flags = 4, value = (x64 and "~A8 LDR	 "..(Flags[flags]).."0, [PC,#0x8]" or "~A LDR	 R0, [PC]")},[2] = {address = address + 4, flags = 4, value = (x64 and "~A8 RET" or "~A BX	 LR")},[3] = {address = address + 8, flags = (flags or 4), value = value}}
        if value == 0 and x64 then
            results = {{address = address, flags = 4, value = "~A8 MOV W0, WZR"}, {address = address + 4, flags = 4, value = self.op_return}}
        end
        local result = {}
        for i = 0, #results -1 do
            result[i+1] = {address = address + (i * 4), flags = 4}
        end
        result = gg.getValues(result)
        gg.setValues(results)
        return function() gg.setValues(result) end
    end
}
return asmLT9