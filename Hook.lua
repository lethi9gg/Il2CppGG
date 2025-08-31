--- @module hook
--- @brief Script Lua để hook memory, hỗ trợ mod game và reverse engineering với GameGuardian.
--- @details Hỗ trợ cả kiến trúc 32-bit và 64-bit, cho phép hook method, param, field, và call.

local gg = gg
--local malloc = require "malloc"
local info = gg.getTargetInfo()
local x64 = info.x64

--- @var pointerFlagsType number Loại flags cho con trỏ (32 cho 64-bit, 4 cho 32-bit)
local pointerFlagsType = x64 and 32 or 4
--- @var pointerSize number Kích thước con trỏ (8 cho 64-bit, 4 cho 32-bit)
local pointerSize = x64 and 8 or 4
--- @var armType number Loại ARM (6 cho 64-bit, 4 cho 32-bit)
local armType = x64 and 6 or 4
--- @var returnType number Kiểu trả về (0x10 cho 64-bit, 0x8 cho 32-bit)
local returnType = x64 and 0x10 or 0x8
--- @var jumpOpcode string Opcode để nhảy (jump) trong memory
local jumpOpcode = x64 and "h5100005820021FD6" or "h04F01FE5"
--- @var nullOpcode string|number Opcode rỗng (null) để điền mặc định
local nullOpcode = x64 and "B4000000h" or 0

--- @function table:union
--- @brief Gộp nhiều bảng vào bảng hiện tại.
--- @param ... table Các bảng cần gộp
--- @return table Bảng hiện tại sau khi gộp
table.__index = table
setmetatable(table, {
    __call = function(t, ...)
        return setmetatable({}, table):union(...)
    end
})
function table:union(...)
    for i = 1, select('#', ...) do
        local o = select(i, ...)
        if o then
            for k, v in pairs(o) do
                self[k] = v
            end
        end
    end
    return self
end

--- @function getValue
--- @brief Lấy giá trị từ memory tại địa chỉ cho trước.
--- @param address number Địa chỉ memory
--- @param flags number|nil Loại flags (nếu nil, dùng mặc định)
--- @return table|number Giá trị từ memory
--- @throws Nếu địa chỉ rỗng
function getValue(address, flags)
    if not address then
        error("địa chỉ rỗng là sao?")
    end
    return not flags and gg.getValues(address) or gg.getValues({{address = address, flags = flags}})[1].value
end

