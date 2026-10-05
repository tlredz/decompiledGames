local Players = game:GetService("Players")
local Grappler = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Grappler)
local object = setmetatable({}, Grappler)
object.__index = object

function object.new(...)
	local self = setmetatable(Grappler.new(...), object)
	self:_Init()
	return self
end

function object.PlayShootSounds(object2)
	object2:CreateSound("rbxassetid://123453281089594", 1, 0.9 + 0.2 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://88826254536827", 1.25, 0.9 + 0.2 * math.random(), true, 5)
end

function object.PlayPullSounds(object2)
	object2:CreateSound("rbxassetid://119983207340759", 1.25, 0.9 + 0.2 * math.random(), true, 5)
end

function object:_Init() end

return object