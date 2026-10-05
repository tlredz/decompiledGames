require(script.Parent.Parent.types)
local config = require(script.Parent.Parent.config)
local intermediate = require(script.Parent.Parent.utils.intermediate)

local function configure(speed)
	if type(speed) == "table" then
		speed = speed.speed
	end

	return {
		speed = speed or config.linear.default.speed
	}
end

local function linear(p, speed)
	if type(speed) == "table" then
		speed = speed.speed
	end

	local v = {
		speed = speed or config.linear.default.speed
	}
	local v2 = intermediate.to(p)
	return function(p2, p3, p4)
		local index = intermediate.index(v2, p2)

		if not index then
			return false
		end

		local velocity = v.speed * p4 * math.sign(index - p3.value)

		if math.abs(velocity) >= math.abs(index - p3.value) then
			p3.complete = true
			p3.value = index
			p3.velocity = 0
		else
			p3.value += velocity
			p3.velocity = velocity
		end
	end
end

return linear