local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v3 = require3(ReplicatedStorage2.Shared.WelcomeBackData)
local v4 = require3(ReplicatedStorage2.Shared.NewQuests.Quests)
local v5 = require3(ReplicatedStorage2.Shared.NewQuests.QuestUtility)
local playerGui = Players.LocalPlayer.PlayerGui
local v6 = nil
v:RemoteFunction("PurchaseWelcomeBackShopItem")
local remoteFunction = v:RemoteFunction("ClaimWelcomeBackMilestone")
local remoteFunction2 = v:RemoteFunction("RedeemWelcomeBackFinalMilestone")
local scrolling = playerGui:WaitForChild("NewWelcomeBack").Frame.Views.Quests.Scrolling
local maxMilestoneXP = v3.MaxMilestoneXP
local welcomeBackMilestones = v3.WelcomeBackMilestones
local milestoneFinalRewards = v3.MilestoneFinalRewards
local v7 = {
	Selected = {
		Image = "rbxassetid://17260717560",
		HoverImage = "rbxassetid://17260717844",
		UIStrokeColor = Color3.fromRGB(91, 46, 0)
	},
	Unselected = {
		Image = "rbxassetid://17260716134",
		HoverImage = "rbxassetid://17260716555",
		UIStrokeColor = Color3.fromRGB(28, 50, 99)
	}
}
local buttons = {}
local v8 = {}
local clones = {}
local v9 = 1
local v10 = nil
local milestoneTemplate = scrolling.TopItems.MilestoneTemplate
milestoneTemplate.Parent = nil
local questTemplate = scrolling.Scrolling.Content.QuestTemplate
questTemplate.Parent = nil
local claimedTemplate = scrolling.Scrolling.Content.ClaimedTemplate
claimedTemplate.Parent = nil
local Quests = {
	Start = function(_)
		v6 = v2.Client:WaitReplion("Data")
		v6:OnChange("WelcomeBackEvent.ClaimedMilestones", UpdateAllMilestoneTiles)
		UpdateAllMilestoneTiles(v6:Get("WelcomeBackEvent.ClaimedMilestones"))
		v6:OnChange("WelcomeBackEvent.Quests.Main.Daily", function(_)
			local v11 = v6:Get("WelcomeBackEvent.Quests.Main.Daily")
			OnQuestsChanged(v11)
		end)
		OnQuestsChanged(v6:Get("WelcomeBackEvent.Quests.Main.Daily"))
		v6:OnChange("WelcomeBackEvent.Quests.XP", OnXPChanged)
		OnXPChanged(v6:Get("WelcomeBackEvent.Quests.XP"))

		for _, button in ipairs(scrolling.Days:GetChildren()) do
			if not button:IsA("ImageButton") then
				continue
			end

			local v11 = tonumber((string.gsub(button.Name, "Day", ""))) or 1
			button.MouseButton1Click:Connect(function()
				SelectButton(v11)
			end)
			buttons[v11] = button
		end

		local v11 = v6:Get("WelcomeBackEvent.Quests.Main.Daily.CurrentDay") or 1
		SelectButton(v11)
	end
}

function SelectButton(p: number)
	v10 = p
	local v11 = buttons[p]
	SelectDayButton(v11)
	DestroyQuestTiles()
end

function UpdateQuestTile(data)
	local questData = v5:GetQuestData(v4.WelcomeBack.Identifier, "Daily", data.QuestId)

	if not questData then
		return
	end

	local value = questData.Arguments.value

	if typeof(value) == "function" then
		value = value(v6)
	end

	local v11 = data.Redeemed and 100 or 0
	local text = data.Redeemed and "Claimed!" or `{math.min(data.Progress, value)}/{value}`
	local clone = v8[data.QuestId]

	if clone and clone.Name == questTemplate.Name and data.Redeemed then
		clone:Destroy()
		v8[data.QuestId] = nil
		clone = nil
	end

	if not clone then
		local v13

		if data.Redeemed then
			v13 = claimedTemplate
		else
			v13 = questTemplate
		end

		clone = v13:Clone()

		if questData.SecondCurrency == "ItemReward" and typeof(questData.SecondReward) == "table" then
			clone.Amount.Text = `+{questData.SecondReward.Value}`
		end

		if data.Redeemed then
			clone.Claimed.Visible = true
		else
			local mouseButton1ClickConnection = nil
			mouseButton1ClickConnection = clone.Claim.MouseButton1Click:Connect(function()
				if v5.RedeemQuestsType:InvokeServer("WelcomeBack", "Daily", data.QuestId) and mouseButton1ClickConnection.Connected then
					mouseButton1ClickConnection:Disconnect()
				end
			end)
			clone.Destroying:Once(function()
				if mouseButton1ClickConnection.Connected then
					mouseButton1ClickConnection:Disconnect()
				end
			end)
		end

		clone.Parent = scrolling.Scrolling.Content
		v8[data.QuestId] = clone
	end

	if clone then
		local v13 = math.clamp(data.Progress / value, 0, 1)

		if not data.Redeemed then
			clone.Unclaimed.Visible = v13 < 1
			clone.Claim.Visible = v13 == 1
		end

		clone.LayoutOrder = data.QuestId + v11
		clone.Title.Text = `{questData.DisplayName} ({questData.Reward} XP)`
		clone.ProgressBar.Title.Text = text
		clone.ProgressBar.Fill.Size = UDim2.fromScale(v13, 1)
	end
