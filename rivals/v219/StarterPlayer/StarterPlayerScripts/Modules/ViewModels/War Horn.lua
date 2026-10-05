local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local warHornEffects = Players.LocalPlayer.PlayerScripts.Assets.Misc.WarHornEffects
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._horn_particles = {}
	self._horn_particles_active = 0
	self._use_effect_attachment = self.Model:FindFirstChild("_warhorn_use", true)
	self:_Init()
	return self
end

function object:PlayHornEffect()
	self:_IncrementParticlesActive(1)
	task.delay(
		AnimationLibrary.Info[self.Info.Animations.Use].ActionTimestamp,
		self._IncrementParticlesActive,
		self,
		-1
	)
end

function object:_IncrementParticlesActive(p)
	self._horn_particles_active += p

	for _, _horn_particle in pairs(self._horn_particles) do
		_horn_particle.Enabled = self._horn_particles_active > 0
	end
end

function object:_Setup()
	for _, child in pairs((warHornEffects:FindFirstChild(self.Name) or warHornEffects.Default).Attachment:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._use_effect_attachment
		table.insert(self._horn_particles, clone)
	end
end

function object:_Init()
	self:_Setup()
end

return object