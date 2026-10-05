local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage3.Packages.Net)
local v3 = require3(ReplicatedStorage3.Common.Utils)
local v4 = require3(ReplicatedStorage3.Packages.Replion)
local v5 = require3(ReplicatedStorage3.Shared.FastUtils)
local v6 = require3(ReplicatedStorage3.Shared.NumberSpinner)
local v7 = require3(ReplicatedStorage3.Shared.MonthlyLeaderboardRewards)
local v8 = require3(ReplicatedStorage3.Controllers.HoverInfoController)
require3(ReplicatedStorage3.Shared.GetCountryFlagEmoji)
local v9 = require3(ReplicatedStorage3.Shared.CountriesToRegions)
local playerGui = Players.LocalPlayer.PlayerGui
local killstreakCounter = playerGui.KillstreakCounter
local monthlyWins = playerGui.MonthlyWins
local v10 = v6.fromGuiObject(monthlyWins.Frame.Rank)
v10.Prefix = " Rank "
v10.Duration = 0.8
v10.Decimals = 0
v10.Commas = true
local v11 = v6.fromGuiObject(monthlyWins.RewardFrame.Rank)
v11.Prefix = " Rank "
v11.Duration = 0.8
v11.Decimals = 0
v11.Commas = true
v2:RemoteEvent("MonthlyLeaderboardRankUpdate")

local function GetDateString(p)
	local universalTime = (p or DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())):ToUniversalTime()
	return (`{universalTime.Year}-{universalTime.Month}`)
end

