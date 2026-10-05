local Players = game:GetService("Players")
local BurstRifle = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Burst Rifle"])
local object = setmetatable({}, BurstRifle)
object.__index = object

function object.new(...)
	local self = setmetatable(BurstRifle.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object