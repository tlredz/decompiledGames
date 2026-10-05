local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage3.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage3.Shared.DailyLeaderboards)
local v4 = require3(ReplicatedStorage3.Common.Utils)
local v5 = require3(ReplicatedStorage3.Packages.Net)
require3(ReplicatedStorage3.ClientGameModules.FFlagClient)
local v6 = require3(ReplicatedStorage3.Packages.Replion)
local v7 = require3(ReplicatedStorage3.Controllers.Trading.IndexController)
require3(ReplicatedStorage3.Controllers.Battlepass.BattlepassViewController)
local v8 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local client = v6.Client
local v9 = nil
local singlePass = playerGui:WaitForChild("SinglePass")
local topContributorPrizes = singlePass.MainFrame.Main.Pages.TopContributorPrizes
local topContributors = singlePass.MainFrame.Main.Pages.TopContributors
playerGui:WaitForChild("SinglePass")
local scrollingFrame = topContributors.ScrollingFrame
local v10 = false

local function getToday(value: number?)
	local v11 = workspace:GetServerTimeNow() - (value or 0) * 24 * 60 * 60
	return DateTime.fromUnixTimestamp(v11):FormatUniversalTime("YYYYMMDD", "en-us")
end

local function getRankReward(p)
	local dailyReward = v3.CNYEvent.DailyRewards[v3.CNYEvent.LeaderboardId]

	if not dailyReward then
		warn((`Invalid DailyLeaderboards for CNYEvent {v3.CNYEvent.LeaderboardId}}`))
		return
	end

	for _, v11 in dailyReward do
		if p <= v11.Rank then
			return v11
		end
	end
end

local SinglePassTopPrizesController = {}
local v11 = true
local v12 = true
local v13 = nil

function SinglePassTopPrizesController:UpdateRewards()
	local cNYEvent = v9.Data.DailyLeaderboard.CNYEvent
	local dailyReward = v3.CNYEvent.DailyRewards[v3.CNYEvent.LeaderboardId]

	if not dailyReward then
		warn((`Invalid DailyLeaderboards for CNYEvent {v3.CNYEvent.LeaderboardId}}`))
		return
	end

	for k, v14 in dailyReward do
		local child = topContributorPrizes:FindFirstChild(`Reward{k}`, true)

		if not child then
			continue
		end

		local count = 0
		local count2 = 0

		for k2, reward in cNYEvent.Rewards do
			local v15 = workspace:GetServerTimeNow() - 0

			if k2 == DateTime.fromUnixTimestamp(v15):FormatUniversalTime("YYYYMMDD", "en-us") then
				continue
			end

			local v16 = workspace:GetServerTimeNow() - -86400

			if k2 == DateTime.fromUnixTimestamp(v16):FormatUniversalTime("YYYYMMDD", "en-us") or (reward.Rank > v14.Rank or (reward.SeasonPassData or v8.Season) < v8.Season) then
				continue
			end

			count += 1

			if reward.Claimed then
				count2 += 1
			end
		end

		child.ClaimButton.Visible = false
		child.Claimed.Visible = false

		if not (count > 0) then
			continue
		end

		if count2 == count then
			local v15 = tostring(getToday(-1))
			local reward = cNYEvent.Rewards[v15]
			local visible

			if reward then
				visible = reward.Claimed
			else
				visible = v10
			end

			child.Claimed.Visible = visible
		else
			child.ClaimButton.Visible = true
		end
	end
end

function SinglePassTopPrizesController:UpdateLeaderboard()
	if not v11 then
		return
	end

	v13 = nil
	local expect = client:WaitReplion("DailyLeaderboard-CNYEvent"):GetExpect("Leaderboard")

	for i = 1, 100 do
		local child = scrollingFrame:FindFirstChild((`Rank{i}`))
		local v14 = expect[i]

		if v14 then
			if v14.userId == localPlayer.UserId then
				v13 = i
			end

			child.LayoutOrder = i
			child.Visible = true
			child.Username.Text = v14.username
			child.Points.Text = v4.ValueConvertor:AddCommas(v14.points)
			local v15 = child
			local v16 = v14
			task.spawn(function()
				v15.Headshot.Image = Players:GetUserThumbnailAsync(
					v16.userId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size150x150
				)
			end)
		else
			child.Visible = false
		end
	end
