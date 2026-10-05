local CameraShakeInstance = {}
CameraShakeInstance.__index = CameraShakeInstance
local new = Vector3.new
local noise = math.noise
CameraShakeInstance.CameraShakeState = {
	FadingIn = 0,
	FadingOut = 1,
	Sustained = 2,
	Inactive = 3
}

function CameraShakeInstance.new(magnitude, value2, p, p2)
	local fadeInDuration = p == nil and 0 or p
	local fadeOutDuration = p2 == nil and 0 or p2
	assert(type(magnitude) == "number", "Magnitude must be a number")
	assert(type(value2) == "number", "Roughness must be a number")
	assert(type(fadeInDuration) == "number", "FadeInTime must be a number")
	assert(type(fadeOutDuration) == "number", "FadeOutTime must be a number")
	return (setmetatable({
		Magnitude = magnitude,
		Roughness = value2,
		PositionInfluence = new(),
		RotationInfluence = new(),
		DeleteOnInactive = true,
		roughMod = 1,
		magnMod = 1,
		fadeOutDuration = fadeOutDuration,
		fadeInDuration = fadeInDuration,
		sustain = fadeInDuration > 0,
		currentFadeTime = fadeInDuration > 0 and 0 or 1,
		tick = Random.new():NextNumber(-100, 100),
		_camShakeInstance = true
	}, CameraShakeInstance))
end

function CameraShakeInstance:UpdateShake(p)
	local tick = self.tick
	local currentFadeTime = self.currentFadeTime
	local vector = new(noise(tick, 0) * 0.5, noise(0, tick) * 0.5, noise(tick, tick) * 0.5)

	if self.fadeInDuration > 0 and self.sustain then
		if currentFadeTime < 1 then
			currentFadeTime += p / self.fadeInDuration
		elseif self.fadeOutDuration > 0 then
			self.sustain = false
		end
	end

	if not self.sustain then
		currentFadeTime -= p / self.fadeOutDuration
	end

	if self.sustain then
		self.tick = tick + p * self.Roughness * self.roughMod
	else
		self.tick = tick + p * self.Roughness * self.roughMod * currentFadeTime
	end

	self.currentFadeTime = currentFadeTime
	return vector * self.Magnitude * self.magnMod * currentFadeTime
end

function CameraShakeInstance:StartFadeOut(fadeOutDuration)
	if fadeOutDuration == 0 then
		self.currentFadeTime = 0
	end

	self.fadeOutDuration = fadeOutDuration
	self.fadeInDuration = 0
	self.sustain = false
end

function CameraShakeInstance:StartFadeIn(p2)
	if p2 == 0 then
		self.currentFadeTime = 1
	end

	self.fadeInDuration = p2 or self.fadeInDuration
	self.fadeOutDuration = 0
	self.sustain = true
end

function CameraShakeInstance.GetScaleRoughness(p)
	return p.roughMod
end

function CameraShakeInstance:SetScaleRoughness(roughMod)
	self.roughMod = roughMod
end

function CameraShakeInstance.GetScaleMagnitude(p)
	return p.magnMod
end

function CameraShakeInstance:SetScaleMagnitude(magnMod)
	self.magnMod = magnMod
end

function CameraShakeInstance.GetNormalizedFadeTime(p)
	return p.currentFadeTime
end

function CameraShakeInstance:IsShaking()
	return self.currentFadeTime > 0 or self.sustain
end

function CameraShakeInstance:IsFadingOut()
	return not self.sustain and self.currentFadeTime > 0
end

function CameraShakeInstance:IsFadingIn()
	return self.currentFadeTime < 1 and self.sustain and self.fadeInDuration > 0
end

function CameraShakeInstance:GetState()
	if self:IsFadingIn() then
		return CameraShakeInstance.CameraShakeState.FadingIn
	end

	if self:IsFadingOut() then
		return CameraShakeInstance.CameraShakeState.FadingOut
	end

	if self:IsShaking() then
		return CameraShakeInstance.CameraShakeState.Sustained
	end

	return CameraShakeInstance.CameraShakeState.Inactive
end

return CameraShakeInstance