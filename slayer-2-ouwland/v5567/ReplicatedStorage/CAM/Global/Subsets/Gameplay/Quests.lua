local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Client.Controllers.Skill_Controller.Settings)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local Quests = {
	Holder = {},
	Rewards = {},
	QuestCD = 10,
	MaxQuestsPerPlayer = 1
}
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Utility = require(game.ReplicatedStorage.CAM.Global.Utility)

function Quests.QuestTask(name: string, p: number, p2: string?, p3: string?)
	if name == nil or p == nil then
		return
	end

	if p2 == nil then
		p2 = name
	end

	local configuration = Instance.new("Configuration")
	configuration.Name = name
	local intValue = Instance.new("IntValue")
	intValue.Name = "Value"
	intValue.Parent = configuration
	local intValue2 = Instance.new("IntValue")
	intValue2.Name = "Max"
	intValue2.Value = p
	intValue2.Parent = configuration
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "Code"
	stringValue.Value = p2 or name
	stringValue.Parent = configuration

	if p3 == nil then
		return configuration
	end

	local stringValue2 = Instance.new("StringValue")
	stringValue2.Name = "Need"
	stringValue2.Value = p3
	stringValue2.Parent = configuration
	return configuration
end

function Quests.TaskNeedMet(instance)
	local need = instance:FindFirstChild("Need")

	if need == nil or need.Value == "" then
		return true
	end

	local child

	if instance.Parent ~= nil then
		child = instance.Parent:FindFirstChild(need.Value) or nil
	end

	if child == nil then
		warn((`Quests: task "{instance.Name}" needs "{need.Value}", which is not a task on this quest`))
		return true
	end

	local value = child:FindFirstChild("Value")
	local max = child:FindFirstChild("Max")
	return value == nil or max == nil or value.Value >= max.Value
end

local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Caps = require(ReplicatedStorage.CAM.Global.Caps)

function Quests.AtLevelCap(p)
	local data = Utility.GetData(p)
	return data ~= nil and data.Exp.Goal.Value >= Caps.Get(p, "Max Level") * gameSettings.expPerLevel
end

function Quests.GetTaskMarker(p, instance)
	local v

	if not (p == nil or p.Markers == nil) then
		v = p.Markers[instance.Name] or nil
	end

	if v ~= nil then
		return v
	end

	local trainingMarkerPositions = gameSettings.TrainingMarkerPositions
	local v2

	if trainingMarkerPositions ~= nil then
		v2 = trainingMarkerPositions[game.PlaceId] or trainingMarkerPositions.Default or nil
	end

	if v2 == nil then
		return nil
	end

	local code = instance:FindFirstChild("Code")
	local v3 = code ~= nil and v2[code.Value] or v2[instance.Name]

	if v3 == nil or v3.Position == nil then
		return nil
	end

	return {
		Icon = v3.Image,
		Position = v3.Position
	}
end

function Quests.DeleteQuest(p, instance, value: string?)
	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	local child

	if typeof(instance) == "Instance" then
		if not instance:IsDescendantOf(data.Quests.Holder) then
			return
		end

		child = instance
	else
		child = data.Quests.Holder:FindFirstChild(instance)
	end

	if child ~= nil then
		if typeof(instance) ~= "Instance" then
			SignalEvent.ToClient(p, "Notify", {
				Text = `{value or "Abandoned"} Quest \\[['{instance}']<{gameSettings.RichTextPopularConfigs.SoroundColor}>]`,
				Type = "Denied"
			})
		end

		if game["Run Service"]:IsServer() then
			local questString = child:FindFirstChild("QuestString")
			local v

			if questString ~= nil then
				v = Quests.Holder[questString.Value] or nil
			end

			if v ~= nil and v.GrantItemOnAccept ~= nil and Utility.HeldItem(data, v.GrantItemOnAccept) ~= nil then
				local Item = require(game.ServerStorage.SAM.Services.Removers.Item)
				Item(p, v.GrantItemOnAccept)
			end
		end

		child:Destroy()
	end
