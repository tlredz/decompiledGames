local Players = game:GetService("Players")
local Flamethrower = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Flamethrower)
local object = setmetatable({}, Flamethrower)
object.__index = object

function object.new(...)
	local self = setmetatable(Flamethrower.new(...), object)
	self:_Init()
	return self
end

function object._CreateFlameSoundEffects(object2)
	return {
		object2:CreateSound("rbxassetid://17209245734", 1.25, 1, true),
		object2:CreateSound("rbxassetid://129124742663895", 2, 1.25, true)
	}
end

function object:_Init() end

return object