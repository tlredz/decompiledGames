local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local _ = ReplicatedStorage.events
local modules = ReplicatedStorage.shared.modules
local Quests = require(modules.Quests)
require(modules.QuestTypes)
local DynamicString = require(modules.DynamicString)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local forPlayerSafe

if RunService:IsServer() then
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	forPlayerSafe = legacyPlayerData.forPlayerSafe
else
	local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
	forPlayerSafe = legacyLocalPlayerData.fetch
end

local questsFolder = {
	Active = "QuestActive",
	Finished = "QuestFinished",
	Legacy = "Quests"
}
local frozen = table.freeze({
	NotStarted = 1,
	InProgress = 2,
	Finished = 3,
	RewardClaimed = 4
})
local QuestShared = {
	QuestState = frozen,
	QuestsFolder = questsFolder,
	LegacyTypeMap = {
		["Angler Quest"] = "Challenge",
		["Getting Settled (#1)"] = "Major",
		["Getting Settled (#2)"] = "Major",
		["Getting Settled (#3)"] = "Major",
		["Getting Settled (#4)"] = "Major",
		["Getting Settled (#5)"] = "Major",
		["Get Settled (#1)"] = "Major",
		["Get Settled (#2)"] = "Major",
		["Get Settled (#3)"] = "Major",
		["Get Settled (#4)"] = "Major"
	},
	ReadDataPath = function(self, p, childName: string)
		local child = forPlayerSafe(p)

		if not child then
			return nil
		end

		if childName == nil then
			return child
		end

		if childName == "QuestActive" or childName == "QuestFinished" or childName == "Quests" then
			return child:FindFirstChild(childName)
		end

		local v2 = string.split(childName, ".")

		for i = 1, #v2 do
			if child == nil then
				return nil
			else
				child = child:FindFirstChild(v2[i])
			end
		end

		return child
	end
}

function QuestShared.EnsureDataPath(_, p, value: string, value2)
	if not RunService:IsServer() then
		warn((`[QuestShared] EnsureDataPath("{value}") called on the client; nothing was created.`))
		return QuestShared:ReadDataPath(p, value)
	end

	local parent = forPlayerSafe(p)

	if not parent or value == nil then
		return parent
	end

	local v3 = string.split(value, ".")

	for k, childName in v3 do
		local v4 = parent:FindFirstChild(childName)

		if not v4 then
			if k < #v3 then
				v4 = Instance.new("Folder")
			elseif typeof(value2) == "string" then
				v4 = Instance.new("StringValue")
			elseif typeof(value2) == "number" then
				v4 = Instance.new("NumberValue")
			elseif typeof(value2) == "boolean" then
				v4 = Instance.new("BoolValue")
			else
				warn((`[QuestShared] EnsureDataPath("{value}") needs a string, number or boolean default.`))
				return nil
			end

			v4.Name = childName

			if k == #v3 then
				v4.Value = value2
			end

			v4.Parent = parent
		end

		parent = v4
	end

	return parent
end

function QuestShared:IsRewardCollected(p, childName: string)
	local dataPath = QuestShared:ReadDataPath(p, questsFolder.Finished)

	if dataPath then
		return dataPath:FindFirstChild(childName) ~= nil
	end

	return false
end

function QuestShared:IsFinished(p, childName: string)
	local questData = QuestShared:GetQuestData(p, childName)

	if not questData then
		return false
	end

	local dataPath = QuestShared:ReadDataPath(p, questsFolder.Active)

	if not dataPath then
		return false
	end

	local child = dataPath:FindFirstChild(childName)

	if not child then
		return false
	end

	for childName2, v2 in questData.List do
		if v2[1] == "DataInstanceValue" then
			local dataPath2 = QuestShared:ReadDataPath(p, v2[2])

			if not dataPath2 then
				return false, childName2
			end

			if typeof(dataPath2.Value) == "number" and typeof(v2[3]) == "number" then
				if dataPath2.Value < v2[3] then
					return false, childName2
				end
			elseif dataPath2.Value ~= v2[3] then
				return false, childName2
			end
		else
			local child2 = child:FindFirstChild(childName2)

			if not child2 then
				return false, childName2
			end

			if typeof(child2.Value) == "number" then
				if child2.Value < v2[2] then
					return false, childName2
				end
			elseif child2.Value ~= v2[2] then
				return false, childName2
			end
		end
	end

	return true
