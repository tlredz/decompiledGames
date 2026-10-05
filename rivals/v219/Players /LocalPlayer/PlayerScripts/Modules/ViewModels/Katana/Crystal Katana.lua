local Players = game:GetService("Players")
local Katana = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Katana)
local object = setmetatable({}, Katana)
object.__index = object

function object.new(...)
	local self = setmetatable(Katana.new(...), object)
	self:_Init()
	return self
end

function object.PlayDeflectHitSounds(object2)
	object2:CreateSound("rbxassetid://14776414133", 1, 1.5 + 0.5 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://14776437962", 0.875, 0.9 + 0.2 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://76243116535648", 1.25, 0.9 + 0.2 * math.random(), true, 5)
end

function object:_Init() end

return object