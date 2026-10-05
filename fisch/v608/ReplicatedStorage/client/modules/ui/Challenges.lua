game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("SoundService")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local packages = ReplicatedStorage.packages
local v = { "common", "rare", "grand" }
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local QuestController = require(legacyControllers.QuestController)
local NotificationController = require(legacyControllers.NotificationController)
local HudController = require(legacyControllers.HudController)
local DataController = require(legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local QuestShared = require(modules.QuestShared)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local remoteFunction = Net:RemoteFunction("Challenges/Reroll", -1)
local remoteFunction2 = Net:RemoteFunction("Challenges/Claim", -1)
local remoteEvent = Net:RemoteEvent("Challenges/OpenMenu")
local anno_localthought = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")
local challenges2 = HudController:GetSafeZone():WaitForChild("Challenges2")
local currentQuest = challenges2:WaitForChild("currentQuest")
local rewardContainer = challenges2:WaitForChild("rewardContainer")
local timeLimit = challenges2:WaitForChild("timeLimit")
local loadingLabel = challenges2:WaitForChild("loadingLabel")
local claimButton = currentQuest:WaitForChild("claimButton")
local Challenges = {}
local clones = {}
local v2 = {}
local v3 = nil
local v4 = nil
local v5 = false
local maid = Trove.new()
local maid2 = maid:Extend()
local maid3 = maid:Extend()

function Challenges.UpdateRewards()
	if not v4 then
		return
	end

	maid2:Clean()
	table.clear(clones)

	for _, childName in v do
		v2[childName] = #clones
		local v6 = v4.RewardPool[childName]
		local child = script.rewardTemplates:FindFirstChild(childName)
		local child2 = rewardContainer.rewardList:FindFirstChild(childName)
		local text = math.round(v4.RewardGroupChances[childName] / #v6) .. "%"

		for i, v8 in ipairs(v6) do
			local clone = child:Clone()
			clone.LayoutOrder = i
			clone.chance.Text = text
			local rewardDescription, image = QuestController:GetRewardDescription(v8.RewardData)

			if rewardDescription then
				clone.tooltip.Text = rewardDescription
			end

			if image then
				clone.rewardIcon.ImageLabel.Image = image
			end

			maid2:Add(clone.MouseEnter:Connect(function()
				clone.tooltip.Visible = true
			end))
			local v11 = clone
			maid2:Add(clone.MouseLeave:Connect(function()
				v11.tooltip.Visible = false
			end))
			clone.Parent = child2
			maid2:Add(clone)
			table.insert(clones, clone)
		end
	end
end

function Challenges.UpdateCycleTimer()
	if not v4 then
		return
	end

	local v6 = {}
	local v7 = (workspace:GetServerTimeNow() - v4.CycleOffset) // v4.CycleDuration * v4.CycleDuration + v4.CycleOffset + v4.CycleDuration
	local v8 = math.max((v3 == "Weekly" and v7 < 1781481600 and 1781481600 or v7) - workspace:GetServerTimeNow(), 0)
	local v9 = v8 // 86400
	local v10

	if v8 >= 86400 then
		table.insert(v6, (`{v9}d`))
		v10 = v8 % 86400
	else
		v10 = v8
	end

	local v11 = v10 // 3600

	if v8 >= 3600 then
		table.insert(v6, (`{v11}h`))
		v10 %= 3600
	end

	local v12 = v10 // 60

	if v8 >= 60 then
		table.insert(v6, (`{v12}m`))
		v10 %= 60
	end

	table.insert(v6, (`{math.round(v10)}s`))
	timeLimit.resetText.Text = `Resets in {table.concat(v6, " ")}`
end

function Challenges.LoadTheme()
	if not v4 then
		return
	end

	challenges2.Header.Label.Text = `{v3} Challenges`
	timeLimit.header.Text = `{v3} Completion Progress`
	local color

	if v3 == "Daily" then
		color = Color3.fromRGB(31, 16, 16)
	else
		color = Color3.fromRGB(15, 21, 31)
	end

	for _ = 1, v4.QuestCount - 1 do
		local clone = script.dividerTemplate:Clone()
		clone.BackgroundColor3 = color
		clone.Parent = timeLimit.bar.dividerContainer
		maid:Add(clone)
	end

	timeLimit.bar.UIStroke.Color = color

	if v3 == "Daily" then
		timeLimit.bar.fill.UIGradient.Color = ColorSequence.new(
			Color3.fromRGB(255, 112, 122),
			Color3.fromRGB(255, 144, 187)
		)
		timeLimit.bar.BackgroundColor3 = Color3.fromRGB(56, 29, 29)
		timeLimit.bar.progressText.TextColor3 = Color3.fromRGB(255, 206, 206)
		timeLimit.resetText.TextColor3 = Color3.fromRGB(255, 123, 125)
	elseif v3 == "Weekly" then
		timeLimit.bar.fill.UIGradient.Color = ColorSequence.new(
			Color3.fromRGB(102, 156, 255),
			Color3.fromRGB(140, 201, 255)
		)
		timeLimit.bar.BackgroundColor3 = Color3.fromRGB(30, 38, 56)
		timeLimit.bar.progressText.TextColor3 = Color3.fromRGB(192, 231, 255)
		timeLimit.resetText.TextColor3 = Color3.fromRGB(114, 175, 255)
	end

	maid:Add(playerDataReplicator:Listen({ "Challenges", v3, "CycleProgress" }, Challenges.UpdateCompletion))
end

function Challenges.UpdateCompletion()
	if not (v4 and v3) then
		return
	end

	local index = playerDataReplicator:Index({ "Challenges", v3, "CycleProgress" })
	timeLimit.bar.progressText.Text = `{index} / {v4.QuestCount}`
	TweenService:Create(timeLimit.bar.fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
		Size = UDim2.fromScale(index / v4.QuestCount, 1)
	}):Play()
	Challenges.UpdateCycleTimer()
end

local v6 = {
	AsOne = true
}

function Challenges.UpdateQuest()
	if not (v4 and v3) then
		return
	end

	maid3:Clean()
	currentQuest.Visible = false
	loadingLabel.Text = "Loading Quest..."
	loadingLabel.Visible = true
	local index = playerDataReplicator:Index({ "Challenges", v3, "ActiveQuestId" })

	if index then
		local questInstance = QuestShared:GetQuestInstance(Players.LocalPlayer, index)

		if not questInstance then
			return
		end

		local _1 = questInstance:WaitForChild("1")
		local questData = QuestShared:GetQuestData(Players.LocalPlayer, index)
		local goalDescription = QuestController:GetGoalDescription(questInstance, _1, 1, true)
		local rewardDescription = QuestController:GetRewardDescription(questData.Rewards, v6)
		currentQuest.questDesc.Text = goalDescription or ""
		currentQuest.rewardDesc.Text = `Reward: {rewardDescription or ""}`

		local function updateProgress()
			local v7 = math.clamp(_1.Value, 0, questData.List[1][2])
			currentQuest.bar.fill.Size = UDim2.fromScale(v7 / questData.List[1][2], 1)
			currentQuest.bar.progressText.Text = `{NumberUtils:Comma(v7)} / {NumberUtils:Comma(questData.List[1][2])}`
			local v8 = _1.Value >= questData.List[1][2]
			v5 = v8
			local color

			if v8 then
				color = Color3.fromRGB(107, 255, 142)
			else
				color = Color3.fromRGB(255, 225, 76)
			end

			claimButton.buttonText.TextColor3 = color
			claimButton.corner.ImageColor3 = color
			claimButton.UIStroke.Color = color

			if v8 then
				claimButton.buttonText.Text = "Claim"
				return
			end

			local v9 = playerDataReplicator:Index({ "Challenges", v3, "RerollCount" }) or 0
			claimButton.buttonText.Text = `Reroll ({v9}/{v4.MaxRerollCount})`
		end

		maid3:Add(_1.Changed:Connect(updateProgress))
		updateProgress()
		currentQuest.Visible = true
		loadingLabel.Visible = false
	elseif playerDataReplicator:Index({ "Challenges", v3, "CycleProgress" }) >= v4.QuestCount then
		loadingLabel.Text = "No Quest Available"
	end
end

function Challenges.LoadQuest()
	if not (v4 and v3) then
		return
	end

	local questActive = legacyLocalPlayerData.fetch():WaitForChild("QuestActive")
	maid:Add(questActive.ChildAdded:Connect(function(child)
		if child.Name == playerDataReplicator:Index({ "Challenges", v3, "ActiveQuestId" }) then
			Challenges.UpdateQuest()
		end
	end))
	maid:Add(questActive.ChildRemoved:Connect(function(child)
		if child.Name == playerDataReplicator:Index({ "Challenges", v3, "ActiveQuestId" }) then
			Challenges.UpdateQuest()
		end
	end))
	maid:Add(playerDataReplicator:Listen({ "Challenges", v3, "ActiveQuestId" }, Challenges.UpdateQuest))
	Challenges.UpdateQuest()
end

function Challenges.SpinReward(p, p2, _)
	local v7 = v2[p] + p2
	local v8 = 0.05

	for _, v9 in clones do
		v9.spinStroke.Visible = false
	end

	local v9 = nil

	for i = math.random(10, 14), math.random(1, 2), -1 do
		local v10 = (v7 - i) % #clones + 1
		local v11 = clones[v10]

		if not v11 then
			warn((`No reward frame at index {v10}`))
			return
		end

		if not v11.Parent then
			return
		end

		if v9 and v9.Parent then
			v9.spinStroke.Visible = false
		end

		v11.spinStroke.UIStroke.Transparency = 0
		v11.spinStroke.corner.ImageTransparency = 0
		v11.spinStroke.Visible = true
		script.Tick:Play()
		task.wait(v8)
		v8 *= 1.25
		v9 = v11
	end

	local v10 = clones[v7]

	if not (v10 and v10.Parent) then
		return
	end

	local spinStroke = v10.spinStroke

	if v9 and v9.Parent then
		v9.spinStroke.Visible = false
	end

	spinStroke.Visible = true
	spinStroke.UIStroke.Transparency = 0
	spinStroke.corner.ImageTransparency = 0
	spinStroke.glowOverlay.ImageTransparency = 0.5
	spinStroke.glowOverlay.SliceScale = 0.75
	spinStroke.glowOverlay.UIGradient.Offset = Vector2.new(0, -1)
	spinStroke.glowOverlay.inner.UIGradient.Offset = Vector2.new(0, -1)
	spinStroke.glowOverlay.Visible = true
	TweenService:Create(spinStroke.glowOverlay.UIGradient, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
		Offset = Vector2.new(0, 1)
	}):Play()
	TweenService:Create(spinStroke.glowOverlay, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {
		SliceScale = 0.1
	}):Play()
	TweenService:Create(spinStroke.glowOverlay.inner.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
		Offset = Vector2.new(0, 1)
	}):Play()
	TweenService:Create(spinStroke.UIStroke, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Transparency = 1
	}):Play()
	TweenService:Create(spinStroke.corner, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}):Play()
	script.Success:Play()
