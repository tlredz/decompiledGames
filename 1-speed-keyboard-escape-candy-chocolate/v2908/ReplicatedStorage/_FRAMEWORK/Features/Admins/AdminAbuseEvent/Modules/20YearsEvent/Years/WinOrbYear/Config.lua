local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
local winOrbs = {
	orbTemplate = "AdminAbuse/20Anniversary/Assets/CollectibleOrb",
	spawnIntervalMinSeconds = 0.5,
	spawnIntervalMaxSeconds = 1,
	orbsPerWave = 14,
	initialOrbsPerPlayer = 250,
	maxActivePerPlayer = 250,
	orbLifetimeSeconds = 60,
	hoverHeightStuds = 2,
	triggerRadiusStuds = 10,
	floatDurationSeconds = 0.45
}
local v2 = {
	[2017] = 0.9,
	[2021] = 0.7,
	[2022] = 0.85,
	[2025] = 0.9
}

local function scaleCount(p: number, p2: number)
	return (math.floor(p * p2 + 0.5))
end

return {
	orbSpawnZoneName = "OrbSpawnZone",
	winOrbs = winOrbs,
	winOrbsForYear = function(p: number)
		local v3 = v2[p]

		if not v3 then
			return winOrbs
		end

		local clone = table.clone(winOrbs)
		clone.orbsPerWave = math.floor(v3 * 14 + 0.5)
		clone.initialOrbsPerPlayer = math.floor(v3 * 250 + 0.5)
		clone.maxActivePerPlayer = math.floor(v3 * 250 + 0.5)
		return clone
	end,
	awardSourceTemplate = "20YearsEvent:%d:WinOrb"
}