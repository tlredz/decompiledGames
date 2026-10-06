local parent = script.Parent
local border = parent.Border
local lineBG = parent.LineBG
local tierIcon = border.TierIcon
local timeLabel = parent.TimeLabel
local rewardsLabel = parent.RewardsLabel
local rewards = parent.Rewards
local teleportingLabel = parent.TeleportingLabel
local leave = parent.Leave
local spike = parent.Spike
game.Players.LocalPlayer:GetMouse()
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local MaterialList = require(ReplicatedStorage.Chest.Modules.MaterialList)
local DungeonImages = require(ReplicatedStorage.Chest.Modules.DungeonImages)
local v = "C"
local v2 = nil

function RandomTest()
	local v3 = math.random(1, 5)

	if v3 == 1 then
		v = "S"
	elseif v3 == 2 then
		v = "A"
	elseif v3 == 3 then
		v = "B"
	elseif v3 == 4 then
		v = "C"
	elseif v3 == 5 then
		v = "D"
	end
end

function UpdateColor(p)
	if p == "S" then
		border.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
		})
	elseif p == "A" then
		border.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 105, 105)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 0, 0))
		})
	elseif p == "B" then
		border.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
		})
	elseif p == "C" then
		border.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 0))
		})
	elseif p == "D" then
		border.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
	end
end

