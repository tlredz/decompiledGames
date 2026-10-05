local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3(game.ReplicatedStorage.Packages.Replion)
require3(game.ReplicatedStorage.Packages.Net)
local v2 = require3(game.ReplicatedStorage.ClientGameModules.GuiHandler)
local v3 = require3(game.ReplicatedStorage.Shared.RankData)
local v4 = require3(game.ReplicatedStorage.Shared.RankedSeasonData)
local window = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("RankMenu").Window
local currentRankLabel = window.CurrentRankLabel
local progressBar = window.ProgressBar
local progressBarLabel = window.ProgressBarLabel
local toNextRankLabel = window.ToNextRankLabel
local icon = window.BadgeFrame.Icon
local glow = window.BadgeFrame.Glow
local rewardAmount = window.RewardAmount
local rewardNameLabel = window.RewardNameLabel
local rewardIcon = window.RewardIcon
local RankMenuController = {}

function RankMenuController.Start(_)
	local v5 = v.Client:WaitReplion("Data")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateProgressBar(p)
		progressBar.Fill.Size = UDim2.fromScale(p, 1)
		progressBarLabel.Text = string.format("%s%%", (math.floor(p * 100)))
	end

	local function selectMode(p)
		local rankedType = v4.GetRankedType()
		local currentSeason = v4.GetCurrentSeason(rankedType)
		local v7 = v5:Get({
			"Elo",
			rankedType,
			`Season{currentSeason}`,
			p
		})
		local rank = v3.GetRank(v7)
		currentRankLabel.Text = rank.Name
		icon.Image = rank.Icon
		glow.ImageColor3 = rank.TextColor

		if rank.Name == v3.RankList[#v3.RankList].Name then
			toNextRankLabel.Text = "You've achieved the highest rank!"
			progressBar.Fill.Size = UDim2.fromScale(1, 1)
			progressBarLabel.Text = string.format("%s%%", 100)
			rewardIcon.Visible = false
			rewardNameLabel.Visible = false
			rewardAmount.Visible = false
			window.MaxRewardLabel.Visible = true
		else
			local nextRank = v3.GetNextRank(v7)
			local minimumElo = nextRank.MinimumElo
			toNextRankLabel.Text = string.format("%s / %s Elo To Next Rank", v7, minimumElo)
			local minimumElo2 = rank.MinimumElo
			updateProgressBar((v7 - minimumElo2) / (minimumElo - minimumElo2)) -- equivalent call inferred; original call site unknown
			local v9 = nil

			if nextRank.Rewards then
				local reward = nextRank.Rewards[rankedType]

				if reward then
					v9 = reward[tostring(currentSeason)]
				end
			elseif nextRank.Reward then
				v9 = nextRank.Reward[rankedType]
			end

			if v9 then
				local v10 = #v9 > 1 and v9[nextRank.PrimaryReward] or v9[1]
				rewardIcon.Image = v10.Icon

				if v10.Type == "Coins" then
					rewardNameLabel.Text = ""
					rewardNameLabel.Visible = false
					rewardAmount.AmountLabel.Text = `+{v10.Value}`
				else
					rewardNameLabel.Text = v10.DisplayName or ""
					rewardNameLabel.Visible = v10.DisplayName ~= ""
					rewardAmount.AmountLabel.Text = "+" .. (type(v10.Value) ~= "number" and "" or v10.Value or "")
					rewardAmount.Visible = type(v10.Value) == "number"
				end
			end

			window.MaxRewardLabel.Visible = false
		end
	end

	for _, button in window.Tabs:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v6 = button
		button.Activated:Connect(function()
			selectMode(v6.Name)
		end)
	end

	selectMode("FFA")
	window.CloseButton.Activated:Connect(function()
		v2:Close("RankMenu")
	end)
end

function RankMenuController.Init(_) end

return RankMenuController