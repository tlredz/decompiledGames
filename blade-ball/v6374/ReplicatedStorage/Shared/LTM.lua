local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(script.DISABLED_ABILITIES)
local v3 = require3(ReplicatedStorage2.Shared.DeepCopy)
local v4 = require3(ReplicatedStorage2.Common.RewardInfo)
local fFlag = require3(ReplicatedStorage2.Common.Utils).FFlag
local v5 = {}
local v6 = {
	RobloxClassic = {
		Id = "RobloxClassic",
		ModeName = "Roblox Classic",
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 1796781825,
			GiftProductId = 1796781825
		},
		TicketDisplayName = "Hacker Ticket",
		TicketName = "HackerTickets",
		LoginStreak = "HackerLoginStreak",
		ClaimedStreaks = "HackerClaimedStreaks",
		LastLoginStreak = "HackerLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2024, 6, 8, 16)
	},
	Dragon = {
		Id = "Dragon",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 1796781825,
			GiftProductId = 1796781825
		},
		TicketDisplayName = "Dragon Ticket",
		TicketName = "DragonTickets",
		LoginStreak = "DragonLoginStreak",
		ClaimedStreaks = "DragonClaimedStreaks",
		LastLoginStreak = "DragonLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2024, 6, 22, 15)
	},
	Rebirth = {
		Id = "Rebirth",
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 1796781825,
			GiftProductId = 1796781825
		},
		TicketDisplayName = "Rebirth Ticket",
		TicketName = "RebirthTickets",
		LoginStreak = "RebirthLoginStreak",
		ClaimedStreaks = "RebirthClaimedStreaks",
		LastLoginStreak = "RebirthLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2024, 7, 1, 16)
	},
	FloodSurvival = {
		Id = "FloodSurvival",
		ModeName = "Flood Survival",
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = true,
			Mode = "FloodSurvival",
			ProductId = 1865615828,
			GiftProductId = 1865615834
		},
		TicketDisplayName = "Water Ticket",
		TicketName = "WaterTickets",
		LoginStreak = "WaterLoginStreak",
		ClaimedStreaks = "WaterClaimedStreaks",
		LastLoginStreak = "WaterLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2024, 7, 20, 16)
	},
	Shark = {
		Id = "Shark",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 1796781825,
			GiftProductId = 1796781825
		},
		TicketDisplayName = "Shark Ticket",
		TicketName = "SharkTickets",
		LoginStreak = "SharkLoginStreak",
		ClaimedStreaks = "SharkClaimedStreaks",
		LastLoginStreak = "SharkLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2024, 8, 1, 12)
	},
	Dodgeball = {
		Id = "Dodgeball",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Dodgeball Ticket",
		TicketName = "Dodgeball4Tickets",
		LoginStreak = "Dodgeball4LoginStreak",
		ClaimedStreaks = "Dodgeball4ClaimedStreaks",
		LastLoginStreak = "Dodgeball4LastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1757779200)
	},
	HotPotato = {
		Id = "HotPotato",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Potato Ticket",
		TicketName = "HotPotatoTickets",
		LoginStreak = "HotPotatoLoginStreak",
		ClaimedStreaks = "HotPotatoClaimedStreaks",
		LastLoginStreak = "HotPotatoLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2024, 10, 19, 9)
	},
	HalloweenEvent = {
		Id = "HalloweenEvent",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		ModeDisplayName = "Halloween Event",
		TicketDisplayName = "Candies",
		TicketName = "HalloweenEvent.Candy",
		CrateCost = 100,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 0,
			GiftProductId = 0
		},
		DateEndTime = DateTime.fromUnixTimestamp(1730523732)
	},
	MysteryBall = {
		Id = "MysteryBall",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		ModeDisplayName = "Mystery Ball",
		TicketDisplayName = "Mystery Ball Ticket",
		TicketName = "MysteryBallTickets",
		LoginStreak = "MysteryBallLoginStreak",
		ClaimedStreaks = "MysteryBallClaimedStreaks",
		LastLoginStreak = "MysteryBallLastLoginStreak",
		CrateCost = 1,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 0,
			GiftProductId = 0
		},
		DateEndTime = DateTime.fromUnixTimestamp(1732381200)
	},
	CrownClash = {
		Id = "CrownClash",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		ModeDisplayName = "Crown Clash",
		TicketDisplayName = "Crowns",
		TicketName = "CrownClash2Tickets",
		LeaderboardVersion = 2,
		CrateCost = 1,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 0,
			GiftProductId = 0
		},
		DateEndTime = DateTime.fromUnixTimestamp(1747501200)
	},
	WinterRoyale = {
		Id = "WinterRoyale",
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		ModeDisplayName = "Winter Royale",
		Pack = {
			IsEnabled = true,
			Mode = "WinterRoyale",
			ProductId = 2669574286,
			GiftProductId = 2669574287,
			Rewards = {
				v4.createSwordReward("Glacial Crown"),
				v4.createExplosionReward("Crown Burst"),
				v4.createEmoteReward("Royal Toast")
			}
		},
		TicketDisplayName = "Winter Royale Ticket",
		TicketName = "WinterRoyaleTickets",
		LoginStreak = "WinterRoyaleLoginStreak",
		ClaimedStreaks = "WinterRoyaleClaimedStreaks",
		LastLoginStreak = "WinterRoyaleLastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1735837200)
	},
	SantasVsElves = {
		Id = "SantasVsElves",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		ModeDisplayName = "Santas vs Elves",
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 0,
			GiftProductId = 0
		},
		DateEndTime = DateTime.fromUnixTimestamp(1735837200)
	},
	Overdrive = {
		Id = "Overdrive",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 1796781825,
			GiftProductId = 1796781825
		},
		LobbyCrateWindow = "OverdriveLobbyCrate",
		LobbyTicketsWindow = "OverdriveLobbyTickets",
		TicketDisplayName = "Overdrive Ticket",
		TicketName = "OverdriveTickets",
		LoginStreak = "OverdriveLoginStreak",
		ClaimedStreaks = "OverdriveClaimedStreaks",
		LastLoginStreak = "OverdriveLastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1772906400)
	},
	Fates = {
		Id = "Fates",
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		ModeDisplayName = "Fates",
		Pack = {
			IsEnabled = true,
			Mode = "Fates",
			ProductId = 2710643457,
			GiftProductId = 2710643456,
			Rewards = {
				v4.createSwordReward("Ancient Trident"),
				v4.createExplosionReward("Ancient Technology"),
				v4.createLTMTicketReward(25, "Fates Tickets")
			}
		},
		TicketDisplayName = "Fates Ticket",
		TicketName = "FatesTickets",
		LoginStreak = "FatesLoginStreak",
		ClaimedStreaks = "FatesClaimedStreaks",
		LastLoginStreak = "FatesLastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1739642400)
	},
	AbilityGame = {
		Id = "AbilityGame",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		ModeDisplayName = "Ability Game",
		TicketDisplayName = "Ability Game Tickets",
		TicketName = "AbilityGameTickets",
		CrateCost = 1,
		Pack = {
			IsEnabled = false,
			Mode = "Storm",
			ProductId = 0,
			GiftProductId = 0
		},
		LoginStreak = "AbilityGameLoginStreak",
		ClaimedStreaks = "AbilityGameClaimedStreaks",
		LastLoginStreak = "AbilityGameLastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1759590000)
	},
	Flying = {
		Id = "Flying",
		UseMapVoting = false,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 2,
		ModeDisplayName = "Zero Gravity LTM",
		Pack = {
			IsEnabled = true,
			Mode = "Flying",
			ProductId = 3234123578,
			GiftProductId = 3234123577,
			Rewards = {
				v4.createSwordReward("Shackled Celestial"),
				v4.createEmoteReward("Cloud 9"),
				v4.createLTMTicketReward(25, "Rocket Tickets")
			}
		},
		TicketDisplayName = "Rocket Ticket",
		TicketName = "Rocket2Tickets",
		LoginStreak = "Rocket2LoginStreak",
		ClaimedStreaks = "Rocket2ClaimedStreaks",
		LastLoginStreak = "Rocket2LastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1742662800)
	},
	SquadRoyale = {
		Id = "SquadRoyale",
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		ModeDisplayName = "Squad Royale",
		LeaderboardVersion = 2,
		Pack = {
			IsEnabled = false,
			Mode = "SquadRoyale",
			ProductId = 0,
			GiftProductId = 0,
			Rewards = {}
		},
		TicketDisplayName = "Squad Royale Ticket",
		TicketName = "SquadRoyaleTickets",
		LoginStreak = "SquadRoyaleLoginStreak",
		ClaimedStreaks = "SquadRoyaleClaimedStreaks",
		LastLoginStreak = "SquadRoyaleLastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1774108800)
	},
	LavaFloor = {
		Id = "LavaFloor",
		ModeName = "Floor is Lava",
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 2,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Lava Ticket",
		TicketName = "Lava2Tickets",
		LoginStreak = "Lava2LoginStreak",
		ClaimedStreaks = "Lava2ClaimedStreaks",
		LastLoginStreak = "Lava2LastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1745683200)
	},
	LuckyBlocks = {
		Id = "LuckyBlocks",
		ModeName = "Lucky Blocks",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 1,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Lucky Ticket",
		TicketName = "LuckyTickets",
		LoginStreak = "LuckyLoginStreak",
		ClaimedStreaks = "LuckyClaimedStreaks",
		LastLoginStreak = "LuckyLastLoginStreak",
		DateEndTime = DateTime.fromUnixTimestamp(1748710800)
	},
	Brainrot = {
		Id = "Brainrot",
		ModeName = "Brainrot Battles",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 1,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Brainrot Ticket",
		TicketName = "BrainrotTickets",
		LoginStreak = "BrainrotLoginStreak",
		ClaimedStreaks = "BrainrotClaimedStreaks",
		LastLoginStreak = "BrainrotLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2025, 1, 1)
	},
	OneAbility = {
		Id = "OneAbility",
		ModeName = "One Ability",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = true,
		LeaderboardVersion = 1,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "One Ability Ticket",
		TicketName = "OneAbility2Tickets",
		LoginStreak = "OneAbility2LoginStreak",
		ClaimedStreaks = "OneAbility2ClaimedStreaks",
		LastLoginStreak = "OneAbility2LastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2026, 4, 25, 17)
	},
	RedLightGreenLight = {
		Id = "RedLightGreenLight",
		ModeName = "Red Light Green Light",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 1,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Red Light Green Light Ticket",
		TicketName = "RedLightGreenLightTickets",
		LoginStreak = "RedLightGreenLightLoginStreak",
		ClaimedStreaks = "RedLightGreenLightClaimedStreaks",
		LastLoginStreak = "RedLightGreenLightLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2025, 7, 26, 17)
	},
	Tag = {
		Id = "Tag",
		ModeName = "Tag!",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 2,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Tag! Ticket",
		TicketName = "Tag2Tickets",
		LoginStreak = "Tag2LoginStreak",
		ClaimedStreaks = "Tag2ClaimedStreaks",
		LastLoginStreak = "Tag2LastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2026, 4, 4, 17)
	},
	Hovergoal = {
		Id = "Hovergoal",
		ModeName = "Hovergoal",
		LobbyLTM = true,
		UseMapVoting = false,
		AllAbilitiesDisabled = true,
		LeaderboardVersion = 1,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Hovergoal Ticket",
		TicketName = "HovergoalTickets",
		LoginStreak = "Hovergoal1LoginStreak",
		ClaimedStreaks = "Hovergoal1ClaimedStreaks",
		LastLoginStreak = "Hovergoal1LastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2025, 11, 15, 17),
		ForceMap = "HovergoalArena",
		Color = Color3.fromRGB(92, 255, 97)
	},
	AbilityBlock = {
		Id = "AbilityBlock",
		ModeName = "Ability Block",
		LobbyLTM = true,
		UseMapVoting = false,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 1,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Ability Block Ticket",
		TicketName = "AbilityBlockTickets",
		LoginStreak = "AbilityBlockLoginStreak",
		ClaimedStreaks = "AbilityBlockClaimedStreaks",
		LastLoginStreak = "AbilityBlockLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2025, 11, 15, 17),
		Color = Color3.fromRGB(255, 189, 76)
	},
	SnowballFight = {
		Id = "SnowballFight",
		ModeName = "Snowball Fight",
		LobbyLTM = true,
		UseMapVoting = false,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 1,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Snowball Fight Ticket",
		TicketName = "SnowballFightTickets",
		LoginStreak = "SnowballFightLoginStreak",
		ClaimedStreaks = "SnowballFightClaimedStreaks",
		LastLoginStreak = "SnowballFightLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2025, 12, 13, 17),
		LobbyCrateWindow = "Snow_LobbyCrate",
		LobbyTicketsWindow = "Snow_LobbyTickets",
		Color = Color3.fromRGB(90, 192, 255)
	},
	SheriffsVsOutlaws = {
		Id = "SheriffsVsOutlaws",
		ModeName = "Sheriffs Vs Outlaws",
		LobbyLTM = true,
		UseMapVoting = false,
		AllAbilitiesDisabled = false,
		LeaderboardVersion = 1,
		Pack = {
			IsEnabled = false,
			Mode = "LavaFloor",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Sheriffs Vs Outlaws Ticket",
		TicketName = "SheriffsVsOutlawsTickets",
		LoginStreak = "SheriffsVsOutlawsLoginStreak",
		ClaimedStreaks = "SheriffsVsOutlawsClaimedStreaks",
		LastLoginStreak = "SheriffsVsOutlawsLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2026, 5, 16, 17),
		ForceMap = "SheriffsVsOutlaws",
		Color = Color3.fromRGB(90, 192, 255)
	},
	Rebound = {
		Id = "Rebound",
		ModeName = "Rebound!",
		LobbyLTM = true,
		UseMapVoting = true,
		AllAbilitiesDisabled = false,
		Pack = {
			IsEnabled = false,
			Mode = "Rebound",
			ProductId = 0,
			GiftProductId = 0
		},
		TicketDisplayName = "Rebound Ticket",
		TicketName = "ReboundTickets",
		LoginStreak = "ReboundLoginStreak",
		ClaimedStreaks = "ReboundClaimedStreaks",
		LastLoginStreak = "ReboundLastLoginStreak",
		DateEndTime = DateTime.fromUniversalTime(2026, 6, 27, 17),
		Color = Color3.fromRGB(92, 255, 198)
	}
}
local v7 = (RunService:IsStudio() or v.isTestGame()) and "CurrentLTM-Test" or "CurrentLTM"
local v8 = (RunService:IsStudio() or v.isTestGame()) and "EndTimeLTM-Test" or "EndTimeLTM"
local fFlag2 = fFlag.GetFFlag(v7, "Rebound")
local v9 = string.split(fFlag2 or "", ",")[1]
local flag

