local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ServerInfo)
return function()
	if v.isLTMServer() then
		return "LTM"
	end

	if v.isElementalServer() then
		return "Elemental"
	end

	if v.isTutorialServer() then
		return "Tutorial"
	end

	if v.isNewPlayerLobbyServer() then
		return "NewPlayerLobby"
	end

	if v.isIntermediatePlayerLobbyServer() then
		return "IntermediatePlayerLobby"
	end

	if v.isTournamentEventServer() then
		return "TournamentDuo"
	end

	if v.isFiftyPlayersServer() then
		return "Fifty"
	end

	local proServer = v.isProServer()

	if proServer then
		return "Pro"
	end

	local duelLobbyServer = v.isDuelLobbyServer()

	if duelLobbyServer then
		return "Duel"
	end

	local duelMatchServer = v.isDuelMatchServer()

	if duelMatchServer then
		return "Duel"
	end

	local rankedMatchServer = v.isRankedMatchServer()

	if rankedMatchServer then
		return "Ranked"
	end

	local rankedLobbyServer = v.isRankedLobbyServer()

	if rankedLobbyServer then
		return "Ranked"
	end

	if v.isNoAbilityRankedLobbyServer() then
		return "No Ability Ranked Lobby"
	end

	if v.isNoAbilityRankedMatchServer() then
		return "No Ability Ranked Match"
	end

	local trainingServer = v.isTrainingServer()

	if trainingServer then
		return "Training"
	end

	if v.isTournamentLobbyServer() or v.isTournamentMatchServer() then
		return "Tournament"
	end

	if v.isDungeonsLobbyServer() or v.isDungeonsMatchServer() then
		return "Dungeon"
	end

	if v.isAFKServer() then
		return "AFK"
	end

	if v.isRhythmServer() then
		return "RhythmLTM"
	end

	if v.isProTradingPlazaServer() then
		return "ProTradingPlaza"
	end

	if v.isTradingPlazaServer() then
		return "TradingPlaza"
	end

	if proServer or rankedMatchServer or rankedLobbyServer or trainingServer or duelLobbyServer or duelMatchServer then
		return
	else
		return "Normal"
	end
end