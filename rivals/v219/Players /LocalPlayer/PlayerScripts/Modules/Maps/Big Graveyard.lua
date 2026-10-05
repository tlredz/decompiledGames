local Players = game:GetService("Players")
local Graveyard = require(Players.LocalPlayer.PlayerScripts.Modules.Maps:WaitForChild("Graveyard"))
local object = setmetatable({}, Graveyard)
object.__index = object

function object.new(...)
	local self = setmetatable(Graveyard.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object