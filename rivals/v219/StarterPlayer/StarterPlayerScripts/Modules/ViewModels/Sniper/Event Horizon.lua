local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Sniper = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels:WaitForChild("Sniper"))
local colorSequence = ColorSequence.new(Color3.fromRGB(198, 99, 255))
local object = setmetatable({}, Sniper)
object.__index = object

function object.new(...)
	local self = setmetatable(Sniper.new(...), object)
	self._reload_start_attachment = self.ItemModel:WaitForChild("Body"):WaitForChild("Black"):WaitForChild("Start")
	self._reload_finish_attachment = self.ItemModel:WaitForChild("Body"):WaitForChild("Black"):WaitForChild("Finish")
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:PlayReloadStartParticles()
	Utility:PlayParticles(self._reload_start_attachment)
end

function object:PlayReloadFinishParticles()
	Utility:PlayParticles(self._reload_finish_attachment)
end

function object:_Init() end

return object