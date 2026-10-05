require(script.Parent.Parent.types)
local config = require(script.Parent.Parent.config)
local intermediate = require(script.Parent.Parent.utils.intermediate)

local function configure(data)
	local mass = data.mass or 1
	local tension = data.tension or config.spring.default.tension
	local friction = data.friction or config.spring.default.friction

	if data.frequency or data.damping then
		local frequency = data.frequency or 0.5
		local damping = data.damping or 1
		tension = (6.283185307179586 / frequency) ^ 2 * mass
		friction = 12.566370614359172 * damping * mass / frequency
	end

	return {
		mass = mass,
		tension = tension,
		friction = friction,
		position = data.position,
		velocity = data.velocity,
		impulse = data.impulse,
		restingVelocity = data.restingVelocity or 0.001,
		restingPosition = data.restingPosition or 0.0001
	}
end

local function spring(p, options)
	local v = configure(options or {})
	local v2 = intermediate.to(p)
	local flag = true
	return function(p2, state, p3)
		local index = intermediate.index(v2, p2)

		if not index then
			return false
		end

		if flag then
			flag = false
			state.value = v.position or state.value or 0
			state.velocity = (v.velocity or state.velocity or 0) + (v.impulse or 0)
		end

		local value = state.value
		local velocity = state.velocity or 0

		for _ = 1, math.min(math.ceil(p3 * 1000 / 1), 100) do
			velocity += (-v.tension * 1e-6 * (value - index) + -v.friction * 0.001 * velocity) / v.mass * 1
			value += velocity * 1
		end

		if math.abs(velocity) < v.restingVelocity and math.abs(value - index) < v.restingPosition then
			state.complete = true
			state.value = index
			state.velocity = 0
		else
			state.value = value
			state.velocity = velocity
		end
	end
end

return spring