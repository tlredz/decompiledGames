local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GamepadService = game:GetService("GamepadService")
game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.ClientGameModules.TextUtility)
local maid = require3(ReplicatedStorage2.Common.Utils).Maid
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v5 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v6 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v7 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
require3(ReplicatedStorage2.Shared.NewQuests.Quests)
local v8 = require3(ReplicatedStorage2.Shared.ThemedQuests.ThemedQuestsData)
local v9 = require3(ReplicatedStorage2.Shared.Quests)
local playerGui = Players.LocalPlayer.PlayerGui
local newDailyQuests = playerGui:WaitForChild("NewDailyQuests")
local holder = newDailyQuests.Holder
local alert = playerGui:WaitForChild("HUD"):WaitForChild("LeftFrame"):FindFirstChild("DailyQuestsPage", true):WaitForChild("Alert")
local questArrow = playerGui.HUD.QuestArrow
local remoteEvent = v2:RemoteEvent("ClaimDailyQuest")
local remoteEvent2 = v2:RemoteEvent("ClaimDailyChest")
local v10 = false
local QuestsController = {
	_questsMaid = maid.new()
}

local function isThemedQuestsEnabled()
	local v11 = v.Client:WaitReplion("Data")

	if not v11 or workspace:GetServerTimeNow() > v8.EndTimestamp then
		return false
	end

	local v12 = v11:Get({
		"ThemedQuests",
		"Quests",
		"Limited",
		"Quests"
	})

	if not v12 then
		return false
	end

	for _, v13 in v12 do
		if not v13.Redeemed then
			return true
		end
	end

	return false
end

local function updateNumClaimableQuests()
	local v11 = v.Client:WaitReplion("Data")

	if isThemedQuestsEnabled() then
		return
	end

	local count = 0
	local count2 = 0

	for _, v12 in v11:GetExpect("CurrentQuests") do
		local v13 = v9[v12]
		local v14 = math.min((v11:Get({ "QuestStats", v13.stat }) or 0) / v13.goal, 1) >= 1
		local v15 = v11:Find("QuestsAwarded", v12) ~= nil

		if not v14 then
			continue
		end

		count += 1

		if not v15 then
			count2 += 1
		end
	end

	local v12 = 1

	for _, uIListLayout in holder.Quests.Daily.BG.Checks:GetChildren() do
		if uIListLayout:IsA("UIListLayout") then
			continue
		end

		uIListLayout.Check.Visible = v12 <= count - count2
		v12 += 1
	end

	if count - count2 >= 3 then
		holder.Quests.Daily.Intermediate.ImageColor3 = Color3.new(1, 1, 1)
	else
		holder.Quests.Daily.Intermediate.ImageColor3 = Color3.fromRGB(157, 157, 157)
	end

	alert.Visible = count2 > 0
	holder.AutoCompleteButton.Visible = count < 3
end

function QuestsController:_createQuest(name)
	local v11 = v9[name]
	local maid2 = maid.new()
	local clone = script.QuestTemplate:Clone()
	clone.Name = name
	clone.QuestTitle.Text = string.format(v11.text, v11.goal)
	local _, v12 = next(v11.rewards)
	local v13 = v.Client:WaitReplion("Data")
	clone.Rewards.Amount.Text = `+{v3.commify(v12.amount)}`
	clone.Intermediate.Activated:Connect(function()
		if v13:Find("AwardedQuests", name) then
			return
		end

		remoteEvent:FireServer(name)
	end)
	clone.Parent = holder.Quests

	local function updateQuestProgress(p2: number)
		local v14 = math.min(p2 / v11.goal, 1)
		local active = v14 >= 1
		clone.ProgressBar.Bar:TweenSize(
			UDim2.fromScale(v14, 1),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quart,
			0.75,
			true
		)
		clone.ProgressBar.ProgressValue.Text = `{math.min(p2, v11.goal)}/{v11.goal}`
		local intermediate = clone.Intermediate
		local imageColor

		if active then
			imageColor = Color3.fromRGB(255, 255, 255)
		else
			imageColor = Color3.fromRGB(150, 150, 150)
		end

		intermediate.ImageColor3 = imageColor
		clone.Intermediate.Active = active
		updateNumClaimableQuests()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateQuestClaimed(visible: boolean)
		clone.Intermediate.Visible = not visible
		clone.CompletedOverlay.Visible = visible
	end

	maid2:GiveTask(clone)
	maid2:GiveTask(v13:OnArrayInsert("QuestsAwarded", function(_, p2)
		if p2 ~= name then
			return
		end

		updateQuestClaimed(true) -- equivalent call inferred; original call site unknown
		updateNumClaimableQuests()
	end))
	maid2:GiveTask(v13:OnChange({ "QuestStats", v11.stat }, function(p2)
		updateQuestProgress(p2)
	end))
	updateQuestProgress(v13:Get({ "QuestStats", v11.stat }) or 0)
	updateQuestClaimed(v13:Find("QuestsAwarded", name) ~= nil) -- equivalent call inferred; original call site unknown
	self._questsMaid[name] = maid2
