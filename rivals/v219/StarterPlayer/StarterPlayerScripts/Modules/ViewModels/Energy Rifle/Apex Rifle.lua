local Players = game:GetService("Players")
local EnergyRifle = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Energy Rifle"])
local apexBeamTracerEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ApexBeamTracerEffect")
local object = setmetatable({}, EnergyRifle)
object.__index = object

function object.new(...)
	local self = setmetatable(EnergyRifle.new(...), object)
	self:_Init()
	return self
end

function object.GetTracerTemplate(_)
	return apexBeamTracerEffect
end

function object:_Init() end

return object