end

function QuestShared:IsStarted(p, childName: string)
	local dataPath = QuestShared:ReadDataPath(p, questsFolder.Active)
	return not dataPath or dataPath:FindFirstChild(childName) ~= nil
end

function QuestShared.CanGet(_, p, childName: string)
	local dataPath = QuestShared:ReadDataPath(p, questsFolder.Active)

	if not dataPath then
		return false
	end

	local dataPath2 = QuestShared:ReadDataPath(p, questsFolder.Finished)

	if not dataPath2 then
		return false
	end

	local questData = QuestShared:GetQuestData(p, childName)

	if dataPath:FindFirstChild(childName) or dataPath2:FindFirstChild(childName) and not questData.IsRepeatable then
		return false
	end

	if questData and questData.WishLocked then
		local SharedWish = require(ReplicatedStorage.shared.modules.SharedWish)

		if not SharedWish.HasGrantFor(p, questData.WishLocked) then
			return false
		end
	end

	if not (questData and questData.Prerequisites) then
		return true
	end

	if questData.Prerequisites.Level and QuestShared:ReadDataPath(p, "Stats.realLevel").Value < questData.Prerequisites.Level then
		return false
	end

	if questData.Prerequisites.QuestComplete then
		for _, v2 in questData.Prerequisites.QuestComplete do
			if not QuestShared:IsRewardCollected(p, v2) then
				return false
			end
		end
	end

	if questData.Prerequisites.QuestActive then
		for _, v2 in questData.Prerequisites.QuestActive do
			if not QuestShared:IsStarted(p, v2) then
				return false
			end
		end
	end

	if not questData.Prerequisites.WorldState then
		return true
	end

	for childName2, v2 in questData.Prerequisites.WorldState do
		local stringValue = ReplicatedStorage.world:FindFirstChild(childName2, true)

		if not (stringValue and stringValue:IsA("StringValue")) then
			return false
		end

		if typeof(v2) == "table" then
			if not table.find(v2, stringValue.Value) then
				return false
			end
		elseif v2 ~= stringValue.Value then
			return false
		end
	end

	return true
end

function QuestShared:GetState(p, childName: string)
	local dataPath = QuestShared:ReadDataPath(p, questsFolder.Legacy)
	local child = dataPath and dataPath:FindFirstChild(childName)

	if child then
		local flag = true

		for _, child2 in child:GetChildren() do
			local parts = child2.Name:split("_")

			if parts[2] ~= "Goal" then
				continue
			end

			local child3 = child:FindFirstChild(parts[1])

			if not (not child3 or child3.Value ~= child2.Value) then
				continue
			end

			flag = false
			break
		end

		if flag then
			return frozen.Finished
		end

		return frozen.InProgress
	else
		if QuestShared:IsRewardCollected(p, childName) then
			return frozen.RewardClaimed
		end

		if QuestShared:IsFinished(p, childName) then
			return frozen.Finished
		end

		if QuestShared:IsStarted(p, childName) then
			return frozen.InProgress
		end

		return frozen.NotStarted
	end
end

function QuestShared:GetSeriesQuests(p: string, flag: boolean)
	local result = {}

	for k, quest in Quests do
		if quest.QuestSeries == p then
			table.insert(result, k)
		end
	end

	if flag then
		table.sort(result, function(a, b)
			local seriesIndex = Quests[a].SeriesIndex or 0
			local seriesIndex2 = Quests[b].SeriesIndex or 0

			if seriesIndex == seriesIndex2 then
				return a < b
			end

			return seriesIndex < seriesIndex2
		end)
	end

	return result
end

function QuestShared.GetSeriesCompletionIndex(_, p, p2: string)
	local seriesIndex = 0

	for _, v2 in QuestShared:GetSeriesQuests(p2, true) do
		if not QuestShared:IsRewardCollected(p, v2) then
			break
		end

		seriesIndex = Quests[v2].SeriesIndex or 1
	end

	return seriesIndex
end

function QuestShared.GetSeriesCompletionCount(_, p, p2: string)
	local count = 0

	for _, v2 in QuestShared:GetSeriesQuests(p2) do
		if QuestShared:IsRewardCollected(p, v2) then
			count += 1
		end
	end

	return count
end

