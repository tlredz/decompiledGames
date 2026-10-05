local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ViewModelParticlesLogic = {}
ViewModelParticlesLogic.__index = ViewModelParticlesLogic

function ViewModelParticlesLogic.new(clientViewModel, value)
	local self = setmetatable({}, ViewModelParticlesLogic)
	self.ClientViewModel = clientViewModel
	self._tag = value or "ArchParticles"
	self._effect_hash = 0
	self._particles = {}
	self:_Init()
	return self
end

function ViewModelParticlesLogic:SetVisible(enabled)
	for _, emitter in pairs(self._particles) do
		emitter.Enabled = enabled

		if not emitter:IsA("ParticleEmitter") or enabled then
			continue
		end

		emitter:Clear()
	end

	if enabled then
		Utility:PlayParticles(self._particles)
	end
end

function ViewModelParticlesLogic:PlayEffect(p, p2)
	self:CancelEffect()
	local _effect_hash = self._effect_hash

	if p > 0 then
		wait(p)

		if self._effect_hash ~= _effect_hash then
			return
		end
	end

	self:SetVisible(false)

	if p2 > 0 then
		wait(p2)

		if self._effect_hash ~= _effect_hash then
			return
		end
	end

	self:SetVisible(true)
end

function ViewModelParticlesLogic:CancelEffect()
	self._effect_hash += 1
end

function ViewModelParticlesLogic:Destroy()
	self:CancelEffect()
end

function ViewModelParticlesLogic:_Setup()
	for _, descendant in pairs(self.ClientViewModel.ItemModel:GetDescendants()) do
		if descendant:HasTag(self._tag) and descendant.Enabled then
			table.insert(self._particles, descendant)
		end
	end
end

function ViewModelParticlesLogic:_Init()
	self:_Setup()
end

return ViewModelParticlesLogic