local JobsEXP = {
	Config = {
		baseMultiplier = 280,
		levelCap = 100,
		rarityThreshold2 = 40,
		rarityThreshold3 = 51,
		spikeMultiplier = 1.75,
		experienceCap = 200000000
	},
	getExpForLevel = function(self, p2)
		if p2 <= 1 then
			return 0
		end

		local total = 0

		for i = 1, p2 - 1 do
			local v

			if self.Config.rarityThreshold2 <= i then
				v = math.floor(i + math.pow(2, i / 13) * 200)
			elseif self.Config.rarityThreshold3 <= i then
				v = math.floor(i + math.pow(2, i / 9) * 200)
			else
				v = math.floor(i + math.pow(2, i / 16) * 200)
			end

			total += v
		end

		return (math.floor(total / 4))
	end,
	getLevelFromExp = function(self, p)
		if p <= 0 then
			return 1
		end

		local v = math.min(p, self.Config.experienceCap)
		local levelCap = self.Config.levelCap
		local v2 = 1

		while v2 <= levelCap do
			local v3 = math.floor((v2 + levelCap) / 2)

			if self:getExpForLevel(v3) <= v then
				v2 = v3 + 1
			else
				levelCap = v3 - 1
			end
		end

		return levelCap
	end,
	getExpForNextLevel = function(self, p)
		local expForLevel = self:getExpForLevel(p)
		return self:getExpForLevel(p + 1) - expForLevel
	end
}
local expForLevel = JobsEXP:getExpForLevel(100)

function JobsEXP:getLevelData(currentExp)
	local level = self:getLevelFromExp(currentExp)
	local expForLevel2 = self:getExpForLevel(level)
	local expForLevel3 = self:getExpForLevel(level + 1)
	local expToNextLevel = expForLevel3 - expForLevel2
	local expInCurrentLevel = currentExp - expForLevel2
	return {
		level = level,
		currentExp = currentExp,
		expInCurrentLevel = expInCurrentLevel,
		expToNextLevel = expToNextLevel,
		percentToNextLevel = expInCurrentLevel / expToNextLevel * 100,
		baseLevelExp = expForLevel2,
		nextLevelExp = expForLevel3,
		maxExp = expForLevel
	}
end

JobsEXP.LevelExpTable = {}

for i = 1, 100 do
	JobsEXP.LevelExpTable[i] = JobsEXP:getLevelData(JobsEXP:getExpForLevel(i)).expToNextLevel
end

function JobsEXP.printExpTable(object, value)
	print("Level | Exp Required | Exp Difference | % Increase")
	print("------|--------------|----------------|----------")
	local v = 0

	for i = 2, value or 99 do
		local expForLevel2 = object:getExpForLevel(i)
		local v2 = expForLevel2 - v
		local v3 = not (v > 0) and 0 or v2 / v * 100 or 0
		local v4 = tostring(expForLevel2):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		local v5 = tostring(v2):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		print(string.format("%5d | %12s | %14s | %8.2f%%", i, v4, v5, v3))

		if i == 7 or i == 14 or i == 42 or i == 70 or i == 92 or i == object.Config.rarityThreshold2 then
			print("------|--------------|----------------|----------")
		end

		v = expForLevel2
	end
end

return JobsEXP