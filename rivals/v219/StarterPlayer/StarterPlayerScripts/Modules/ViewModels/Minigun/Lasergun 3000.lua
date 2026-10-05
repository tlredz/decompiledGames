local Players = game:GetService("Players")
local Minigun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Minigun)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 0, 0))
local object = setmetatable({}, Minigun)
object.__index = object

function object.new(...)
	local self = setmetatable(Minigun.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object._CreateMinigunShootingSounds(object2)
	local sound = object2:CreateSound("rbxassetid://17722581026", 0.75, 1, true)
	sound.TimePosition = 0.5 * math.random()
	sound.Looped = true
	local sound2 = object2:CreateSound("rbxassetid://17722580791", 0.75, 1, true)
	sound2.TimePosition = 0.5 * math.random()
	sound2.Looped = true
	local sound3 = object2:CreateSound("rbxassetid://17722580585", 0.75, 1, true)
	sound3.TimePosition = 0.5 * math.random()
	sound3.Looped = true
	return { sound, sound2, sound3 }
end

function object._CreateMinigunWindingSounds(object2)
	local sound = object2:CreateSound("rbxassetid://17722633119", 0.25, 1, true)
	sound.Looped = true
	return { sound }
end

function object:_Init() end

return object