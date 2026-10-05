local Players = game:GetService("Players")
local Flamethrower = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Flamethrower)
local object = setmetatable({}, Flamethrower)
object.__index = object

function object.new(...)
	local self = setmetatable(Flamethrower.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object