end

function QuestsController:_updateQuestArrowVisibility()
	local enabled = newDailyQuests.Enabled
	questArrow.Visible = not enabled and v10 and not v7.Condensed.CurrentState
	newDailyQuests.Holder.Arrow.Visible = enabled and v10 and not v7.Condensed.CurrentState
end

function QuestsController:SetToggleEnabled(flag: boolean)
	if v6:IsMobile() then
		flag = false
	end

	v10 = flag
	self:_updateQuestArrowVisibility()
end

function QuestsController:Close()
	if isThemedQuestsEnabled() then
		v4:Close("ThemedQuests")
	else
		v4:Close("DailyQuests")
	end
end

function QuestsController:Start()
	local v11 = v.Client:WaitReplion("Data")

	for _, v12 in v11:GetExpect("CurrentQuests") do
		self:_createQuest(v12)
	end

	if v11:Get("DontShowDailyQuestChest") then
		v11:OnChange("DontShowDailyQuestChest", function(flag: boolean)
			holder.Quests.Daily.Visible = not flag
		end)
	end

	holder.Quests.Daily.Visible = not v11:Get("DontShowDailyQuestChest")

	local function updateDailyChest()
		local dailyQuestChestClaimed = v11:Get("DailyQuestChestClaimed")
		holder.Quests.Daily.CompletedOverlay.Visible = dailyQuestChestClaimed
		holder.Quests.Daily.Intermediate.Visible = not dailyQuestChestClaimed
	end

	v11:OnChange("DailyQuestChestClaimed", updateDailyChest)
	task.spawn(updateDailyChest)
	v7.Condensed.StateChanged:Connect(function()
		self:_updateQuestArrowVisibility()
	end)
	v4:OnGuiOpen("DailyQuests", function(p)
		if isThemedQuestsEnabled() then
			v4:Open("ThemedQuests")
			return
		end

		p.Enabled = false
		newDailyQuests.Enabled = true
		self:_updateQuestArrowVisibility()
		local guiObject = newDailyQuests:FindFirstChildWhichIsA("GuiObject", true)

		if guiObject then
			GamepadService:EnableGamepadCursor(guiObject)
		end
	end)
	v4:OnGuiClose("DailyQuests", function()
		if isThemedQuestsEnabled() then
			v4:Close("ThemedQuests")
			return
		end

		newDailyQuests.Enabled = false
		self:_updateQuestArrowVisibility()
	end)
	v11:OnChange("CurrentQuests", function(items)
		self._questsMaid:DoCleaning()

		for _, item in items do
			self:_createQuest(item)
		end

		updateNumClaimableQuests()
	end)
	updateNumClaimableQuests()
	holder.AutoCompleteButton.Activated:Connect(function()
		v5:PromptPurchase(1608142521, Enum.InfoType.Product)
	end)
	holder.Quests.Daily.Intermediate.Activated:Connect(function()
		remoteEvent2:FireServer()
	end)
	holder.RefreshQuestsButton.Activated:Connect(function()
		v5:PromptPurchase(1606946101, Enum.InfoType.Product)
	end)
	holder.CloseButton.Activated:Connect(function()
		self:Close()
	end)
	questArrow.Activated:Connect(function()
		v4:Open("DailyQuests")
	end)
	newDailyQuests.Holder.Arrow.Activated:Connect(function()
		v4:Close("DailyQuests")
	end)
	v6.OnChange:Connect(function()
		if v6:IsMobile() then
			self:SetToggleEnabled(false)
		end
	end)

	if isThemedQuestsEnabled() then
		v11:OnChange({ "ThemedQuests", "Opened" }, updateNumClaimableQuests)
	end
end

return QuestsController