local Players = game:GetService("Players")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules")
local Quests = require(modules.Quests)
local QuestTypes = require(modules.QuestTypes)
local QuestShared = require(modules.QuestShared)
local legacyControllers = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
require(legacyControllers.QuestController)
require(legacyControllers.DataController)
local legacyControllers2 = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
local QuestController = require(legacyControllers2.QuestController)
local DataController = require(legacyControllers2.DataController)
local CrewController = require(legacyControllers2.CrewController)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local legacyLocalPlayerData = require(ReplicatedStorage:WaitForChild("client"):WaitForChild("modules"):WaitForChild("legacyLocalPlayerData"))
local localPlayer = Players.LocalPlayer
local questBook = localPlayer.PlayerGui:WaitForChild("hud").safezone.QuestBook
local questList = questBook.questList
local listContents = questList.listContents
local questDetails = questBook.questDetails
local detailContents = questDetails.detailContents
local objectives = detailContents.objectives
local rewards = detailContents.rewards
local searchBox = questList.searchBox
local track = questDetails.options.Track
local navigate = questDetails.options.Navigate
TweenInfo.new(0.5, Enum.EasingStyle.Quint)
local color = Color3.new(0, 0, 0)
local color2 = Color3.new(1, 1, 1)
local color3 = Color3.fromRGB(156, 255, 164)
local color4 = Color3.fromRGB(162, 234, 166)
local color5 = Color3.fromRGB(234, 116, 118)
local remoteEvent = Net:RemoteEvent("Quests/ToggleTrack", 1e999)
local remoteEvent2 = Net:RemoteEvent("Quests/RequestNavigate", -1)
local QuestBook = {}

local function clearList(instance)
	for _, guiObject in instance:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

local v = {}

local function getQuestExpiryUnix(data)
	if data.ExpiresAt then
		return data.ExpiresAt.UnixTimestamp
	end

	if data.HasCustomData then
		local customData = QuestShared:GetCustomData(localPlayer, data.Id)

		if customData and typeof(customData.ExpiresAt) == "number" then
			return customData.ExpiresAt
		end
	end

	return nil
end

local object = setmetatable({}, {
	__mode = "k"
})

local function applyCountdown(countdown, data)
	local v2 = object[countdown]

	if not v2 then
		v2 = {
			Text = countdown.timerLabel.TextColor3,
			Icon = countdown.icon.ImageColor3
		}
		object[countdown] = v2
	end

	if data.WishLocked then
		countdown:RemoveTag("QuestCountdown")
		countdown:SetAttribute("ExpiresAt", nil)
		countdown.timerLabel.Text = "Wished"
		countdown.timerLabel.TextColor3 = Color3.fromRGB(190, 210, 255)
		countdown.icon.ImageColor3 = Color3.fromRGB(190, 210, 255)
		countdown.Visible = true
	else
		countdown.timerLabel.TextColor3 = v2.Text
		countdown.icon.ImageColor3 = v2.Icon
		local unixTimestamp

		if data.ExpiresAt then
			unixTimestamp = data.ExpiresAt.UnixTimestamp
		elseif data.HasCustomData then
			local customData = QuestShared:GetCustomData(localPlayer, data.Id)

			if customData and typeof(customData.ExpiresAt) == "number" then
				unixTimestamp = customData.ExpiresAt
			end
		end

		if unixTimestamp then
			countdown.Visible = true
			countdown:SetAttribute("ExpiresAt", unixTimestamp)
			countdown:AddTag("QuestCountdown")
		else
			countdown:RemoveTag("QuestCountdown")
			countdown.Visible = false
			countdown:SetAttribute("ExpiresAt", nil)
		end
	end
end

QuestBook.typeDividers = {}
QuestBook.questEntries = {}
QuestBook.indicators = {}
QuestBook.selected = nil
QuestBook.mainTrove = Trove.new()
QuestBook.questTroves = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function hasMatch(objectives2, activeObjectives)
	for _, item in objectives2 do
		if table.find(activeObjectives, item) then
			return item
		end
	end

	return nil
end

function QuestBook.getDisplayLocation(p)
	if not p.NavigationTargets then
		return
	end

	for _, navigationTarget in p.NavigationTargets do
		if navigationTarget.Objectives then
			local match = hasMatch(navigationTarget.Objectives, QuestShared:GetActiveObjectives(localPlayer, p.Id)) -- equivalent call inferred; original call site unknown

			if not match or navigationTarget.ObjectiveValues and not table.find(
				navigationTarget.ObjectiveValues,
				QuestShared:GetObjectiveValue(localPlayer, p.Id, match)
			) then
				continue
			end
		end

		if (navigationTarget.AllComplete == nil or navigationTarget.AllComplete == QuestShared:IsFinished(
			localPlayer,
			p.Id
		)) and navigationTarget.Zone then
			return navigationTarget.Zone
		end
	end

	return nil
