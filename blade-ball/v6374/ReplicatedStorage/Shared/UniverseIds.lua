local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local VoiceChatService = game:GetService("VoiceChatService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local v = nil

local function GetReplion(p, value: string?)
	if not v then
		v = require3(ReplicatedStorage2.Packages.Replion)
	end

	if not v then
		return
	end

	if isClient then
		return v.Client:WaitReplion(value or "Data")
	end

	local replionFor = isServer and v.Server:GetReplionFor(p, value or "Data")

	if replionFor then
		return replionFor
	end
end

local function VoiceChatAccessible(p)
	local success, result = pcall(VoiceChatService.IsVoiceEnabledForUserIdAsync, VoiceChatService, p.UserId)

	if success then
		return result
	end

	warn("Unable to fetch VoiceEnabledForUserId. Error: " .. result)
	return false
end

local function ProAccessible(p)
	if not v then
		v = require3(ReplicatedStorage2.Packages.Replion)
	end

	local replionFor

	if v then
		if isClient then
			replionFor = v.Client:WaitReplion("Data")
		else
			replionFor = isServer and v.Server:GetReplionFor(p, "Data") or nil
		end
	end

	if replionFor then
		return (replionFor:Get({ "TotalStats", "Wins" }) or 0) >= 50
	end

	return false
end

local function DuelAccessible(p)
	return not require3(game.ReplicatedStorage.ServerInfo).isDuelMatchServer()
end

local function AlwaysAccessible(p)
	return true
end

local function NotAccessible(p)
	return false
end

local function TradingAccessible(instance)
	require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
	local v2 = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
	local v3 = require3(ReplicatedStorage2.Shared.Policy)

	if RunService:IsClient() then
		if not v3:GetPolicyInfo().IsPaidItemTradingAllowed then
			return false
		end
	else
		local v4, v5 = v3:GetPlayerPolicyInfo(instance):now():await()

		if v4 and not v5.IsPaidItemTradingAllowed then
			return false
		end
	end

	if not v then
		v = require3(ReplicatedStorage2.Packages.Replion)
	end

	local replionFor

	if v then
		if isClient then
			replionFor = v.Client:WaitReplion("Data")
		else
			replionFor = isServer and v.Server:GetReplionFor(instance, "Data") or nil
		end
	end

	if not replionFor then
		return false
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local tradeLockedUntil = replionFor:Get("TradeLockedUntil")

	if tradeLockedUntil and tradeLockedUntil > 0 and serverTimeNow < tradeLockedUntil then
		return false
	end

	local v4 = replionFor:Get({ "TotalStats", "Wins" }) or 0
	return v2.TimeoutFFlag("TradingEnabled", 5, true) == true and not replionFor:Get("TradeBanned") and v4 >= 1
end

local function ProTradingPlazaAccessible(instance)
	local totalRAP = instance:GetAttribute("TotalRAP")

	if not v then
		v = require3(ReplicatedStorage2.Packages.Replion)
	end

	local replionFor

	if v then
		if isClient then
			replionFor = v.Client:WaitReplion("Inventory")
		elseif isServer then
			replionFor = v.Server:GetReplionFor(instance, "Inventory") or nil
		end
	end

	if not replionFor then
		return false
	end

	if not v then
		v = require3(ReplicatedStorage2.Packages.Replion)
	end

	local replionFor2

	if v then
		if isClient then
			replionFor2 = v.Client:WaitReplion("Data")
		elseif isServer then
			replionFor2 = v.Server:GetReplionFor(instance, "Data") or nil
		end
	end

	if not replionFor2 then
		return false
	end

	local v2 = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
	local tokens = replionFor:Get("Tokens") or 0
	local lastSavedRAP = replionFor2:Get("LastSavedRAP")
	local v3 = (totalRAP or lastSavedRAP or 0) + tokens
	local result

	if game.GameId == 4777817887 then
		local success
		success, result = pcall(function()
			local fFlag = v2.GetFFlag("TradingPlazaStaffBypassGroupRank")

			if fFlag then
				return fFlag <= instance:GetRankInGroup(game.CreatorId)
			end

			return false
		end)
		_ = success
	else
		result = false
	end

	return TradingAccessible(instance) and (v3 >= 50000 or result)
end

local function RankedAccessible(p)
	if not v then
		v = require3(ReplicatedStorage2.Packages.Replion)
	end

	local replionFor

	if v then
		if isClient then
			replionFor = v.Client:WaitReplion("Data")
		else
			replionFor = isServer and v.Server:GetReplionFor(p, "Data") or nil
		end
	end

	if not replionFor then
		return false
	end

	if replionFor.Data.RankedBanned then
		return false, -1
	end

	local v2 = replionFor:Get({ "TotalStats", "Wins" }) or 0
	local v3 = math.max(0, 10 - v2)
	local v4 = v2 >= 10
	local forceRankedMode = workspace:GetAttribute("ForceRankedMode") == true
	return v4 or forceRankedMode, v3
end

local function BossFightEventAccessible(p)
	return true
end

local function LTMAccessible(object)
	return ReplicatedStorage2.Shared.LTM.GetRecentLTM:Invoke().DateEndTime.UnixTimestamp > DateTime.now().UnixTimestamp or (RunService:IsStudio() or object:IsInGroup(12836673) and object:GetRankInGroup(12836673) >= 210)
end

local function CanInviteDuel(p)
	return not require3(game.ReplicatedStorage.ServerInfo).isDuelMatchServer()
end

local function ElementalAccessible(p)
	return true
end

local v2 = {
	Testing = {
		RBBattles = {
			PlaceId = 101792363513541,
			Accessible = NotAccessible,
			RejectionStatus = "50 PLAYER MODE IS NOT ENABLED",
			CanInvite = false
		},
		Voice = {
			PlaceId = 15351764032,
			Accessible = VoiceChatAccessible,
			RejectionStatus = "You do not have Voice Chat (13+) enabled!",
			CanInvite = true
		},
		Pro = {
			PlaceId = 15351763826,
			Accessible = ProAccessible,
			RejectionStatus = "You need at least 50 Wins!",
			CanInvite = true
		},
		Duel = {
			PlaceId = 15351764507,
			Accessible = DuelAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = CanInviteDuel
		},
		Ranked = {
			PlaceId = 15351764187,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatches", "Ranked" },
			CanInvite = true
		},
		RankedMatches = {
			PlaceId = 15351764348,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatches", "Ranked" },
			CanInvite = false
		},
		RankedNoAbility = {
			PlaceId = 0,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatchesNoAbility", "RankedNoAbility" },
			CanInvite = true
		},
		RankedMatchesNoAbility = {
			PlaceId = 0,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatchesNoAbility", "RankedNoAbility" },
			CanInvite = false
		},
		AFK = {
			PlaceId = 15351764966,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		Rhythm = {
			PlaceId = 118316345169916,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		Default = {
			PlaceId = 15351762625,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		MultiplayerTraining = {
			RequiredPlayers = 1,
			PlaceId = 15351764740,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		BossFight = {
			PlaceId = 15351765466,
			Accessible = BossFightEventAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		LTM = {
			PlaceId = 15552625961,
			Accessible = LTMAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		Elemental = {
			PlaceId = 16031541538,
			Accessible = ElementalAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		IntermediatePlayerLobbies = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		NewPlayerLobbiesTest = {
			PlaceId = 16581613207,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		NewPlayerLobbies = {
			PlaceId = 15582834071,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		Tutorial = {
			RequiredPlayers = 1,
			PlaceId = 16331635995,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		MobileServers = {
			PlaceId = 15462212483,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		TournamentLobby = {
			PlaceId = 16331633255,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		TournamentMatches = {
			PlaceId = 16331634414,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		TournamentDuo = {
			PlaceId = 17757578266,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		RegionalTournament = {
			PlaceId = 15351764881,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		ClanWar = {
			PlaceId = 16331635718,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		DungeonsLobby = {
			PlaceId = 15509357472,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		DungeonsMatch = {
			PlaceId = 15351765130,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		TradingPlaza = {
			PlaceId = 15582835531,
			Accessible = TradingAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false,
			AssociatedPlaces = { "ProTradingPlaza", "TradingPlaza" }
		},
		ProTradingPlaza = {
			PlaceId = 94739503741288,
			Accessible = ProTradingPlazaAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false,
			AssociatedPlaces = { "ProTradingPlaza", "TradingPlaza" }
		},
		BladeLeague = {
			PlaceId = 75474715372485,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		FiftyPlayers = {
			PlaceId = 15351765130,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		}
	},
	Dev = {
		RBBattles = {
			PlaceId = 101792363513541,
			Accessible = NotAccessible,
			RejectionStatus = "50 PLAYER MODE IS NOT ENABLED",
			CanInvite = false
		},
		Voice = {
			PlaceId = 15092011734,
			Accessible = VoiceChatAccessible,
			RejectionStatus = "You do not have Voice Chat (13+) enabled!",
			CanInvite = true
		},
		Pro = {
			PlaceId = 15131070225,
			Accessible = ProAccessible,
			RejectionStatus = "You need at least 50 Wins!",
			CanInvite = true
		},
		Duel = {
			PlaceId = 15227672707,
			Accessible = DuelAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = CanInviteDuel
		},
		Ranked = {
			PlaceId = 14907104587,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatches", "Ranked" },
			CanInvite = true
		},
		RankedMatches = {
			PlaceId = 15181537975,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatches", "Ranked" },
			CanInvite = false
		},
		RankedNoAbility = {
			PlaceId = 0,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatchesNoAbility", "RankedNoAbility" },
			CanInvite = true
		},
		RankedMatchesNoAbility = {
			PlaceId = 0,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatchesNoAbility", "RankedNoAbility" },
			CanInvite = false
		},
		AFK = {
			PlaceId = 15106881665,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		Rhythm = {
			PlaceId = 118316345169916,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		Default = {
			PlaceId = 14486733015,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		MultiplayerTraining = {
			RequiredPlayers = 1,
			PlaceId = 15229817314,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		BossFight = {
			PlaceId = 15509346379,
			Accessible = BossFightEventAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		LTM = {
			PlaceId = 15552625961,
			Accessible = LTMAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		Elemental = {
			PlaceId = 16031521714,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		IntermediatePlayerLobbies = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		NewPlayerLobbiesTest = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		NewPlayerLobbies = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		Tutorial = {
			RequiredPlayers = 1,
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		MobileServers = {
			PlaceId = 15582813408,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		TournamentLobby = {
			PlaceId = 0,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		TournamentMatches = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		TournamentDuo = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		RegionalTournament = {
			PlaceId = 15509346379,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		ClanWar = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		DungeonsLobby = {
			PlaceId = 0,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		DungeonsMatch = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		TradingPlaza = {
			PlaceId = 0,
			Accessible = TradingAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false,
			AssociatedPlaces = { "ProTradingPlaza", "TradingPlaza" }
		},
		ProTradingPlaza = {
			PlaceId = 0,
			Accessible = ProTradingPlazaAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false,
			AssociatedPlaces = { "ProTradingPlaza", "TradingPlaza" }
		},
		BladeLeague = {
			PlaceId = 75474715372485,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		FiftyPlayers = {
			PlaceId = 0,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		}
	},
	Public = {
		RBBattles = {
			PlaceId = 101792363513541,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		Voice = {
			PlaceId = 15131065025,
			Accessible = VoiceChatAccessible,
			RejectionStatus = "You do not have Voice Chat (13+) enabled!",
			CanInvite = true
		},
		Pro = {
			PlaceId = 14732610803,
			Accessible = ProAccessible,
			RejectionStatus = "You need at least 50 Wins!",
			CanInvite = true
		},
		Ranked = {
			PlaceId = 14915220621,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatches", "Ranked" },
			CanInvite = true
		},
		RankedMatches = {
			PlaceId = 15264892126,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatches", "Ranked" },
			CanInvite = false
		},
		RankedNoAbility = {
			PlaceId = 15582821022,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatchesNoAbility", "RankedNoAbility" },
			CanInvite = true
		},
		RankedMatchesNoAbility = {
			PlaceId = 15582823307,
			Accessible = RankedAccessible,
			RejectionStatus = "Failed to teleport!",
			AssociatedPlaces = { "RankedMatchesNoAbility", "RankedNoAbility" },
			CanInvite = false
		},
		AFK = {
			PlaceId = 14368557094,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		Rhythm = {
			PlaceId = 97204747083036,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		Duel = {
			PlaceId = 15144787112,
			Accessible = DuelAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = CanInviteDuel
		},
		Default = {
			PlaceId = 13772394625,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		MultiplayerTraining = {
			RequiredPlayers = 1,
			PlaceId = 15234596844,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		BossFight = {
			PlaceId = 15185247558,
			Accessible = BossFightEventAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		LTM = {
			PlaceId = 15552588346,
			Accessible = LTMAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		Elemental = {
			PlaceId = 15517169103,
			Accessible = ElementalAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		IntermediatePlayerLobbies = {
			PlaceId = 0,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		NewPlayerLobbiesTest = {
			PlaceId = 16331600459,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		NewPlayerLobbies = {
			PlaceId = 16281300371,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		Tutorial = {
			RequiredPlayers = 1,
			PlaceId = 16044264830,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		MobileServers = {
			PlaceId = 15509350986,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		TournamentLobby = {
			PlaceId = 16331595046,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		TournamentMatches = {
			PlaceId = 16331596518,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		TournamentDuo = {
			PlaceId = 17757592456,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		RegionalTournament = {
			PlaceId = 111661204337143,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		ClanWar = {
			PlaceId = 16331598816,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		DungeonsLobby = {
			PlaceId = 16581648071,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = true
		},
		DungeonsMatch = {
			PlaceId = 16456370330,
			Accessible = NotAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		TradingPlaza = {
			PlaceId = 16581637217,
			Accessible = TradingAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false,
			AssociatedPlaces = { "ProTradingPlaza", "TradingPlaza" }
		},
		ProTradingPlaza = {
			PlaceId = 92458008626219,
			Accessible = ProTradingPlazaAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false,
			AssociatedPlaces = { "ProTradingPlaza", "TradingPlaza" }
		},
		BladeLeague = {
			PlaceId = 80316691895873,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		},
		FiftyPlayers = {
			PlaceId = 16456370330,
			Accessible = AlwaysAccessible,
			RejectionStatus = "Failed to teleport!",
			CanInvite = false
		}
	}
}

if game.GameId == 5295074138 then
	return v2.Testing
end

if game.GameId == 5001998742 then
	return v2.Dev
end

return v2.Public