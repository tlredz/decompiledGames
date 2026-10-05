local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = ""
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
local v2 = require3(ReplicatedStorage2.Shared.UniverseIds)
local ServerInfo = {}

function ServerInfo.GetRankType(_)
	if ServerInfo.isNoAbilityRankedLobbyServer() or ServerInfo.isNoAbilityRankedMatchServer() then
		return "NoAbility"
	end

	return "Normal"
end

function ServerInfo.isReservedServer()
	if not RunService:IsServer() then
		return workspace:GetAttribute("isReservedServer")
	end

	return game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
end

function ServerInfo.isPrivateServer()
	if not RunService:IsServer() then
		return workspace:GetAttribute("isPrivateServer")
	end

	return game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0
end

function ServerInfo.isMobileServer()
	return game.PlaceId == v2.MobileServers.PlaceId
end

function ServerInfo.isTutorialServer()
	return game.PlaceId == v2.Tutorial.PlaceId or v == "Tutorial"
end

function ServerInfo.isNewPlayerLobbyServer()
	return game.PlaceId == v2.NewPlayerLobbies.PlaceId or game.PlaceId == v2.NewPlayerLobbiesTest.PlaceId or v == "NewPlayerLobby" or v == "NewPlayerLobbyTest"
end

function ServerInfo.isNewPlayerLobbyTestServer()
	return game.PlaceId == v2.NewPlayerLobbiesTest.PlaceId or v == "NewPlayerLobbyTest"
end

function ServerInfo.isIntermediatePlayerLobbyServer()
	return game.PlaceId == v2.IntermediatePlayerLobbies.PlaceId or v == "IntermediatePlayerLobby"
end

function ServerInfo.isElementalServer()
	return game.PlaceId == v2.Elemental.PlaceId or v == "Elemental"
end

function ServerInfo.isAFKServer()
	return game.PlaceId == v2.AFK.PlaceId or v == "AFK"
end

function ServerInfo.isRhythmServer()
	return game.PlaceId == v2.Rhythm.PlaceId or v == "Rhythm"
end

function ServerInfo.isVoiceServer()
	return game.PlaceId == v2.Voice.PlaceId or v == "Voice"
end

function ServerInfo.isBossFightServer()
	return game.PlaceId == v2.BossFight.PlaceId or v == "BossFight"
end

function ServerInfo.isRBBattlesServer()
	return game.PlaceId == v2.RBBattles.PlaceId or v == "RBBattles"
end

function ServerInfo.isLTMServer()
	return game.PlaceId == v2.LTM.PlaceId or v == "LTM"
end

function ServerInfo.isProServer()
	return game.PlaceId == v2.Pro.PlaceId or v == "Pro"
end

function ServerInfo.isRankedLobbyServer()
	return game.PlaceId == v2.Ranked.PlaceId or game.PlaceId == v2.RankedNoAbility.PlaceId or v == "RankedLobby" or v == "NoAbilityRankedLobby"
end

function ServerInfo.isRankedMatchServer()
	return (game.PlaceId == v2.RankedMatches.PlaceId or game.PlaceId == v2.RankedMatchesNoAbility.PlaceId) and ServerInfo.isReservedServer() or v == "Ranked" or v == "NoAbilityRanked"
end

function ServerInfo.isNoAbilityRankedMatchServer()
	return game.PlaceId == v2.RankedMatchesNoAbility.PlaceId or v == "NoAbilityRanked"
end

function ServerInfo.isNoAbilityRankedLobbyServer()
	return game.PlaceId == v2.RankedNoAbility.PlaceId or v == "NoAbilityRankedLobby"
end

function ServerInfo.isTrainingServer()
	return game.PlaceId == v2.MultiplayerTraining.PlaceId or v == "Training"
end

function ServerInfo.isDuelLobbyServer()
	return game.PlaceId == v2.Duel.PlaceId and not ServerInfo.isReservedServer() or v == "Duel"
end

function ServerInfo.isDuelMatchServer()
	return game.PlaceId == v2.Duel.PlaceId and ServerInfo.isReservedServer()
end

function ServerInfo.isTestGame()
	return game.GameId ~= 4777817887
