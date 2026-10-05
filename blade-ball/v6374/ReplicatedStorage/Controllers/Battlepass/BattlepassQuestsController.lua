local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Shared.NewQuests.Quests)
local v4 = require3(ReplicatedStorage2.Shared.NewQuests.QuestUtility)
local v5 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v6 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassViewController)
local v9 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local localPlayer = Players.LocalPlayer
local v10 = nil
local battlepass = localPlayer.PlayerGui:WaitForChild("Battlepass")
local background = battlepass.Main.Background
local quests

if v8 == "Window" then
	quests = background.Quests
else
	quests = background.TopButtons.Quests
end

local questsFrame = battlepass.QuestsFrame
local completedTemplate

if v8 == "ShowRoom" then
	completedTemplate = questsFrame.TasksBG.TasksList.CompletedTemplate
	completedTemplate.Parent = nil
else
	completedTemplate = nil
end

local taskTemplate = questsFrame.TasksBG.TasksList.TaskTemplate
taskTemplate.Parent = nil
local goldenTaskTemplate = questsFrame.TasksBG.TasksList.GoldenTaskTemplate
goldenTaskTemplate.Parent = nil
local v11 = 0
local flag = false
local v12 = {
	Active = {
		Image = "rbxassetid://71707670097247",
		HoverImage = "rbxassetid://130331079715588",
		UIStrokeColor = Color3.fromRGB(98, 62, 0)
	},
	Inactive = {
		Image = "rbxassetid://106891633286111",
		HoverImage = "rbxassetid://113415142476551",
		UIStrokeColor = Color3.fromRGB(98, 0, 5)
	}
}
local clonesByUUID = {}
local expires = workspace:GetServerTimeNow() + v4.QUEST_TIME_OFFSET.Daily
local v13 = nil
local v14 = v.new()

local function GetSeasonPassTeamMultiplier()
	local v15 = v2.Client:WaitReplion("Data")

	if not (v15 and v15:Get("SeasonPassTeamUUID")) then
		return 0
	end

	local seasonPassTeam = v15:Get("SeasonPassTeam")

	if not seasonPassTeam then
		return 0
	end

	local count = 0

	for _, member in seasonPassTeam.members do
		local playerByUserId = Players:GetPlayerByUserId(member)

		if not (playerByUserId and playerByUserId ~= localPlayer) then
			continue
		end

		local success, result = pcall(localPlayer.IsFriendsWith, localPlayer, playerByUserId.UserId)

		if success and result then
			count += 1
		end
	end

	return count * 1
end

local BattlepassQuestsController = {}

