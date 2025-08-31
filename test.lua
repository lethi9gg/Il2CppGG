-- Il2CppGG by LeThi9GG
require("init")


-- VÍ DỤ SỬ DỤNG

-- Get Image By Name
local Assembly = Il2Cpp.Image("Assembly-CSharp") -- Get all images Il2Cpp.Image()
-- Tìm Class Theo Image
local PlayerScript = Assembly:Class(nil, "PlayerScript") -- (namespace, classname)

-- Tìm Class Theo (ClassInfoAddress, Tên, Index) (Gợi Ý Dùng GetIndex() Để Lấy Index Của Class Nó Sẽ Nhanh Hơn Rất Nhiều)
--local PlayerScript = Il2Cpp.Class("PlayerScript")
--print(PlayerScript:GetIndex())

-- Tìm Method Trong Class Bằng Tên Hoặc GetMethods() Tất Cả Method
local LateUpdate = PlayerScript:GetMethod("LateUpdate")
local addPoints = PlayerScript:GetMethod("addPoints")

-- Tìm Field Trong Class Bằng Tên Hoặc GetFields() Tất Cả Field
local points = PlayerScript:GetField("points")

-- Tìm Field Bằng Tên Hoặc FieldInfoAddress
--local points = Il2Cpp.Field("points")

-- Tìm Method Bằng Tên Hoặc MethodInfoAddress
--local AddPoints = Il2Cpp.Method("AddPoints")


-- Ví Dụ Chỉnh sửa Field
local obj = PlayerScript:GetInstance()
points:SetValue(obj, 1000)


-- DUMP output C#
--print( PlayerScript:Dump() )


-- Hooking

-- hook field(points) bằng method(LateUpdate)
local _LateUpdate = LateUpdate:field()
_LateUpdate:setValues({{offset = points.offset, flags = "int", value = 9999}})
gg.sleep(10000)
_LateUpdate:off()


-- hook param của method(addPoints)
local _addPoints = addPoints:method()
_addPoints:param({{param = 1, flags = "int", value = 999999}})
gg.sleep(10000)
_addPoints:off()


-- hook call method(addPoints) bằng method(LateUpdate)
local _addPoints = LateUpdate:call()(addPoints)
_addPoints:setValues({{param = 1, flags = "int", value = 999}})
gg.sleep(10000)
_addPoints:off()