end

function QuestBook.addTypeDivider(data)
	local clone = script.typeDivider:Clone()
	clone.Name = tostring(data.Order)
	clone.typeInfo.typeIcon.Image = data.IconSmall
	clone.typeInfo.typeName.Text = data.NameFull
	local color6 = data.Color
	clone.typeInfo.BackgroundColor3 = color6
	clone.bottomBorder.BackgroundColor3 = color6
	local lerped = data.Color:Lerp(color2, 0.5)
	clone.typeInfo.typeIcon.UIGradient.Color = ColorSequence.new(lerped, color2)
	clone.typeInfo.typeName.UIGradient.Color = ColorSequence.new(lerped, color2)
	clone.Parent = listContents
	QuestBook.typeDividers[data.Name] = clone
	return clone
end

function QuestBook.updateTypeDividers()
	local v2 = {}

	for _, typeDivider in QuestBook.typeDividers do
		typeDivider.Visible = false
	end

	for k, questEntry in QuestBook.questEntries do
		local questData = QuestShared:GetQuestData(localPlayer, k) or v[k]
		v2[questData.QuestType] = true

		if questEntry.Visible and QuestBook.typeDividers[questData.QuestType] then
			QuestBook.typeDividers[questData.QuestType].Visible = true
		end
	end

	for k, typeDivider in QuestBook.typeDividers do
		if v2[k] then
			continue
		end

		typeDivider:Destroy()
		QuestBook.typeDividers[k] = nil
	end
end

function QuestBook.updateDetails(p)
	local questInstance = QuestShared:GetQuestInstance(localPlayer, p.Id)

	if not questInstance then
		return
	end

	for k, v2 in QuestShared:GetQuestData(localPlayer, p.Id).List do
		local child = objectives:FindFirstChild((tostring(k)))

		if not child then
			continue
		end

		local child2 = questInstance:FindFirstChild((tostring(k)))

		if v2[1] == "DataInstanceValue" then
			child2 = QuestShared:ReadDataPath(localPlayer, v2[2])
		end

		local goalDescription, v3 = QuestController:GetGoalDescription(questInstance, child2, k)
		child.line.Text = goalDescription

		if v3 then
			child.icon.Image = "rbxassetid://88990232999627"
			child.icon.ImageColor3 = color3
			child.icon.ImageTransparency = 0.1
			child.line.TextColor3 = color3
		else
			child.icon.Image = "rbxassetid://17848872395"
			child.icon.ImageColor3 = color2
			child.icon.ImageTransparency = 0.5
			child.line.TextColor3 = color2
		end
	end

	local completeDesc = detailContents.completeDesc
	completeDesc.Visible = QuestShared:GetState(localPlayer, p.Id) >= QuestShared.QuestState.Finished and detailContents.completeDesc.Text ~= ""
	local locationInfo = detailContents.quickDetails.locationInfo
	local displayLocation = QuestBook.getDisplayLocation(p)

	if displayLocation then
		locationInfo.locationName.Text = displayLocation
		locationInfo.Visible = true
	else
		locationInfo.Visible = false
	end

	local tracking = questInstance:FindFirstChild("Tracking")
	local value = tracking and tracking.Value
	local v3 = value and color5 or color4
	track.UIStroke.Color = v3
	track.ImageColor3 = v3
	track.Label.TextColor3 = v3
	track.Label.Text = value and "Untrack" or "Track"
	DataController.PlayerDataReplicator:WaitForLoaded()

	if DataController.PlayerDataReplicator:Index({ "Navigation", "Target" }) == p.Id then
		navigate.Label.Text = "Stop Navigating"
	else
		navigate.Label.Text = "Navigate"
	end
end

