local MovementConfig = require(script.Parent.MovementConfig)
local crossingBalance = MovementConfig.CrossingBalance
return table.freeze({
	calculate = function(p, p2)
		local catchers = math.max(0, (math.floor(p)))
		local runners = math.max(0, (math.floor(p2)))
		local v3 = catchers + runners
		local pressure = not (crossingBalance.Enabled and catchers > 0 and runners > 0 and v3 > 2) and 0 or math.clamp(
			(catchers - 1) / (v3 - 2),
			0,
			1
		) ^ crossingBalance.PressureExponent
		return {
			catchers = catchers,
			runners = runners,
			pressure = pressure,
			runnerScale = 1 + crossingBalance.RunnerMaxBonus * pressure,
			catcherScale = 1 - crossingBalance.CatcherMaxReduction * pressure
		}
	end
})