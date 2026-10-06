local MathEquationTiming = {
	TOKEN_COUNT = 5
}

-- equivalent calls inferred from this helper; original call sites unknown
local function nonNegative(tokenInterval)
	if type(tokenInterval) == "number" then
		return (math.max(tokenInterval, 0))
	end

	return 0
end

function MathEquationTiming.tokenRevealTime(p, p2: number)
	local v = math.clamp(math.floor(p2), 1, MathEquationTiming.TOKEN_COUNT)
	local v2 = nonNegative(p.tokenInterval) -- equivalent call inferred; original call site unknown

	if v <= 4 then
		return (v - 1) * v2
	end

	return v2 * 3 + nonNegative(p.resultRevealDelay)
end

function MathEquationTiming.calculateDuration(p)
	return MathEquationTiming.tokenRevealTime(p, MathEquationTiming.TOKEN_COUNT) + nonNegative(p.fireDelay)
end

return MathEquationTiming