local function fn(p, p2, p3, duration)
	local v = p / duration

	if v < 0.36363636363636365 then
		return p3 * (7.5625 * v * v) + p2
	end

	if v < 0.7272727272727273 then
		local v2 = v - 0.5454545454545454
		return p3 * (7.5625 * v2 * v2 + 0.75) + p2
	end

	if v < 0.9090909090909091 then
		local v2 = v - 0.8181818181818182
		return p3 * (7.5625 * v2 * v2 + 0.9375) + p2
	end

	local v2 = v - 0.9545454545454546
	return p3 * (7.5625 * v2 * v2 + 0.984375) + p2
end

local v = {
	Linear = function(state, p)
		state.SecondsPassed += p
		local v2 = math.clamp(state.SecondsPassed / state.Duration, 0, 1)
		return v2, v2 >= 1
	end,
	QuadIn = function(state, p)
		state.SecondsPassed += p
		local v2 = state.SecondsPassed / state.Duration / state.Duration
		local v3 = math.clamp(1 * v2 * v2 + 0, 0, 1)
		return v3, v3 >= 1
	end,
	QuadOut = function(state, p)
		state.SecondsPassed += p
		local v2 = state.SecondsPassed / state.Duration / state.Duration
		local v3 = math.clamp(-1 * v2 * (v2 - 2) + 0, 0, 1)
		return v3, v3 >= 1
	end,
	QuadInOut = function(state, p)
		state.SecondsPassed += p
		local v2 = state.SecondsPassed / state.Duration / (state.Duration / 2)
		local v3

		if v2 < 1 then
			v3 = 0.5 * v2 * v2 + 0
		else
			v3 = -0.5 * (v2 * (v2 - 2) - 1) + 0
		end

		local v4 = math.clamp(v3, 0, 1)
		return v4, v4 >= 1
	end,
	BounceOut = function(state, p)
		state.SecondsPassed += p
		local v2 = math.clamp(fn(state.SecondsPassed / state.Duration, 0, 1, state.Duration), 0, 1)
		return v2, v2 >= 1
	end,
	ElasticOut = function(state, p)
		state.SecondsPassed += p
		local v2 = state.SecondsPassed / state.Duration
		local v3 = math.pow(2, -10 * v2) * math.sin((v2 * 10 - 0.75) * 6.283185307179586 / 3) + 1

		if state.SecondsPassed / state.Duration >= 1 then
			return 1, true
		end

		return v3
	end,
	Looped = function(state, p)
		state.SecondsPassed += p
		return state.SecondsPassed % state.Duration / state.Duration
	end,
	Target = function(state, p)
		local target = math.sign(state.Target or 0)

		if target == 0 then
			target = -math.sign(state.SecondsPassed)
		end

		if target == 0 then
			return 0, true
		end

		if state.UpdateTime then
			local v2 = (Time.GetSyncedUTC() - state.UpdateTime) * target
			state.SecondsPassed = state.RegisteredSeconds + v2
			state.UpdateTime = nil
			state.RegisteredSeconds = nil
		else
			state.SecondsPassed += target * p
		end

		local v2 = (target > 0 and math.min or math.max)(state.SecondsPassed / state.Duration, state.Target)
		return v2, v2 == state.Target
	end
}
return {
	GetEasingStyles = function(_)
		return v
	end
}