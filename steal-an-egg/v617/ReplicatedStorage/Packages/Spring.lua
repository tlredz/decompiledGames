local createVector = vector.create
local Spring = {}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getIsValueValid(p)
	return p == p and p ~= nil
end

function Spring.new(p, p2)
	if not getIsValueValid(p) then
		p = typeof(p) == "Vector3" and createVector(0, 0, 0) or 0
	end

	local clock = p2 or tick
	return (setmetatable({
		_clock = clock,
		_time0 = clock(),
		_position0 = p,
		_velocity0 = 0 * p,
		_target = p,
		_damper = 1,
		_speed = 1
	}, Spring))
end

function Spring:Impulse(p2)
	if not getIsValueValid(p2) then
		return
	end

	self.Velocity += p2
end

function Spring:TimeSkip(p)
	local _clock = self._clock()
	local _positionVelocity, velocity = self:_positionVelocity(_clock + p)
	self._position0 = _positionVelocity
	self._velocity0 = velocity
	self._time0 = _clock
end

function Spring:getPosition()
	return self:_positionVelocity(self._clock())
end

function Spring:__index(p)
	if Spring[p] then
		return Spring[p]
	end

	if p == "Value" or p == "Position" or p == "p" then
		local _positionVelocity, _ = self:_positionVelocity(self._clock())
		return _positionVelocity
	end

	if p == "Velocity" or p == "v" then
		local _, v = self:_positionVelocity(self._clock())
		return v
	end

	if p == "Target" or p == "t" then
		return self._target
	end

	if p == "Damper" or p == "d" then
		return self._damper
	end

	if p == "Speed" or p == "s" then
		return self._speed
	end

	if p == "Clock" then
		return self._clock
	end

	error(("%q is not a valid member of Spring"):format((tostring(p))), 2)
end

function Spring:__newindex(p, value)
	local _clock = self._clock()

	if not getIsValueValid(value) then
		return
	end

	if p == "Value" or p == "Position" or p == "p" then
		local _, velocity = self:_positionVelocity(_clock)
		self._position0 = value
		self._velocity0 = velocity
		self._time0 = _clock
	elseif p == "Velocity" or p == "v" then
		local _positionVelocity, _ = self:_positionVelocity(_clock)
		self._position0 = _positionVelocity
		self._velocity0 = value
		self._time0 = _clock
	elseif p == "Target" or p == "t" then
		local _positionVelocity, velocity = self:_positionVelocity(_clock)
		self._position0 = _positionVelocity
		self._velocity0 = velocity
		self._target = value
		self._time0 = _clock
	elseif p == "Damper" or p == "d" then
		local _positionVelocity, velocity = self:_positionVelocity(_clock)
		self._position0 = _positionVelocity
		self._velocity0 = velocity
		self._damper = math.clamp(value, 0, 1)
		self._time0 = _clock
	elseif p == "Speed" or p == "s" then
		local _positionVelocity, velocity = self:_positionVelocity(_clock)
		self._position0 = _positionVelocity
		self._velocity0 = velocity
		self._speed = value < 0 and 0 or value
		self._time0 = _clock
	else
		if p ~= "Clock" then
			error(("%q is not a valid member of Spring"):format((tostring(p))), 2)
			return
		end

		local _positionVelocity, velocity = self:_positionVelocity(_clock)
		self._position0 = _positionVelocity
		self._velocity0 = velocity
		self._clock = value
		self._time0 = value()
	end
end

function Spring:_positionVelocity(p)
	local _position0 = self._position0
	local _velocity0 = self._velocity0
	local _target = self._target
	local _damper = self._damper
	local _speed = self._speed
	local v = _speed * (p - self._time0)
	local v2 = _damper * _damper
	local v3, v4, v5

	if v2 < 1 then
		v3 = math.sqrt(1 - v2)
		local v6 = math.exp(-_damper * v) / v3
		v4 = v6 * math.cos(v3 * v)
		v5 = v6 * math.sin(v3 * v)
	elseif v2 == 1 then
		v3 = 1
		v4 = math.exp(-_damper * v) / v3
		v5 = v4 * v
	else
		v3 = math.sqrt(v2 - 1)
		local v6 = math.exp((-_damper + v3) * v) / (2 * v3)
		local v7 = math.exp((-_damper - v3) * v) / (2 * v3)
		v4 = v6 + v7
		v5 = v6 - v7
	end

	local v6 = v3 * v4 + _damper * v5
	local v7 = 1 - (v3 * v4 + _damper * v5)
	local v8 = v5 / _speed
	local v9 = -_speed * v5
	local v10 = _speed * v5
	local v11 = v3 * v4 - _damper * v5
	return v6 * _position0 + v7 * _target + v8 * _velocity0, v9 * _position0 + v10 * _target + v11 * _velocity0
end

return Spring