function QuestShared.GetCurrentSeriesQuest(_, p, p2: string)
	local v2 = nil
	local v3 = nil
	local v4 = nil

	for k, v5 in QuestShared:GetSeriesQuests(p2, true) do
		local state = QuestShared:GetState(p, v5)

		if state == frozen.NotStarted then
			if v2 == nil or v3 == frozen.RewardClaimed then
				return v5, state, k
			else
				break
			end
		else
			v4 = k
			v3 = state
			v2 = v5
		end
	end

	return v2, v3, v4
end

function QuestShared.GetActiveQuests(_, p)
	local questDatas = {}
	local dataPath = QuestShared:ReadDataPath(p, questsFolder.Active)

	if not dataPath then
		return {}
	end

	for _, child in dataPath:GetChildren() do
		if not (Quests[child.Name] and (not child.Name:match("%-MASTERY$") or child:FindFirstChild("1") and not (child["1"].Value < 0))) then
			continue
		end

		table.insert(questDatas, QuestShared:GetQuestData(p, child.Name))
	end

	return questDatas
end

function QuestShared:ConvertLegacyQuest(instance)
	local displayName = instance.Name:split("_")[1]
	local list = {}

	for _, child in instance:GetChildren() do
		local v4 = string.split(child.Name, "_")

		if v4[2] == "Goal" then
			table.insert(list, {
				"DataInstanceValue",
				`Quests.{instance.Name}.{v4[1]}`,
				child.Value,
				v4[1]
			})
		end
	end

	if #list == 0 then
		return nil
	end

	local rewards = {}

	if instance:FindFirstChild("CoinsReward") and instance.CoinsReward.Value > 0 then
		table.insert(rewards, { "Currency", "Coins", instance.CoinsReward.Value })
	end

	if instance:FindFirstChild("XPReward") and instance.XPReward.Value > 0 then
		table.insert(rewards, { "XP", instance.XPReward.Value })
	end

	if instance:FindFirstChild("TitleReward") and instance.TitleReward.Value ~= "None" then
		table.insert(rewards, { "Title", instance.TitleReward.Value })
	end

	return {
		Id = instance.Name,
		DisplayName = displayName,
		Icon = not instance:FindFirstChild("Icon") and "rbxassetid://18162767851" or instance.Icon.Value or "rbxassetid://18162767851",
		IconColor = Color3.new(0, 0, 0),
		QuestType = QuestShared.LegacyTypeMap[displayName] or "Side",
		Description = instance.Value,
		List = list,
		Rewards = rewards
	}
end

function QuestShared.GetLegacyQuests(_, p)
	local result = {}
	local dataPath = QuestShared:ReadDataPath(p, "Quests")

	if not dataPath then
		return {}
	end

	for _, child in dataPath:GetChildren() do
		result[child] = QuestShared:ConvertLegacyQuest(child)
	end

	return result
end

function QuestShared.GetTrackedQuests(_, p)
	local result = {}
	local dataPath = QuestShared:ReadDataPath(p, questsFolder.Active)
	local dataPath2 = QuestShared:ReadDataPath(p, questsFolder.Legacy)

	if dataPath then
		for _, child in dataPath:GetChildren() do
			if child:FindFirstChild("Tracking") and child.Tracking.Value then
				table.insert(result, QuestShared:GetQuestData(p, child.Name))
			end
		end
	end

	if dataPath2 then
		for _, child in dataPath2:GetChildren() do
			if child:FindFirstChild("Tracking") and child.Tracking.Value then
				table.insert(result, QuestShared:ConvertLegacyQuest(child))
			end
		end
	end

	return result
end

function QuestShared:GetQuestInstance(p, childName: string)
	local dataPath = QuestShared:ReadDataPath(p, questsFolder.Active)
	local dataPath2 = QuestShared:ReadDataPath(p, questsFolder.Legacy)
	return dataPath and dataPath:FindFirstChild(childName) or dataPath2 and dataPath2:FindFirstChild(childName) or nil
end

function QuestShared:GetCustomData(p, p2: string)
	local quest = Quests[p2]

	if not (quest and quest.HasCustomData) then
		return nil
	end

	local questInstance = QuestShared:GetQuestInstance(p, p2)

	if questInstance and questInstance:FindFirstChild("CustomData") then
		return HttpService:JSONDecode(questInstance.CustomData.Value)
	end

	return nil
end

local v2 = nil
local v3 = {}

