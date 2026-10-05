local SpawnRateConfig = {
	COMMON_WEIGHT = 75,
	UNCOMMON_WEIGHT = 25,
	RARE_BASE_WEIGHT = 10,
	RARE_FLOOR_THRESHOLD = 5,
	RARE_WEIGHT_PER_STEP = 1,
	RARE_INTERVAL = 2,
	MAIN_BASE_WEIGHT = 4,
	MAIN_FLOOR_THRESHOLD = 5,
	MAIN_WEIGHT_PER_STEP = 4,
	MAIN_INTERVAL = 5,
	DANDY_WEIGHT_PER_NOBUY = 5,
	DANDY_NOBUY_THRESHOLD = 2,
	MILESTONE_MAIN_FLOOR = 20,
	MILESTONE_RARE_FLOOR = 15,
	NATURAL_MILESTONE_SPAWNS = true
}

function SpawnRateConfig.GetRareWeight(p)
	if SpawnRateConfig.RARE_FLOOR_THRESHOLD <= p then
		local v = math.max(SpawnRateConfig.RARE_INTERVAL, 1)
		return SpawnRateConfig.RARE_BASE_WEIGHT + SpawnRateConfig.RARE_WEIGHT_PER_STEP * (math.floor((p - SpawnRateConfig.RARE_FLOOR_THRESHOLD) / v) + 1)
	else
		return SpawnRateConfig.RARE_BASE_WEIGHT
	end
end

function SpawnRateConfig.GetMainWeight(p)
	if SpawnRateConfig.MAIN_FLOOR_THRESHOLD <= p then
		local v = math.max(SpawnRateConfig.MAIN_INTERVAL, 1)
		return SpawnRateConfig.MAIN_WEIGHT_PER_STEP * math.floor((p - SpawnRateConfig.MAIN_FLOOR_THRESHOLD) / v) + SpawnRateConfig.MAIN_BASE_WEIGHT
	else
		return 0
	end
end

return SpawnRateConfig