end

function OnQuestsChanged(p)
	if not p then
		return
	end

	local v11 = v6:Get("WelcomeBackEvent.Quests.Main.Daily.CurrentDay") or 1
	local v12 = v10 or v11

	if v12 == v11 then
		for _, quest in ipairs(p.Quests) do
			UpdateQuestTile(quest)
		end
	else
		local v13 = {}

		if v4.WelcomeBack.Daily then
			local redeemed = v12 < v11
			local progress = v12 < v11 and 100000000000 or 0

			for i, quest in ipairs(v4.WelcomeBack.Daily.Quests) do
				if quest.OrderedDay == v12 then
					table.insert(v13, {
						QuestId = i,
						Progress = progress,
						Redeemed = redeemed,
						UUID = "REPLICA",
						GENERATED = 0
					})
				end
			end
		end

		for _, v14 in ipairs(v13) do
			UpdateQuestTile(v14)
		end
	end

	if v10 then
		scrolling.Scrolling.PreviousDay.Visible = v11 < v10
	else
		scrolling.Scrolling.PreviousDay.Visible = false
	end

	local v13 = v6:Get("WelcomeBackEvent.ClaimedMilestones")
	UpdateAllMilestoneTiles(v13)
end

function DestroyQuestTiles()
	for _, v11 in v8 do
		v11:Destroy()
	end

	table.clear(v8)
	local v11 = v6:Get("WelcomeBackEvent.Quests.Main.Daily")

	if v11 then
		OnQuestsChanged(v11)
	end
end

function UpdateMilestoneTile(p: number, p2: number, p3)
	local welcomeBackMilestone = welcomeBackMilestones[p]
	local visible = p3[p]
	local count = #welcomeBackMilestones
	local clone = clones[p]

	if not clone then
		clone = milestoneTemplate:Clone()
		clone.ItemName.Text = welcomeBackMilestone.Reward.DisplayName or ""
		clone.Vector.Image = welcomeBackMilestone.Reward.Icon or ""
		clone.Change.Visible = p == count

		if not visible then
			local mouseButton1ClickConnection = nil
			mouseButton1ClickConnection = clone.Claim.MouseButton1Click:Connect(function()
				local v12

				if p == count then
					if v9 then
						v12 = remoteFunction2:InvokeServer(v9)
					else
						_G.SendNotification("You do not have a reward selected!")
						return
					end
				else
					v12 = remoteFunction:InvokeServer(p)
				end

				if v12 then
					mouseButton1ClickConnection:Disconnect()
				end
			end)

			if p == count then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function cycleFinalReward()
					local v12 = (v9 or 1) + 1
					local v13 = #milestoneFinalRewards < v12 and 1 or v12
					v9 = v13
					local milestoneFinalReward = milestoneFinalRewards[v13]

					if milestoneFinalReward then
						clone.ItemName.Text = milestoneFinalReward.DisplayName
						clone.Vector.Image = milestoneFinalReward.Icon or ""
					end
				end

				clone.Change.MouseButton1Click:Connect(function()
					if not visible then
						cycleFinalReward() -- equivalent call inferred; original call site unknown
					end
				end)
			end
		end

		clone.Parent = scrolling.TopItems
		clones[p] = clone
	end

	if clone then
		if p == count then
			clone.Change.Visible = not visible
		else
			clone.Change.Visible = false
		end

		clone.Claimed.Visible = visible
		clone.Claim.Visible = not visible and welcomeBackMilestone.XP <= p2
		clone.ItemName.Visible = not visible and p2 < welcomeBackMilestone.XP or visible
	end
end

function UpdateAllMilestoneTiles(p)
	if not p then
		return
	end

	local v11 = v6:Get("WelcomeBackEvent.Quests.XP") or 0

	for i in ipairs(welcomeBackMilestones) do
		UpdateMilestoneTile(i, v11, p)
	end
end

function OnXPChanged(value: number?)
	local v11 = value or 0

	if v11 then
		local v12 = math.clamp(v11 / maxMilestoneXP, 0, 1)
		scrolling.ProgressBar.Fill.Size = UDim2.fromScale(v12, 1)

		for i, welcomeBackMilestone in ipairs(welcomeBackMilestones) do
			local child = scrolling.ProgressBar.Places:FindFirstChild((`Circle{i}`))

			if child then
				child.Text.Text = tostring(welcomeBackMilestone.XP)
			end
		end

		local v13 = v6:Get("WelcomeBackEvent.ClaimedMilestones")
		UpdateAllMilestoneTiles(v13)
	end
end

function SelectDayButton(p)
	for _, v11 in ipairs(buttons) do
		local selected

		if v11 == p then
			selected = v7.Selected
		else
			selected = v7.Unselected
		end

		v11.Image = selected.Image
		v11.HoverImage = selected.HoverImage
		local uIStroke = v11:FindFirstChildWhichIsA("UIStroke", true)

		if uIStroke then
			uIStroke.Color = selected.UIStrokeColor
		end
	end
end

return Quests