if v6[v9] then
	flag = false
else
	v9 = "Hovergoal"
	flag = true
end

local serverProfiles = {}
serverProfiles[1] = v9

local function getLTM(p: string)
	return v5[p]
end

local function getActiveLTM(p: string)
	local v11 = v5[p]

	if v11 and table.find(serverProfiles, p) then
		return v11
	end

	return nil
end

local function getProfiles()
	local result = table.create(#serverProfiles)

	for _, v11 in serverProfiles do
		result[v11] = v5[v11]
	end

	return result
end

local function getRecentLTM()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v11 = 1e999
	local v12 = nil

	for _, v13 in v5 do
		if v13.LobbyLTM then
			continue
		end

		local v14 = serverTimeNow - v13.DateEndTime.UnixTimestamp

		if not (v14 < v11) then
			continue
		end

		v12 = v13
		v11 = v14
	end

	return v12
end

local function getPriorityLTM()
	for _, v11 in serverProfiles do
		local v12 = v5[v11]

		if v12.IsActive() then
			return v12
		end
	end

	return v5[serverProfiles[1]]
end

local v11 = {
	"TicketName",
	"LoginStreak",
	"ClaimedStreaks",
	"LastLoginStreak"
}

local function getCurrentLTM()
	local flag2 = true
	local v12

	for _, v13 in serverProfiles do
		v12 = v5[v13]

		if not v12.IsActive() then
			continue
		end

		flag2 = false
		break
	end

	if flag2 then
		v12 = v5[serverProfiles[1]]
	end

	local fFlag3 = fFlag.GetFFlag(v7, v12 and v12.Id)
	local fFlag4 = fFlag.GetFFlag(v8, v12 and v12.DateEndTime.UnixTimestamp)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v13 = string.split(fFlag3 or "", ",")
	local v14 = v13[1]
	local versionId = tonumber(v13[2])

	if v6[v14] then
		flag = false
	else
		v14 = "Hovergoal"
		flag = true
	end

	if not (serverTimeNow < fFlag4) then
		return nil
	end

	local result = v5[v14]

	if not versionId then
		return result
	end

	for _, v16 in v11 do
		if result[v16] and not result["Original" .. v16] then
			result["Original" .. v16] = result[v16]
		end

		result[v16] = tostring(result["Original" .. v16]) .. versionId
	end

	result.VersionId = versionId
	return result
end

local function getEndTime()
	local flag2 = true
	local v12

	for _, v13 in serverProfiles do
		v12 = v5[v13]

		if not v12.IsActive() then
			continue
		end

		flag2 = false
		break
	end

	if flag2 then
		v12 = v5[serverProfiles[1]]
	end

	local unixTimestamp = fFlag.GetFFlag(v8, v12 and v12.DateEndTime.UnixTimestamp)

	if flag then
		unixTimestamp = v6.Hovergoal.DateEndTime.UnixTimestamp
	end

	return unixTimestamp
end

script.GetLTM.OnInvoke = getLTM
script.GetRecentLTM.OnInvoke = getRecentLTM

local function OnModeChange(onEvent)
	return script.OnModeChange.Event:Connect(onEvent)
end

local v12 = nil
local v13 = nil
fFlag.OnChange(function()
	local fFlag3 = fFlag.GetFFlag(v7, serverProfiles[1])
	local v14 = string.split(fFlag3 or "", ",")
	local v15 = v14[1]
	local versionId = tonumber(v14[2])

	if v6[v15] then
		flag = false
	else
		v15 = "Hovergoal"
		flag = true
	end

	serverProfiles = { v15 }
	local v17 = v5[v15]

	if os.time() > v17.DateEndTime.UnixTimestamp then
		return
	end

	if versionId then
		for _, v18 in v11 do
			if v17[v18] and not v17["Original" .. v18] then
				v17["Original" .. v18] = v17[v18]
			end

			v17[v18] = tostring(v17["Original" .. v18]) .. versionId
		end

		v17.VersionId = versionId
	end

	if v12 == v15 and v13 == versionId then
		return
	end

	v12 = v15
	v13 = versionId
	script.OnModeChange:Fire(v17)
end)

local function New(k: string)
	local v14 = v6[k]
	local v15 = v3(v14)
	local modeDisplayName

	if v14.ModeDisplayName then
		modeDisplayName = v14.ModeDisplayName
	elseif v14.ModeName then
		modeDisplayName = v14.ModeName
	else
		modeDisplayName = v14.Id
	end

	local formatted = `{modeDisplayName} Limited Mode`

	function v15.IsActive(flag2: boolean?)
		local unixTimestamp = v15.DateEndTime.UnixTimestamp

		if not flag2 or flag then
			return DateTime.now().UnixTimestamp <= unixTimestamp
		end

		local flag3 = true
		local v16

		for _, v17 in serverProfiles do
			v16 = v5[v17]

			if not v16.IsActive() then
				continue
			end

			flag3 = false
			break
		end

		if flag3 then
			v16 = v5[serverProfiles[1]]
		end

		unixTimestamp = fFlag.GetFFlag(v8, v16 and v16.DateEndTime.UnixTimestamp)

		if flag then
			unixTimestamp = v6.Hovergoal.DateEndTime.UnixTimestamp
		end

		return DateTime.now().UnixTimestamp <= unixTimestamp
	end

	function v15.getDisabledAbilities()
		local v16 = v2[v15.getGameMode()]
		return v16 or {}
	end

	function v15.getGameMode()
		return k
	end

	function v15.getModeName()
		return modeDisplayName
	end

	function v15.getDisplayName()
		return formatted
	end

	function v15.getTimeLeftSeconds()
		return v15.DateEndTime.UnixTimestamp - DateTime.now().UnixTimestamp
	end

	function v15.getTimeLeftDHMS()
		local timeLeftSeconds = v15.getTimeLeftSeconds()
		local v16 = ""

		if timeLeftSeconds > 86400 then
			v16 ..= ` {timeLeftSeconds // 86400}d`
		end

		if timeLeftSeconds > 3600 then
			v16 ..= ` {timeLeftSeconds // 3600 % 24}h`
		end

		if timeLeftSeconds > 60 then
			v16 ..= ` {timeLeftSeconds // 60 % 60}m`
		end

		return (v16 .. ` {timeLeftSeconds // 1 % 60}s`):gsub("^ ", "")
	end

	return v15
end

for k, _ in v6 do
	v5[k] = New(k)
end

return {
	getLTM = getLTM,
	getActiveLTM = getActiveLTM,
	getRecentLTM = getRecentLTM,
	getPriorityLTM = getPriorityLTM,
	getCurrentLTM = getCurrentLTM,
	getEndTime = getEndTime,
	serverProfiles = serverProfiles,
	getProfiles = getProfiles,
	OnModeChange = OnModeChange
}