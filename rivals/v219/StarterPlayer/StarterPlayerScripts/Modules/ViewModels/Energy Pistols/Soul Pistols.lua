local Players = game:GetService("Players")
local EnergyPistols = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Energy Pistols"])
local object = setmetatable({}, EnergyPistols)
object.__index = object

function object.new(...)
	local self = setmetatable(EnergyPistols.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object