--- @function setValues
--- @brief Set giá trị vào memory và thêm vào danh sách GameGuardian.
--- @param results table Bảng chứa các giá trị {address, flags, value, freeze}
--- @param freeze boolean|nil Nếu true, giữ giá trị trong danh sách
--- @return table Danh sách các giá trị đã set
--- @throws Nếu bảng results rỗng
function setValues(results, freeze)
    if not results or next(results) == nil then
        error("Bảng giá trị rỗng")
    end
    local t = {}
    for i, v in pairs(results) do
        t[#t + 1] = {address = v.address, flags = v.flags, value = v.value, freeze = true}
    end
    gg.addListItems(t)
    gg.removeListItems(freeze and {} or t)
    return t
end

--- @module opcode
--- @brief Module xử lý opcode cho hook.
local opcode = {}

--- @function opcode.generateLDR
--- @brief Tạo opcode LDR để load giá trị từ memory.
--- @param param number Tham số (register index)
--- @param index number Offset trong memory
--- @param flags string Loại flags (int, float, double, string)
--- @param x64 boolean Kiến trúc 64-bit hay không
--- @return string Opcode LDR
function opcode.generateLDR(param, index, flags, x64)
    local iP = string.format("0x%X", index)
    local opR = x64 and flags or "R" .. param
    return x64 and "~A8 LDR " .. opR .. ", [PC,#" .. iP .. "]" or "~A LDR " .. opR .. ", [PC,#" .. (iP - 8) .. "]"
end

--- @function opcode.generateSTR
--- @brief Tạo opcode STR để store giá trị vào memory.
--- @param param number Tham số (register index)
--- @param offset number Offset trong memory
--- @param flags string Loại flags (int, float, double, string)
--- @param x64 boolean Kiến trúc 64-bit hay không
--- @return string Opcode STR
function opcode.generateSTR(param, offset, flags, x64)
    local opR = (x64 and flags or "R") .. param
    return x64 and "~A8 STR " .. opR .. ", [X0,#" .. offset .. "]" or "~A STR " .. opR .. ", [R0,#" .. offset .. "]"
end

--- @table hook
--- @brief Đối tượng chính để hook memory.
local hook = {}

--- @field flags table Ánh xạ loại dữ liệu (int, float, double, string) sang ký hiệu register
hook.flags = {int = "X", float = "S", double = "D", string = "X"}
--- @field type table Ánh xạ loại dữ liệu sang flags của GameGuardian
hook.type = {int = 4, float = 16, double = 64, string = pointerFlagsType}

--- @function hook.addToResults
--- @brief Thêm giá trị vào danh sách kết quả.
--- @param res table Danh sách kết quả
--- @param address number Địa chỉ memory
--- @param flags number Loại flags
--- @param value any Giá trị cần set
function hook.addToResults(res, address, flags, value)
    res[#res + 1] = {address = address, flags = flags, value = value}
end

--- @function hook:searchPointer
--- @brief Tìm kiếm con trỏ trong memory.
--- @param address number Địa chỉ cần tìm
--- @param ranges number|nil Vùng memory để tìm (mặc định: 4 | 32 | -2080896)
--- @return table Danh sách kết quả tìm kiếm
--- @throws Nếu địa chỉ rỗng
function hook:searchPointer(address, ranges)
    if not address then
        error("Địa chỉ rỗng")
    end
    gg.setRanges(ranges or (4 | 32 | -2080896))
    gg.clearResults()
    gg.searchNumber(address, pointerFlagsType)
    local count = gg.getResultsCount()
    if count == 0 and x64 then
        gg.searchNumber(tostring(address | 0xB400000000000000), pointerFlagsType)
        count = gg.getResultsCount()
    end
    if count == 0 then
        print("Không tìm thấy con trỏ nào tại địa chỉ: " .. tostring(address))
        return {}
    end
    local results = gg.getResults(count) or {}
    gg.clearResults()
    return results
end

--- @function hook:off
--- @brief Tắt hook và khôi phục giá trị gốc.
function hook:off()
    if self.on then
        setValues({self.methodInfo})
        self.on = false
        --print("Hook đã off")
    end
end

setmetatable(hook, {
    __call = function(self, ...)
        return setmetatable({...}, {
            __index = self,
            __call = function(self, ...)
                return self:init(...)
            end
        })
    end
})

--- @field hook.call table Instance để hook call
hook.call = hook()
--- @field hook.method table Instance để hook method
hook.method = hook()
--- @field hook.field table Instance để hook field
hook.field = hook()
--- @field hook.param table Instance để hook param
hook.param = hook()

--- @var PARAM_OFFSET number Offset cho param (0x38 cho 64-bit, 0x30 cho 32-bit)
local PARAM_OFFSET = x64 and 0x38 or 0x30
--- @var FIELD_OFFSET number Offset cho field (gấp đôi PARAM_OFFSET)
local FIELD_OFFSET = PARAM_OFFSET * 2
hook.param.offset = { value = PARAM_OFFSET }
hook.field.offset = { value = FIELD_OFFSET }

--- @function hook.method:init
--- @brief Khởi tạo hook cho method.
--- @param methodInfoAddress number Địa chỉ của hàm
--- @return table Instance hook.method
--- @throws Nếu địa chỉ rỗng hoặc không hợp lệ
function hook.method:init(methodInfo)
    if not methodInfo then
        error("Địa chỉ hàm rỗng")
    end
    self.methodInfo = {address = methodInfo.address, value = methodInfo.methodPointer, flags = pointerFlagsType}
    self.methodPointer = self.methodInfo.value
    if self.methodPointer == 0 then
        error("địa chỉ " .. string.format("%X", self.methodPointer) .. " fail")
    end
    self.on = false
    return self
end

--- @function hook.method:call
--- @brief Gọi hàm với địa chỉ con trỏ mới.
--- @param methodPointerAddress number Địa chỉ con trỏ mới
--- @return table Instance hook.call
function hook.method:call(methodInfo)
    return hook.call(self.methodInfo.address)(methodInfo)
end

--- @function hook.method:param
--- @brief Set tham số cho method hook.
--- @param table table Bảng chứa tham số {param, flags, value}
--- @return table Instance hook.method
--- @throws Nếu bảng tham số rỗng hoặc không hợp lệ
function hook.method:param(table)
    if not table or next(table) == nil then
        error("Bảng tham số rỗng")
    end
    if not self.on then
        local values = {
            {address = self.methodPointer, flags = pointerFlagsType},
            {address = self.methodPointer + pointerSize, flags = pointerFlagsType}
        }
        self.results = gg.getValues(values)
        self.alloc = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE | gg.PROT_EXEC)

        local result = {}
        hook.addToResults(result, self.alloc, pointerFlagsType, self.results[1].value)
        hook.addToResults(result, self.alloc + pointerSize, pointerFlagsType, self.results[2].value)
        hook.addToResults(result, self.methodPointer, pointerFlagsType, jumpOpcode)
        hook.addToResults(result, self.methodPointer + pointerSize, pointerFlagsType, self.alloc)

        setValues(result)
        self.param = hook.param(self.methodPointer + (pointerSize * 2), self.alloc + (pointerSize * 2))
        setValues(self.param:setValues(table))
        self.on = true
        return self
    end
    setValues(self.param:setValues(table))
    self.on = true
    return self
end

--- @function hook.method:off
--- @brief Tắt hook method và khôi phục giá trị gốc.
function hook.method:off()
    if self.on then
        setValues(self.results)
        self.on = false
        --print("Method hook off")
    end
end

--- @function hook.param:init
--- @brief Khởi tạo hook cho tham số.
--- @param methodPointerAddress number Địa chỉ hàm
--- @param allocAddress number|nil Địa chỉ phân bổ memory (nếu nil, tự động phân bổ)
--- @return table Instance hook.param
--- @throws Nếu địa chỉ rỗng hoặc không hợp lệ
function hook.param:init(methodPointerAddress, allocAddress)
    if not methodPointerAddress then
        error("Địa chỉ hàm rỗng")
    end
    self.methodPointer = methodPointerAddress
    if self.methodPointer == 0 then
        error("Địa chỉ " .. string.format("%X", self.methodPointer) .. " fail")
    end
    self.alloc = allocAddress or gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE | gg.PROT_EXEC)
    local res = {}
    for i = 0, 9 do
        hook.addToResults(res, self.alloc + (i * 4), 4, nullOpcode)
    end
    hook.addToResults(res, self.alloc + (10 * 4), pointerFlagsType, jumpOpcode)
    hook.addToResults(res, self.alloc + (10 * 4) + (x64 and 8 or 4), pointerFlagsType, methodPointerAddress)
    setValues(res)
    return self
