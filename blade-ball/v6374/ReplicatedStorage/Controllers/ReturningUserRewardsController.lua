local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Common.ReturningUserRewardsInfo)
local playerGui = Players.LocalPlayer.PlayerGui

-- equivalent calls inferred from this helper; original call sites unknown
local function getTime()
	return workspace:GetServerTimeNow()
end

local v5 = {
	Claim = {
		Image = "rbxassetid://81726386552071",
		Hovered = "rbxassetid://127923150250664",
		Stroke = Color3.fromRGB(14, 94, 0)
	},
	Locked = {
		Image = "rbxassetid://111289493438103",
		Hovered = "rbxassetid://111289493438103",
		Stroke = Color3.fromRGB(74, 72, 75)
	},
	Claimed = {
		Image = "rbxassetid://111289493438103",
		Hovered = "rbxassetid://111289493438103",
		Stroke = Color3.fromRGB(74, 72, 75)
	}
}
local remoteFunction = v2:RemoteFunction("ReturningUserRewardsClaim")
return {
	Start = function(_)
		local v6 = v.Client:WaitReplion("Data")
		local rewardsContainer = playerGui:WaitForChild("ReturningUserRewards").Frame.RewardsContainer
		local children = {}

		for i = 1, #v4.Rewards do
			local child = rewardsContainer:FindFirstChild((`Day{i}`))

			if not child then
				continue
			end

			local reward = v4.Rewards[i]
			child.DayCount.Text = `DAY {i}`
			child.Main.Heading.Text = reward.DisplayName
			child.Main.Amount.Text = ""
			child.Main.Reward.Image = reward.Icon or ""
			child.Main.Button.Activated:Connect(function()
				remoteFunction:InvokeServer()
			end)
			children[i] = child
		end

		local function updateState()
			local returningUserRewards = v6:Get("ReturningUserRewards")

			if not returningUserRewards then
				return
			end

			local currentDayI = returningUserRewards.currentDayI
			local currentDayStartTime = returningUserRewards.currentDayStartTime
			local time = getTime() -- equivalent call inferred; original call site unknown

			for i = 1, #v4.Rewards do
				local v7 = children[i]
				local v8 = currentDayStartTime + v4.PlayTimeToUnlockReward
				local v9 = i < currentDayI
				local v10

				if v8 <= time then
					v10 = currentDayI == i
				else
					v10 = false
				end

				local v11

				if currentDayStartTime <= time then
					v11 = not v9 and currentDayI == i
				else
					v11 = false
				end

				local v12

				if time < currentDayStartTime then
					v12 = currentDayI == i
				else
					v12 = false
				end

				local v13 = v8 - time
				local label = v7.Main.Button.Label
				local text

				if v9 then
					text = "Claimed"
				elseif v10 then
					text = "Claim"
				elseif v11 then
					text = v3.ValueConvertor:FormatTimeWithDaysFull(v13):gsub("%s", ""):gsub("[hms]", ":"):gsub(
						":$",
						""
					)
				else
					text = not v12 and "Locked" or v3.ValueConvertor:FormatTimeWithDaysFull(currentDayStartTime - time):gsub(
						"%s",
						""
					):gsub(
						"[hms]",
						":"
					):gsub(
						":$",
						""
					)
				end

				label.Text = text
				v7.Main.Button.Active = not v9 and v10
				local claimed

				if v9 then
					claimed = v5.Claimed
				elseif v10 or v11 then
					claimed = v5.Claim
				else
					claimed = v5.Locked
				end

				v7.Main.Button.Image = claimed.Image
				v7.Main.Button.HoverImage = claimed.Hovered
				v7.Main.Button.Label.UIStroke.Color = claimed.Stroke
				v7.Main.Lock.Visible = claimed == v5.Locked
			end
		end

		task.defer(function()
			updateState()

			while true do
				task.wait(1)
				updateState()
			end
		end)
	end
}