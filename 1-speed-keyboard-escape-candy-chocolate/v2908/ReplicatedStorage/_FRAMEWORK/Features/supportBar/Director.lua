local Config = require(script.Parent.Config)
require(script.Parent.Types)
local clone = table.clone(Config.defaults)
local cruzShare = clone.cruzShare
local totalVotes = clone.totalVotes
local cruzShare2 = clone.cruzShare
local autoIntervalSeconds = 0
local random = Random.new()

function jitter(p: number, p2: number)
	return p + (random:NextNumber() * 2 - 1) * p2
end

function resolveTargetShare()
	if clone.autoMode then
		return cruzShare2
	end

	return clone.cruzShare
end

local Director = {}

function Director.getConfig()
	return table.clone(clone)
end

function Director.setConfig(data)
	local v = data.totalVotes ~= clone.totalVotes
	local v2 = data.autoMode and not clone.autoMode
	clone = table.clone(data)

	if v then
		totalVotes = data.totalVotes
	end

	if v2 then
		autoIntervalSeconds = data.autoIntervalSeconds
	end
end

function Director.step(p: number)
	totalVotes = math.max(0, totalVotes + clone.totalGrowthPerMinute * p / 60)

	if clone.autoMode then
		autoIntervalSeconds += p

		if autoIntervalSeconds >= clone.autoIntervalSeconds then
			autoIntervalSeconds = 0
			cruzShare2 = random:NextNumber(clone.autoMinShare, clone.autoMaxShare)
		end
	end

	local v = clone.driftPerSecond * p
	local v2 = resolveTargetShare() - cruzShare
	cruzShare = math.clamp(cruzShare + math.clamp(v2, -v, v), 0, 1)
end

function Director.buildSnapshot()
	local v = math.max(0, (math.round((jitter(totalVotes, totalVotes * clone.totalNoise)))))
	local cruz = math.round(v * math.clamp(jitter(cruzShare, clone.shareNoise), 0, 1))
	return {
		active = clone.active,
		cruz = cruz,
		splink = v - cruz,
		at = os.time()
	}
end

return Director