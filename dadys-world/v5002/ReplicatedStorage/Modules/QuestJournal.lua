local QuestJournal = {}
game:GetService("Players")
game:GetService("ReplicatedStorage")
local AchievementSystem = require(script.Parent.AchievementSystem)
local StarredAchievementManager = require(script.Parent.StarredAchievementManager)
local MyDataController = require(script.Parent.MyDataController)
local v = {
	{
		id = "Distance",
		name = "🚶 Distance & Travel",
		description = "Explore the world and track your journeys",
		icon = "🏃",
		color = Color3.fromRGB(100, 200, 100)
	},
	{
		id = "Extraction",
		name = "⚙️ Machines & Floors",
		description = "Master generators and conquer floors",
		icon = "🏭",
		color = Color3.fromRGB(200, 150, 50)
	},
	{
		id = "Items",
		name = "🎒 Items & Collection",
		description = "Gather and use items effectively",
		icon = "📦",
		color = Color3.fromRGB(150, 100, 200)
	},
	{
		id = "Ichor",
		name = "🧪 Ichor & Economy",
		description = "Collect ichor and support Dandy",
		icon = "💰",
		color = Color3.fromRGB(200, 100, 150)
	},
	{
		id = "Dialogue",
		name = "💬 Social & Stories",
		description = "Listen to gossips and learn lore",
		icon = "🗣️",
		color = Color3.fromRGB(100, 150, 200)
	},
	{
		id = "Niche",
		name = "🏆 Special Challenges",
		description = "Unique and difficult accomplishments",
		icon = "⭐",
		color = Color3.fromRGB(255, 215, 0)
	}
}

function QuestJournal.GetDetailedProgress(p)
	local progress = AchievementSystem.CalculateProgress(p)
	local result = {}

	for k, v2 in pairs(progress) do
		local definition = v2.definition
		local timeEstimate = "Unknown"

		if not v2.completed and v2.currentValue > 0 then
			local v4 = v2.currentValue / (os.time() - (p.firstPlayTime or os.time()))

			if v4 > 0 then
				local v5 = (definition.requirement - v2.currentValue) / (v4 * 3600)

				if v5 < 1 then
					timeEstimate = string.format("%.0f minutes", v5 * 60)
				elseif v5 < 24 then
					timeEstimate = string.format("%.1f hours", v5)
				else
					timeEstimate = string.format("%.1f days", v5 / 24)
				end
			end
		end

		local priority

		if v2.progressPercent >= 75 then
			priority = "High"
		elseif v2.progressPercent >= 50 then
			priority = "Medium"
		elseif definition.difficulty == "Bronze" and v2.progressPercent >= 25 then
			priority = "Medium"
		else
			priority = "Low"
		end

		local isAchievementStarred = StarredAchievementManager.IsAchievementStarred(p, k)
		result[k] = {
			id = k,
			title = definition.title,
			description = definition.description,
			category = definition.category,
			difficulty = definition.difficulty,
			progress = v2.currentValue,
			requirement = definition.requirement,
			progressPercent = v2.progressPercent,
			completed = v2.completed,
			isStarred = isAchievementStarred,
			priority = priority,
			timeEstimate = timeEstimate,
			rewards = definition.rewards,
			showProgressNotification = definition.showProgressNotification or false,
			categoryData = nil
		}
	end

	return result
end