function QuestBook.openDetails(data)
	local v2 = QuestTypes[data.QuestType] or QuestTypes.Side
	local questData = QuestBook.selected and (QuestShared:GetQuestData(localPlayer, QuestBook.selected) or v[QuestBook.selected])
	QuestBook.selected = data.Id
	local questData2 = QuestShared:GetQuestData(localPlayer, data.Id)
	local header = detailContents.header
	header.questIcon.Image = data.Icon
	header.questName.Text = data.DisplayName
	local lerped = (data.IconColor or v2.Color):Lerp(color2, 0.65)
	header.questIcon.UIGradient.Color = ColorSequence.new(lerped, color2)
	header.questName.UIGradient.Color = ColorSequence.new(lerped, color2)

	if data.Description and data.Description ~= "" then
		detailContents.questDesc.Text = data.Description
		detailContents.questDesc.Visible = true
		detailContents.descDivider.Visible = true
	else
		detailContents.questDesc.Visible = false
		detailContents.descDivider.Visible = false
	end

	if data.CompletedDescription and data.CompletedDescription ~= "" then
		detailContents.completeDesc.Text = data.CompletedDescription
	else
		detailContents.completeDesc.Text = ""
	end

	local quickDetails = detailContents.quickDetails
	local typeInfo = quickDetails.typeInfo
	typeInfo.typeIcon.Image = v2.IconSmall
	typeInfo.typeName.Text = v2.NameFull
	local lerped2 = v2.Color:Lerp(color2, 0.5)
	typeInfo.typeIcon.UIGradient.Color = ColorSequence.new(lerped2, color2)
	typeInfo.typeName.UIGradient.Color = ColorSequence.new(lerped2, color2)
	applyCountdown(quickDetails.countdown, data)
	clearList(objectives)

	for k, _ in questData2.List do
		local clone = script.listItem:Clone()
		clone.LayoutOrder = k
		clone.line.Text = ""
		clone.Name = tostring(k)
		clone.Parent = objectives
	end

	if #questData2.List == 1 then
		detailContents.objectiveHeader.Text = "Current Objective:"
	else
		detailContents.objectiveHeader.Text = "Current Objectives:"
	end

	clearList(rewards)
	local rewards2 = data.Rewards

	if data.DisplayRewardsFrom then
		local questData3 = QuestShared:GetQuestData(localPlayer, data.DisplayRewardsFrom)

		if questData3 and questData3.Rewards then
			rewards2 = questData3.Rewards
		end
	end

	if rewards2 and #rewards2 > 0 then
		for k, reward in rewards2 do
			if reward[1] == "DataInstanceValue" then
				continue
			end

			local clone = script.listItem:Clone()
			clone.LayoutOrder = k
			clone.line.Text = QuestController:GetRewardDescription(reward) or "???"
			clone.line.Font = Enum.Font.SourceSans
			clone.Parent = rewards
		end

		rewards.Visible = true
		detailContents.rewardDivider.Visible = true
		detailContents.rewardHeader.Visible = true
	else
		rewards.Visible = false
		detailContents.rewardDivider.Visible = false
		detailContents.rewardHeader.Visible = false
	end

	if data.QuestType == "Crew" then
		local quest = Quests[data.Id]
		local rating = quest and quest.Rating

		if typeof(rating) == "number" then
			task.spawn(function()
				local fetched = CrewController.Fetch()

				if not fetched or typeof(fetched.MemberCount) ~= "number" or QuestBook.selected ~= data.Id then
					return
				end

				local v3 = rating * math.max(fetched.MemberCount, 1)

				for _, child in rewards:GetChildren() do
					local line = child:FindFirstChild("line")

					if not (line and line:IsA("TextLabel")) then
						continue
					end

					line.Text = `+{NumberUtils:Comma(v3)} Crew Rating`
					break
				end
			end)
		end
	end

	navigate.Visible = QuestShared:CanNavigate(localPlayer, data.Id)

	if questData and questData.Id ~= data.Id then
		QuestBook.updateQuest(questData)
	end

	QuestBook.updateQuest(data)
end

function QuestBook.updateQuest(p)
	local questEntry = QuestBook.questEntries[p.Id]

	if not questEntry then
		return
	end

	local color6 = (QuestTypes[p.QuestType] or QuestTypes.Side).Color
	questEntry.BackgroundColor3 = QuestBook.selected == p.Id and color6 or color6:Lerp(color, 0.65)
	local quickDetails = questEntry.questInfo.quickDetails
	local countdown = quickDetails.countdown
	applyCountdown(countdown, p)
	local locationInfo = quickDetails.locationInfo
	local displayLocation = QuestBook.getDisplayLocation(p)

	if displayLocation then
		locationInfo.locationName.Text = displayLocation
		locationInfo.Visible = true
	else
		locationInfo.Visible = false
	end

	local rewardUnclaimed = quickDetails.rewardUnclaimed

	if QuestShared:GetState(localPlayer, p.Id) == QuestShared.QuestState.Finished then
		rewardUnclaimed.Visible = true
	else
		rewardUnclaimed.Visible = false
	end

	quickDetails.Visible = countdown.Visible or locationInfo.Visible or rewardUnclaimed.Visible

	if QuestBook.selected == p.Id then
		questEntry.indicator.Visible = false
		QuestBook.indicators[p.Id] = nil
		QuestBook.updateDetails(p)
	end
