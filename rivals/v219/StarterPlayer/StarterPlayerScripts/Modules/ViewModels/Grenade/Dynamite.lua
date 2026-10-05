local Players = game:GetService("Players")
local Grenade = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Grenade)
local object = setmetatable({}, Grenade)
object.__index = object

function object.new(...)
	local self = setmetatable(Grenade.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object