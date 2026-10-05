local Players = game:GetService("Players")
local Minigun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Minigun)
local object = setmetatable({}, Minigun)
object.__index = object

function object.new(...)
	local self = setmetatable(Minigun.new(...), object)
	self:_Init()
	return self
end

function object._CreateMinigunShootingSounds(object2)
	local sound = object2:CreateSound("rbxassetid://112116120783481", 8.75, 1, true)
	sound.TimePosition = 0.25 + 0.25 * math.random()
	sound.Looped = true
	return { sound }
end

function object._CreateMinigunWindingSounds(object2)
	local sound = object2:CreateSound("rbxassetid://111731354794881", 0.5, 1, true)
	sound.TimePosition = 2
	sound.Looped = true
	return { sound }
end

function object:_Init() end

return object