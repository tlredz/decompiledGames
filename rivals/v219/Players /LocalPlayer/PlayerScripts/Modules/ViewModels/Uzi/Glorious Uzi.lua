local Players = game:GetService("Players")
local Uzi = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Uzi)
local object = setmetatable({}, Uzi)
object.__index = object

function object.new(...)
	local self = setmetatable(Uzi.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object