function ResetTween()
	spike.Visible = false
	rewards.Visible = false
	timeLabel.Visible = false
	teleportingLabel.Visible = false
	leave.Visible = false
	rewardsLabel.Visible = false
	TweenService:Create(border, TweenInfo.new(0.4), {
		Size = UDim2.fromScale(0, 0)
	}):Play()
	TweenService:Create(lineBG, TweenInfo.new(0.4), {
		Size = UDim2.fromScale(1, 0)
	}):Play()

	for _, frame in pairs(rewards:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Size = UDim2.fromScale(0, 0)

		if frame:FindFirstChild("UIStroke") then
			frame.UIStroke.Thickness = 0
		end

		if not frame:FindFirstChild("ClickFrame") then
			continue
		end

		frame.ClickFrame.Size = UDim2.fromScale(0, 0)
		frame.ClickFrame.ImageTransparency = 0
	end
end

function Reset()
	leave.Visible = false
	spike.ImageTransparency = 1
	spike.Visible = false
	border.Visible = false
	lineBG.Visible = false
	tierIcon.Visible = false
	border.Position = UDim2.fromScale(0.5, 0.5)
	border.Size = UDim2.fromScale(1, 1)
	lineBG.Size = UDim2.fromScale(1, 0)
	tierIcon.Size = UDim2.fromScale(3, 3)
	timeLabel.Position = UDim2.fromScale(0.5, 0.575)
	timeLabel.TextTransparency = 1
	rewardsLabel.Position = UDim2.fromScale(0.5, 0.425)
	rewardsLabel.TextTransparency = 1

	for _, frame in pairs(rewards:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Size = UDim2.fromScale(0, 0)

		if frame:FindFirstChild("UIStroke") then
			frame.UIStroke.Thickness = 0
		end

		if not frame:FindFirstChild("ClickFrame") then
			continue
		end

		frame.ClickFrame.Size = UDim2.fromScale(0, 0)
		frame.ClickFrame.ImageTransparency = 0
	end

	leave.BackgroundTransparency = 1
	leave.TextTransparency = 1
	leave.Position = UDim2.fromScale(0.5, 0.5)
	teleportingLabel.TextTransparency = 1
	teleportingLabel.Position = UDim2.fromScale(0.5, 0.5)
end

function TweenReward(p)
	TweenService:Create(p, TweenInfo.new(0.3), {
		Size = UDim2.fromScale(0.9, 0.9)
	}):Play()
	TweenService:Create(p.UIStroke, TweenInfo.new(0.3), {
		Thickness = 2
	}):Play()
	TweenService:Create(p.ClickFrame, TweenInfo.new(0.3), {
		Size = UDim2.fromScale(5, 5),
		ImageTransparency = 1
	}):Play()
end

function SetUp(items)
	local WAIT_INTERVAL = 0.1
	local WAIT_INTERVAL_2 = 0.3
	UpdateColor(v)
	local image2

	if v == "S" then
		image2 = "rbxassetid://114074567040694"
	elseif v == "A" then
		image2 = "rbxassetid://133911178762475"
	elseif v == "B" then
		image2 = "rbxassetid://96525054078747"
	elseif v == "C" then
		image2 = "rbxassetid://118768051458516"
	elseif v == "D" then
		image2 = "rbxassetid://81797437039093"
	else
		image2 = "rbxassetid://81797437039093"
	end

	local dungeonImage = DungeonImages[game.PlaceId]

	if dungeonImage then
		border.MapFrame.MapIconLabel.Image = dungeonImage[v2].Image
	end

	lineBG.Visible = true
	TweenService:Create(lineBG, TweenInfo.new(0.2), {
		Size = UDim2.fromScale(1, 0.2)
	}):Play()
	task.wait(WAIT_INTERVAL)
	border.Visible = true
	TweenService:Create(border, TweenInfo.new(0.2), {
		Size = UDim2.fromScale(0.225, 0.225)
	}):Play()
	task.wait(WAIT_INTERVAL_2)
	tierIcon.Image = image2
	tierIcon.Visible = true
	TweenService:Create(tierIcon, TweenInfo.new(0.2), {
		Size = UDim2.fromScale(0.9, 0.9)
	}):Play()
	local clone = script.ClickFrame:Clone()
	_G.PU:Dust(clone, 1)
	clone.Parent = parent
	TweenService:Create(clone, TweenInfo.new(0.2), {
		Size = UDim2.fromScale(2, 2),
		ImageTransparency = 1
	}):Play()
	task.wait(0.5)
	TweenService:Create(border, TweenInfo.new(0.3), {
		Position = UDim2.fromScale(0.1, 0.5)
	}):Play()
	task.wait(WAIT_INTERVAL)
	TweenService:Create(rewardsLabel, TweenInfo.new(0.3), {
		Position = UDim2.fromScale(0.25, 0.425),
		TextTransparency = 0
	}):Play()
	task.wait(WAIT_INTERVAL)
	TweenService:Create(timeLabel, TweenInfo.new(0.3), {
		Position = UDim2.fromScale(0.25, 0.575),
		TextTransparency = 0
	}):Play()
	task.spawn(function()
		for k, item in pairs(items) do
			if item == 0 then
				continue
			end

			local image = ""
			local layoutOrder = 999

			if k == "Gem" then
				layoutOrder = 1
				image = "rbxassetid://93539612642768"
			elseif k == "beli" then
				layoutOrder = 2
				image = "rbxassetid://77439389607269"
			elseif k == "BattlepassExp" then
				layoutOrder = 3
				image = "rbxassetid://95765459362353"
			end

			if MaterialList[k] then
				image = MaterialList[k].Image
			end

			local clone2 = script.RewardFrame:Clone()
			clone2.Name = k
			clone2.LayoutOrder = layoutOrder
			clone2.ImageLabel.Image = image
			clone2.AmountLabel.Text = item
			clone2.Parent = rewards
			TweenReward(clone2)
			task.wait(0.1)
		end
	end)
	task.wait(WAIT_INTERVAL)
	spike.Visible = true
	TweenService:Create(spike, TweenInfo.new(1.5), {
		ImageTransparency = 0
	}):Play()
	task.wait(WAIT_INTERVAL_2)
	TweenService:Create(leave, TweenInfo.new(0.3), {
		Position = UDim2.fromScale(0.935, 0.5),
		BackgroundTransparency = 0,
		TextTransparency = 0
	}):Play()
	task.wait(0.2)
	TweenService:Create(teleportingLabel, TweenInfo.new(0.3), {
		Position = UDim2.fromScale(0.9, 0.5),
		TextTransparency = 0
	}):Play()
	task.wait(WAIT_INTERVAL_2)
end

Reset()
script.Parent:WaitForChild("Event").Event:Connect(function(data)
	local rewardData = data.RewardData
	local teleportBackTime = data.TeleportBackTime
	local dungeonRank = data.DungeonRank
	local dungeonClearTime = data.DungeonClearTime
	local difficulty = data.Difficulty
	local v3 = teleportBackTime and tonumber(teleportBackTime) or 5
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://91851114010629",
		Volume = 2
	})
	_G.PU:Dust(sound, 5)
	sound.Parent = script.Parent
	sound:Play()
	local v4 = math.floor(dungeonClearTime / 60)
	local v5 = dungeonClearTime % 60
	local v6 = string.format("%02d:%02d", v4, v5)
	v2 = difficulty
	v = dungeonRank
	timeLabel.Text = "Time: " .. v6
	Reset()
	task.wait(0.1)
	task.spawn(function()
		SetUp(rewardData)
	end)
	local lastTime = tick()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateCount()
		teleportingLabel.Text = "Teleporting in " .. v3 - math.floor(tick() - lastTime)
	end

	UpdateCount() -- equivalent call inferred; original call site unknown

	while tick() - lastTime < v3 do
		task.wait(0.5)
		UpdateCount() -- equivalent call inferred; original call site unknown
	end

	ResetTween()
	task.wait(0.5)
	script.Parent:Destroy()
end)

while true do
	if border.Visible then
		local v3 = task.wait() * 60
		border.UIStroke.UIGradient.Rotation = (border.UIStroke.UIGradient.Rotation + v3 * 5) % 360

		if spike.Visible then
			spike.Rotation = (spike.Rotation - v3) % 360
		end
	else
		task.wait()
		border:GetPropertyChangedSignal("Visible"):Wait()
	end
end