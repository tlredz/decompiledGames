local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Common.DailyLoginInfo)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local getPlayerTimezone = ReplicatedStorage2.Remotes.GetPlayerTimezone
require3(ReplicatedStorage2.Controllers.AnalyticsController)
local v5 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v6 = require3(ReplicatedStorage2.Common.ReturningUserRewardsInfo)
local v7 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentDay()
	return (math.floor((workspace:GetServerTimeNow() + v7:Get("TimezoneOffsetInHours") * 3600) / 86400))
end

local function getDayStartTimestamp(p: number)
	return p * 86400
end

local function getDailyLoginGuiName()
	local currentDailyLoginType = v7:Get("CurrentDailyLoginType")

	if v7:Get("ReturningUserRewards") and v7:Get("ReturningUserRewards.currentDayI") <= #v6.Rewards and v5:IsDataReady() and v5:GetKey("ReturningUserRewardsEnabled") then
		return "ReturningUserRewards"
	end

	if currentDailyLoginType == "Longterm" then
		return
	else
		return (`DailyLogin_{currentDailyLoginType}_Rewards`)
	end
end

local v8 = false
local DailyLoginController = {}

function DailyLoginController:_notify()
	local icon = require3(ReplicatedStorage2.Controllers.UI.TopBarController):GetIcon("DailyLogin")

	if not v8 and icon then
		v8 = true
		icon:notify()
	end
end

