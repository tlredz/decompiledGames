local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Math = require(ReplicatedStorage.Modules.Shared.Math)
local VehicleSpeedState = require(script.Parent.VehicleSpeedState)
local v = Component.new({
	Tag = "SpeedReactiveVFX"
})
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)

local function toScaleStep(p: number)
	return (math.round(p / 0.05))
end

local function buildScaledValues(authored, p: number, _scaleLifetime: boolean)
	local v2 = {
		enabled = p > 0,
		rate = authored.rate * p,
		size = Math.scaleNumberSequence(authored.size, p),
		speed = NumberRange.new(authored.speed.Min * p, authored.speed.Max * p),
		lifetime = 0
	}
	local lifetime

	if _scaleLifetime then
		lifetime = NumberRange.new(authored.lifetime.Min * p, authored.lifetime.Max * p)
	else
		lifetime = authored.lifetime
	end

	v2.lifetime = lifetime
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyEmitterValues(emitter, data)
	emitter.Enabled = data.enabled
	emitter.Rate = data.rate
	emitter.Size = data.size
	emitter.Speed = data.speed
	emitter.Lifetime = data.lifetime
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._emitterRecords = {}
	self._toggleEffects = {}
	self._authoredVolumes = {}
	self._appliedScaleStep = nil
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"VehicleSpeedState",
		VehicleSpeedState
	)
	assert(
		waitForAncestorComponent,
		(`SpeedReactiveVFX requires a VehicleSpeedState ancestor on {self.Instance:GetFullName()}`)
	)
	self._speedState = waitForAncestorComponent
	self._idleScale = self.Instance:GetAttribute("VFXIdleScale") or 0.5
	self._rampExponent = self.Instance:GetAttribute("VFXRampExponent") or 2
	self._scaleLifetime = self.Instance:GetAttribute("VFXScaleLifetime") == true
	self._Janitor:Add(function()
		for k, _authoredVolume in self._authoredVolumes do
			k:Stop()
			k.Volume = _authoredVolume
		end

		self:RestoreEmitters()
	end)
	self._Janitor:Add(self._speedState.OnActiveChanged:Connect(function(flag: boolean)
		self:SetToggleEffectsEnabled(flag)
	end))
	self._Janitor:Add(self._speedState.OnOccupiedChanged:Connect(function(flag: boolean)
		self:SetEmittersScaled(flag)
	end))
	self._Janitor:Add(self._speedState.OnSpeedProgressChanged:Connect(function(p: number)
		self:ApplyScaleStep((math.round(self:CalculateScale(p) / 0.05)))
	end))

	for _, descendant in self.Instance:GetDescendants() do
		self:RegisterEffect(descendant)
	end

	self._Janitor:Add(self.Instance.DescendantAdded:Connect(function(descendant)
		self:RegisterEffect(descendant)
	end))
end

function v:RegisterEffect(instance)
	if instance:IsA("ParticleEmitter") then
		local v2 = {
			emitter = instance,
			authored = {
				enabled = instance.Enabled,
				rate = instance.Rate,
				size = instance.Size,
				speed = instance.Speed,
				lifetime = instance.Lifetime
			},
			valuesByScaleStep = {}
		}
		table.insert(self._emitterRecords, v2)

		if self._speedState:IsOccupied() then
			self:ApplyScaleStepToEmitter(v2, self:GetCurrentScaleStep())
		end
	elseif instance:IsA("Trail") or instance:IsA("Beam") then
		table.insert(self._toggleEffects, instance)
		instance.Enabled = self._speedState:IsActive()
	elseif instance:IsA("Sound") then
		self._authoredVolumes[instance] = instance.Volume
		self:SetSoundPlaying(instance, self._speedState:IsActive())
	end
end

function v:CalculateScale(p2: number)
	return (math.lerp(self._idleScale, 1, p2 ^ self._rampExponent))
end

function v:GetCurrentScaleStep()
	return (math.round(self:CalculateScale(self._speedState:GetSpeedProgress()) / 0.05))
end

function v:SetEmittersScaled(flag: boolean)
	if flag then
		self:ApplyScaleStep(self:GetCurrentScaleStep())
	else
		self:RestoreEmitters()
	end
end

function v:ApplyScaleStep(appliedScaleStep: number)
	if not (self._speedState:IsOccupied() and appliedScaleStep ~= self._appliedScaleStep) then
		return
	end

	self._appliedScaleStep = appliedScaleStep

	for _, _emitterRecord in self._emitterRecords do
		self:ApplyScaleStepToEmitter(_emitterRecord, appliedScaleStep)
	end
end

function v:ApplyScaleStepToEmitter(data, p2: number)
	local v2 = data.valuesByScaleStep[p2]

	if v2 == nil then
		v2 = buildScaledValues(data.authored, p2 * 0.05, self._scaleLifetime)
		data.valuesByScaleStep[p2] = v2
	end

	applyEmitterValues(data.emitter, v2) -- equivalent call inferred; original call site unknown
end

function v:RestoreEmitters()
	self._appliedScaleStep = nil

	for _, _emitterRecord in self._emitterRecords do
		applyEmitterValues(_emitterRecord.emitter, _emitterRecord.authored) -- equivalent call inferred; original call site unknown
	end
end

function v:SetToggleEffectsEnabled(enabled: boolean)
	for _, _toggleEffect in self._toggleEffects do
		_toggleEffect.Enabled = enabled
	end

	for k in self._authoredVolumes do
		self:SetSoundPlaying(k, enabled)
	end
end

function v:SetSoundPlaying(object, flag: boolean)
	self._Janitor:Remove(object)
	local _authoredVolume = self._authoredVolumes[object]

	if flag then
		object.Volume = _authoredVolume

		if not object.IsPlaying then
			object:Play()
		end
	else
		if not object.IsPlaying then
			object.Volume = _authoredVolume
			return
		end

		local tween = TweenService:Create(object, tweenInfo, {
			Volume = 0
		})
		tween.Completed:Once(function(p2)
			if p2 ~= Enum.PlaybackState.Completed then
				return
			end

			object:Stop()
			object.Volume = _authoredVolume
		end)
		self._Janitor:Add(tween, "Cancel", object)
		tween:Play()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v