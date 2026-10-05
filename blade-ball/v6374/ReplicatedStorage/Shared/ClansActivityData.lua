local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.NewQuestData)
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(game.ReplicatedStorage.Shared.GetServerType)
local v3 = require3(ReplicatedStorage2.Shared.AbilityUtils)
local v4 = require3(ReplicatedStorage2.Common.RewardInfo)
local unixTimestamp = DateTime.fromUniversalTime(2025, 3, 22, 17).UnixTimestamp

local function getWeekNumber(p)
	local v5 = os.date("*t", p)
	local v6 = os.time({
		year = v5.year,
		month = 1,
		day = 1
	})
	local wday = os.date("*t", v6).wday
	return (math.ceil((os.difftime(p, v6) / 86400 + wday) / 7))
end

local function getCurrentYearNumber(p)
	return (tonumber(os.date("%Y", p)))
end

local function getCurrentDayNumber(p)
	return (tonumber(os.date("%d", p)))
end

local _ = {
	[150] = {
		Crowns = 60
	},
	[450] = {
		Crowns = 65
	},
	[900] = {
		Crowns = 70
	},
	[1500] = {
		Crowns = 75
	}
}
local clanWeeklyMilestones = {
	{
		ActivityPoints = 700,
		Reward = v4.createCrownsReward(15)
	},
	{
		ActivityPoints = 1700,
		Reward = v4.createCrownsReward(20)
	},
	{
		ActivityPoints = 3400,
		Reward = v4.createCrownsReward(30)
	}
}
local _ = {
	Login_To_BladeBall = {
		QuestKey = "Login_To_BladeBall",
		ProgressAction = "Login",
		DisplayName = "Login to Blade Ball",
		MaxProgress = 1,
		StaticOnly = true,
		SimpleReward = {
			ActivityPoints = 10,
			Crowns = 5
		}
	},
	Play_BladeBall = {
		QuestKey = "Play_BladeBall",
		ProgressAction = "Play_Time",
		StaticOnly = true,
		IntializeFunction = function(p, _, p2)
			local v7

			if p2.Requirment then
				v7 = p2.Requirment
			else
				v7 = math.random(1, 2)
			end

			local maxProgress = ({ 10, 30 })[v7]
			p.OverwriteProperties.DisplayName = string.format("Play Blade Ball for %d minutes", maxProgress)
			p.OverwriteProperties.MaxProgress = maxProgress
			p.QuestData.TimeCount = 0
		end,
		ProgressFunction = function(state, _)
			state.QuestData.TimeCount += 1

			if state.QuestData.TimeCount % 60 == 0 then
				state.CurrentProgress = math.clamp(state.CurrentProgress + 1, 0, state.OverwriteProperties.MaxProgress)
			end
		end,
		CustomReward = {
			RewardFunction = function(p, _)
				return {
					Crowns = (p.QuestData.TimeCount == 1800 and 2 or 1) * 5,
					ActivityPoints = 10
				}
			end
		}
	},
	Win_With_Clan_Member = {
		QuestKey = "Win_With_Clan_Member",
		ProgressAction = "Win_With_Clan_Member",
		DisplayName = "Win 3 games playing with someone in your clan",
		MaxProgress = 3,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Eliminate_With_Dash = {
		QuestKey = "Eliminate_With_Dash",
		ProgressAction = "Kill_Streak_Increment",
		DisplayName = "Eliminate 5 players in one game using dash",
		MaxProgress = 5,
		ProgressFunction = function(p, p2, p3: number)
			if not v.Server:GetReplionFor(p2, "Data") then
				return
			end

			local _ = require3(ReplicatedStorage2.Shared.Inventory).Server
			local equippedAbility = v3.getEquippedAbility(p2, "Ability")

			if not equippedAbility then
				return
			end

			if equippedAbility.Name == "Dash" then
				p.CurrentProgress = math.max(p.CurrentProgress, p3)
			end
		end,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Play_With_Clan_Member = {
		QuestKey = "Play_With_Clan_Member",
		ProgressAction = "Play_With_Clan_Member",
		DisplayName = "Play with 1+ clan members",
		MaxProgress = 1,
		ProgressFunction = function(p, p2, items)
			local replionFor = v.Server:GetReplionFor(p2, "Data")

			if not replionFor then
				return
			end

			local clanId = replionFor:Get("ClanId")

			if not clanId then
				return
			end

			local flag = false

			for _, item in items do
				local replionFor2 = v.Server:GetReplionFor(item, "Data")

				if not replionFor2 then
					continue
				end

				local clanId2 = replionFor2:Get("ClanId")

				if not (clanId2 and clanId == clanId2) then
					continue
				end

				flag = true
				break
			end

			if flag then
				p.CurrentProgress = math.max(p.CurrentProgress + 1, 1)
			end
		end,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Gain_Elo = {
		QuestKey = "Gain_Elo",
		ProgressAction = "Gain_Elo",
		DisplayName = "Gain 100 Ranked ELO",
		MaxProgress = 100,
		ProgressFunction = function(p, _, p2: number)
			p.CurrentProgress += math.max(p2, 0)
		end,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Place_Top_In_Ranked = {
		QuestKey = "Place_Top_In_Ranked",
		ProgressAction = "Place_Top_In_Ranked",
		DisplayName = "Place Top 5 in Ranked",
		MaxProgress = 1,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Win_Duel_Round = {
		QuestKey = "Win_Duel_Round",
		ProgressAction = "Win_Duel_Flawless",
		DisplayName = "Win 3 duels without losing a single round",
		MaxProgress = 3,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Eliminate_With_Clan_Member = {
		QuestKey = "Eliminate_With_Clan_Member",
		ProgressAction = "Eliminate",
		DisplayName = "Eliminate 25 players with a clan mate in your game",
		MaxProgress = 25,
		ProgressFunction = function(p, p2, p3)
			local flag = false
			local replionFor = v.Server:GetReplionFor(p2, "Data")

			if not replionFor then
				return
			end

			local clanId = replionFor:Get("ClanId")

			if not clanId then
				return
			end

			local v6 = require3(game.ServerScriptService.Game.CoreGameModules.MapManager)

			for _, participant in p3.participants do
				if v6.isVirtualPlayer(participant) then
					continue
				end

				local replionFor2 = v.Server:GetReplionFor(participant, "Data")

				if not replionFor2 then
					continue
				end

				local clanId2 = replionFor2:Get("ClanId")

				if not (clanId2 and clanId == clanId2) then
					continue
				end

				flag = true
				break
			end

			if flag then
				p.CurrentProgress = math.min(p.CurrentProgress + 1, 25)
			end
		end,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Play_Ranked_Duo_With_Clan_Member = {
		QuestKey = "Play_Ranked_Duo_With_Clan_Member",
		ProgressAction = "Play_Ranked_Duo_With_Clan_Member",
		DisplayName = "Play 5 Ranked Duos games with a clan mate",
		MaxProgress = 5,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Eliminate_Clan_Member = {
		QuestKey = "Eliminate_Clan_Member",
		ProgressAction = "EliminateVictim",
		DisplayName = "Eliminate 3 clan members in any game mode",
		MaxProgress = 3,
		ProgressFunction = function(p, p2, p3)
			local replionFor = v.Server:GetReplionFor(p2, "Data")

			if not replionFor then
				return
			end

			local clanId = replionFor:Get("ClanId")

			if not clanId then
				return
			end

			local replionFor2 = v.Server:GetReplionFor(p3, "Data")

			if not replionFor2 then
				return
			end

			local clanId2 = replionFor2:Get("ClanId")

			if not clanId2 then
				return
			end

			if clanId == clanId2 then
				p.CurrentProgress += 1
			end
		end,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Play_In_Training_Mode = {
		QuestKey = "Play_In_Training_Mode",
		ProgressAction = "Play_In_Training_Mode",
		DisplayName = "Play training mode for 10 minutes",
		MaxProgress = 600,
		ProgressFunction = function(p, _, _: number)
			if v2() == "Training" then
				p.CurrentProgress = math.max(p.CurrentProgress, 600)
			end
		end,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Use_Same_Sword_As_Clan_Member = {
		QuestKey = "Use_Same_Sword_As_Clan_Member",
		ProgressAction = "Use_Same_Sword_As_Clan_Member",
		DisplayName = "Use the same sword as your clan mate",
		MaxProgress = 1,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	},
	Eliminate_Different_Clan = {
		QuestKey = "Eliminate_Different_Clan",
		ProgressAction = "Eliminate_Different_Clan",
		DisplayName = "Eliminate 5 players from a Different clan",
		MaxProgress = 5,
		ProgressFunction = function(p, p2, p3)
			local replionFor = v.Server:GetReplionFor(p2, "Data")

			if not replionFor then
				return
			end

			local clanId = replionFor:Get("ClanId")

			if not clanId then
				return
			end

			local replionFor2 = v.Server:GetReplionFor(p3, "Data")

			if not replionFor2 then
				return
			end

			local clanId2 = replionFor2:Get("ClanId")

			if not clanId2 then
				return
			end

			if clanId ~= clanId2 then
				p.CurrentProgress = math.max(p.CurrentProgress + 1, 5)
			end
		end,
		SimpleReward = {
			Crowns = 5,
			ActivityPoints = 10
		}
	}
}
local _ = {
	Login_To_BladeBall = {
		QuestKey = "Login_To_BladeBall",
		ProgressAction = "Login",
		DisplayName = "Log in to Blade Ball on 5 different days",
		MaxProgress = 5,
		StaticOnly = true,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Win_Match = {
		QuestKey = "Win_Match",
		ProgressAction = "Win_Match",
		DisplayName = "Win 10 matches",
		MaxProgress = 10,
		StaticOnly = true,
		SimpleReward = {
			Crowns = 30,
			ActivityPoints = 30
		}
	},
	Play_BladeBall = {
		QuestKey = "Play_BladeBall",
		ProgressAction = "Play_Time",
		DisplayName = "Play Blade Ball for 300 minutes",
		MaxProgress = 300,
		StaticOnly = true,
		IntializeFunction = function(p, _, _: number)
			p.QuestData.TimeCount = 0
		end,
		ProgressFunction = function(state, _)
			state.QuestData.TimeCount += 1

			if state.QuestData.TimeCount % 60 == 0 then
				state.CurrentProgress += 1
			end
		end,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 25
		}
	},
	Place_Top_In_Ranked = {
		QuestKey = "Place_Top_In_Ranked",
		ProgressAction = "Place_Top_In_Ranked",
		MaxProgress = 5,
		DisplayName = "Place top 1 in ranked 5+ times",
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Gain_Elo = {
		QuestKey = "Gain_Elo",
		ProgressAction = "Gain_Elo",
		MaxProgress = 500,
		DisplayName = "Gain 500+ ELO in Ranked",
		ProgressFunction = function(p, _, p2: number)
			p.CurrentProgress += math.max(p2, 0)
		end,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Play_Ranked_Duo_With_Clan_Mate = {
		QuestKey = "Play_Ranked_Duo_With_Clan_Mate",
		ProgressAction = "Play_Ranked_Duo_With_Clan_Member",
		MaxProgress = 25,
		DisplayName = "Play 25 ranked duo matches with a clan mate",
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Unbox_Legendary_Skins = {
		QuestKey = "Unbox_Legendary_Skins",
		ProgressAction = "Unbox_Legendary_Skin",
		DisplayName = "Unbox 3 legendary skins from the sword or explosion crate.",
		MaxProgress = 3,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Play_With_Clan_Mates = {
		QuestKey = "Play_With_Clan_Mates",
		ProgressAction = "Play_With_Clan_Member",
		DisplayName = "Play with 2+ clan mates in one game",
		MaxProgress = 1,
		ProgressFunction = function(p, p2, list)
			if not v.Server:GetReplionFor(p2, "Data") then
				return
			end

			if #list >= 2 then
				p.CurrentProgress = math.max(p.CurrentProgress + 1, 1)
			end
		end,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Get_Kills_Pro_Server = {
		DisplayName = "Get 100 elims in pro lobbies",
		ProgressAction = "Eliminate",
		ProgressFunction = function(p, _)
			if v2() == "Pro" then
				p.CurrentProgress += 1
			end
		end,
		MaxProgress = 100,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Gift_To_Clan_Mate = {
		QuestKey = "Gift_To_Clan_Mate",
		ProgressAction = "Gift_To_Clan_Mate",
		DisplayName = "Gift a Robux item/pass to a clan mate",
		MaxProgress = 1,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Play_Map = {
		QuestKey = "Play_Map",
		ProgressAction = "Play_Map",
		DisplayName = "Play on 10+ different maps",
		IntializeFunction = function(p, _, _: number)
			p.QuestData.PlayedMaps = {}
		end,
		ProgressFunction = function(state, _, p: string)
			if not state.QuestData.PlayedMaps[p] then
				state.QuestData.PlayedMaps[p] = true
				state.CurrentProgress += 1
			end
		end,
		MaxProgress = 10,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	},
	Earn_Credit = {
		QuestKey = "Earn_Credit",
		ProgressAction = "Match_Spend_Coins",
		DisplayName = "Earn 7,000 coins in any game mode",
		ProgressFunction = function(p, _, p2: number)
			p.CurrentProgress += p2
		end,
		MaxProgress = 7000,
		SimpleReward = {
			Crowns = 20,
			ActivityPoints = 20
		}
	}
}
local ClansActivityData = {}
ClansActivityData.PersonalWeeklyMilestones = {
	{
		ActivityPoints = 150,
		Reward = v4.createCrownsReward(60)
	},
	{
		ActivityPoints = 450,
		Reward = v4.createCrownsReward(65)
	},
	{
		ActivityPoints = 900,
		Reward = v4.createCrownsReward(70)
	},
	{
		ActivityPoints = 1500,
		Reward = v4.createCrownsReward(75)
	}
}
ClansActivityData.ClanWeeklyMilestones = clanWeeklyMilestones
ClansActivityData.ClanLevels = {
	4300,
	13700,
	24400,
	37400,
	125900,
	157400
}

function ClansActivityData.getWeeksSinceOverhaul()
	return (workspace:GetServerTimeNow() - unixTimestamp) // 604800
end

ClansActivityData.getWeekNumber = getWeekNumber

function ClansActivityData.LEGACY_getActivityFromTime(p)
	return (`W{getWeekNumber(p)}Y{tonumber(os.date("%Y", p))}`)
end

return ClansActivityData