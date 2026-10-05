local Players = game:GetService("Players")
local Knife = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ViewModels"):WaitForChild("Knife"))
local object = setmetatable({}, Knife)
object.__index = object

function object.new(...)
	local self = setmetatable(Knife.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self.Animator:OverridePreviousAnimationsOnPlay(true)
end

return object