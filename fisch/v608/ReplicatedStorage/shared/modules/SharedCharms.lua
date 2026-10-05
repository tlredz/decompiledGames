game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local packages = ReplicatedStorage.packages
require(packages.Net)
require(packages.Signal)
require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local charms = require(modules.library.charms)
local SharedIdolFavor = require(modules.SharedIdolFavor)
local SharedDataHelper = require(modules.SharedDataHelper)
local constants = {
	LEVEL_CAP1 = 5,
	LEVEL_CAP2 = 10,
	MAX_LEVEL = 15,
	BASE_XP_PER_LEVEL = 190,
	LEVEL_XP_RAMP = 2,
	FISHING_XP_RATIO = 0.1,
	MAX_CHARMS_LEVEL_REQ = {
		0,
		5,
		10,
		20,
		30,
		45,
		60,
		80,
		100
	}
}
local SharedCharms = {
	Constants = constants,
	getRequiredXp = function(p: number)
		return 2 ^ (p - 1) * 190
	end,
	getStatBoost = function(p: string, p2: number)
		local charm = charms[p]

		if charm then
			return charm.BaseStatBoost + charm.StatBoostPerLevel * (p2 - 1)
		end

		warn((`Unknown Charm "{p}"`))
		return 0
	end,
	getMaxCharmsForLevel = function(p: number)
		for i, v2 in ipairs(constants.MAX_CHARMS_LEVEL_REQ) do
			if p < v2 then
				return i - 1
			end

			if v2 == p then
				return i
			end
		end

		return 9
	end
}

function SharedCharms.getMaxCharmsForPlayer(p)
	return SharedCharms.getMaxCharmsForLevel(SharedIdolFavor.GetLevel(p))
end

function SharedCharms.countActiveCharms(p)
	local count = 0

	for _ in SharedDataHelper.indexNewFormat(p, { "Charms", "Equipped" }) do
		count += 1
	end

	return count
end

return SharedCharms