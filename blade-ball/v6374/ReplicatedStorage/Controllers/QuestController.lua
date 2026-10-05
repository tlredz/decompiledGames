local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Shared.NewQuestData)
local v5 = require3(script.QuestButtonVisual)
local v6 = require3(script.ContainerManager)
local v7 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v8 = require3(ReplicatedStorage2.Packages.Net)
local v9 = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v10 = require3(ReplicatedStorage2.Shared.DynArgs)
require3(ReplicatedStorage2.Controllers.AnalyticsController)
local v11 = v10.And()
ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 169, 34)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 62, 13))
})
ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 23, 49)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(1, 15, 31))
})
local maid = v2.Maid
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v12 = nil
local quests = nil
local mainFrame = nil
local buttons = nil
local close = nil
maid.new()
local QuestController = {
	QuestTypeTemplates = {
		Daily = DailyQuestTemplate,
		Limited = LimitedQuestTemplate,
		Returning = LimitedQuestTemplate
	},
	PathAllias = {
		Daily = { "QuestsData", "DailyQuests", "Quests" },
		Limited = { "QuestsData", "LimitedQuests" },
		Returning = { "QuestsData", "ReturningQuests", "Quests" }
	},
	UpdateList = {},
	DAILY_QUEST_COMPLETE_TEXT = "<font color=\"rgb(0, 255, 0)\">Completed</font>",
	DAILY_QUEST_EXPIRED_TEXT = "<font color=\"rgb(255, 0, 0)\">Expired</font>",
	SwitchBetweenPage = function(self, currentSection: string)
		mainFrame:SetAttribute("CurrentSection", currentSection)
	end
}

function QuestController:Hook()
	self:PopulateLimitedQuest()
	self:SetupReturningButtons()
	self:TrackReturningQuestUpdate()
	self:PopulateReturningQuestsOfDay(1)
	self:PopulateDailyQuests()
	self:PopulateHUDQuestTracker()
	local expect = v12:GetExpect({ "QuestsData", "WeeklyPoints" })
	self:UpdateWeeklyPointUI(mainFrame.Daily.Points, expect)
	self:UpdateWeeklyPointUI(mainFrame.Limited.Points, expect)
	local HUD = playerGui:WaitForChild("HUD")
	local leftFrame = HUD:WaitForChild("LeftFrame")
	local questTracker = HUD:WaitForChild("RightFrame"):WaitForChild("QuestTracker")
	v11.StateChanged:Connect(function(visible)
		questTracker.Visible = visible
	end)
	v3:OnGuiOpen("Wheel", function()
		v11:SetTag("SpinWheel", false)
	end)
	v3:OnGuiClose("Wheel", function()
		v11:SetTag("SpinWheel", true)
	end)

	for _, scrollingFrame in leftFrame:GetChildren() do
		if not scrollingFrame:IsA("ScrollingFrame") then
			continue
		end

		local child = buttons:FindFirstChild(scrollingFrame.Name)

		if not child then
			continue
		end

		local name = scrollingFrame.Name
		local v13 = v6:New(scrollingFrame)
		local v14 = scrollingFrame
		local v15 = child
		child.Activated:Connect(function()
			v14:SetAttribute("Section", (tostring(v15.Name)))
		end)
		local v16 = scrollingFrame
		local v17 = child
		scrollingFrame:GetAttributeChangedSignal("Section"):Connect(function()
			if v16:GetAttribute("Section") == v17.Name then
				v6:Show(v13)
			else
				v6:Hide(v13)
			end
		end)
		scrollingFrame:SetAttribute("Section", (tostring(1)))
		local v20 = child
		local v21 = scrollingFrame
		leftFrame:GetAttributeChangedSignal("CurrentSection"):Connect(function()
			local visible = leftFrame:GetAttribute("CurrentSection") == name
			local v23 = v5.VisualStateForPageSelection[visible]
			v20.HoverImage = v23.Hover
			v20.Image = v23.Normal
			v21.Visible = visible
		end)
		local name2 = name
		child.Activated:Connect(function()
			warn("Switching Pages")
			QuestController:SwitchBetweenPage(name2)
		end)
	end

	leftFrame:SetAttribute("CurrentSection", "Daily")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTime(p)
	local v13 = math.floor(p / 3600)
	local v14 = math.floor(p % 3600 / 60)
	local v15 = p % 60
	return string.format("%02d:%02d:%02d", v13, v14, v15)
end

function QuestController.ReturnQuestsOfType(_, _: string)
	v12:GetExpect({ "QuestsData", "questType" })
end

