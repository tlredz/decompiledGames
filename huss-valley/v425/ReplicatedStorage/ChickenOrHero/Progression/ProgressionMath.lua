local ProgressionConfig = require(script.Parent.ProgressionConfig)
local ProgressionMath = {
	crossing = function(p, p2, p3)
		local v = p3 or ProgressionConfig

		if p <= 0 or p2 <= 0 then
			return 0
		end

		return (math.round(v.CrossingBaseXP + v.CrossingPressureXP * p / (p + p2)))
	end,
	totalForLevel = function(p, p2)
		local v = p2 or ProgressionConfig
		local v2 = math.max(0, math.floor(p) - 1)
		return v2 * v.FirstLevelXP + v.LevelStepXP * v2 * (v2 - 1) / 2
	end
}

function ProgressionMath.state(value, p)
	local v = p or ProgressionConfig
	local total = (type(value) ~= "number" or value ~= value) and 0 or math.clamp(
		math.floor(value),
		0,
		9000000000000000
	) or 0
	local firstLevelXP = v.FirstLevelXP
	local levelStepXP = v.LevelStepXP
	local v3

	if levelStepXP == 0 then
		v3 = math.floor(total / firstLevelXP)
	else
		local v4 = 2 * firstLevelXP - levelStepXP
		v3 = math.floor((-v4 + math.sqrt(v4 * v4 + 8 * levelStepXP * total)) / (2 * levelStepXP))
	end

	local level = math.max(1, v3 + 1)

	while ProgressionMath.totalForLevel(level + 1, v) <= total do
		level += 1
	end

	while total < ProgressionMath.totalForLevel(level, v) do
		level -= 1
	end

	local needed = firstLevelXP + levelStepXP * (level - 1)
	local earned = total - ProgressionMath.totalForLevel(level, v)
	return {
		total = total,
		level = level,
		earned = earned,
		needed = needed,
		ratio = earned / needed
	}
end

return ProgressionMath