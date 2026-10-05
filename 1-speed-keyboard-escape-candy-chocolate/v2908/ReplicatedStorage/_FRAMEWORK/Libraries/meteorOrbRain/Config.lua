require(script.Parent.Parent.floatingOrbWins.Types)
require(script.Parent.Types)
local Config = {}

local function mergeOrbs(p, p2)
	local clone = table.clone(p.orbs)
	local orbs

	if p2 then
		orbs = p2.orbs
	end

	if orbs then
		for k, orb in orbs do
			if orb ~= nil then
				clone[k] = orb
			end
		end
	end

	return clone
end

local function checkConfigCoherent(data)
	if data.dropIntervalMinSeconds <= 0 or data.dropIntervalMinSeconds > data.dropIntervalMaxSeconds then
		return false, "meteorOrbRain: dropIntervalMinSeconds must be > 0 and <= dropIntervalMaxSeconds"
	end

	if data.dropsPerWave < 1 then
		return false, "meteorOrbRain: dropsPerWave must be at least 1"
	end

	if data.maxActiveMeteors < 1 then
		return false, "meteorOrbRain: maxActiveMeteors must be at least 1"
	end

	if data.fallDurationSeconds <= 0 then
		return false, "meteorOrbRain: fallDurationSeconds must be > 0"
	end

	return true, nil
end

function Config.default()
	return {
		dropIntervalMinSeconds = 1.2,
		dropIntervalMaxSeconds = 2.2,
		dropsPerWave = 2,
		maxActiveMeteors = 8,
		fallDurationSeconds = 1.6,
		fallHeightStuds = 140,
		fallDriftStuds = 40,
		impactRadiusStuds = 7,
		impactDamage = 0,
		zoneEdgeMarginStuds = 4,
		orbHoverStuds = 3,
		orbs = {
			orbScale = 3,
			triggerRadiusStuds = 10,
			orbLifetimeSeconds = 14,
			maxActivePerPlayer = 12
		}
	}
end

function Config.resolve(options)
	local default = Config.default()
	local clone = table.clone(default)

	for k, v in options or {} do
		if k ~= "orbs" and v ~= nil then
			clone[k] = v
		end
	end

	local clone2 = table.clone(default.orbs)
	local orbs

	if options then
		orbs = options.orbs
	end

	if orbs then
		for k, orb in orbs do
			if orb ~= nil then
				clone2[k] = orb
			end
		end
	end

	clone.orbs = clone2
	local flag, v

	if clone.dropIntervalMinSeconds <= 0 or clone.dropIntervalMinSeconds > clone.dropIntervalMaxSeconds then
		flag = false
		v = "meteorOrbRain: dropIntervalMinSeconds must be > 0 and <= dropIntervalMaxSeconds"
	elseif clone.dropsPerWave < 1 then
		flag = false
		v = "meteorOrbRain: dropsPerWave must be at least 1"
	elseif clone.maxActiveMeteors < 1 then
		flag = false
		v = "meteorOrbRain: maxActiveMeteors must be at least 1"
	elseif clone.fallDurationSeconds <= 0 then
		flag = false
		v = "meteorOrbRain: fallDurationSeconds must be > 0"
	else
		flag = true
	end

	if flag then
		return clone
	end

	error(v)
end

return Config