end

function Quests.Quest(name: string, instance)
	local configuration = Instance.new("Configuration")
	configuration.Name = name
	local configuration2 = Instance.new("Configuration")
	configuration2.Name = "Tasks"
	configuration2.Parent = configuration

	if typeof(instance) == "Instance" then
		instance.Parent = configuration2
		return configuration
	end

	for _, v in ipairs(instance) do
		v.Parent = configuration2
	end

	return configuration
end

function Quests.GetQuestInfo(p: string)
	local v = Quests.Holder[p]

	if v ~= nil then
		return v
	end

	for _, v2 in pairs(Quests.Holder) do
		if v2.QuestInstance ~= nil and v2.QuestInstance.Name == p then
			return v2
		end
	end

	return nil
end

function Quests.GetQuestCategory(p: string)
	local questInfo = Quests.GetQuestInfo(p)
	return questInfo ~= nil and questInfo.Category or "Combat"
end

function Quests.GetPlayerQuestState(p, childName: string)
	local data = Utility.GetData(p)

	if data == nil then
		return "None"
	end

	local questInfo = Quests.GetQuestInfo(childName)

	if questInfo ~= nil and questInfo.QuestInstance ~= nil and data.Quests.Holder:FindFirstChild(questInfo.QuestInstance.Name) ~= nil then
		return "Doing"
	end

	local completed = data.Quests:FindFirstChild("Completed")

	if completed == nil or completed:FindFirstChild(childName) == nil then
		return "None"
	end

	return "Done"
end

function Quests.CanAddQuest(p, p2: string, flag: boolean?)
	local localPlayer

	if p2 == nil and p ~= nil then
		localPlayer = game.Players.LocalPlayer
		p2 = p
	else
		localPlayer = p
	end

	local data = Utility.GetData(localPlayer)
	local questInfo = Quests.GetQuestInfo(p2)

	if questInfo ~= nil and questInfo.LogCompletion == true and Quests.GetPlayerQuestState(localPlayer, p2) == "Done" then
		return false, 2
	end

	if questInfo ~= nil and questInfo.Requirements ~= nil and not ItemRequirements.Passes(data, questInfo.Requirements) then
		return nil
	end

	local name

	if questInfo == nil then
		name = p2
	else
		name = questInfo.QuestInstance.Name
	end

	local questCategory = Quests.GetQuestCategory(p2)
	local count = 0
	local name2 = nil

	for _, child in ipairs(data.Quests.Holder:GetChildren()) do
		local questString = child:FindFirstChild("QuestString")

		if Quests.GetQuestCategory(questString ~= nil and questString.Value or child.Name) ~= questCategory then
			continue
		end

		count += 1

		if name2 == nil then
			name2 = child.Name
		end
	end

	local v = MinigameSettings.Get("NoQuestCategoryLimit") == true
	local v2 = math.max(Quests.QuestCD, questInfo == nil and 0 or questInfo.AcceptCooldown or 0)
	local v3 = flag == true or v2 < Utility.Tick() - data.Quests.LastTime.Value
	local v4 = v or count < Quests.MaxQuestsPerPlayer

	if v3 and v4 then
		if data.Quests.Holder:FindFirstChild(name) == nil then
			return true
		end

		return false, 1
	else
		return false, not v3, name2
	end
end

function Quests.RewardsOf(instance, p)
	local questString = instance:FindFirstChild("QuestString")
	local v = Quests.Holder[questString ~= nil and questString.Value or instance.Name]
	local rewards

	if v ~= nil then
		rewards = v.Rewards or nil
	end

	if rewards == nil then
		return nil
	end

	local clone = table.clone(rewards)
	local maxLevelMastery = v.MaxLevelMastery

	if p ~= nil and type(maxLevelMastery) == "number" and maxLevelMastery > 0 and Quests.AtLevelCap(p) then
		clone.Exp = nil
		clone.FlatMastery = maxLevelMastery
	end

	local rewardFactor = instance:FindFirstChild("RewardFactor")

	if rewardFactor ~= nil and rewardFactor.Value ~= 1 then
		for k, v2 in clone do
			if type(v2) == "number" then
				clone[k] = v2 * rewardFactor.Value
			end
		end
	end

	return clone
