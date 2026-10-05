local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Olympics2026_BobsledEffects"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._lastPosition = self.Instance:GetPivot().Position
	self._speed = 0
	self.Instance:WaitForChild("Movement"):Play()
	self.Instance:WaitForChild("Sliding"):Play()
	self.Instance:WaitForChild("Wind"):Play()
end

function v:SteppedUpdate(p: number)
	local position = self.Instance:GetPivot().Position
	local v2 = position - self._lastPosition
	self._lastPosition = position
	self._speed = math.lerp(self._speed, v2.Magnitude / p, p * 10)
	local v3 = math.clamp(self._speed / 60, 0, 1)
	self.Instance.Movement.PitchShiftSoundEffect.Octave = math.map(v3, 0, 1, 0.8, 1.2)
	self.Instance.Sliding.PlaybackSpeed = math.map(v3, 0, 1, 0.5, 0.9)
	self.Instance.Wind.PitchShiftSoundEffect.Octave = math.map(v3, 0, 1, 0.8, 1.2)
	self.Instance.Movement.Volume = math.map(v3, 0, 1, 0, 0.8)
	self.Instance.Sliding.Volume = math.map(v3, 0, 1, 0, 0.3)
	self.Instance.Wind.Volume = math.map(v3, 0, 1, 0, 0.8)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v