end

--- @function hook.param:setValues
--- @brief Set giá trị cho tham số hook.
--- @param table table Bảng chứa tham số {param, flags, value}
--- @return table Danh sách giá trị để set vào memory
--- @throws Nếu flags không hợp lệ
function hook.param:setValues(table)
    local res = {}
    for i, v in pairs(table) do
        if not v.flags or not self.type[v.flags] then
            error("Loại flags không hợp lệ: " .. tostring(v.flags))
        end
        local param = v.param or i
        local index = (param - 1) * 4
        local iP = self.offset.value + index
        local opLDR = v.flags and opcode.generateLDR(param, iP, self.flags[v.flags], x64) or nullOpcode
        hook.addToResults(res, self.alloc + index, 4, opLDR)
        hook.addToResults(res, self.alloc + index + iP, self.type[v.flags] or 32, v.flags and v.value or 0)
    end
    return res
end

--- @function hook.call:init
--- @brief Khởi tạo hook cho call.
--- @param methodInfoAddress number Địa chỉ hàm
--- @return function Hàm để set địa chỉ con trỏ mới
--- @throws Nếu địa chỉ rỗng hoặc không hợp lệ
function hook.call:init(methodInfo)
    if not methodInfo then
        error("Địa chỉ hàm rỗng")
    end
    self.methodInfo = {address = methodInfo.address, value = methodInfo.methodPointer, flags = pointerFlagsType}
    self.methodPointer = self.methodInfo.value
    if self.methodPointer == 0 then
        error("Địa chỉ " .. string.format("%X", self.methodPointer) .. " fail")
    end
    self.on = false
    return function(methodInfo)
        self.to = methodInfo.methodPointer
        self.param = hook.param(methodInfo.methodPointer)
        self.alloc = self.param.alloc
        return self
    end