end

function Quests.AddQuest(p, p2: string, data)
	local localPlayer

	if p2 == nil and p ~= nil then
		localPlayer = game.Players.LocalPlayer
		p2 = p
	else
		localPlayer = p
	end

	local v = Quests.Holder[p2]

	if v == nil or localPlayer == nil or not Quests.CanAddQuest(localPlayer, p2, data == nil or data.Client ~= true) then
		return
	end

	local data2 = Utility.GetData(localPlayer)
	local clone = v.QuestInstance:Clone()
	local stringValue = Instance.new("StringValue")
	stringValue.Value = p2
	stringValue.Name = "QuestString"
	stringValue.Parent = clone
	local v2 = Quests.Holder[p2]
	local timer = data ~= nil and data.Timer

	if not timer then
		if v2 == nil then
			timer = nil
		else
			timer = v2.Timer or nil
		end
	end

	local noSave = data ~= nil and data.NoSave or v2 ~= nil and v2.NoSave or nil

	if timer ~= nil then
		local folder = Instance.new("Folder")
		folder.Name = "Timer"
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Started"
		numberValue.Value = os.time()
		numberValue.Parent = folder
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Name = "Target"
		numberValue2.Value = timer
		numberValue2.Parent = folder
		folder.Parent = clone
	end

	if noSave ~= nil then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "NoSave"
		boolValue.Value = noSave
		boolValue.Parent = clone
	end

	if data ~= nil and data.RewardFactor ~= nil and data.RewardFactor ~= 1 then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "RewardFactor"
		numberValue.Value = data.RewardFactor
		numberValue.Parent = clone
	end

	clone.Parent = data2.Quests.Holder

	if data ~= nil and data.Client == true then
		data2.Quests.LastTime.Value = Utility.Tick()
	end

	return true
end

local function questClockRunsHere()
	return not gameSettings.IsMenu
end

local function timersOf(instance)
	local quests = instance:FindFirstChild("Quests")
	local questsHolder = quests ~= nil and quests:FindFirstChild("Holder") or nil

	if questsHolder == nil then
		return {}
	end

	return (questsHolder:GetChildren())
end

function Quests.TimerPaused(instance)
	local timer = instance:FindFirstChild("Timer")

	if timer == nil then
		return false
	end

	local started = timer:FindFirstChild("Started")
	return started ~= nil and started.Value == 0
end

function Quests.PauseTimers(p)
	assert(game["Run Service"]:IsServer(), "Quests: only the server pauses a slot's timers")

	for _, v in timersOf(p) do
		local timer = v:FindFirstChild("Timer")

		if timer == nil then
			continue
		end

		local started = timer:FindFirstChild("Started")
		local target = timer:FindFirstChild("Target")

		if started == nil or target == nil or target.Value <= 0 or started.Value == 0 then
			continue
		end

		local v2 = started.Value + target.Value - os.time()
		started.Value = 0
		target.Value = math.max(0, (math.floor(v2)))
	end
end

function Quests.ResumeTimers(p)
	assert(game["Run Service"]:IsServer(), "Quests: only the server resumes a slot's timers")

	if gameSettings.IsMenu then
		return
	end

	for _, v in timersOf(p) do
		local timer = v:FindFirstChild("Timer")

		if timer == nil then
			continue
		end

		local started = timer:FindFirstChild("Started")
		local target = timer:FindFirstChild("Target")

		if started ~= nil and target ~= nil and target.Value > 0 and started.Value == 0 then
			started.Value = os.time()
		end
	end
end

return Quests