local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.CratesContent)
return {
	QuestObjectTemplate = {
		QuestType = "",
		CurrentProgress = 0,
		QuestKey = "",
		Completed = false,
		QuestData = {},
		OverwriteProperties = {},
		RewardGiven = false,
		Active = true
	},
	InternalQuests = {
		Welcome_Back = {
			QuestKey = "Welcome_Back",
			ProgressAction = "Win_Game",
			DisplayName = "Win a match.",
			SimpleReward = {
				Credits = 1700,
				CrateKeys = table.create(3, "Sword")
			},
			MaxProgress = 1
		}
	},
	LimitedQuests = {},
	Quests = {
		Parry_Ball = {
			QuestKey = "Parry_Ball",
			ProgressAction = "Parry_Ball",
			DisplayName = "Parry 5 Balls",
			CustomReward = {
				RewardFunction = function(p, _)
					return {
						Credits = math.floor(0.5 * (p.QuestData.ParryAmount or 1) + 5)
					}
				end
			},
			IntializeFunction = function(p, _, _: number)
				local v2 = math.random(1, 4) * 30
				p.OverwriteProperties.DisplayName = string.format("Parry the ball %d times", v2)
				p.OverwriteProperties.MaxProgress = v2
				p.QuestData.ParryAmount = v2
			end
		},
		Visit_AFK_World = {
			QuestKey = "Visit_AFK_World",
			ProgressAction = "Visit_AFK_World",
			DisplayName = "Visit The AFK World",
			SimpleReward = {
				Credits = 100
			}
		},
		Enter_Stand_Off = {
			QuestKey = "Enter_Stand_Off",
			ProgressAction = "Enter_Stand_Off",
			DisplayName = "Enter a Stand Off 2 Times",
			SimpleReward = {
				Credits = 100
			},
			MaxProgress = 2
		},
		Spend_Coins = {
			QuestKey = "Spend_Coins",
			ProgressAction = "Spend_Coins",
			ProgressFunction = function(p, _, p2: number)
				p.CurrentProgress += p2
			end,
			IntializeFunction = function(p, p2, _: number)
				local v2 = math.floor((math.floor((math.clamp(
					0.2 * v.Server:WaitReplionFor(p2, "Data"):Get({ "Credits" }),
					500,
					3000
				))) + 250) / 500) * 500
				p.OverwriteProperties.DisplayName = string.format("Spend %d Coins", v2)
				p.OverwriteProperties.MaxProgress = v2
				p.QuestData.CoinRequirement = v2
			end,
			CustomReward = {
				RewardFunction = function(p, _)
					return {
						Credits = math.floor((1.15 * (p.QuestData.CoinRequirement or 1) + 25) / 50) * 50
					}
				end
			}
		},
		Eliminate_Enemies_In_Match = {
			QuestKey = "Eliminate_Enemies_In_Match",
			ProgressAction = "Kill_Streak_Increment",
			CustomReward = {
				RewardFunction = function(p, _)
					return {
						Credits = 30 * (p.QuestData.KillCount or 1)
					}
				end
			},
			IntializeFunction = function(p, _, _: number)
				local v2 = math.random(2, 4)
				p.OverwriteProperties.DisplayName = string.format("Eliminate %d players In one match", v2)
				p.OverwriteProperties.MaxProgress = v2
				p.QuestData.KillCount = v2
			end,
			ProgressFunction = function(p, _, p2: number)
				p.CurrentProgress = math.max(p.CurrentProgress, p2)
			end
		},
		Win_Game_Type = {
			QuestKey = "Win_Game_Type",
			ProgressAction = "Win_Game",
			IntializeFunction = function(p, _, _: number)
				local v2 = { "Teams", "Randomizer" }
				local gameMode = v2[math.random(1, #v2)]
				p.OverwriteProperties.DisplayName = string.format("Win a %s Match", gameMode)
				p.QuestData.GameMode = gameMode
			end,
			ProgressFunction = function(p, _, p2: string)
				if p2 == p.QuestData.GameMode then
					p.CurrentProgress = 1
				end
			end,
			SimpleReward = {
				Credits = 100
			},
			MaxProgress = 1
		}
	},
	WeeklyPointRewards = {},
	GetQuestsOfType = function(p, _: string)
		local quests = {}

		for _, quest in p.Quests do
			table.insert(quests, quest)
		end

		return quests
	end
}