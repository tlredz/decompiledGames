local Players = game:GetService("Players")
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(object2)
	if object2:IsFullyAiming() then
		return (Gun.GetAutoShootReactionTime(object2))
	end

	return nil
end

function object:_Init() end

return object