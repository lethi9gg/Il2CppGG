-- Il2CppGG by LeThi9GG
gg.alert("Script test Il2CppGG by LeThi9GG\n\nGame test: Zombie cubes 2\n\n", "", "")
require("init") -- or build.Il2CppGG
Il2Cpp()

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
local removePoints = PlayerScript:GetMethod("removePoints")

-- Tìm Field Trong Class Bằng Tên Hoặc GetFields() Tất Cả Field
local points = PlayerScript:GetField("points")

-- Tìm Field Bằng Tên Hoặc FieldInfoAddress
--local points = Il2Cpp.Field("points")

-- Tìm Method Bằng Tên Hoặc MethodInfoAddress
--local AddPoints = Il2Cpp.Method("AddPoints")


-- Ví Dụ Chỉnh sửa Field
gg.toast("edit field in Object\npoints: 1000")
local obj = PlayerScript:GetInstance()
points:SetValue(obj, 1000)

-- DUMP output C#
--io.open("dump.cs", "w"):write(PlayerScript:Dump()):close()

--[[ All 
-- Il2Cpp:Dumper({
    DumpField = true,
    DumpProperty = true,
    DumpMethod = true,
    DumpFieldOffset = true,
    DumpMethodOffset = true,
    DumpTypeDefIndex = false,
}, {
    path = nil, -- Auto
    image = nil -- Mặt định là tất cả, ví dụ {Il2Cpp.Image("Assembly-CSharp")}
})
]]
-- Patch memory
gg.toast("Patch memory method removePoints = false")
removePoints:SetValue(false)
gg.sleep(10000)
removePoints:RestoreValue()
gg.toast("Off patch memory method removePoints")

-- Hooking

-- hook field(points) bằng method(LateUpdate)
gg.toast("Hook field points in method LateUpdate")
local _LateUpdate = LateUpdate:field()
_LateUpdate:setValues({{offset = points.offset, flags = "int", value = 9999}})
gg.toast("Hook field points = 9999 from LateUpdate")
gg.sleep(10000)
_LateUpdate:off()
gg.toast("Off hook field")

-- hook param của method(addPoints)
gg.toast("Hook param method addPoints")
local _addPoints = addPoints:method()
_addPoints:param({{param = 1, flags = "int", value = 999999}})
gg.toast("Hook param 1 in addPoints = 999999")
gg.sleep(10000)
_addPoints:off()
gg.toast("Off hook param")

-- hook call method(addPoints) bằng method(LateUpdate)
gg.toast("Hook call method addPoints in method LateUpdate")
local _addPoints = LateUpdate:call()(addPoints)
_addPoints:setValues({{param = 1, flags = "int", value = 999}})
gg.toast("Hook call addPoints(999) from LateUpdate")
gg.sleep(10000)
_addPoints:off()
gg.toast("Off hook call")

gg.alert("Done test!")