function QuestJournal.GetOrganizedQuests(p)
	local detailedProgress = QuestJournal.GetDetailedProgress(p)
	local result = {}

	for _, info in ipairs(v) do
		result[info.id] = {
			info = info,
			quests = {},
			stats = {
				total = 0,
				completed = 0,
				inProgress = 0,
				starred = 0
			}
		}
	end

	for _, v2 in pairs(detailedProgress) do
		local v3 = result[v2.category]

		if not v3 then
			continue
		end

		v2.categoryData = v3.info
		table.insert(v3.quests, v2)
		v3.stats.total = v3.stats.total + 1

		if v2.completed then
			v3.stats.completed = v3.stats.completed + 1
		elseif v2.progress > 0 then
			v3.stats.inProgress = v3.stats.inProgress + 1
		end

		if v2.isStarred then
			v3.stats.starred = v3.stats.starred + 1
		end
	end

	for _, v2 in pairs(result) do
		table.sort(v2.quests, function(a, b)
			if a.isStarred and not b.isStarred then
				return true
			end

			if not a.isStarred and b.isStarred or a.completed and not b.completed then
				return false
			end

			return not (a.completed or not b.completed) or a.progressPercent > b.progressPercent
		end)
	end

	return result
end

function QuestJournal.GetRecommendedQuests(p, value)
	local detailedProgress = QuestJournal.GetDetailedProgress(p)
	local v2 = {}
	local quests = {}

	for _, quest in pairs(detailedProgress) do
		if quest.completed then
			continue
		end

		local total = 0

		if quest.isStarred then
			total += 1000
		end

		local score = total + quest.progressPercent * 10

		if quest.difficulty == "Bronze" then
			score += 100
		elseif quest.difficulty == "Silver" then
			score += 50
		end

		if quest.progressPercent > 10 then
			score += 200
		end

		table.insert(v2, {
			quest = quest,
			score = score
		})
	end

	table.sort(v2, function(a, b)
		return a.score > b.score
	end)

	for i = 1, math.min(value or 5, #v2) do
		table.insert(quests, v2[i].quest)
	end

	return quests
end

function QuestJournal.GetJournalStats(p)
	local detailedProgress = QuestJournal.GetDetailedProgress(p)
	local result = {
		totalQuests = 0,
		completedQuests = 0,
		starredQuests = 0,
		questsInProgress = 0,
		completionRate = 0,
		categoryProgress = {},
		nearCompletion = {},
		recentProgress = {},
		unclaimedRewards = {
			titles = {},
			stickers = {},
			skins = {}
		}
	}

	for _, v2 in pairs(detailedProgress) do
		result.totalQuests += 1

		if v2.completed then
			result.completedQuests += 1

			if v2.rewards.title then
				table.insert(result.unclaimedRewards.titles, v2.rewards.title)
			end

			if v2.rewards.sticker then
				table.insert(result.unclaimedRewards.stickers, v2.rewards.sticker)
			end

			if v2.rewards.skin then
				table.insert(result.unclaimedRewards.skins, v2.rewards.skin)
			end
		elseif v2.progress > 0 then
			result.questsInProgress += 1
		end

		if v2.isStarred then
			result.starredQuests += 1
		end

		if v2.progressPercent >= 75 and not v2.completed then
			table.insert(result.nearCompletion, v2)
		end

		if not result.categoryProgress[v2.category] then
			result.categoryProgress[v2.category] = {
				total = 0,
				completed = 0
			}
		end

		result.categoryProgress[v2.category].total = result.categoryProgress[v2.category].total + 1

		if v2.completed then
			result.categoryProgress[v2.category].completed = result.categoryProgress[v2.category].completed + 1
		end
	end

	if result.totalQuests > 0 then
		result.completionRate = result.completedQuests / result.totalQuests * 100
	end

	return result
end

function QuestJournal.FormatProgress(p, p2)
	return AchievementSystem.FormatProgress(p, p2)
end

function QuestJournal.GetJournalData(callback)
	MyDataController:onReplicaReady(function(p)
		local playerData = {
			AchievementStats = p.Data.AchievementStats or {},
			CompletedAchievements = p.Data.CompletedAchievements or {},
			UnlockedTitles = p.Data.UnlockedTitles or {},
			SelectedTitle = p.Data.SelectedTitle or "",
			StarredAchievements = p.Data.StarredAchievements or {},
			AchievementSettings = p.Data.AchievementSettings or {},
			firstPlayTime = p.Data.FirstJoinTime or os.time()
		}
		callback({
			organizedQuests = QuestJournal.GetOrganizedQuests(playerData),
			recommendedQuests = QuestJournal.GetRecommendedQuests(playerData, 5),
			journalStats = QuestJournal.GetJournalStats(playerData),
			playerData = playerData
		})
	end, function()
		callback(nil)
	end)
end

function QuestJournal.PrintJournalOverview()
	QuestJournal.GetJournalData(function(p)
		if not p then
			print("❌ Quest Journal: No data available")
			return
		end

		local journalStats = p.journalStats
		print("=== 🏆 QUEST JOURNAL OVERVIEW ===")
		print(string.format(
			"Progress: %d/%d quests completed (%.1f%%)",
			journalStats.completedQuests,
			journalStats.totalQuests,
			journalStats.completionRate
		))
		print(string.format("⭐ Starred: %d quests", journalStats.starredQuests))
		print(string.format("📊 In Progress: %d quests", journalStats.questsInProgress))
		print()
		print("📁 CATEGORY BREAKDOWN:")

		for _, v2 in ipairs(v) do
			local id = v2.id
			local v3 = journalStats.categoryProgress[id]

			if not v3 then
				continue
			end

			local v4 = not (v3.total > 0) and 0 or v3.completed / v3.total * 100 or 0
			print(string.format("  %s %s: %d/%d (%.0f%%)", v2.icon, v2.name, v3.completed, v3.total, v4))
		end

		print()
		print("🎯 RECOMMENDED QUESTS:")

		for i, recommendedQuest in ipairs(p.recommendedQuests) do
			local v2 = recommendedQuest.completed and "✅ COMPLETED" or string.format(
				"%.1f%% (%s)",
				recommendedQuest.progressPercent,
				recommendedQuest.timeEstimate
			)
			print(string.format(
				"  %d. %s%s - %s",
				i,
				recommendedQuest.isStarred and "⭐ " or "",
				recommendedQuest.title,
				v2
			))
		end

		if #journalStats.nearCompletion > 0 then
			print()
			print("🚀 NEAR COMPLETION:")

			for _, v2 in ipairs(journalStats.nearCompletion) do
				print(string.format("  - %s (%.1f%%)", v2.title, v2.progressPercent))
			end
		end

		if #journalStats.unclaimedRewards.titles > 0 or #journalStats.unclaimedRewards.stickers > 0 then
			print()
			print("🎁 UNCLAIMED REWARDS:")

			for _, title in ipairs(journalStats.unclaimedRewards.titles) do
				print("  📋 Title:", title)
			end

			for _, sticker in ipairs(journalStats.unclaimedRewards.stickers) do
				print("  🏷️ Sticker:", sticker)
			end
		end
	end)
end

function QuestJournal.GetActiveQuestTracker(callback)
	QuestJournal.GetJournalData(function(data)
		if not data then
			callback(nil)
			return
		end

		local activeQuests = {}

		for _, organizedQuest in pairs(data.organizedQuests) do
			for _, quest in ipairs(organizedQuest.quests) do
				if not quest.isStarred or quest.completed or not (#activeQuests < 3) then
					continue
				end

				table.insert(activeQuests, quest)
			end
		end

		if #activeQuests < 3 then
			for _, recommendedQuest in ipairs(data.recommendedQuests) do
				if #activeQuests >= 3 then
					break
				end

				local v4 = false

				for _, v6 in ipairs(activeQuests) do
					if v6.id ~= recommendedQuest.id then
						continue
					end

					v4 = true
					break
				end

				if not v4 then
					table.insert(activeQuests, recommendedQuest)
				end
			end
		end

		callback({
			activeQuests = activeQuests,
			completionRate = data.journalStats.completionRate,
			totalCompleted = data.journalStats.completedQuests,
			totalQuests = data.journalStats.totalQuests
		})
	end)
end

return QuestJournal