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
	local sound = object2:CreateSound("rbxassetid://17246880027", 8.75, 0.75, true)
	sound.TimePosition = 0.25 + 0.25 * math.random()
	sound.Looped = true
	return { sound }
end

function object._CreateMinigunWindingSounds(object2)
	local sound = object2:CreateSound("rbxassetid://17251084003", 0.5, 0.75, true)
	sound.TimePosition = 2
	sound.Looped = true
	return { sound }
end

function object:_Init() end

return object