end

function SinglePassTopPrizesController:Start()
	v9 = client:WaitReplion("Data", 300)
	v2:OnGuiOpen(singlePass.Name, function()
		v5:RemoteEvent("SetDailyLeaderboardReplication"):FireServer("CNYEvent", true)
		self:UpdateLeaderboard()
	end)
	v2:OnGuiClose(singlePass.Name, function()
		v5:RemoteEvent("SetDailyLeaderboardReplication"):FireServer("CNYEvent", false)
	end)
	local dailyReward = v3.CNYEvent.DailyRewards[v3.CNYEvent.LeaderboardId]

	if not dailyReward then
		warn((`Invalid DailyLeaderboards for CNYEvent {v3.CNYEvent.LeaderboardId}}`))
		dailyReward = {}
	end

	for _, v14 in dailyReward do
		local child = topContributorPrizes:FindFirstChild((tostring(v14.Rank)))

		if not child then
			continue
		end

		local reward = v14.Rewards[1]
		child.Vector.Image = reward.Icon
		child.ItemName.Text = reward.DisplayName
		child.Claim.Activated:Connect(function()
			if not v5:Invoke("ClaimDailyLeaderboardReward", "CNYEvent") then
				return
			end

			v10 = true
			SinglePassTopPrizesController:UpdateRewards()
		end)
		print(reward, v7:CanPreview(reward), child)
		child.Inspect.Visible = v7:CanPreview(reward)
		child.Inspect.Activated:Connect(function()
			print("A")
			singlePass.Enabled = false
			v7:PreviewReward(reward, nil, function()
				singlePass.Enabled = true
			end)
		end)
	end

	v2:OnGuiOpen("SinglePass", function()
		self:UpdateRewards()
	end)
	v9:OnDescendantChange("DailyLeaderboards.CNYEvent", function()
		self:UpdateRewards()
	end)

	for k, v14 in dailyReward do
		local child = topContributorPrizes:FindFirstChild(`Reward{k}`, true)

		if not child then
			continue
		end

		local reward = v14.Rewards[1]
		local vector = child:FindFirstChild("Vector", true)
		vector.Image = reward.Icon or "rbxassetid://0"
		local itemName = child.ItemName
		local text

		if k == 1 then
			text = reward.DisplayName:upper()
		else
			text = reward.DisplayName
		end

		itemName.Text = text
		child.ClaimButton.Activated:Connect(function()
			if not v5:Invoke("ClaimDailyLeaderboardReward", "CNYEvent") then
				return
			end

			v10 = true
			SinglePassTopPrizesController:UpdateRewards()
		end)
		child.Inspect.Visible = v7:CanPreview(reward)
		child.Inspect.Activated:Connect(function()
			singlePass.Enabled = false
			v7:PreviewReward(reward, nil, function()
				singlePass.Enabled = true
			end)
		end)
	end

	local template = scrollingFrame.Template
	template.Parent = nil

	for i = 1, 100 do
		local clone

		if i <= 3 and scrollingFrame:FindFirstChild((`Rank{i}`)) then
			clone = scrollingFrame:FindFirstChild((`Rank{i}`))
		else
			clone = template:Clone()
			clone.Name = `Rank{i}`
			clone.Parent = scrollingFrame
		end

		clone.Placement.Text = `#{i}`
		clone.LayoutOrder = i
		clone.Headshot.Image = ""
		clone.Points.Text = ""
	end

	client:WaitReplion("DailyLeaderboard-CNYEvent"):OnChange("Leaderboard", function()
		v11 = true

		if v2:IsOpen("SinglePass") and v12 then
			self:UpdateLeaderboard()
		end
	end)
	self:UpdateLeaderboard()
	v.WindowFocused:Connect(function()
		v12 = true

		if v2:IsOpen("SinglePass") then
			self:UpdateLeaderboard()
		end
	end)
	v.WindowFocusReleased:Connect(function()
		v12 = false
	end)
end

return SinglePassTopPrizesController