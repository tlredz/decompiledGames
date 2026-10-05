local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage3.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage3.Shared.Battlepass.InfiniteGachaRaceRewards)
local v4 = require3(ReplicatedStorage3.Common.Utils)
local v5 = require3(ReplicatedStorage3.Packages.Net)
local v6 = require3(ReplicatedStorage3.ClientGameModules.FFlagClient)
local v7 = require3(ReplicatedStorage3.Packages.Replion)
local v8 = require3(ReplicatedStorage3.Controllers.Battlepass.BattlepassViewController)
local v9 = require3(ReplicatedStorage3.Controllers.Trading.IndexController)
local v10 = require3(ReplicatedStorage3.Controllers.HoverInfoController)
local v11 = require3(ReplicatedStorage3.Shared.BattlepassUIType)
local v12 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local client = v7.Client
local v13 = nil
local v14 = nil
local topSpenderRewards = playerGui:WaitForChild("TopSpenderRewards")
local frame = playerGui:WaitForChild("GachaRaceLeaderboard").Frame
local list = frame.List
local page = topSpenderRewards.Page
local visible = false

local function getToday(value: number?)
	local v16 = workspace:GetServerTimeNow() - (value or 0) * 24 * 60 * 60
	return DateTime.fromUnixTimestamp(v16):FormatUniversalTime("YYYYMMDD", "en-us")
end

local function getRankReward(p)
	local v16 = v3[v12.Season]

	if not v16 then
		warn((`Invalid GachaRaceRewards for season {v12.Season}`))
		return
	end

	for _, v17 in v16 do
		if p <= v17.Rank then
			return v17
		end
	end
end

local GachaRaceController = {}
local v16 = true
local v17 = true
local v18 = nil

function GachaRaceController:UpdateRecentPlacement()
	local gachaRaceLeaderboard = v14.Data.GachaRaceLeaderboard
	local dateTime = DateTime.fromUnixTimestamp(v12.SeasonData.StartTimestamp - 3456000)
	local flag = false
	local rank = 0

	for k, reward in gachaRaceLeaderboard.Rewards do
		local v19 = tonumber((string.sub(k, 1, 4)))
		local v20 = tonumber((string.sub(k, 5, 6)))
		local v21 = tonumber((string.sub(k, 7, 8)))
		local dateTime2 = DateTime.fromLocalTime(v19, v20, v21, 12)

		if not (dateTime2.UnixTimestamp >= dateTime.UnixTimestamp and reward.CurrentSeason) then
			continue
		end

		rank = reward.Rank
		dateTime = dateTime2
		flag = true
	end

	page.MyLastRank.Visible = flag

	if flag then
		local formatLocalTime = dateTime:FormatLocalTime("ll", LocalizationService.RobloxLocaleId)
		page.MyLastRank.Text = `Placed #{rank} on {formatLocalTime}`
	end
end

function GachaRaceController:UpdateRewards()
	local gachaRaceLeaderboard = v14.Data.GachaRaceLeaderboard
	page.MyRank.Text = not v18 and "" or `My Rank: {v18}`
	local mySpending = page.MySpending
	local robuxSpent = gachaRaceLeaderboard.RobuxSpent
	local v19 = workspace:GetServerTimeNow() - 0
	mySpending.Text = `My Spending: {robuxSpent[DateTime.fromUnixTimestamp(v19):FormatUniversalTime("YYYYMMDD", "en-us")] or 0} `
	local v20 = v3[v12.Season]

	if not v20 then
		warn((`Invalid GachaRaceRewards for season {v12.Season}`))
		return
	end

	for k, v21 in v20 do
		local child = page:FindFirstChild(`Reward{k}`, true)

		if not child then
			continue
		end

		local count = 0
		local count2 = 0

		for k2, reward in gachaRaceLeaderboard.Rewards do
			local v22 = workspace:GetServerTimeNow() - 0

			if k2 == DateTime.fromUnixTimestamp(v22):FormatUniversalTime("YYYYMMDD", "en-us") then
				continue
			end

			local v23 = workspace:GetServerTimeNow() - -86400

			if k2 == DateTime.fromUnixTimestamp(v23):FormatUniversalTime("YYYYMMDD", "en-us") or (reward.Rank > v21.Rank or (reward.CurrentSeason or v12.Season) < v12.Season) then
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
			local v22 = tostring(getToday(-1))
			local _ = gachaRaceLeaderboard.Rewards[v22]
			child.Claimed.Visible = visible
		else
			child.ClaimButton.Visible = true
		end
	end
end

function GachaRaceController:UpdateLeaderboard()
	if not v16 then
		return
	end

	v18 = nil
	local expect = v13:GetExpect("Leaderboard")

	for i = 1, 100 do
		local child = list:FindFirstChild((`Rank{i}`))
		local v19 = expect[i]

		if v19 then
			if v19.userId == localPlayer.UserId then
				v18 = i
			end

			child.LayoutOrder = i
			child.Visible = true
			child.Username.Text = v19.username
			child.Points.Text = v4.ValueConvertor:AddCommas(v19.points)
			local v20 = child
			local v21 = v19
			task.spawn(function()
				v20.PlayerPortrait.Image = Players:GetUserThumbnailAsync(
					v21.userId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size150x150
				)
			end)
		else
			child.Visible = false
		end
	end
