local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local chainsawParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ChainsawParticles")
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._spike_toggle = false
	self._spike_parts = {}
	self._next_toggle = 0
	self._hold_particles = {}
	self._idle_sound_hash = 0
	self:_Init()
	return self
end

function object.CreateHoldSounds(object2)
	return { object2:CreateSound("rbxassetid://16359327230", 0.5, 1, true) }
end

function object.PlayStartingHoldSounds(_) end

function object:EnableParticles(enabled)
	for _, _hold_particle in pairs(self._hold_particles) do
		_hold_particle.Enabled = enabled
	end
end

function object:Update(p, p2, p3)
	ClientViewModel.Update(self, p, p2, p3)

	if not p3.IsActive or tick() < self._next_toggle then
		return
	end

	self._next_toggle = tick() + 0.03
	self._spike_toggle = not self._spike_toggle

	for k, _spike_part in pairs(self._spike_parts) do
		self:_LocalTransparencyModifier(k, "Update", _spike_part == self._spike_toggle and 0 or 1)
	end
end

function object:_PlayIdleSound(p, value)
	local v = value or 0.2

	if v > 0 then
		wait(v)

		if p ~= self._idle_sound_hash then
			return
		end
	end

	local sound = self:CreateSound("rbxassetid://13645858587", 0.375, 1, true)

	if sound then
		sound.Looped = true
	end

	local sound2 = self:CreateSound("rbxassetid://13646484249", 0.375, 1, true)

	if sound2 then
		sound2.Looped = true
	end

	local sound3 = self:CreateSound("rbxassetid://13646484113", 0.25, 1, true)

	if sound3 then
		sound3.Looped = true
	end
end

function object:_RegisterSpikesPart(p2, p3)
	self._spike_parts[p2] = p3
end

function object:_RegisterBlade(parent)
	for _, child in pairs((chainsawParticles:FindFirstChild(self.Name) or chainsawParticles.Default):GetChildren()) do
		local clone = child:Clone()
		clone.Parent = parent
		table.insert(self._hold_particles, clone)
	end
end

function object:_Init()
	self.Equipped:Connect(function()
		self._idle_sound_hash += 1
		self:_PlayIdleSound(self._idle_sound_hash)
	end)
	self.Unequipped:Connect(function()
		self._idle_sound_hash += 1
	end)
end

return object