return {
	Start = function(_)
		local v12 = v4.Client:WaitReplion("Data")
		local v13 = {}
		monthlyWins.Frame.Position = UDim2.fromScale(0.5, -0.2)
		monthlyWins.RewardFrame.Position = UDim2.fromScale(0.5, -0.2)

		local function onAbsoluteSizeChange()
			local instantFFlag = v3.FFlag.GetInstantFFlag("MonthlyLeaderboardRewardsEnabled", false)
			local rewardFrame

			if instantFFlag then
				rewardFrame = monthlyWins.RewardFrame
			else
				rewardFrame = monthlyWins.Frame
			end

			local v14

			if instantFFlag then
				v14 = v11
			else
				v14 = v10
			end

			v14.TextSize = rewardFrame.Rank.AbsoluteSize.Y
		end

		monthlyWins.Frame.Rank:GetPropertyChangedSignal("AbsoluteSize"):Connect(onAbsoluteSizeChange)
		monthlyWins.RewardFrame.Rank:GetPropertyChangedSignal("AbsoluteSize"):Connect(onAbsoluteSizeChange)
		task.defer(onAbsoluteSizeChange)

		local function execute(p)
			local fFlag = v3.FFlag.GetFFlag("MonthlyLeaderboardRewardsEnabled", false)
			local v14

			if fFlag then
				v14 = v11
			else
				v14 = v10
			end

			local rewardFrame

			if fFlag then
				rewardFrame = monthlyWins.RewardFrame
				monthlyWins.Frame.Visible = false
			else
				rewardFrame = monthlyWins.Frame
				monthlyWins.RewardFrame.Visible = false
			end

			rewardFrame.Visible = true
			monthlyWins.Enabled = true
			killstreakCounter.Enabled = false
			v5.fastTween(rewardFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0.05)
			})
			v14.Duration = 0
			v14.Value = p.prevRank
			rewardFrame.Change.Text = "(+0)"
			local country = v12:Get("Country") or "US"
			local v15 = v9[country] or "NA"
			rewardFrame.Title.Text = `Monthly Wins ({v15})`
			local universalTime = DateTime.fromUnixTimestamp(workspace:GetServerTimeNow()):ToUniversalTime()
			local formatted = `{universalTime.Year}-{universalTime.Month}`
			local v16 = v7[formatted]

			if fFlag and not v16 then
				warn((`Failed to find MonthlyLeaderboard rewards for {formatted}!`))
			end

			if fFlag and v16 then
				local v17 = v16[#v16]

				for k, v19 in v16 do
					if not (v19.Rank >= p.rank) then
						continue
					end

					v17 = v16[math.max(1, k - 1)]
					break
				end

				local v19 = v3.ValueConvertor:AddCommas(v17.Rank)
				monthlyWins.RewardFrame.Top.Text = `Top {v19}`
				monthlyWins.RewardFrame.Reward.Vector.Image = v17.Reward.Icon or v3.Icons:GetIcon("DEFAULT_MISSING")
				local visible

				if v17.Reward.Type == "Custom" then
					visible = v17.Reward.DisplayName == "PLACEHOLDER"
				else
					visible = false
				end

				local vector = monthlyWins.RewardFrame.Reward.Vector
				local imageColor

				if visible then
					imageColor = Color3.fromRGB(0, 0, 0)
				else
					imageColor = Color3.fromRGB(255, 255, 255)
				end

				vector.ImageColor3 = imageColor
				monthlyWins.RewardFrame.Reward.QuestionMark.Visible = visible

				if v8:CanShowRewardInfo(v17.Reward) then
					v8:AddFromRewardInfo(
						monthlyWins.RewardFrame.Reward,
						v17.Reward,
						(`Awarded to the top {v19} in each region at the end of the month`)
					)
				end

				local formatted2 = `The top {v19} per region at the end of the month will receive reward.`
				monthlyWins.Frame.Info.TextLabel.Text = formatted2
				monthlyWins.RewardFrame.Info.TextLabel.Text = formatted2
			end

			task.wait(0.15)
			v14.Duration = 0.8
			v14.Value = p.rank
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0
			numberValue.Changed:Connect(function(p2: number)
				local v17 = p2 // 1

				if v17 == 0 then
					rewardFrame.Change.Visible = false
					return
				end

				rewardFrame.Change.Visible = true
				rewardFrame.Change.Text = `({v17 > 0 and "+" or ""}{v3.ValueConvertor:AddCommas(v17)})`
			end)
			v5.fastTween(numberValue, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Value = p.prevRank - p.rank
			})
			task.wait(4)
			v5.fastTween(rewardFrame, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(0.5, -0.2)
			}).Completed:Wait()
			monthlyWins.Enabled = false
			killstreakCounter.Enabled = true
			task.wait()
		end

		local flag = false
		local requestExecuteQueue

		requestExecuteQueue = function()
			if flag then
				return nil
			end

			local v14 = table.remove(v13, 1)

			if not v14 then
				return nil
			end

			flag = true
			xpcall(execute, warn, v14)
			flag = false
			task.spawn(requestExecuteQueue)
			return true
		end

		v2:Connect(
			"MonthlyLeaderboardRankUpdate",
			function(leaderboardType: string, rank: number, prevRank: number, p4: string)
				if not (p4 ~= "Global" and leaderboardType == "Wins") then
					return
				end

				table.insert(v13, {
					leaderboardType = leaderboardType,
					rank = rank,
					prevRank = prevRank
				})

				if flag then
					return
				end

				local v14 = table.remove(v13, 1)

				if not v14 then
					return
				end

				flag = true
				xpcall(execute, warn, v14)
				flag = false
				task.spawn(requestExecuteQueue)
			end
		)
		monthlyWins.Frame.Rank:GetPropertyChangedSignal("AbsoluteSize"):Connect(onAbsoluteSizeChange)
		monthlyWins.RewardFrame.Rank:GetPropertyChangedSignal("AbsoluteSize"):Connect(onAbsoluteSizeChange)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function toggleInfoFrame(visible: boolean)
			monthlyWins.Frame.Info.Visible = visible
			monthlyWins.RewardFrame.Info.Visible = visible
		end

		monthlyWins.Frame.InfoButton.MouseEnter:Connect(function()
			toggleInfoFrame(true) -- equivalent call inferred; original call site unknown
		end)
		monthlyWins.RewardFrame.InfoButton.MouseEnter:Connect(function()
			toggleInfoFrame(true) -- equivalent call inferred; original call site unknown
		end)
		monthlyWins.Frame.InfoButton.MouseLeave:Connect(function()
			toggleInfoFrame(false) -- equivalent call inferred; original call site unknown
		end)
		monthlyWins.RewardFrame.InfoButton.MouseLeave:Connect(function()
			toggleInfoFrame(false) -- equivalent call inferred; original call site unknown
		end)
		v.WindowFocusReleased:Connect(function()
			toggleInfoFrame(false) -- equivalent call inferred; original call site unknown
		end)
		v.InputEnded:Connect(function(_, gameProcessed: boolean)
			if not gameProcessed then
				return
			end

			toggleInfoFrame(false) -- equivalent call inferred; original call site unknown
		end)
	end
}