local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Grappler = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Grappler)
local object = setmetatable({}, Grappler)
object.__index = object

function object.new(...)
	local self = setmetatable(Grappler.new(...), object)
	self._shoot_particles_attachment = self.ItemModel:WaitForChild("Body"):WaitForChild("Black"):WaitForChild("ShootParticles")
	self:_Init()
	return self
end

function object:PlayShootSounds()
	self:CreateSound("rbxassetid://139881930563519", 1.5, 1 + 0.1 * math.random(), true, 5)
	self:CreateSound("rbxassetid://119208207944073", 0.875, 1 + 0.1 * math.random(), true, 5)
	Utility:PlayParticles(self._shoot_particles_attachment)
end

function object.PlayPullSounds(object2)
	object2:CreateSound("rbxassetid://80351710007259", 1.5, 1 + 0.1 * math.random(), true, 5)
end

function object:_Init() end

return object