end

function ServerInfo.isDevPlaceGame()
	return game.GameId == 5001998742
end

function ServerInfo.isTournamentMatchServer()
	return game.PlaceId == v2.TournamentMatches.PlaceId or v == "TournamentMatch"
end

function ServerInfo.isTournamentLobbyServer()
	return game.PlaceId == v2.TournamentLobby.PlaceId or v == "TournamentLobby"
end

function ServerInfo.isTournamentEventServer()
	return game.PlaceId == v2.TournamentDuo.PlaceId or v == "TournamentDuo"
end

function ServerInfo.isClanWarServer()
	return game.PlaceId == v2.ClanWar.PlaceId or v == "ClanWar"
end

function ServerInfo.isDungeonsMatchServer()
	return false
end

function ServerInfo.isDungeonsLobbyServer()
	return game.PlaceId == v2.DungeonsLobby.PlaceId or v == "DungeonsLobby"
end

function ServerInfo.isTradingPlazaServer()
	return game.PlaceId == v2.TradingPlaza.PlaceId or game.PlaceId == v2.ProTradingPlaza.PlaceId or v == "TradingPlaza" or v == "ProTradingPlaza"
end

function ServerInfo.isProTradingPlazaServer()
	return game.PlaceId == v2.ProTradingPlaza.PlaceId or v == "ProTradingPlaza"
end

function ServerInfo.isMedalTournamentLobby()
	return game.PlaceId == 130710618219168 or v == "MedalTournamentLobby"
end

function ServerInfo.isMedalTournamentMatch()
	return game.PlaceId == 97797226605681 or v == "MedalTournamentMatch"
end

function ServerInfo.isMedalServer()
	return ServerInfo.isMedalTournamentLobby() or ServerInfo.isMedalTournamentMatch()
end

function ServerInfo.isHuntPrivateServer()
	return workspace:GetAttribute("isHuntPrivateServer") == true
end

function ServerInfo.isRegionalTournamentMatch()
	return game.PlaceId == v2.RegionalTournament.PlaceId or v == "RegionalTournamentMatch"
end

function ServerInfo.isFiftyPlayersServer()
	return game.PlaceId == v2.FiftyPlayers.PlaceId or v == "FiftyPlayers"
end

function ServerInfo.legacy()
	script:SetAttribute("MainGamePlaceId", v2.Default.PlaceId)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "isDuelLobby"
	boolValue.Value = ServerInfo.isDuelLobbyServer()
	boolValue.Parent = script
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "RankedType"
	stringValue.Value = (ServerInfo.isNoAbilityRankedLobbyServer() or ServerInfo.isNoAbilityRankedMatchServer()) and "NoAbility" or "Normal"
	stringValue.Parent = script
	script.isRankedLobby.Value = ServerInfo.isRankedLobbyServer()
	local boolValue2 = Instance.new("BoolValue")
	boolValue2.Name = "isRankedMatch"
	boolValue2.Value = ServerInfo.isRankedMatchServer()
	boolValue2.Parent = script
	local boolValue3 = Instance.new("BoolValue")
	boolValue3.Name = "isTrainingMatch"
	boolValue3.Value = ServerInfo.isTrainingServer()
	boolValue3.Parent = script
	local boolValue4 = Instance.new("BoolValue")
	boolValue4.Name = "isDuelMatchServer"
	boolValue4.Value = ServerInfo.isDuelMatchServer()
	boolValue4.Parent = script
end

if not RunService:IsServer() then
	return ServerInfo
end

workspace:SetAttribute("isPrivateServer", ServerInfo.isPrivateServer())
workspace:SetAttribute("isReservedServer", ServerInfo.isReservedServer())
local privateServerOwnerId = game.PrivateServerOwnerId
local v3

if RunService:IsStudio() then
	v3 = workspace.Camera:FindFirstChild("isHuntPrivateServer") ~= nil
elseif game.GameId == 5001998742 then
	v3 = privateServerOwnerId == 276557820
else
	v3 = privateServerOwnerId == 8239127797
end

if v3 then
	workspace:SetAttribute("isHuntPrivateServer", v3)
end

return ServerInfo