end

--- @function hook.call:setValues
--- @brief Set giá trị cho call hook.
--- @param table table Bảng chứa tham số {param, flags, value}
--- @return table Instance hook.call
function hook.call:setValues(table)
    local res = self.param:setValues(table)
    if not self.on then
        hook.addToResults(res, self.methodInfo.address, self.methodInfo.flags, self.alloc)
        self.on = true
    end
    setValues(res)
    return self
end

--- @function hook.field:init
--- @brief Khởi tạo hook cho field.
--- @param methodInfoAddress number Địa chỉ field
--- @return table Instance hook.field
--- @throws Nếu địa chỉ rỗng hoặc không hợp lệ
function hook.field:init(methodInfo)
    if not methodInfo then
        error("Địa chỉ hàm rỗng")
    end
    self.methodInfo = {address = methodInfo.address, value = methodInfo.methodPointer, flags = pointerFlagsType}
    self.methodPointer = self.methodInfo.value
    if self.methodPointer == 0 then
        error("Địa chỉ " .. string.format("%X", self.methodPointer) .. " fail")
    end
    self.on = false
    self.alloc = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE | gg.PROT_EXEC)
    local res = {}
    for i = 0, 18 do
        hook.addToResults(res, self.alloc + (i * 4), 4, nullOpcode)
    end
    hook.addToResults(res, self.alloc + (22 * 4), pointerFlagsType, jumpOpcode)
    hook.addToResults(res, self.alloc + (22 * 4) + (x64 and 8 or 4), pointerFlagsType, self.methodPointer)
    setValues(res)
    return self
end

--- @function hook.field:setValues
--- @brief Set giá trị cho field hook.
--- @param table table Bảng chứa {offset, flags, value}
--- @return table Instance hook.field
--- @throws Nếu offset hoặc flags không hợp lệ
function hook.field:setValues(table)
    local res = {}
    for i, v in pairs(table) do
        if not v.offset or not v.flags or not self.type[v.flags] then
            error("Offset hoặc flags không hợp lệ: " .. tostring(v.flags))
        end
        local offset = v.offset
        local index = (i - 1) * 4
        local iP = self.offset.value + index
        local opR = (x64 and self.flags[v.flags] or "R") .. i
        local opLDR = v.flags and opcode.generateLDR(i, iP, self.flags[v.flags], x64) or nullOpcode
        local opSTR = v.flags and opcode.generateSTR(i, offset, self.flags[v.flags], x64) or nullOpcode
        hook.addToResults(res, self.alloc + index, 4, opLDR)
        hook.addToResults(res, self.alloc + index + 8, 4, opSTR)
        hook.addToResults(res, self.alloc + index + iP, self.type[v.flags] or 32, v.flags and v.value or 0)
    end
    if not self.on then
        hook.addToResults(res, self.methodInfo.address, self.methodInfo.flags, self.alloc)
        self.on = true
    end
    setValues(res)
    return self
end


return hook