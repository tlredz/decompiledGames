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
	object2:CreateSound("rbxassetid://14776414133", 1.25, 1.5 + 0.5 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://14776437962", 1, 0.9 + 0.2 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://110122962237431", 1.5, 1.25 + 0.25 * math.random(), true, 5)
end

function object:_Init() end

return object