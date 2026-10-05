local Players = game:GetService("Players")
local BaseSlingshot = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseSlingshot)
local object = setmetatable({}, BaseSlingshot)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseSlingshot.new(...), object)
	self:_Init()
	return self
end

function object.PlayAimSound(object2, p)
	object2:CreateSound("rbxassetid://96253147006478", 0.375, 2 + (p and 0.1 or 0), true, 5)
end

function object:_Init()
	self:_RegisterDefaultAmmoVisuals()
end

return object