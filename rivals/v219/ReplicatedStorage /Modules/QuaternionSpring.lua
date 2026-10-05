local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quaternion = require(ReplicatedStorage.Modules:WaitForChild("Quaternion"))
local QuaternionSpring = {
	_type = "QuaternionSpring"
}

function QuaternionSpring.new(p, value: number?, value2: number?, callback)
	local v = p or Quaternion.identity
	local clock = callback or os.clock
	return (setmetatable({
		_clock = clock,
		_time = clock(),
		_position = v,
		_velocity = createVector(0, 0, 0),
		_target = v,
		_damping = value or 1,
		_speed = value2 or 1,
		_initial = v
	}, QuaternionSpring))
end

function QuaternionSpring:Reset(p2)
	local v = p2 or self._initial
	self._position = v
	self._target = v
	self._velocity = createVector(0, 0, 0)
end

function QuaternionSpring:Impulse(vector2: Vector3)
	self._velocity += vector2
end

local function _positionVelocity(data, p: number)
	local _position = data._position
	local _velocity = data._velocity
	local _target = data._target
	local _damping = data._damping
	local _speed = data._speed
	local v = _speed * (p - data._time)
	local v2 = _damping * _damping
	local v3, v4, v5

	if v2 < 1 then
		v3 = math.sqrt(1 - v2)
		local v6 = math.exp(-_damping * v) / v3
		v4 = v6 * math.cos(v3 * v)
		v5 = v6 * math.sin(v3 * v)
	elseif v2 == 1 then
		v4 = math.exp(-_damping * v)
		v5 = v4 * v
		v3 = 1
	else
		v3 = math.sqrt(v2 - 1)
		local v6 = 2 * v3
		local v7 = math.exp((-_damping + v3) * v) / v6
		local v8 = math.exp((-_damping - v3) * v) / v6
		v4 = v7 + v8
		v5 = v7 - v8
	end

	local v6 = 1 - (v3 * v4 + _damping * v5)
	local v7 = v5 / _speed
	local v8 = _speed * v5
	local v9 = v3 * v4 - _damping * v5
	local integrate = _position:Slerp(_target, v6):Integrate(_velocity, v7)
	local axisAngle, v10 = _position:Difference(_target):ToAxisAngle()
	return integrate, axisAngle * v10 * v8 + _velocity * v9
end

function QuaternionSpring:TimeSkip(p2: number)
	local _clock = self._clock()
	local position, velocity = _positionVelocity(self, _clock + p2)
	self._position = position
	self._velocity = velocity
	self._time = _clock
end

function QuaternionSpring:__index(p: string)
	if QuaternionSpring[p] then
		return QuaternionSpring[p]
	end

	if p == "Position" or p == "p" then
		local v, _ = _positionVelocity(self, self._clock())
		return v
	end

	if p == "Velocity" or p == "v" then
		local _, v = _positionVelocity(self, self._clock())
		return v
	end

	if p == "Target" or p == "t" then
		return self._target
	end

	if p == "Damping" or p == "d" then
		return self._damping
	end

	if p == "Speed" or p == "s" then
		return self._speed
	end

	if p == "Clock" then
		return self._clock
	end

	error(string.format("%q is not a valid member of QuaternionSpring.", (tostring(p))), 2)
end

function QuaternionSpring:__newindex(p2: string, callback)
	local _clock = self._clock()

	if p2 == "Position" or p2 == "p" then
		local _, velocity = _positionVelocity(self, _clock)
		self._position = callback
		self._velocity = velocity
		self._time = _clock
	elseif p2 == "Velocity" or p2 == "v" then
		local position, _ = _positionVelocity(self, _clock)
		self._position = position
		self._velocity = callback
		self._time = _clock
	elseif p2 == "Target" or p2 == "t" then
		local position, velocity = _positionVelocity(self, _clock)
		self._position = position
		self._velocity = velocity
		self._target = callback
		self._time = _clock
	elseif p2 == "Damping" or p2 == "d" then
		local position, velocity = _positionVelocity(self, _clock)
		self._position = position
		self._velocity = velocity
		self._damping = callback
		self._time = _clock
	elseif p2 == "Speed" or p2 == "s" then
		local position, velocity = _positionVelocity(self, _clock)
		self._position = position
		self._velocity = velocity
		self._speed = callback < 0 and 0 or callback
		self._time = _clock
	else
		if p2 ~= "Clock" then
			error(string.format("%q is not a valid member of QuaternionSpring.", (tostring(p2))), 2)
			return
		end

		local position, velocity = _positionVelocity(self, _clock)
		self._position = position
		self._velocity = velocity
		self._clock = callback
		self._time = callback()
	end
end

return QuaternionSpring