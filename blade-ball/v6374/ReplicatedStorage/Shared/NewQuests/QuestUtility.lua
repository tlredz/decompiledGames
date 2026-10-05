local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Shared.NewQuests.Quests)
local v3 = {
	IncludeXP = "INCLUDE-XP",
	IncludeDaily = "INCLUDE-DAILY-QUESTS",
	DailyQuestsDisabled = "DAILY-QUESTS-DISABLED",
	IncludeWeekly = "INCLUDE-WEEKLY-QUESTS",
	WeeklyQuestsDisabled = "WEEKLY-QUESTS-DISABLED",
	IncludeLimited = "INCLUDE-LIMITED-QUESTS",
	LimitedQuestsDisabled = "LIMITED-QUESTS-DISABLED",
	IncludeOrderedDaily = "INCLUDE-ORDERED-DAILY-QUESTS",
	IncludeQuestTiers = "INCLUDE-QUEST-TIERS",
	IncludeCustomQuestTiers = "INCLUDE-CUSTOM-QUEST-TIERS",
	MaxQuestTier = "MAX-QUEST-TIER",
	StartingQuestTier = "STARTING-QUEST-TIER",
	UseLimitedTimestamp = "USE-LIMITED-TIMESTAMP",
	MaxOrderedDays = "MAX-ORDERED-DAYS",
	AutoRedeemQuests = "AUTO-REDEEM-QUESTS"
}
local QuestUtility = {}
QuestUtility.QUEST_CONTAINER_TYPE = v3
QuestUtility.QUEST_TIME_OFFSET = {
	Daily = 86400,
	Weekly = 604800,
	Limited = 2592000
}
QuestUtility.RedeemQuestsType = v:RemoteFunction("RedeemQuestsType")
QuestUtility.QuestRefreshed = v:RemoteEvent("QuestRefreshed")

function QuestUtility.GetQuestData(_, p: string, p2: string, p3: number)
	local v4 = v2[p] and v2[p][p2]

	if not v4 then
		return
	end

	local quest = v4.Quests[p3]

	if quest then
		return quest
	end
end

function QuestUtility.GetPaths(_, p: string)
	return {
		[v3.IncludeDaily] = `{p}.Main.Daily`,
		[v3.IncludeWeekly] = `{p}.Main.Weekly`,
		[v3.IncludeLimited] = `{p}.Limited`
	}
end

return QuestUtility