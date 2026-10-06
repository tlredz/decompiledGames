local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraShake = {}
CameraShake.__index = CameraShake

function CameraShake.new(p)
	local self = setmetatable({}, CameraShake)
	self._config = (p or require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("BattleConfig"))).visual.cameraShake
	self._amplitude = 0
	self._duration = 0
	self._elapsed = 0
	self._freqX = 0
	self._freqY = 0
	return self
end

function CameraShake:trigger(value: number, p)
	if type(value) ~= "number" or value <= 0 then
		return
	end

	local _config = self._config
	local amplitude = _config.maxOffset * math.clamp(value, 0, 1) * (not p and 1 or p.amplitudeScale or 1)

	if amplitude <= (not (self._duration > 0 and self._elapsed < self._duration) and 0 or self._amplitude * (1 - self._elapsed / self._duration)) then
		return
	end

	self._amplitude = amplitude
	self._duration = p and p.duration or _config.duration
	self._elapsed = 0
	self._freqX = _config.minFrequency + math.random() * (_config.maxFrequency - _config.minFrequency)
	self._freqY = _config.minFrequency + math.random() * (_config.maxFrequency - _config.minFrequency)
end

function CameraShake:getOffset(value: number)
	if self._duration <= 0 then
		return createVector(0, 0, 0)
	end

	self._elapsed += math.max(0, value or 0)

	if self._elapsed >= self._duration then
		self:reset()
		return createVector(0, 0, 0)
	end

	local v = self._amplitude * (1 - self._elapsed / self._duration)
	return (Vector3.new(
		math.sin(self._elapsed * self._freqX * 6.283185307179586) * v,
		math.sin(self._elapsed * self._freqY * 6.283185307179586 + 1.5707963267948966) * v,
		0
	))
end

function CameraShake:reset()
	self._amplitude = 0
	self._duration = 0
	self._elapsed = 0
end

return CameraShake