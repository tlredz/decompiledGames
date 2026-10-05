local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
require3(game.ReplicatedStorage.Packages.Replion)
local v2 = require3(game.ReplicatedStorage.Packages.Net)
local v3 = require3(game.ReplicatedStorage.Shared.RankData)
local v4 = require3(game.ReplicatedStorage.Packages.Replion)
local v5 = require3(game.ReplicatedStorage.Common.Utils)
local v6 = require3(game.ReplicatedStorage.Shared.RankedSeasonData)
local localPlayer = game.Players.LocalPlayer
local remoteEvent = v2:RemoteEvent("PlayRankUpAnimation")
local rankUpAnimation = localPlayer:WaitForChild("PlayerGui"):WaitForChild("RankUpAnimation")
local sinkInput = rankUpAnimation.SinkInput
local rankFrame = rankUpAnimation.RankFrame
local whiteGlow = rankFrame.WhiteGlow
local underGlow = rankFrame.UnderGlow
local amount = rankFrame.Score.Amount
local continueLabel = rankUpAnimation.ContinueLabel
local rewardList = rankUpAnimation.RewardList

local function close()
	TweenService:Create(sinkInput, TweenInfo.new(0.25), {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(continueLabel, TweenInfo.new(0.25), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(continueLabel.UIStroke, TweenInfo.new(0.25), {
		Transparency = 1
	}):Play()
	TweenService:Create(rankFrame, TweenInfo.new(0.25), {
		Size = UDim2.new()
	}):Play()
	rewardList.Visible = false

	for _, guiBase2d in rewardList:GetChildren() do
		if guiBase2d:IsA("GuiBase2d") then
			guiBase2d:Destroy()
		end
	end

	task.wait(0.5)
	rankUpAnimation.Enabled = false
end

local function playAnimationSequence(p, p2, p3)
	local v7 = v4.Client:WaitReplion("Data")
	local currentSeason = v6.GetCurrentSeason(p2)
	local v8 = v7:Get({
		"Elo",
		p2,
		`Season{currentSeason}`,
		p3
	})
	local rank = v3.GetRank(p)
	local rank2 = v3.GetRank(v8)
	rankUpAnimation.Enabled = true
	TweenService:Create(sinkInput, TweenInfo.new(0.25), {
		BackgroundTransparency = 0.1
	}):Play()
	task.wait(0.5)
	rankFrame.RankBadge.Image = rank.Icon
	rankFrame.CurrentRank.Text = rank.Name
	amount.Text = v5.ValueConvertor:AddCommas(p)
	TweenService:Create(rankFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(0.5, 0.5)
	}):Play()
	task.wait(0.5)
	TweenService:Create(whiteGlow, TweenInfo.new(1), {
		ImageTransparency = 0
	}):Play()
	task.wait(1)
	rankFrame.RankBadge.Image = rank2.Icon
	rankFrame.CurrentRank.Text = rank2.Name
	TweenService:Create(whiteGlow, TweenInfo.new(0.5), {
		ImageTransparency = 1
	}):Play()
	task.defer(function()
		local intValue = Instance.new("IntValue")
		intValue.Value = p

		local function onChange(p4)
			amount.Text = v5.ValueConvertor:AddCommas(p4)
		end

		intValue.Changed:Connect(onChange)
		TweenService:Create(intValue, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			Value = v8
		}):Play()
		task.wait(0.5)
		intValue:Destroy()
	end)
	task.wait(0.25)
	underGlow.ImageColor3 = Color3.fromRGB(161, 175, 181)
	TweenService:Create(underGlow, TweenInfo.new(0.3), {
		ImageTransparency = 1
	}):Play()

	if rank2 and rank2.Rewards then
		local v9 = rank2.Rewards[p2][tostring(currentSeason)]
		task.wait(2)

		for k, v10 in v9 do
			local clone = script.RewardTile:Clone()
			clone.LayoutOrder = k

			if v10.Amount then
				clone.AmountLabel.Text = string.format("x%s", v5.ValueConvertor:AddCommas(v10.Amount))
			end

			if v10.DisplayName then
				clone.NameLabel.Text = v10.DisplayName
			end

			clone.Icon.Image = v10.Icon or ""
			clone.Parent = rewardList
		end

		amount.Parent.Visible = false
		rewardList.Visible = true
	end

	task.wait(2)
	continueLabel.Text = "(Tap to continue)"

	if v.MouseEnabled then
		continueLabel.Text = "(Click to continue)"
	elseif v.GamepadEnabled then
		continueLabel.Text = "(Press any button to continue)"
	end

	continueLabel.Visible = true
	task.wait(0.75)
	local v9 = false
	task.delay(20, function()
		if not v9 then
			v9 = true
			close()
		end
	end)
	v.InputBegan:Wait()

	if not v9 then
		v9 = true
		close()
	end
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(playAnimationSequence)
	end
}