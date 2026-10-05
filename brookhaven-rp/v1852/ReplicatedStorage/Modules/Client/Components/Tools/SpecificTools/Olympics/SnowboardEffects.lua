local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "SnowboardEffects"
})
local numberRange = NumberRange.new(0.8, 1.115)
local numberRange2 = NumberRange.new(0, 0.3)
local numberRange3 = NumberRange.new(0, 0.8)
local numberRange4 = NumberRange.new(0.8, 1)
local numberRange5 = NumberRange.new(0, 0.3)
local numberRange6 = NumberRange.new(0, 0.3)
local numberRange7 = NumberRange.new(0.8, 1.1)
local numberRange8 = NumberRange.new(0.8, 1.1)
local _ = {
	Riding = 1,
	Holding = 2
}

function v:Construct()
	self._Janitor = Janitor.new()
	self._raycastParams = RaycastParams.new()
	self._raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self._raycastParams.RespectCanCollide = true
	self._inAir = false
	self._flyingStartTime = 0
	self._vfxActiveState = {}
	self._decelerationTime = 0
	self._moveParticleEnabled = false
	self._stopParticlesEnabled = false
	self._previousSpeed = 0
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self._equipped = true
		self.Instance.Handle.Movement:Play()
		self.Instance.Handle.DiveBomb:Play()
		self.Instance.Handle.Wind:Play()
		self.Instance.Handle.Stopping:Play()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self._equipped = false
		self.Instance.Handle.Movement:Stop()
		self.Instance.Handle.DiveBomb:Stop()
		self.Instance.Handle.Wind:Stop()
		self.Instance.Handle.Stopping:Stop()
	end))
end

function v:SteppedUpdate(p)
	if not self._equipped then
		return
	end

	self:UpdateAudio()
	self:UpdateVFX(p)
end

function v:UpdateAudio()
	local magnitude = self.Instance.Handle.AssemblyLinearVelocity.Magnitude
	local v2 = magnitude / 110
	local v3 = math.clamp(magnitude / 50, 0, 1)
	local v4 = math.clamp(v2, 0, 1)
	local octave = math.map(v3, 0, 1, numberRange.Min, numberRange.Max)
	local octave2 = math.map(v3, 0, 1, numberRange4.Min, numberRange4.Max)
	local octave3 = math.map(v4, 0, 1, numberRange7.Min, numberRange7.Max)
	local volume = math.map(v3, 0, 1, numberRange2.Min, numberRange2.Max)
	local volume2 = math.map(v4, 0, 1, numberRange5.Min, numberRange5.Max)
	local volume3 = math.map(v4, 0, 1, numberRange6.Min, numberRange6.Max)

	if self._inAir then
		volume = 0
		volume2 = 0
	end

	local isRiding = self:IsRiding()

	if not isRiding then
		volume = 0
		volume2 = 0
		volume3 = 0
	end

	self.Instance.Handle.Movement.PitchShiftSoundEffect.Octave = octave
	self.Instance.Handle.DiveBomb.PitchShiftSoundEffect.Octave = octave2
	self.Instance.Handle.Wind.PitchShiftSoundEffect.Octave = octave3
	self.Instance.Handle.Movement.Volume = volume
	self.Instance.Handle.DiveBomb.Volume = volume2
	self.Instance.Handle.Wind.Volume = volume3

	if not isRiding then
		return
	end

	if self:GetFloorResult() then
		if os.clock() - self._flyingStartTime < 0.1 or not self._inAir then
			return
		end

		local playbackSpeed = math.map(v4, 0, 1, 0.5, 2)
		local volume4 = math.map(v4, 0, 1, 0, 0.3)
		self._inAir = false
		self.Instance.Handle.OnLand.PlaybackSpeed = playbackSpeed
		self.Instance.Handle.OnLand.Volume = volume4
		self.Instance.Handle.OnLand:Play()
		self:PlayVFX("OnLand")
	else
		if self._inAir then
			return
		end

		self._inAir = true
		self._flyingStartTime = os.clock()
	end
end

function v:UpdateVFX(p)
	local isRiding = self:IsRiding()

	if self._inAir or not isRiding then
		self:StopVFX("Riding")
		self:StopVFX("Stopping")
		self._moveParticleEnabled = false
		self._stopParticlesEnabled = false
		self.Instance.Handle.Stopping.Volume = 0
		self.Instance.Handle.Stopping.PitchShiftSoundEffect.Octave = 0
	else
		local volume = 0
		local octave = 0
		local magnitude = self.Instance.Handle.AssemblyLinearVelocity.Magnitude

		if magnitude > 10 and not (self._moveParticleEnabled or self._isFlying) then
			self._moveParticleEnabled = true
			self:PlayVFX("Riding")
		elseif magnitude < 10 and self._moveParticleEnabled then
			self._moveParticleEnabled = false
			self:StopVFX("Riding")
		end

		if self._moveParticleEnabled and self._isFlying then
			self._moveParticleEnabled = false
			self:StopVFX("Riding")
		end

		local v4 = self._previousSpeed - magnitude > 0.2

		if v4 then
			self._decelerationTime += p
		else
			self._decelerationTime = math.max(0, self._decelerationTime - p * 5)
		end

		if v4 and self._decelerationTime > 0.2 then
			volume = math.map(magnitude, 0, 110, numberRange3.Min, numberRange3.Max)
			octave = math.map(magnitude, 0, 110, numberRange8.Min, numberRange8.Max)

			if not self._stopParticlesEnabled then
				self:PlayVFX("Stopping")
				self._stopParticlesEnabled = true
			end
		elseif self._stopParticlesEnabled then
			self:StopVFX("Stopping")
			self._stopParticlesEnabled = false
		end

		self.Instance.Handle.Stopping.Volume = volume
		self.Instance.Handle.Stopping.PitchShiftSoundEffect.Octave = octave
		self._previousSpeed = magnitude
	end
end

function v:PlayVFX(p2: string)
	if self._vfxActiveState[p2] then
		return
	end

	self._vfxActiveState[p2] = true

	for _, effect in self.Instance.Parent:GetDescendants() do
		if effect:IsDescendantOf(self.Instance) then
			continue
		end

		if effect:IsA("ParticleEmitter") and effect.Name == p2 .. "Particle" then
			if effect:GetAttribute("EmitCount") then
				effect:Emit(effect:GetAttribute("EmitCount"))
			else
				effect.Enabled = true
			end
		elseif effect:IsA("Trail") and effect.Name == p2 then
			effect.Enabled = true
		end
	end
end

function v:StopVFX(p2: string)
	if not self._vfxActiveState[p2] then
		return
	end

	self._vfxActiveState[p2] = false

	for _, effect in self.Instance.Parent:GetDescendants() do
		if effect:IsDescendantOf(self.Instance) then
			continue
		end

		if effect:IsA("ParticleEmitter") and effect.Name == p2 .. "Particle" then
			effect.Enabled = false
		elseif effect:IsA("Trail") and effect.Name == p2 then
			effect.Enabled = false
		end
	end
end

function v:GetFloorResult()
	local parent = self.Instance.Parent
	self._raycastParams.FilterDescendantsInstances = { parent }
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return workspace:Raycast(humanoidRootPart.Position, -humanoidRootPart.CFrame.UpVector * 5, self._raycastParams)
	end

	return nil
end

function v:IsRiding()
	return self.Instance:GetAttribute("CurrentAnimation") == 1
end

function v:Stop()
	self._Janitor:Destroy()
end

return v