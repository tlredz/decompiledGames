local Players = game:GetService("Players")
local Exogun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Exogun)
local object = setmetatable({}, Exogun)
object.__index = object

function object.new(...)
	local self = setmetatable(Exogun.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object