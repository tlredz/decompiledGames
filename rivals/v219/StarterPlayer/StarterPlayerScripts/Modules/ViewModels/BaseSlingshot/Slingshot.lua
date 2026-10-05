local Players = game:GetService("Players")
local BaseSlingshot = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseSlingshot)
local object = setmetatable({}, BaseSlingshot)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseSlingshot.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self:_RegisterDefaultAmmoVisuals()
end

return object