function QuestController:AddQuestToUpdateList(questFrame, questObject)
	local expect = v12:GetExpect({ "QuestsData", "DailyQuests", "QuestRefreshTimestamp" })
	table.insert(self.UpdateList, {
		QuestObject = questObject,
		QuestFrame = questFrame,
		ExpireTimestamp = expect
	})
	self:UpdateQuestTimer(questFrame, expect - os.time())
end

function QuestController:ClearUpdateList()
	table.clear(self.UpdateList)
end

function QuestController:RemoveQuestFromUpdateList(p2)
	for k, v13 in self.UpdateList do
		if v13.QuestObject.UUID ~= p2.UUID then
			continue
		end

		table.remove(self.UpdateList, k)
		break
	end
end

function QuestController:PopulateQuests(items, parent)
	for _, item in items do
		local questFrame = self:CreateQuestFrame(item)

		if questFrame then
			questFrame.Parent = parent
		end
	end
end

function QuestController:PopulateQuestsOfPath(p, p2)
	self:PopulateQuests(v12:GetExpect(p), p2)
end

function QuestController:CreateQuestFrame(data)
	local questType = data.QuestType
	local questObjectInformation = self:GetQuestObjectInformation(data)

	if questObjectInformation then
		local clone = self.QuestTypeTemplates[questType]:Clone()
		clone:SetAttribute("UUID", data.UUID)
		local claim = clone:FindFirstChild("Claim")

		if claim then
			claim.Activated:Connect(function()
				if v8:Invoke("ClaimQuest", data.UUID) then
					clone:Destroy()
				end
			end)
		end

		if questType == "Daily" and not data.Completed then
			self:AddQuestToUpdateList(clone, data)
		end

		self:PopulateQuestFrame(clone, data, questObjectInformation)
		return clone
	else
		warn("QuestInformation is missing for QuestKey: ", data.QuestKey)
		warn("... Is the QuestKey the same as the Index?")
	end
end

function QuestController:GetAllInProgressQuests()
	local result = {}

	for _, pathAllia in self.PathAllias do
		for _, v13 in v12:GetExpect(pathAllia) do
			if not v13.Active or v13.Completed then
				continue
			end

			table.insert(result, v13)
		end
	end

	return result
end

function QuestController:PopulateLimitedQuest()
	if not self.LimitedQuestContainer then
		self.LimitedQuestContainer = LimitedQuestContainer:Clone()
		self.LimitedQuestContainer.Parent = mainFrame.Limited
	end

	self:PopulateQuestsOfPath(self.PathAllias.Limited, self.LimitedQuestContainer.Container)
end

function QuestController:PopulateDailyQuests()
	if not self.DailyQuestContainer then
		self.DailyQuestContainer = DailyQuestContainer:Clone()
		self.DailyQuestContainer.Parent = mainFrame.Daily
	end

	self:PopulateQuestsOfPath(self.PathAllias.Daily, self.DailyQuestContainer.Container)
end

local v13 = {
	Limited = 3,
	Daily = 2,
	Returning = 1
}

function QuestController:PopulateHUDQuestTracker()
	local HUD = playerGui:WaitForChild("HUD")
	HUD:WaitForChild("LeftFrame")
	local questTracker = HUD:WaitForChild("RightFrame"):WaitForChild("QuestTracker")
	local questTitle = questTracker:WaitForChild("TitleFade"):WaitForChild("QuestTitle")
	local fill = questTracker:WaitForChild("Progress"):WaitForChild("Fill")
	local rewards = questTracker:WaitForChild("Rewards")
	local allInProgressQuests = self:GetAllInProgressQuests()
	table.sort(allInProgressQuests, function(a, b)
		return v13[a.QuestType] > v13[b.QuestType]
	end)
	local allInProgressQuest = allInProgressQuests[1]

	if not allInProgressQuest then
		v11:SetTag("SelectedQuest", false)
		return
	end

	local questObjectInformation = self:GetQuestObjectInformation(allInProgressQuest)

	if not questObjectInformation then
		warn("Can't find Quest Infromation for HUD")
		return
	end

	local maxProgress = allInProgressQuest.OverwriteProperties.MaxProgress or questObjectInformation.MaxProgress or 1
	local v14 = math.clamp(allInProgressQuest.CurrentProgress or 0, 0, maxProgress)
	local displayName = allInProgressQuest.OverwriteProperties.DisplayName or questObjectInformation.DisplayName or "QUEST_IS_MISSING_A_DISPLAY_NAME"
	local v15 = v14 / maxProgress

	for _, frame in rewards:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local rewardInformation = self:GetRewardInformation(allInProgressQuest, questObjectInformation)

	for k, text in rewardInformation do
		local clone = RewardTemplate:Clone()
		local rewardTitle = clone.RewardTitle
		local vector = clone.Vector

		if k == "Lootboxes" or k == "Crate" or k == "CrateKeys" then
			rewardTitle.Text = "x" .. #text
		else
			rewardTitle.Text = text
		end

		vector.Image = v9:GetIcon("DEFAULT_MISSING")
		clone.Visible = true
		clone.Parent = rewards
	end

	questTitle.Text = displayName
	fill.Size = UDim2.fromScale(math.clamp(v15, 0.1, 1), fill.Size.Y.Scale)
	v11:SetTag("SelectedQuest", true)
