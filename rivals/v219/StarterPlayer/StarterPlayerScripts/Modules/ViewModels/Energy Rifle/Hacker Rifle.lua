local Players = game:GetService("Players")
local EnergyRifle = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Energy Rifle"])
local hackerBeamTracerEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("HackerBeamTracerEffect")
local object = setmetatable({}, EnergyRifle)
object.__index = object

function object.new(...)
	local self = setmetatable(EnergyRifle.new(...), object)
	self:_Init()
	return self
end

function object.GetTracerTemplate(_)
	return hackerBeamTracerEffect
end

function object:_Init() end

return object