function DailyLoginController:Start()
	getPlayerTimezone.OnClientInvoke = function()
		return (math.round((os.time() - workspace:GetServerTimeNow()) / 3600))
	end

	v7 = v.Client:WaitReplion("Data")

	if not v7:Get("TimezoneOffsetInHours") then
		getPlayerTimezone:InvokeServer((math.round((os.time() - workspace:GetServerTimeNow()) / 3600)))
	end

	while not v7:Get("TimezoneOffsetInHours") do
		task.wait(1)
	end

	local v9 = {}

	for k in v3 do
		if k ~= "LegacyModernized" then
			v9[k] = playerGui:WaitForChild((`DailyLogin_{k}_Rewards`))
		end
	end

	local dailyLogin = require3(ReplicatedStorage2.Controllers.UI.TopBarController):WaitForIcon("DailyLogin")
	dailyLogin.toggled:Connect(function(p, p2)
		if p2 ~= "User" then
			return
		end

		local dailyLoginGuiName = getDailyLoginGuiName()

		if not dailyLoginGuiName or dailyLoginGuiName == "" then
			warn("NO DAILY LOGIN GUI NAME")
			return
		end

		if not p then
			v4:Close(dailyLoginGuiName)
			return
		end

		dailyLogin:clearNotices()
		v4:Open(dailyLoginGuiName)
	end)
	v7:OnChange("CurrentDailyLoginType", function(_, p)
		if p then
			v4:Close((`DailyLogin_{p}_Rewards`))
		end
	end)
	v4:OnClose(function(p)
		if p.Name:match("DailyLogin_%w+_Rewards") and dailyLogin.isSelected then
			dailyLogin:deselect()
		end
	end)
	local dailyLogin2 = v9.DailyLogin
	local page = dailyLogin2.Page
	page.CloseButton.Activated:Connect(function()
		v4:Close(dailyLogin2.Name)
	end)
	local bottom = page.Bottom

	for k, reward in v3.DailyLogin.Rewards do
		local v10 = bottom[`D{k}`]
		local v11 = reward.Rewards[2] or reward.Rewards[1]
		v10.Vector.Image = v11.Icon or "rbxassetid://0"
		local v12 = k

		local function updateFrame()
			local v15 = v7:Get("DailyLoginData.DailyLogin.StartDay") or math.floor((workspace:GetServerTimeNow() + v7:Get("TimezoneOffsetInHours") * 3600) / 86400)
			local v16 = math.floor((workspace:GetServerTimeNow() + v7:Get("TimezoneOffsetInHours") * 3600) / 86400) - v15
			local visible = v16 < v12

			if v12 == v16 then
				v10.Top.Text = "Today"
			elseif v12 == v16 + 1 then
				v10.Top.Text = "Tomorrow"
			else
				v10.Top.Text = `Day {v12}`
			end

			local vector = v10.Vector
			local imageColor

			if visible then
				imageColor = Color3.new(0, 0, 0)
			else
				imageColor = Color3.new(1, 1, 1)
			end

			vector.ImageColor3 = imageColor
			local uIGradient = v10.UIGradient
			local color

			if visible then
				color = script.DarkBackground.Color
			else
				color = script.LightBackground.Color
			end

			uIGradient.Color = color
			v10.QuestionMark.Visible = visible
			local v20 = workspace:GetServerTimeNow() + v7:Get("TimezoneOffsetInHours") * 3600

			if visible then
				v10.Bottom.Text = `Get in {v2.ValueConvertor:FormatShortTime((v15 + v12) * 86400 - v20)}`
			else
				v10.Bottom.Text = v11.DisplayName or "Unnamed"
			end
		end

		v2.Thread.Every(1, updateFrame)
	end

	local today = page.Today
	local tomorrow = page.Tomorrow
	local wait = page.Wait
	local cashOut = page.CashOut
	local cashOutEnd = page.CashOutEnd
	cashOut.Activated:Connect(function()
		v2.Network:Fire("ClaimLoginReward", "CashOut")
	end)
	cashOutEnd.Activated:Connect(function()
		v2.Network:Fire("ClaimLoginReward", "CashOut")
	end)
	wait.Activated:Connect(function()
		v2.Network:Fire("ClaimLoginReward", "Wait")
	end)
	v2.Thread.Every(1, function()
		local v10 = v7:Get("DailyLoginData.DailyLogin.StartDay") or math.floor((workspace:GetServerTimeNow() + v7:Get("TimezoneOffsetInHours") * 3600) / 86400)
		local currentDay = getCurrentDay() -- equivalent call inferred; original call site unknown
		local v11 = currentDay - v10
		local v12 = currentDay + 1
		local v13 = v12 - v10
		local reward = v3.DailyLogin.Rewards[v11]
		today.Visible = reward and true or false

		if reward then
			for i = 1, 2 do
				local reward2 = reward.Rewards[i]
				local v14 = today[`Box{i}`]
				v14.Visible = reward2 and true or false

				if not reward2 then
					continue
				end

				v14.Vector.Image = reward2.Icon or "rbxassetid://0"
				v14.Label.Text = reward2.DisplayName
			end
		end

		local reward2 = v3.DailyLogin.Rewards[v13]
		tomorrow.Visible = reward2 and true or false

		if reward2 then
			for i = 1, 2 do
				local reward3 = reward2.Rewards[i]
				local v14 = tomorrow[`Box{i}`]
				v14.Visible = reward3 and true or false

				if not reward3 then
					continue
				end

				v14.Vector.Image = reward3.Icon or "rbxassetid://0"
				v14.Label.Text = reward3.DisplayName
				local uIGradient = v14.UIGradient
				local color

				if i == 2 then
					color = script.DarkBackground.Color
				else
					color = script.LightBackground.Color
				end

				uIGradient.Color = color

				if i ~= 2 then
					continue
				end

				v14.QuestionMark.Visible = true
				v14.Label.Text = `Get in {v2.ValueConvertor:FormatShortTime(v12 * 86400 - workspace:GetServerTimeNow() + v7:Get("TimezoneOffsetInHours") * 3600)}`
			end
		end

		local v14 = v7:Get("DailyLoginData.DailyLogin.LastWait") or 0
		local v15 = v7:Get("DailyLoginData.DailyLogin.CashedOut")
		local v16 = currentDay <= v14

		if reward2 then
			page.YouWaited.Visible = not v15 and v16
			page.YouWaited.Text = `Come back in {v2.ValueConvertor:FormatShortTime(v12 * 86400 - workspace:GetServerTimeNow() + v7:Get("TimezoneOffsetInHours") * 3600)}`
			wait.Visible = not v15 and not v16 and reward
			cashOut.Visible = not v15 and not v16 and reward
		else
			page.YouWaited.Visible = false
			wait.Visible = false
			cashOut.Visible = false
			cashOutEnd.Visible = not v15
		end
	end)
	task.spawn(function()
		local D30 = v9.D30
		local country = v7:Get("Country")

		if not country then
			local thread = coroutine.running()
			v7:OnChange("Country", function(p)
				country = p
				task.spawn(thread)
			end)
		end

		local _ = ({
			TH = true,
			VN = true,
			TW = true,
			SG = true,
			HK = true
		})[country] and true or false
		local page2 = D30.Page
		page2.Visible = true
		local rewards = page2.Rewards
		page2.CloseButton.Activated:Connect(function()
			v4:Close(D30.Name)
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setFrameStyle(state, p: string)
			state.Claimed.Visible = p == "Claimed"
			state.Available.Visible = p == "Claimable"
			state.Active = p == "Claimable"

			if state.Parent.Name == "Top" then
				state.Image = p == "Default" and "rbxassetid://15343677462" or "rbxassetid://15343776517"
			end
		end

		local function setFrameLocked(instance, visible: boolean)
			local vector = instance.Vector
			local imageColor

			if visible then
				imageColor = Color3.new(0, 0, 0)
			else
				imageColor = Color3.new(1, 1, 1)
			end

			vector.ImageColor3 = imageColor
			instance.RewardName.Text = visible and "???" or instance:GetAttribute("DisplayName") or ""

			if instance.Parent.Name ~= "Top" then
				instance.Lock.Visible = visible
				instance.Lock2.Visible = visible
			end
		end

		local descendants = {}

		for _, descendant in rewards:GetDescendants() do
			local layoutOrder = tonumber(descendant.Name:match("^Day(%d+)$") or "")

			if not layoutOrder then
				continue
			end

			local reward = v3.D30.Rewards[layoutOrder]

			if reward then
				descendants[layoutOrder] = descendant
				descendant.Day.Text = `Day {layoutOrder}`
				descendant.LayoutOrder = layoutOrder
				descendant.Vector.Image = reward.Icon or "rbxassetid://0"
				descendant:SetAttribute("DisplayName", reward.DisplayName or "")
				local layoutOrder2 = layoutOrder
				descendant.Activated:Connect(function()
					local v12 = v7:Get("DailyLoginData.D30")

					if v12.DaysClaimedStreak == layoutOrder2 - 1 and workspace:GetServerTimeNow() >= v12.NextClaim then
						v2.Network:Fire("ClaimLoginReward")
						v4:Close(D30.Name)
					end
				end)
			else
				descendant.Visible = false
			end
		end

		local function updateRewards()
			if v7:Get("CurrentDailyLoginType") ~= "D30" then
				return
			end

			local v10 = v7:Get("DailyLoginData.D30.CurrentMonth")
			local v11 = v7:Get("DailyLoginData.D30.DaysClaimedStreak")
			local v12 = v7:Get("DailyLoginData.D30.NextClaim")
			local serverTimeNow = workspace:GetServerTimeNow()

			for k, reward in v3.D30.Rewards do
				local v13 = descendants[k]
				local v14 = (v10 - 1) * 21 + k

				if reward.Type == "MonthVariant" then
					reward = reward.Value[v10][1]
				end

				v13.Day.Text = `Day {v14}`

				if k % 7 == 0 and v13:FindFirstChild("Desc") then
					v13.Desc.Text = `Play {v14} days in a row to unlock this rare item!`
				end

				local uIScale = v13.Vector:FindFirstChild("UIScale")

				if uIScale then
					uIScale:Destroy()
				end

				if reward.Type == "Sword" then
					local uIScale_2 = Instance.new("UIScale", v13.Vector)
					uIScale_2.Scale = 1.5
				end

				local v15 = "Default"

				if k <= v11 then
					v15 = "Claimed"
				elseif v11 == k - 1 and v12 <= serverTimeNow then
					self:_notify()
					v15 = "Claimable"
				end

				setFrameStyle(v13, v15) -- equivalent call inferred; original call site unknown
				setFrameLocked(v13, v15 == "Default")
			end
		end

		local nextRewardIn = page2.NextRewardIn
		local v10 = nil
		v2.Thread.Every(55, function()
			if v7:Get("CurrentDailyLoginType") ~= "D30" then
				return
			end

			local nextClaim = v7.Data.DailyLoginData.D30.NextClaim
			local serverTimeNow = workspace:GetServerTimeNow()
			local v11 = nextClaim - serverTimeNow

			if v11 > 0 then
				nextRewardIn.Text = `Next reward in: {v2.ValueConvertor:FormatTime(v11)}`
			else
				nextRewardIn.Text = ""
			end

			if nextClaim <= serverTimeNow and v10 ~= nextClaim then
				updateRewards()
				v10 = nextClaim
			end
		end)
		v7:OnChange("DailyLoginData.D30.CurrentMonth", updateRewards)
		v7:OnChange("DailyLoginData.D30.DaysClaimedStreak", updateRewards)
		v7:OnChange("CurrentDailyLoginType", updateRewards)
		updateRewards()

		local function setConsecutiveFrameStyle(state, p: string)
			state.Claimed.Visible = p == "Claimed"
			state.Available.Visible = p == "Claimable"
			state.Active = p == "Claimable"
			state.Image = p == "Default" and "rbxassetid://15343840909" or "rbxassetid://15343871405"
		end

		local consecutive = page2.Consecutive
		local consecutiveDays = page2.ConsecutiveDays

		local function updateConsecutive()
			local v11 = tonumber(v7:Get("DailyLoginData.D30.ConsecutiveStreak")) or 0
			consecutiveDays.Text = `{v11} Consecutive Days`

			for k, consecutiveReward in v3.D30.ConsecutiveRewards do
				local day = consecutive[`Day{k}`].Day
				day.Rewards.Reward.Vector.Image = consecutiveReward.Icon or "rbxassetid://00000"

				if k <= v11 then
					day.Claimed.Visible = true
					day.Available.Visible = false
					day.Active = false
					day.Image = "rbxassetid://15343871405"
				else
					day.Claimed.Visible = false
					day.Available.Visible = false
					day.Active = false
					day.Image = "rbxassetid://15343840909"
				end
			end
		end

		v2.Thread.Every(1, updateConsecutive)
	end)
	local frame = v9.Longterm.Frame
	local frames = {}

	for _, frame2 in frame.Rewards:GetChildren() do
		if not frame2:IsA("Frame") then
			continue
		end

		for _, frame3 in frame2:GetChildren() do
			if frame3:IsA("Frame") then
				frames[tonumber(frame3.Name:match("%d+"))] = frame3
			end
		end
	end

	local function updateRewards()
		local v10 = v7:Get("DailyLoginData.Longterm.CurrentMonth")
		local v11 = v7:Get("DailyLoginData.Longterm.DaysClaimedStreak")
		v7:Get("DailyLoginData.Longterm.NextClaim")

		for k, reward in v3.Longterm.Rewards do
			local v12 = frames[k]

			if reward.Type == "MonthVariant" then
				reward = reward.Value[v10][1]
			end

			v12.TopBar.DayCounterTextLabel.Text = `Day {(v10 - 1) * 30 + k}`
			v12.Reward.ImageLabel.Image = reward.Icon or "rbxassetid://0"
			v12.Reward.AmountTextLabel.Text = reward.DisplayName or ""
			v12.ClaimedCover.Visible = k <= v11
			local uIScale = v12.Reward.ImageLabel:FindFirstChild("UIScale")

			if uIScale then
				uIScale:Destroy()
			end

			if reward.Type == "Sword" then
				local uIScale_2 = Instance.new("UIScale", v12.Reward.ImageLabel)
				uIScale_2.Scale = 1.5
			end

			local v13 = v11 == k - 1 and "Green" or "Default"

			if v13 == "Default" then
				v12.UIStroke.Color = Color3.fromRGB(12, 46, 75)
				v12.TopBar.UIGradient.Color = script.TopBarDefault.Color
			elseif v13 == "Green" then
				v12.UIStroke.Color = Color3.fromRGB(118, 232, 31)
				v12.TopBar.UIGradient.Color = script.TopBarGreen.Color
			end
		end

		for _, frame2 in frame.Highlights:GetChildren() do
			if not frame2:IsA("Frame") then
				continue
			end

			local v12 = tonumber(frame2.Name:match("%d+"))
			local reward = v3.Longterm.Rewards[v12]

			if reward.Type == "MonthVariant" then
				reward = reward.Value[v10][1]
			end

			frame2.TopBar.DayCounterTextLabel.Text = `Day {(v10 - 1) * 30 + v12}`
			frame2.Reward.ImageLabel.Image = reward.Icon or "rbxassetid://0"
			frame2.Reward.AmountTextLabel.Text = reward.DisplayName or ""
			frame2.ClaimedCover.Visible = v12 <= v11
		end
	end

	v7:OnChange("DailyLoginData.Longterm.CurrentMonth", updateRewards)
	v7:OnChange("DailyLoginData.Longterm.DaysClaimedStreak", updateRewards)
	updateRewards()
	frame.Claim.Activated:Connect(function()
		v2.Network:Fire("ClaimLoginReward")
	end)
	v2.Thread.Every(1, function()
		local visible = frame.Claim.Visible
		frame.Claim.Visible = workspace:GetServerTimeNow() > (v7:Get("DailyLoginData.Longterm.NextClaim") or 1e999)

		if frame.Claim.Visible then
			frame.NextClaim.Visible = false
		else
			local v10 = v7:Get("DailyLoginData.Longterm.NextClaim")

			if v10 then
				frame.NextClaim.Visible = true
				frame.NextClaim.Text = `Next claim in: {v2.ValueConvertor:FormatShortTime(v10 - workspace:GetServerTimeNow())}`
			else
				frame.NextClaim.Visible = false
			end
		end

		if frame.Claim.Visible ~= visible then
			updateRewards()
		end
	end)
	local v10 = false
	local connection = nil
	connection = v4:OnOpen(function()
		connection:Disconnect()
		v10 = true
	end)
end

return DailyLoginController