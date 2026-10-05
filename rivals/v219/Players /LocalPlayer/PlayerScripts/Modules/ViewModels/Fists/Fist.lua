local Players = game:GetService("Players")
local Fists = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Fists)
local object = setmetatable({}, Fists)
object.__index = object

function object.new(...)
	local self = setmetatable(Fists.new(...), object)
	self.LeftArmIKControlDisabled = true
	self:_Init()
	return self
end

function object:_Init() end

return object