end

function QuestBook.autoselect()
	local v2 = {}
	local v3 = {}

	for k, questEntry in QuestBook.questEntries do
		local questInstance = QuestShared:GetQuestInstance(localPlayer, k)

		if not questInstance then
			continue
		end

		local tracking = questInstance:FindFirstChild("Tracking")

		if tracking and tracking.Value then
			table.insert(v2, { questEntry.Name, k })
		elseif #v2 == 0 then
			table.insert(v3, { questEntry.Name, k })
		end
	end

	if #v2 > 0 then
		v3 = v2
	end

	table.sort(v3, function(a, b)
		return a[1] < b[1]
	end)
	local v4 = v3[1]

	if v4 then
		QuestBook.openDetails(QuestShared:GetQuestData(localPlayer, v4[2]) or v[v4[2]])
		detailContents.Visible = true
		questDetails.options.Visible = true
		questDetails.empty.Visible = false
	else
		detailContents.Visible = false
		questDetails.options.Visible = false
		questDetails.empty.Visible = true
	end
end

function QuestBook.addQuest(data)
	local maid = Trove.new()
	local v2 = QuestTypes[data.QuestType] or QuestTypes.Side

	if not QuestBook.typeDividers[data.QuestType] then
		QuestBook.addTypeDivider(v2)
	end

	local clone = script.quest:Clone()
	clone.Name = `{v2.Order} {data.DisplayName:lower()}`
	local color6 = v2.Color
	clone.leftBorder.BackgroundColor3 = color6
	clone.BackgroundColor3 = color6:Lerp(color, 0.65)
	clone.questInfo.questName.Text = data.DisplayName
	clone.indicator.Visible = QuestBook.indicators[data.Id] or false
	clone.Parent = listContents
	maid:Add(clone)
	QuestBook.questTroves[data.Id] = maid
	QuestBook.questEntries[data.Id] = clone
	QuestBook.updateQuest(data)
	maid:Add(function()
		if QuestBook.questEntries[data.Id] == clone then
			QuestBook.questEntries[data.Id] = nil
		end
	end)
	maid:Add(clone.Activated:Connect(function()
		QuestBook.openDetails(data)
	end))
	maid:Add(clone.MouseEnter:Connect(function()
		clone.arrow:TweenPosition(UDim2.new(1, 2, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
	end))
	maid:Add(clone.MouseLeave:Connect(function()
		clone.arrow:TweenPosition(UDim2.new(1, -5, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
	end))
	return clone
end

function QuestBook.removeQuest(p: string)
	local questTrove = QuestBook.questTroves[p]

	if questTrove then
		questTrove:Clean()
		QuestBook.questTroves[p] = nil
	end

	if QuestBook.selected == p then
		QuestBook.autoselect()
	end

	QuestBook.updateTypeDividers()
end

function QuestBook.unloadQuests()
	QuestBook.mainTrove:Clean()

	for _, questTrove in QuestBook.questTroves do
		questTrove:Clean()
	end

	table.clear(QuestBook.questTroves)

	for _, typeDivider in QuestBook.typeDividers do
		typeDivider:Destroy()
	end

	table.clear(QuestBook.typeDividers)
end

function QuestBook.updateSearch()
	local text = searchBox.Text:lower()

	for k, questEntry in QuestBook.questEntries do
		local questData = QuestShared:GetQuestData(localPlayer, k) or v[k]

		if text == "" or questData and questData.DisplayName:lower():find(text, 1, true) then
			questEntry.Visible = true
		else
			questEntry.Visible = false
		end
	end

	QuestBook.updateTypeDividers()
end

function QuestBook.toggleTracking()
	if not (QuestBook.selected and (Quests[QuestBook.selected] or v[QuestBook.selected])) then
		return
	end

	local questInstance = QuestShared:GetQuestInstance(localPlayer, QuestBook.selected)

	if not questInstance then
		return
	end

	local tracking = questInstance:FindFirstChild("Tracking")

	if tracking then
		tracking.Value = not tracking.Value
	end

	remoteEvent:FireServer(questInstance, not tracking or tracking.Value)
	local v2 = not tracking or tracking.Value
	local v3 = v2 and color5 or color4
	track.UIStroke.Color = v3
	track.ImageColor3 = v3
	track.Label.TextColor3 = v3
	track.Label.Text = v2 and "Untrack" or "Track"
end

function QuestBook.toggleNavigate()
	if not (QuestBook.selected and (Quests[QuestBook.selected] or v[QuestBook.selected])) then
		return
	end

	if DataController.PlayerDataReplicator:Index({ "Navigation", "Target" }) == QuestBook.selected then
		remoteEvent2:FireServer(nil)
	else
		remoteEvent2:FireServer(QuestBook.selected)
	end
end

function QuestBook.loadQuests()
	QuestBook.unloadQuests()
	searchBox.Text = ""

	for _, v2 in QuestShared:GetActiveQuests(localPlayer) do
		QuestBook.addQuest(v2)
	end

	for _, v2 in QuestShared:GetLegacyQuests(localPlayer) do
		v[v2.Id] = v2
		QuestBook.addQuest(v2)
	end

	QuestBook.mainTrove:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(QuestBook.updateSearch))
	QuestBook.mainTrove:Add(track.Activated:Connect(QuestBook.toggleTracking))
	QuestBook.mainTrove:Add(navigate.Activated:Connect(QuestBook.toggleNavigate))
	local dataPath = QuestShared:ReadDataPath(localPlayer, "QuestActive")

	if dataPath then
		QuestBook.mainTrove:Add(dataPath.ChildAdded:Connect(function(child)
			QuestBook.addQuest(assert(QuestShared:GetQuestData(localPlayer, child.Name)))
		end))
		QuestBook.mainTrove:Add(dataPath.ChildRemoved:Connect(function(child)
			QuestBook.removeQuest(child.Name)
		end))
	end

	local dataPath2 = QuestShared:ReadDataPath(localPlayer, "Quests")

	if dataPath2 then
		QuestBook.mainTrove:Add(dataPath2.ChildAdded:Connect(function(child)
			local convertLegacyQuest = QuestShared:ConvertLegacyQuest(child)

			if not convertLegacyQuest then
				return
			end

			v[child.Name] = convertLegacyQuest
			QuestBook.addQuest(convertLegacyQuest)
		end))
		QuestBook.mainTrove:Add(dataPath2.ChildRemoved:Connect(function(child)
			QuestBook.removeQuest(v[child.Name].Id)
			v[child.Name] = nil
		end))
	end

	if QuestBook.selected and QuestBook.questEntries[QuestBook.selected] then
		QuestBook.openDetails(QuestShared:GetQuestData(localPlayer, QuestBook.selected) or v[QuestBook.selected])
	else
		QuestBook.autoselect()
	end

	local guiInset, v2 = GuiService:GetGuiInset()
	local v3 = v2 + Vector2.new(0, 90)
	questBook.Size = UDim2.new(0.85, -guiInset.X - v3.X, 1, -guiInset.Y - v3.Y)
	questBook.Position = UDim2.new(0.5, guiInset.X / 2 - v3.X / 2, 0.5, guiInset.Y / 2 - v3.Y / 2)
end

local function onQuestInstance(p)
	QuestBook.indicators[p.Name] = true

	if QuestBook.questEntries[p.Name] then
		QuestBook.questEntries[p.Name].indicator.Visible = true
	end
end

function QuestBook.init()
	questBook:GetPropertyChangedSignal("Visible"):Connect(function()
		if questBook.Visible then
			QuestBook.loadQuests()
		else
			QuestBook.unloadQuests()
		end
	end)

	if not localPlayer:GetAttribute("DataLoaded") then
		localPlayer:GetAttributeChangedSignal("DataLoaded"):Wait()
	end

	local fetched = legacyLocalPlayerData.fetch()
	local questActive = fetched:WaitForChild("QuestActive")
	local quests = fetched:WaitForChild("Quests")
	questActive.ChildAdded:Connect(onQuestInstance)
	quests.ChildAdded:Connect(onQuestInstance)
	DataController.PlayerDataReplicator:Observe({ "Navigation" }, function()
		if QuestBook.selected then
			local questData = QuestShared:GetQuestData(localPlayer, QuestBook.selected)

			if not questData then
				return
			end

			QuestBook.updateQuest(questData)
		end
	end)
end

return QuestBook