function BattlepassQuestsController.Start(_)
	v10 = v2.Client:WaitReplion("Data")
	v4.QuestRefreshed.OnClientEvent:Connect(function(p)
		if p ~= "Daily" and p ~= "Weekly" and p ~= "Limited" then
			return
		end

		BattlepassQuestsController:RefreshQuestCategory(p)
	end)
	local notificationLabel = quests.NotificationLabel

	local function updateNotificationLabel()
		notificationLabel.Label.Text = tostring(0)
		notificationLabel.Visible = false
	end

	task.spawn(updateNotificationLabel)
	v14:Connect(updateNotificationLabel)

	if v8 == "Window" and questsFrame:FindFirstChild("Close") then
		questsFrame.Close.Activated:Connect(function()
			questsFrame.Visible = false
		end)
	end

	for _, button in ipairs(questsFrame.LeftButtons:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local v15 = string.gsub(button.Name, "Quests", "")
		local v17 = button
		button.Activated:Connect(function()
			if v13 == v15 then
				return
			end

			BattlepassQuestsController:RefreshQuestCategory(v15, function()
				BattlepassQuestsController:DestroyQuestTiles()
				updateTimerLabel()
				BattlepassQuestsController:SetButton(v15, v17)
			end)
		end)
		local textLabel = button:FindFirstChild("TextLabel")

		if not textLabel then
			continue
		end

		local amount = v3.InfiniteBattlepass[v15].Amount
		textLabel.Text ..= ` ({amount})`
	end

	BattlepassQuestsController:SetButton("Daily", questsFrame.LeftButtons.DailyQuests)
	local arrow = quests:WaitForChild("Arrow")
	arrow.Position -= UDim2.fromOffset(0, 8)
	local tween = TweenService:Create(
		arrow,
		TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
		{
			Position = arrow.Position + UDim2.fromOffset(0, 8)
		}
	)
	tween:Play()
	quests.Activated:Once(function()
		tween:Cancel()
		tween:Destroy()
		local tween2 = TweenService:Create(arrow, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
			ImageTransparency = 1
		})
		tween2:Play()
		tween2.Completed:Wait()
		arrow:Destroy()
		tween2:Destroy()
	end)

	local function onXPChanged()
		if v8 == "Window" then
			return
		end

		local v15 = v10:Get("InfiniteBattlepass.Quests.XP") or 0
		local tierFromXP = v9.SeasonData.Rewards.getTierFromXP(v15)
		local v16 = tierFromXP + 1
		local rewards = v9.SeasonData.Rewards.getRewards(tierFromXP, v16, localPlayer)
		local reward = rewards[1]
		local reward2 = rewards[2]
		local xp = reward.xp
		local xp2 = reward2.xp
		questsFrame.ProgressBar.Header.Text = `Tier {v16} Progression`

		if v16 == tierFromXP then
			questsFrame.ProgressBar.Amount.Text = "MAX"
			questsFrame.ProgressBar.Fill.Size = UDim2.fromScale(1, 0.884)
		elseif tierFromXP > 0 then
			questsFrame.ProgressBar.Amount.Text = `{v6:AddCommas(v15 - xp)}/{v6:AddCommas(xp2 - xp)}`
			questsFrame.ProgressBar.Fill.Size = UDim2.fromScale(math.clamp((v15 - xp) / (xp2 - xp), 0.04, 1), 0.884)
		else
			questsFrame.ProgressBar.Amount.Text = `{v6:AddCommas(v15)}/{v6:AddCommas(xp2)}`
			questsFrame.ProgressBar.Fill.Size = UDim2.fromScale(math.clamp(v15 / xp2, 0.04, 1), 0.884)
		end
	end

	task.spawn(onXPChanged)
	v10:OnChange("InfiniteBattlepass.Quests.XP", onXPChanged)

	for _, v15 in ipairs({ "Daily", "Weekly", "Limited" }) do
		local replionPathFromQuestCategory, v16 = getReplionPathFromQuestCategory(v15)

		if not replionPathFromQuestCategory then
			continue
		end

		local v17 = v15
		v10:OnChange(v16, function()
			if flag then
				return
			end

			if v13 == v17 then
				BattlepassQuestsController:RefreshQuestCategory(v17)
			end
		end)
	end

	if battlepass.Enabled then
		BattlepassQuestsController:RefreshQuestCategory("Daily")
	else
		local connection = nil
		connection = v7:OnGuiOpen("Battlepass", function()
			connection:Disconnect()
			BattlepassQuestsController:RefreshQuestCategory("Daily")
		end)
	end

	v5.Every(1, updateTimerLabel)

	local function tryUpdateMultiplier()
		local seasonPassTeamMultiplier = GetSeasonPassTeamMultiplier()

		if seasonPassTeamMultiplier ~= v11 then
			v11 = seasonPassTeamMultiplier

			for _, v16 in { "Daily", "Weekly", "Limited" } do
				BattlepassQuestsController:RefreshQuestCategory(v16)
			end
		end
	end

	Players.PlayerAdded:Connect(tryUpdateMultiplier)
	Players.PlayerRemoving:Connect(tryUpdateMultiplier)
	pcall(function()
		StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(tryUpdateMultiplier)
	end)
	pcall(function()
		StarterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(tryUpdateMultiplier)
	end)
	task.spawn(tryUpdateMultiplier)
end

