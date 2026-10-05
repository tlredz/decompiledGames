require(script.Parent.Types)
local v = "running"
local v2 = 0
local StateTracker = {}

function StateTracker.reset()
	v = "running"
	v2 = 0
end

function StateTracker.getState()
	return v
end

function StateTracker.getSpeed()
	return v2
end

function StateTracker.climb(p: number)
	local v3 = v ~= "climbing" or math.abs(p - v2) > 0.1
	v = "climbing"
	v2 = p
	return v3
end

function StateTracker.update(vector: Vector3, vector2: Vector3, flag: boolean, flag2: boolean, flag3: boolean)
	local dot = vector:Dot(vector2)
	local v3, magnitude

	if flag then
		v3 = "running"

		if flag3 then
			magnitude = (vector - vector2 * dot).Magnitude
		else
			magnitude = 0
		end
	else
		v3 = flag2 and dot > 0 and "jumping" or "freefall"
		magnitude = vector.Magnitude
	end

	local v4

	if v3 == v then
		if v3 == "running" then
			v4 = math.abs(magnitude - v2) > 0.1
		else
			v4 = false
		end
	else
		v4 = true
	end

	v = v3
	v2 = magnitude
	return v4
end

return StateTracker