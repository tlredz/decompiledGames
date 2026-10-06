local BattleAnalysisTypes = {
	BUCKET_WIDTH = 2,
	BUCKET_COUNT = 31,
	PAIR_SEPARATOR = "|"
}

function BattleAnalysisTypes.makePairKey(p: string, p2: string)
	if p <= p2 then
		return p .. BattleAnalysisTypes.PAIR_SEPARATOR .. p2
	end

	return p2 .. BattleAnalysisTypes.PAIR_SEPARATOR .. p
end

function BattleAnalysisTypes.parsePairKey(value: string)
	local v = string.find(value, BattleAnalysisTypes.PAIR_SEPARATOR, 1, true)

	if v then
		return string.sub(value, 1, v - 1), (string.sub(value, v + 1))
	end

	return nil, nil
end

function BattleAnalysisTypes.bucketIndexForDuration(p: number)
	return (math.clamp(math.floor(p / BattleAnalysisTypes.BUCKET_WIDTH) + 1, 1, BattleAnalysisTypes.BUCKET_COUNT))
end

function BattleAnalysisTypes.bucketLabel(p: number)
	local BUCKET_WIDTH = BattleAnalysisTypes.BUCKET_WIDTH

	if BattleAnalysisTypes.BUCKET_COUNT <= p then
		return string.format("%d+", (p - 1) * BUCKET_WIDTH)
	end

	return string.format("%d-%d", (p - 1) * BUCKET_WIDTH, p * BUCKET_WIDTH)
end

function BattleAnalysisTypes.emptyBuckets()
	local result = table.create(BattleAnalysisTypes.BUCKET_COUNT, 0)

	for i = 1, BattleAnalysisTypes.BUCKET_COUNT do
		result[i] = 0
	end

	return result
end

function BattleAnalysisTypes.newPairStat()
	return {
		matches = 0,
		winsByRole = {},
		draws = 0,
		totalDuration = 0,
		durationBuckets = BattleAnalysisTypes.emptyBuckets(),
		lastSeed = 0
	}
end

function BattleAnalysisTypes.normalizePairStat(data)
	if typeof(data) ~= "table" then
		return BattleAnalysisTypes.newPairStat()
	end

	local emptyBuckets = BattleAnalysisTypes.emptyBuckets()

	if typeof(data.durationBuckets) == "table" then
		for i = 1, BattleAnalysisTypes.BUCKET_COUNT do
			local durationBucket = data.durationBuckets[i]
			emptyBuckets[i] = typeof(durationBucket) ~= "number" and 0 or durationBucket
		end
	end

	local winsByRole = {}

	if typeof(data.winsByRole) == "table" then
		for k, v2 in data.winsByRole do
			if not (typeof(k) == "string" and typeof(v2) == "number") then
				continue
			end

			winsByRole[k] = v2
		end
	end

	return {
		matches = typeof(data.matches) ~= "number" and 0 or data.matches,
		winsByRole = winsByRole,
		draws = typeof(data.draws) ~= "number" and 0 or data.draws,
		totalDuration = typeof(data.totalDuration) ~= "number" and 0 or data.totalDuration,
		durationBuckets = emptyBuckets,
		lastSeed = typeof(data.lastSeed) ~= "number" and 0 or data.lastSeed
	}
end

function BattleAnalysisTypes:mergePairStat(data)
	self.matches += data.matches
	self.draws += data.draws
	self.totalDuration += data.totalDuration
	self.lastSeed = math.max(self.lastSeed, data.lastSeed)

	for k, v in data.winsByRole do
		self.winsByRole[k] = (self.winsByRole[k] or 0) + v
	end

	for i = 1, BattleAnalysisTypes.BUCKET_COUNT do
		self.durationBuckets[i] = (self.durationBuckets[i] or 0) + (data.durationBuckets[i] or 0)
	end
end

return BattleAnalysisTypes