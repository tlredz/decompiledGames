require(script.Parent.Types)
local Config = {}

local function checkConfigCoherent(result)
	if result.spawnIntervalMinSeconds <= 0 or result.spawnIntervalMinSeconds > result.spawnIntervalMaxSeconds then
		return false, "floatingOrbWins: spawnIntervalMinSeconds must be > 0 and <= spawnIntervalMaxSeconds"
	end

	if result.orbsPerWave < 1 then
		return false, "floatingOrbWins: orbsPerWave must be at least 1"
	end

	if result.maxActivePerPlayer < 1 then
		return false, "floatingOrbWins: maxActivePerPlayer must be at least 1"
	end

	if result.initialOrbsPerPlayer < 0 or result.initialOrbsPerPlayer > result.maxActivePerPlayer then
		return false, "floatingOrbWins: initialOrbsPerPlayer must be >= 0 and <= maxActivePerPlayer"
	end

	if result.spawnCandidates < 1 then
		return false, "floatingOrbWins: spawnCandidates must be at least 1"
	end

	if result.orbLifetimeSeconds <= 0 then
		return false, "floatingOrbWins: orbLifetimeSeconds must be > 0"
	end

	if result.triggerRadiusStuds <= 0 then
		return false, "floatingOrbWins: triggerRadiusStuds must be > 0"
	end

	if result.floatDurationSeconds <= 0 then
		return false, "floatingOrbWins: floatDurationSeconds must be > 0"
	end

	if result.endScale <= 0 or result.endScale > 1 then
		return false, "floatingOrbWins: endScale must be > 0 and <= 1"
	end

	if result.orbScale <= 0 then
		return false, "floatingOrbWins: orbScale must be > 0"
	end

	return true, nil
end

function Config.default()
	return {
		orbTemplate = "Assets/Events/FloatingWinOrb",
		spawnIntervalMinSeconds = 0.7,
		spawnIntervalMaxSeconds = 1.6,
		orbsPerWave = 2,
		initialOrbsPerPlayer = 0,
		maxActivePerPlayer = 14,
		orbLifetimeSeconds = 16,
		hoverHeightStuds = 10,
		zoneEdgeMarginStuds = 4,
		spawnCandidates = 8,
		triggerRadiusStuds = 25,
		floatDurationSeconds = 0.45,
		endScale = 0.05,
		orbScale = 1,
		idleBobStuds = 0.5,
		idleBobSpeed = 2,
		idleSpinSpeed = 1.5,
		collectSpinSpeed = 22,
		collectCooldownSeconds = 0.15,
		collectMaxDistanceStuds = 150
	}
end

function Config.resolve(options)
	local result = Config.default()

	for k, v in options or {} do
		if v ~= nil then
			result[k] = v
		end
	end

	local v, v2 = checkConfigCoherent(result)

	if v then
		return result
	end

	error(v2)
end

return Config