function BattlepassQuestsController:SetButton(p: string, p2)
	for _, button in ipairs(questsFrame.LeftButtons:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local active

		if button == p2 then
			active = v12.Active
		else
			active = v12.Inactive
		end

		button.Image = active.Image
		button.HoverImage = active.HoverImage
		local textLabel = button:FindFirstChild("TextLabel")

		if not textLabel then
			continue
		end

		local uIStroke = textLabel:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Color = active.UIStrokeColor
		end
	end

	questsFrame.Header.Label.Text = `{p} Quests`
end

function BattlepassQuestsController:DestroyQuestTiles()
	if flag then
		return
	end

	flag = true

	for _, v15 in clonesByUUID do
		v15:Destroy()
	end

	table.clear(clonesByUUID)
	flag = false
end

function BattlepassQuestsController:RefreshQuestCategory(p, callback)
	local replionPathFromQuestCategory, v15 = getReplionPathFromQuestCategory(p)

	if not replionPathFromQuestCategory then
		return false
	end

	local v16 = v10:Get(v15)

	if not v16 then
		return false
	end

	v13 = p
	expires = v16.Expires

	if callback then
		callback()
	end

	for _, quest in ipairs(v16.Quests) do
		local questData = v4:GetQuestData(v3.InfiniteBattlepass.Identifier, p, quest.QuestId)

		if not questData then
			continue
		end

		local value = questData.Arguments.value

		if typeof(value) == "function" then
			value = value(v10)
		end

		local v17 = math.clamp(quest.Progress, 0, value)
		local clone = clonesByUUID[quest.UUID]

		if not clone then
			if questData.Premium then
				clone = goldenTaskTemplate:Clone()
			else
				clone = taskTemplate:Clone()
			end

			local text

			if questData.Premium and v8 == "ShowRoom" then
				text = `[PREMIUM] {questData.DisplayName}`
			else
				text = questData.DisplayName
			end

			clone.Frame.TaskName.Text = text
			clone.Frame.XpBar.Label.Text = questData.Currency:upper()
			clone.Frame.XpBar.Amount.Text = questData.Reward
			clone.Parent = questsFrame.TasksBG.TasksList
			clonesByUUID[quest.UUID] = clone
		end

		if quest.Redeemed then
			clone.LayoutOrder = value + 100000
		else
			clone.LayoutOrder = questData.Reward * -100 + value
		end

		local score = clone.Frame.Score
		local text2

		if v8 == "Window" then
			text2 = `{math.floor(v17)}/{value}`
		else
			text2 = `Progress: {math.floor(v17)}/{value}`
		end

		score.Text = text2
		clone.Frame.Multiplier.Label.Text = `{v11}x`
		clone.Frame.Multiplier.Visible = v11 > 0

		if v8 == "ShowRoom" then
			local v19 = math.clamp(v17 / value, 0.04, 1)
			local v20 = v17 == 0
			clone.Frame.FilledBar.Visible = not v20
			clone.Frame.FilledBar.Size = UDim2.fromScale(v19, 0.884)
			local image

			if quest.Redeemed then
				image = completedTemplate.Claimed.Image
			else
				image = taskTemplate.Claimed.Image
			end

			clone.Frame.Claimed.Image = image
			clone.Frame.XpBar.Visible = not quest.Redeemed
		end

		clone.Frame.Claimed.Visible = quest.Redeemed
	end

	return true
end

function updateTimerLabel()
	if battlepass.Enabled then
		local serverTimeNow = workspace:GetServerTimeNow()
		local restock = questsFrame.TimerBG.Restock
		local text

		if v8 == "Window" then
			text = v6:FormatTimeHHMMSS(expires - serverTimeNow)
		else
			text = `Resets in: {v6:FormatTimeHHMMSS(expires - serverTimeNow)}`
		end

		restock.Text = text
	end
end

function getReplionPathFromQuestCategory(p: string)
	for k, v15 in v4:GetPaths(v3.InfiniteBattlepass.ReplionPath) do
		local parts = v15:split(".")
		local v16 = parts and parts[#parts]

		if v16 and v16 == p then
			return k, v15
		end
	end
end

return BattlepassQuestsController