end

function QuestController:SetupReturningButtons()
	local sectionButtons = mainFrame.Returning.SectionButtons
	local v14 = math.floor((os.time() - v12:GetExpect({ "QuestsData", "ReturningQuests", "InitalLoginTimestamp" })) / 86400) + 1

	for i = 1, 5 do
		local clone

		if i <= v14 then
			clone = CompletedQuestButton:Clone()
		else
			clone = LockedQuestButton:Clone()
		end

		if i <= v14 then
			local v15 = i
			clone.Activated:Connect(function()
				self:PopulateReturningQuestsOfDay(v15)
			end)
		end

		clone.TextLabel.Text = string.format("Day %d", i)
		clone.LayoutOrder = i
		clone.Parent = sectionButtons
	end
end

function QuestController:PopulateReturningQuestsOfDay(p: number)
	if not self.ReturningQuestContainer then
		self.ReturningQuestContainer = DailyQuestContainer:Clone()
		self.ReturningQuestContainer.Parent = mainFrame.Returning
	end

	for _, frame in self.ReturningQuestContainer.Container:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local v14 = {}

	for _, v15 in v12:GetExpect(self.PathAllias.Returning) do
		if v15.QuestData.AssignedDay and v15.QuestData.AssignedDay == p then
			table.insert(v14, v15)
		end
	end

	self:PopulateQuests(v14, self.ReturningQuestContainer.Container)
end

function QuestController:GetRewardInformation(p, p2)
	local customReward = p2.CustomReward
	local getRewardInfo = customReward and p2.CustomReward.GetRewardInfo

	if not customReward then
		return p2.SimpleReward or {}
	end

	if getRewardInfo then
		return (p2.CustomReward.GetRewardInfo(p, localPlayer))
	end

	return (p2.CustomReward.RewardFunction(p, localPlayer))
end

function QuestController:PopulateQuestFrame(instance, data, p)
	local title = instance.Title
	local amount = instance.Amount
	local fill = instance.Progress.Fill
	local maxProgress = data.OverwriteProperties.MaxProgress or p.MaxProgress or 1
	local displayName = data.OverwriteProperties.DisplayName or p.DisplayName or "QUEST_IS_MISSING_A_DISPLAY_NAME"
	local v14 = (data.CurrentProgress - 0) / (maxProgress - 0)
	local v15 = math.clamp(data.CurrentProgress or 0, 0, maxProgress)

	if data.QuestType == "Daily" and data.Completed then
		instance.Time.Text = self.DAILY_QUEST_COMPLETE_TEXT
	end

	local rewardInformation = self:GetRewardInformation(data, p)
	local v16 = 1

	for k, text in rewardInformation do
		if v16 > 2 then
			break
		end

		local child = instance:FindFirstChild("Rew" .. v16)

		if child then
			local textLabel = child.Frame.TextLabel
			local _ = child.Vector

			if k == "Lootboxes" or k == "Crate" or k == "CrateKeys" then
				textLabel.Text = "x" .. #text
			else
				textLabel.Text = text
			end

			child.Visible = true
		end

		v16 += 1
	end

	if v16 == 2 then
		local rew1 = instance:FindFirstChild("Rew1")
		local text

		if rew1 then
			text = tonumber(rew1.Frame.TextLabel.Text)
			rew1.Frame.TextLabel.Text = text / 2
		end

		local rew2 = instance:FindFirstChild("Rew2")

		if rew2 then
			rew2.Frame.TextLabel.Text = text / 2
			rew2.Visible = true
		end
	end

	local claim = instance:FindFirstChild("Claim")

	if claim then
		if data.Completed then
			claim.Visible = true
		else
			claim.Visible = false
		end
	end

	title.Text = displayName
	amount.Text = string.format("%d/%d", v15, maxProgress)
	fill.Size = UDim2.fromScale(math.min(1, v14), fill.Size.Y.Scale)
