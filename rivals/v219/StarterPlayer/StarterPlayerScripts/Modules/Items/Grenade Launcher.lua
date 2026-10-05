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

function object.StartAiming(object2, ...)
	local v, _, v2, v3 = object2:StartShooting(...)

	if v then
		return true, "StartAiming", v2, v3
	end

	return false
end

function object.FinishAiming(_, _)
	return false
end

function object:_Init() end

return object