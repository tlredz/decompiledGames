local Players = game:GetService("Players")
local Katana = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Katana)
local v = { "rbxassetid://78366036290786", "rbxassetid://94469349981552" }
local object = setmetatable({}, Katana)
object.__index = object

function object.new(...)
	local self = setmetatable(Katana.new(...), object)
	self:_Init()
	return self
end

function object.PlayDeflectHitSounds(object2)
	object2:CreateSound("rbxassetid://14776414133", 1, 1.5 + 0.5 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://14776437962", 0.75, 0.9 + 0.2 * math.random(), true, 5)
	object2:CreateSound(v[math.random(#v)], 1.25, 1 + 0.25 * math.random(), true, 5)
end

function object:_Init() end

return object