end

function QuestController:GetQuestObjectInformation(p)
	if p.QuestType ~= "Limited" then
		return v4.Quests[p.QuestKey]
	end

	local limitedQuest = v4.LimitedQuests[p.QuestKey]
	return limitedQuest or v4.InternalQuests[p.QuestKey]
end

function QuestController:UpdateWeeklyPointUI(p, p2: number)
	local pointCounter = p.PointCounter
	local fill = p.Progress.Fill
	local v14 = ({
		0.08,
		0.295,
		0.509,
		0.724,
		1
	})[math.min(p2, 5)]
	pointCounter.Text = string.format("Points: %d", p2)
	fill.Size = UDim2.fromScale(v14, fill.Size.Y.Scale)
end

function QuestController:TrackQuestUpdate()
	for k, pathAllia in self.PathAllias do
		local v14 = k
		v12:OnChange(pathAllia, function(p)
			self:PopulateHUDQuestTracker()

			if v14 == "Returning" then
				self:PopulateReturningQuestsOfDay(1)
				return
			end

			self:ClearUpdateList()

			for i, frame in self.DailyQuestContainer.Container:GetChildren() do
				if frame:IsA("Frame") then
					frame:Destroy()
				end
			end

			for i, frame in self.LimitedQuestContainer.Container:GetChildren() do
				if frame:IsA("Frame") then
					frame:Destroy()
				end
			end

			self:PopulateDailyQuests()
			self:PopulateLimitedQuest()
		end)
	end

	v12:OnChange({ "QuestsData", "WeeklyPoints" }, function(p, _)
		self:UpdateWeeklyPointUI(mainFrame.Daily.Points, p)
		self:UpdateWeeklyPointUI(mainFrame.Limited.Points, p)
	end)
end

function QuestController:TrackReturningQuestUpdate()
	local sectionButtons = mainFrame.Returning.SectionButtons
	v12:OnChange({ "QuestsData", "ReturningQuests", "InitalLoginTimestamp" }, function(_, _)
		for _, button in sectionButtons:GetChildren() do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		self:SetupReturningButtons()
		self:PopulateReturningQuestsOfDay(1)
	end)
end

function QuestController:Start()
	v7:WaitForData()

	if not v7:GetKey("NewQuestSystemEnabled") then
		return
	end

	v12 = v.Client:WaitReplion("Data")
	quests = playerGui:WaitForChild("Quests")
	mainFrame = quests:WaitForChild("MainFrame")
	buttons = mainFrame:WaitForChild("Buttons")
	close = mainFrame:WaitForChild("Close")
	local dailyQuests = playerGui:WaitForChild("DailyQuests")
	v3:OnGuiOpen("DailyQuests", function()
		dailyQuests.Enabled = false
		quests.Enabled = true
	end)
	v3:OnGuiClose("DailyQuests", function()
		quests.Enabled = false
	end)
	close.Activated:Connect(function()
		warn("Close Button Activated!")
		v3:Close("DailyQuests")
	end)
	self:Hook()
	self:TrackQuestUpdate()
	task.spawn(function()
		while true do
			task.spawn(self.UpdateQuestCountdown, self)
			task.wait(1)
		end
	end)
end

function QuestController:PopupWelcomeBack()
	local welcomeBack = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("WelcomeBack")
	local frame = welcomeBack:WaitForChild("Frame")
	local letsGo = frame:WaitForChild("LetsGo")
	local moreRewards = frame:WaitForChild("MoreRewards")
	letsGo.Activated:Connect(function()
		v3:Close(welcomeBack.Name)
	end)
	moreRewards.Activated:Connect(function()
		v3:Close(welcomeBack.Name)
		v3:Open("DailyQuests")
	end)
	v3:Open(welcomeBack.Name)
end

v8:Connect("EnableWelcomeBackPopup", function()
	QuestController:PopupWelcomeBack()
end)

function QuestController:UpdateQuestTimer(instance, p2: number)
	local time = instance:FindFirstChild("Time")
	local text = formatTime(p2) -- equivalent call inferred; original call site unknown

	if time and p2 <= 0 then
		time.Text = self.DAILY_QUEST_EXPIRED_TEXT
	else
		time.Text = text
	end
end

function QuestController:UpdateQuestCountdown()
	local now = os.time()

	for _, v14 in self.UpdateList do
		local v15 = v14.ExpireTimestamp - now

		if v15 <= 0 then
			self:RemoveQuestFromUpdateList(v14)
		end

		self:UpdateQuestTimer(v14.QuestFrame, v15)
	end
end

return QuestController