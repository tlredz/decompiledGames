local ScoreboardModule = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ItemModule = require(script.Parent.ItemModule)
local LevelModule = require(script.Parent.LevelModule)
local XboxModule = require(script.Parent.XboxModule)

function ScoreboardModule.Commafy(value)
	repeat
		local v
		value, v = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
		k = v
	until k == 0

	return value
end

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayTweens(items)
	for _, item in pairs(items) do
		item:Play()
	end
end

local v = {
	VersusFrame = true,
	Title = true,
	LevelUp = true
}
Color3.fromRGB(125, 125, 125)
local v2 = {
	Sheriff = "Hero",
	Hero = "Sheriff"
}

local function GetCharacterIcon(childName)
	local userThumbnailAsync = _G.PlayerIcons[childName]

	if userThumbnailAsync ~= nil then
		return userThumbnailAsync
	end

	print("No Player Image: " .. tostring(childName))
	local child = game.Players:FindFirstChild(childName)
	local userId = child and child.userId or 0
	userThumbnailAsync = game.Players:GetUserThumbnailAsync(
		math.abs(userId),
		Enum.ThumbnailType.AvatarBust,
		Enum.ThumbnailSize.Size352x352
	)
	return userThumbnailAsync
end

function ScoreboardModule.DisplayScoreboard(data)
	local v3 = game.Players.LocalPlayer.PlayerGui:GetAttribute("Device") == "Phone" or game.Players.LocalPlayer.PlayerGui:GetAttribute("Device") == "Tablet"
	_G.LastRound = data.RoundCount
	local gameModeName = data.GameModeName
	local playerData = data.PlayerData
	local xPRewards = data.Rewards.XPRewards
	local totalEarnedXP = data.Rewards.TotalEarnedXP
	local winCondition = data.WinCondition
	local _ = data.RoundCount

	if gameModeName == "FreezeTag" then
		return
	end

	local scoreboard_Phone = v3 and game.Players.LocalPlayer.PlayerGui.Scoreboard_Phone or game.Players.LocalPlayer.PlayerGui.Scoreboard
	local container = (scoreboard_Phone:FindFirstChild(gameModeName) or scoreboard_Phone.BonusModes).Container
	local rewardContainer = container:FindFirstChild("RewardContainer") or container

	if rewardContainer.Name == "RewardContainer" then
		rewardContainer.Visible = false
	end

	local title = container.VersusFrame:FindFirstChild("Title") or container.Title

	for _, child in pairs(scoreboard_Phone:GetChildren()) do
		child.Visible = child == container.Parent
	end

	local UserInputService = game:GetService("UserInputService")

	if UserInputService.GamepadEnabled then
		local UserInputService2 = game:GetService("UserInputService")

		if not UserInputService2.MouseEnabled then
			title.Close.Visible = false
			title.CloseXbox.Visible = true
		end
	end

	XboxModule.Bind("CloseScoreboard", Enum.KeyCode.ButtonY, function()
		scoreboard_Phone.Enabled = false
		XboxModule.Unbind("CloseScoreboard")
	end)

	for _, frame in pairs(rewardContainer:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Visible = v[frame.Name] ~= nil

		if frame.Name == "LevelUp" then
			frame.Visible = playerData[game.Players.LocalPlayer.Name] ~= nil
		end
	end

	if data.GameModeName == "Classic" then
		local text = nil
		local v5 = nil

		for k2, v6 in pairs(data.PlayerData) do
			if v6.Role == "Sheriff" then
				v5 = k2
			elseif v6.Role == "Murderer" then
				text = k2
			end
		end

		if text == nil or v5 == nil then
			scoreboard_Phone.Enabled = false
			XboxModule.Unbind("CloseScoreboard")
			return
		else
			local container2 = container.VersusFrame.Container
			local container3 = container2.Murderer.Container
			container3.PlayerIcon.Image = GetCharacterIcon(text)
			container3.PlayerName.Text = text
			container3.Dead.Visible = playerData[text].Dead
			local container4 = container2.Sheriff.Container
			local shooter = data.Shooter or v5
			container4.PlayerIcon.Image = GetCharacterIcon(shooter)
			local role = playerData[shooter].Role
			container4[role].Visible = true
			container4[v2[role]].Visible = false
			container4.PlayerName.Text = shooter
			container4.Dead.Visible = playerData[shooter].Dead
			ItemModule.DisplayItem(container2.KnifeFrame, Sync.Weapons[playerData[text].Knife])
			ItemModule.DisplayItem(container2.GunFrame, Sync.Weapons[playerData[shooter].Gun])
			local v6

			if winCondition == "MurdererWin" then
				v6 = "MurdererWin"
			elseif winCondition == "MurdererDied" and shooter and shooter == v5 then
				v6 = "Sheriff"
			elseif winCondition == "MurdererDied" and shooter and shooter ~= v5 then
				v6 = "Hero"
			else
				v6 = "Innocents"
			end

			local v7 = winCondition == "SheriffWin" and "Sheriff" or v6 == "Innocents" and data.Was1v1 == true and "Draw" or v6

			for _, child in pairs(title:GetChildren()) do
				if child.Name ~= "Close" and child.Name ~= "CloseXbox" then
					child.Visible = child.Name == v7
				end
			end
		end
	elseif data.GameModeName == "Assassin" then
		title.Draw.Visible = winCondition == "TimeRanOut"
		title.MurdererWin.Visible = winCondition == "PlayerWon"
		local name = "No-one"

		if winCondition == "PlayerWon" then
			for k2, v5 in pairs(playerData) do
				if v5.Dead ~= false then
					continue
				end

				name = k2
				break
			end
		else
			name = game.Players.LocalPlayer.Name
		end

		title.MurdererWin.Text = name .. " has won!"
		local container2 = container.VersusFrame.Container
		local container3 = container2.Murderer.Container

		if name == "No-one" then
			container3.PlayerIcon.Image = ""
		else
			container3.PlayerIcon.Image = GetCharacterIcon(name)
		end

		container3.PlayerName.Text = name
		container3.Role.Visible = winCondition == "PlayerWon"

		if name == game.Players.LocalPlayer then
			container3.PlayerName.Text = "(You)"
		end

		if name ~= "No-one" then
			ItemModule.DisplayItem(container2.KnifeFrame, Sync.Weapons[playerData[name].Knife])
		end
	elseif data.GameModeName == "ScaryMode" then
		local text = nil

		for k2, v5 in pairs(data.PlayerData) do
			if v5.Role == "Murderer" then
				text = k2
			end
		end

		title.MurdererWin.Visible = winCondition == "MurdererWin"
		title.InnocentsEscaped.Visible = winCondition ~= "MurdererWin"
		local container2 = container.VersusFrame.Container.Murderer.Container
		container2.PlayerIcon.Image = GetCharacterIcon(text)
		container2.PlayerName.Text = text
		container2.Dead.Visible = playerData[text].Dead or winCondition == "InnocentsEscaped"
	elseif gameModeName == "FreezeTag" then
		title.Freezers.Visible = winCondition == "FreezersWin"
		title.Runners.Visible = winCondition == "RunnersWin" or winCondition == "Time"
	elseif gameModeName == "SnowballFight" then
		title.Freezers.Visible = winCondition == "FreezersWin"
		title.Runners.Visible = winCondition == "RunnersWin"
	end

	local v4 = playerData[game.Players.LocalPlayer.Name]

	if v4 == nil and not data.Was1v1 then
		container.Enabled = true
	else
		local XP = v4.XP
		local XP2 = container.LevelUp.Level.XPBar.XP
		local level = LevelModule.GetLevel(XP)
		local progressToNextLevel = LevelModule.GetProgressToNextLevel(XP)
		container.LevelUp.Level.Level.LevelText.Text = not (level < 100) and 100 or level + 1 or 100
		local v5 = progressToNextLevel > 1 and 1 or progressToNextLevel
		XP2.Size = UDim2.new(v5, XP2.Size.X.Offset, XP2.Size.Y.Scale, XP2.Size.Y.Offset)
		container.LevelUp.Coins.CoinIcon.TextLabel.Text = v4.Coins or 0
		container.LevelUp.TotalXP.XPIcon.TextLabel.Text = "+0"
		scoreboard_Phone.Enabled = true
		wait(1)

		for k2, xPReward in pairs(xPRewards) do
			wait(0.5)
			local container2 = rewardContainer[k2].Container
			container2.TextLabel.Text = xPReward.Text
			container2.XPIcon.TextLabel.Text = (xPReward.Multiplier or "+") .. ScoreboardModule.Commafy(xPReward.XP)
			container2.Parent.Visible = true
			rewardContainer.Visible = true
		end

		wait(0.5)
		local tweenValue = container.LevelUp.TotalXP.XPIcon.TextLabel.TweenValue
		tweenValue.Value = 0
		tweenValue.Changed:connect(function()
			container.LevelUp.TotalXP.XPIcon.TextLabel.Text = "+" .. ScoreboardModule.Commafy((math.floor(tweenValue.Value)))
		end)
		PlayTweens({ TweenService:Create(tweenValue, tweenInfo2, {
				Value = totalEarnedXP
			}) }) -- equivalent call inferred; original call site unknown
		local v7 = LevelModule.GetLevel(XP + totalEarnedXP) - LevelModule.GetLevel(XP)
		local level2 = LevelModule.GetLevel(XP + totalEarnedXP)
		local v8 = level2 + 1
		print("CurrentLevel", level, "TotalEarnedXP", totalEarnedXP, "LevelsGained", v7, "NewLevel", level2, "MyXP", XP)
		local _ = v8 > 100
		local _ = level2 > 100

		if v7 > 0 then
			for i = 1, v7 do
				local v9 = 0.7

				if i == 1 then
					v9 *= 1 - progressToNextLevel
				end

				PlayTweens({ TweenService:Create(
						XP2,
						TweenInfo.new(v9, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
						{
							Size = UDim2.new(1, 0, 1, 0)
						}
					) }) -- equivalent call inferred; original call site unknown
				wait(v9)
				XP2.Size = UDim2.new(0, 0, 1, 0)
				container.LevelUp.Level.Level.LevelText.Text = level + i + 1
			end
		end

		local v9 = XP + totalEarnedXP
		local v10 = v9 > 1237500 and 1237500 or v9
		local progressToNextLevel2 = LevelModule.GetProgressToNextLevel(v10)
		local v11 = progressToNextLevel2 > 1 and 1 or progressToNextLevel2 < 0 and 0 or progressToNextLevel2
		PlayTweens({ TweenService:Create(XP2, tweenInfo, {
				Size = UDim2.new(v11, 0, 1, 0)
			}) }) -- equivalent call inferred; original call site unknown
		wait(1.5)
	end

	wait(10)
	scoreboard_Phone.Enabled = false
	XboxModule.Unbind("CloseScoreboard")
end

return ScoreboardModule