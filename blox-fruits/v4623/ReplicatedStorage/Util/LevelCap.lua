local RunService = game:GetService("RunService")
require(game.ReplicatedStorage.Definitions.Map)
local CONSTANTS = require(script.CONSTANTS)
local LEVELS_PER_BONUS_MOMENT = CONSTANTS.LEVELS_PER_BONUS_MOMENT
local LevelCap = {
	getSecretLevelsUnlocked = function(items, items2)
		local total = 0

		if items then
			for _, item in items do
				if item.Completed then
					total += LEVELS_PER_BONUS_MOMENT
				end
			end
		end

		if items2 then
			for _, _ in items2 do
				total += LEVELS_PER_BONUS_MOMENT
			end
		end

		return (math.clamp(total, 0, CONSTANTS.LEVEL_CAP.EXTENSIONS.SECRETS))
	end
}

function LevelCap.tryGetLevelCap(instance)
	if RunService:IsServer() then
		local Global = require(game.ServerStorage.Global)
		local v = Global.session[instance]

		if not v then
			return nil
		end

		local data = v.Data
		local secretLevelsUnlocked = LevelCap.getSecretLevelsUnlocked(data.BonusMoments, data.CompletedMaps)
		return (math.clamp(
			CONSTANTS.LEVEL_CAP.BASE + secretLevelsUnlocked,
			CONSTANTS.LEVEL_CAP.BASE,
			LevelCap.getMaxLevelCap(instance)
		))
	else
		local attribute = instance:GetAttribute(CONSTANTS.LEVEL_CAP.ATTR_KEY)

		if type(attribute) == "number" then
			return attribute
		end

		return nil
	end
end

function LevelCap.getLevelCap(p)
	return LevelCap.tryGetLevelCap(p) or CONSTANTS.LEVEL_CAP.BASE
end

function LevelCap.getMaxLevelCap(_)
	return CONSTANTS.LEVEL_CAP.THEORETICAL_MAX
end

LevelCap.replicateLevelCap = RunService:IsServer() and function(instance)
	instance:SetAttribute(CONSTANTS.LEVEL_CAP.ATTR_KEY, LevelCap.tryGetLevelCap(instance))
end or nil
return LevelCap