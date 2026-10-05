local Players = game:GetService("Players")
local Minigun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Minigun)
local object = setmetatable({}, Minigun)
object.__index = object

function object.new(...)
	local self = setmetatable(Minigun.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object