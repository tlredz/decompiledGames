local Players = game:GetService("Players")
local Molotov = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Molotov)
local object = setmetatable({}, Molotov)
object.__index = object

function object.new(...)
	local self = setmetatable(Molotov.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object