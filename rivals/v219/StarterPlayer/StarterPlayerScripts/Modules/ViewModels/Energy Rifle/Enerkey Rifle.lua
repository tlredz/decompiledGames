local Players = game:GetService("Players")
local EnergyRifle = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Energy Rifle"])
local keyBeamTracerEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("KeyBeamTracerEffect")
local object = setmetatable({}, EnergyRifle)
object.__index = object

function object.new(...)
	local self = setmetatable(EnergyRifle.new(...), object)
	self:_Init()
	return self
end

function object.GetTracerTemplate(_)
	return keyBeamTracerEffect
end

function object.PlayAimSound(object2, p)
	object2:CreateSound("rbxassetid://96253147006478", 0.375, 2 + (p and 0.1 or 0), true, 5)
end

function object:_Init() end

return object