end

function GachaRaceController:Start()
	v14 = client:WaitReplion("Data", 300)
	local battlepass = playerGui:WaitForChild("Battlepass")
	local v19

	if v11 == "Window" then
		v19 = playerGui:WaitForChild("BattlepassSpinGacha").Main
	else
		v19 = battlepass.Main.Background.Views.SpinGacha
	end

	local dailyRace = v19.DailyRace
	dailyRace.Activated:Connect(function()
		v8:Close()
		v2:Open("TopSpenderRewards")
	end)

	local function updateVisible()
		dailyRace.Visible = (v14:Get((`InfGachaTimesSpun{v12.Season}`)) or 0) >= 10 and v6:GetKey("GachaRaceEnabled")
	end

	local visible2

	if (v14:Get((`InfGachaTimesSpun{v12.Season}`)) or 0) >= 10 then
		visible2 = v6:GetKey("GachaRaceEnabled")
	else
		visible2 = false
	end

	dailyRace.Visible = visible2
	v14:OnChange(`InfGachaTimesSpun{v12.Season}`, updateVisible)
	v2:OnGuiOpen("GachaRaceLeaderboard", function()
		v5:RemoteEvent("SetGachaRaceReplication"):FireServer(true)
		self:UpdateLeaderboard()
	end)
	v2:OnGuiClose("GachaRaceLeaderboard", function()
		v5:RemoteEvent("SetGachaRaceReplication"):FireServer(false)
	end)
	v2:OnGuiOpen("TopSpenderRewards", function()
		self:UpdateRewards()
		self:UpdateRecentPlacement()
	end)
	v14:OnDescendantChange("GachaRaceLeaderboard", function()
		self:UpdateRewards()
		self:UpdateRecentPlacement()
	end)
	page.ViewRanksButton.Activated:Connect(function()
		v2:Open("GachaRaceLeaderboard")
	end)
	page.CloseButton.Activated:Connect(function()
		if v11 == "Window" then
			v8:OpenView("Battlepass")
		else
			v8:Open()
		end
	end)
	local v21 = v3[v12.Season]

	if not v21 then
		warn((`Invalid GachaRaceRewards for season {v12.Season}`))
		v21 = {}
	end

	for k, v22 in v21 do
		local child = page:FindFirstChild(`Reward{k}`, true)

		if not child then
			continue
		end

		local reward = v22.Rewards[1]
		local rewardIcon = child:FindFirstChild("RewardIcon", true)
		rewardIcon.Image = reward.Icon or "rbxassetid://0"
		local label = rewardIcon.Label
		local text

		if k == 1 then
			text = reward.DisplayName:upper()
		else
			text = reward.DisplayName
		end

		label.Text = text
		local canPreview = v9:CanPreview(reward)
		child.Inspect.Visible = canPreview

		if canPreview then
			local v24 = reward
			child.Inspect.Activated:Connect(function()
				v2:Close("TopSpenderRewards")
				v9:PreviewReward(v24, "TopSpenderRewards")
			end)
		end

		if v10:CanShowRewardInfo(reward) then
			v10:AddFromRewardInfo(child, reward)
		else
			v10:Remove(child)
		end

		child.ClaimButton.Activated:Connect(function()
			if not v5:Invoke("ClaimGachaRaceReward") then
				return
			end

			visible = true
			GachaRaceController:UpdateRewards()
		end)
	end

	v4.Thread.Every(1, function()
		local now = DateTime.now()
		local universalTime = now:ToUniversalTime()
		local dateTime = DateTime.fromUniversalTime(universalTime.Year, universalTime.Month, universalTime.Day)
		page.TimeUntil.Title.Text = `Refreshes in {v4.ValueConvertor:FormatTimeWithDaysFull(86400 - (now.UnixTimestamp - dateTime.UnixTimestamp))}`
	end)
	local close = frame:FindFirstChild("Close") or frame:FindFirstChild("CloseButton")

	if close then
		close.Activated:Connect(function()
			v2:Open("TopSpenderRewards")
		end)
	end

	local template = list.Template
	template.Parent = nil

	for i = 1, 100 do
		local clone

		if i <= 3 then
			clone = list:FindFirstChild((`Rank{i}`))
		else
			clone = template:Clone()
			clone.Name = `Rank{i}`
			clone.Parent = list
		end

		clone.Title.Text = `#{i}`
		clone.LayoutOrder = i
		clone.PlayerPortrait.Image = ""
		clone.RewardImage.Label.Image = ""
	end

	v13 = client:WaitReplion("GachaRaceLeaderboard")
	v13:OnChange("Leaderboard", function()
		v16 = true

		if v2:IsOpen("GachaRaceLeaderboard") and v17 then
			self:UpdateLeaderboard()
		end
	end)
	self:UpdateLeaderboard()
	v.WindowFocused:Connect(function()
		v17 = true

		if v2:IsOpen("GachaRaceLeaderboard") then
			self:UpdateLeaderboard()
		end
	end)
	v.WindowFocusReleased:Connect(function()
		v17 = false
	end)
end

return GachaRaceController