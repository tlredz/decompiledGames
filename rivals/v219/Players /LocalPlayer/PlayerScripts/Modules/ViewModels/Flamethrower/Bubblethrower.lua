local Players = game:GetService("Players")
local Flamethrower = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Flamethrower)
local object = setmetatable({}, Flamethrower)
object.__index = object

function object.new(...)
	local self = setmetatable(Flamethrower.new(...), object)
	self:_Init()
	return self
end

function object.PlayAirblastSoundEffect(object2)
	object2:CreateSound("rbxassetid://17209245422", 1, 1, true, 5)
	object2:CreateSound("rbxassetid://113753648748200", 1.125, 1 + 0.1 * math.random(), true, 10)
end

function object._CreateFlameSoundEffects(object2)
	return { object2:CreateSound("rbxassetid://100941596743597", 1.5, 1, true) }
end

function object:_Init() end

return object