function QuestShared:GetQuestData(p, name: string)
	if not name then
		return nil
	end

	if typeof(name) == "Instance" then
		name = name.Name
	end

	if Quests[name] then
		local copy = Quests[name]

		if copy.IsSecret then
			if RunService:IsClient() then
				if v3[name] then
					table.insert(v3[name], coroutine.running())
					coroutine.yield()
				else
					v3[name] = {}

					if v2 == nil then
						local Net = require(ReplicatedStorage.packages.Net)
						v2 = Net:RemoteFunction("GetActiveQuestData", -1)
					end

					local v4 = v2:InvokeServer(name)

					if v4 then
						for k, v5 in v4 do
							copy[k] = v5
						end

						copy.IsSecret = nil
					end

					for _, callback in v3[name] or {} do
						task.spawn(callback)
					end

					v3[name] = nil
				end
			else
				local questSecretsLoader = ServerScriptService.server.modules.QuestSecretsLoader

				if not questSecretsLoader:GetAttribute("SecretsLoaded") then
					questSecretsLoader:GetAttributeChangedSignal("SecretsLoaded"):Wait()
				end
			end
		end

		if RunService:IsClient() and copy.DisplayList then
			copy.List = copy.DisplayList
			copy.DisplayList = nil
		end

		if not copy.HasCustomData then
			return copy
		end

		local customData = QuestShared:GetCustomData(p, name)

		if not customData then
			return copy
		end

		copy = GeneralUtils.copy(copy, true)
		copy.DisplayName = copy.DisplayName and DynamicString:Format(copy.DisplayName, customData)
		copy.Description = copy.Description and DynamicString:Format(copy.Description, customData)
		copy.CompletedDescription = copy.CompletedDescription and DynamicString:Format(
			copy.CompletedDescription,
			customData
		)
		local recurse

		recurse = function(items)
			for k, item in items do
				if typeof(item) ~= "table" then
					continue
				end

				if item.__var then
					items[k] = customData[item.__var]
				else
					recurse(item)
				end
			end
		end

		recurse(copy)
		return copy
	else
		local dataPath = QuestShared:ReadDataPath(p, questsFolder.Legacy)

		if not dataPath then
			return
		end

		local child = dataPath:FindFirstChild(name)

		if child then
			return QuestShared:ConvertLegacyQuest(child)
		end

		return nil
	end
end

function QuestShared.CanNavigate(_, p, p2: string)
	local questData = QuestShared:GetQuestData(p, p2)

	if not (questData and questData.NavigationTargets) then
		return false
	end

	for _, navigationTarget in questData.NavigationTargets do
		if navigationTarget.Tags and #navigationTarget.Tags > 0 then
			return true
		end
	end

	return false
end

function QuestShared.GetActiveObjectives(_, p, p2: string)
	local questData = QuestShared:GetQuestData(p, p2)
	local questInstance = QuestShared:GetQuestInstance(p, p2)

	if not (questData and questInstance) then
		return {}
	end

	local childNames = {}

	for childName, v4 in questData.List do
		if v4[1] == "DataInstanceValue" then
			local dataPath = QuestShared:ReadDataPath(p, v4[2])

			if typeof(v4[3]) == "number" then
				if not dataPath or dataPath.Value < v4[3] then
					table.insert(childNames, childName)
				end
			elseif not dataPath or dataPath.Value ~= v4[3] then
				table.insert(childNames, childName)
			end
		else
			local child = questInstance:FindFirstChild(childName)

			if typeof(v4[2]) == "number" then
				if not child or child.Value < v4[2] then
					table.insert(childNames, childName)
				end
			elseif not child or child.Value ~= v4[2] then
				table.insert(childNames, childName)
			end
		end
	end

	return childNames
end

function QuestShared:GetObjectiveInstance(p, p2: string, childName: number)
	local questInstance = QuestShared:GetQuestInstance(p, p2)

	if not questInstance then
		return nil
	end

	local questData = QuestShared:GetQuestData(p, p2)

	if not questData then
		return nil
	end

	local v4 = questData.List[childName]

	if v4[1] == "DataInstanceValue" then
		return QuestShared:ReadDataPath(p, v4[2])
	end

	return questInstance:FindFirstChild(childName)
end

function QuestShared.GetObjectiveValue(_, p, p2: string, p3: number)
	local objectiveInstance = QuestShared:GetObjectiveInstance(p, p2, p3)

	if objectiveInstance then
		return objectiveInstance.Value
	end

	return nil
end

return QuestShared