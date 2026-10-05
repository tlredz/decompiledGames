local JourneyMath = {
	totalForTier = function(p, data)
		local v = math.max(0, math.min(data.MaxTier, p) - 1)
		return v * data.FirstTierXP + data.TierStepXP * v * (v - 1) / 2
	end
}

function JourneyMath.state(value, p)
	local v = math.max(0, (math.floor(value or 0)))
	local tier = 1

	while tier < p.MaxTier and JourneyMath.totalForTier(tier + 1, p) <= v do
		tier += 1
	end

	local totalForTier = JourneyMath.totalForTier(tier, p)
	local needed = not (tier < p.MaxTier) and 0 or JourneyMath.totalForTier(tier + 1, p) - totalForTier or 0
	return {
		tier = tier,
		earned = v - totalForTier,
		needed = needed,
		ratio = needed > 0 and math.clamp((v - totalForTier) / needed, 0, 1) or 1,
		complete = tier == p.MaxTier
	}
end

return JourneyMath