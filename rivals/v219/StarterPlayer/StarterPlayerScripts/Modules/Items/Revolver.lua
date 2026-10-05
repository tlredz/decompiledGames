local Players = game:GetService("Players")
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self.ToggleAimEnabled = nil
	self:_Init()
	return self
end

function object.StartAiming(object2, p)
	return object2:StartShooting(p, true)
end

function object.FinishAiming(_, _)
	return false
end

function object.StartSprinting(_, _)
	return false
end

function object:_Init() end

return object