end

function Challenges.Load(p: string, p2)
	v4 = p2
	v3 = p
	maid:Clean()
	maid:Add(maid2)
	maid:Add(maid3)
	Challenges.LoadTheme()
	Challenges.UpdateRewards()
	Challenges.UpdateCompletion()
	Challenges.LoadQuest()
	maid:Add(task.spawn(function()
		while task.wait(1) do
			Challenges.UpdateCycleTimer()
		end
	end))
	challenges2.Visible = true
end

function Challenges.init()
	playerDataReplicator:WaitForLoaded()
	local v7 = false
	claimButton.Activated:Connect(function()
		if v7 or not v3 then
			return
		end

		v7 = true

		if v5 then
			NotificationController:PauseNotifications("ChallengeSpin")
			local v8, v9, v10 = remoteFunction2:InvokeServer(v3)

			if v8 and v9 and v10 then
				Challenges.SpinReward(v8, v9, v10)
			end

			NotificationController:UnpauseNotifications("ChallengeSpin")
		elseif playerDataReplicator:Index({ "Challenges", v3, "RerollCount" }) <= 0 then
			anno_localthought:Fire("You've reached the reroll limit for this quest!")
		else
			remoteFunction:InvokeServer(v3)
		end

		v7 = false
	end)
	challenges2:GetPropertyChangedSignal("Visible"):Connect(function()
		if not challenges2.Visible then
			maid:Clean()
		end
	end)
	remoteEvent.OnClientEvent:Connect(Challenges.Load)
end

return Challenges