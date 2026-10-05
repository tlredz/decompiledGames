local Players = game:GetService("Players")
local Medkit = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Medkit)
local object = setmetatable({}, Medkit)
object.__index = object

function object.new(...)
	local self = setmetatable(Medkit.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object