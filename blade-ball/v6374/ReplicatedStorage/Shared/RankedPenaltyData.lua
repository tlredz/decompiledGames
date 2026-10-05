local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local v = require3(ReplicatedStorage2.ServerInfo)
return {
	GracePeriodAmount = 3,
	CurrentRankedPenaltyDataVersion = 4,
	NonPunishablePenalty = {
		MatchInProgress = true
	},
	PunishablePenaltyReason = {
		Adandoning = true,
		MatchInProgress = false,
		AFK = true,
		Warning = false
	},
	RESET_TIME_FOR_CLEAR = 604800,
	AMOUNT_OF_GAMES_FOR_CLEAR = 30,
	GetListType = function(_, p: string?)
		if p then
			return p
		end

		local v2 = (v.isNoAbilityRankedMatchServer() or v.isNoAbilityRankedLobbyServer()) and "NoAbility" or "None"
		return (v.isRankedLobbyServer() or v.isRankedMatchServer()) and "Normal" or v2
	end
}