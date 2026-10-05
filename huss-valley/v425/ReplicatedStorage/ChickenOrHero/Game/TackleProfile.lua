return table.freeze({
	select = function(data, value, max)
		local speedRatio = math.clamp(value / math.max(max, 0.01), 0, 1)
		local variant = data.Variants[1]

		for _, variant2 in data.Variants do
			if variant2.MinSpeedRatio <= speedRatio then
				variant = variant2
			end
		end

		local clone = table.clone(data)

		for k, v2 in variant do
			clone[k] = v2
		end

		clone.EntrySpeed = math.clamp(value, 0, max)
		clone.SpeedRatio = speedRatio
		local v2 = math.max(
			variant.Distance * (data.DistanceMultiplier or 1),
			clone.EntrySpeed * clone.Duration * (data.RunDistanceMultiplier or 1)
		)
		local duration = clone.Duration
		local v3 = math.min(clone.MotionBlendIn or 0.02, duration * 0.25)
		local v4 = duration - (v3 + math.min(clone.MotionBrake or 0.12, duration * 0.45)) / 2
		local v5 = math.clamp(clone.EntrySpeed, 0, v2 / math.max(v3, 0.001))
		local v6 = math.max(0, (v2 - v5 * v3 / 2) / v4)
		local v7 = math.clamp(data.BoostStrength or 1, 0, 1)
		local v8 = math.min(v6, v5) + math.max(0, v6 - v5) * v7
		local v9 = v5 * v3 / 2 + v8 * v4
		clone.Distance = math.min(v9, data.MaxDistance or 1e999)
		local v10 = not (v9 > 0) and 1 or clone.Distance / v9 or 1
		local duration2 = clone.Duration
		clone.Duration = duration2 * v10
		clone.MotionBlendIn = (clone.MotionBlendIn or 0.02) * v10
		clone.MotionBrake = (clone.MotionBrake or 0.12) * v10
		clone.Recovery += duration2 - clone.Duration
		return clone
	end
})