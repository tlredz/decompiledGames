local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local clientGameModules = ReplicatedStorage2.ClientGameModules
local common = ReplicatedStorage2.Common
local packages = ReplicatedStorage2.Packages
local v = require3(packages.Net)
local v2 = require3(packages.Replion)
local v3 = require3(packages.Signal)
local v4 = require3(clientGameModules.GuiHandler)
require3(script.Types)
local v5 = require3(ReplicatedStorage2.Shared.HourlyWheelData)
local v6 = require3(common.Utils)
local v7 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local remoteEvent = v:RemoteEvent("HourlyWheel/ClaimStreakReward")
local v8 = nil
local hourlyWheel = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HourlyWheel")
local main = hourlyWheel.Main
local spinner = main.Spinner
local v9 = {}
local v10 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getTimeNow()
	return DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())
end

local HourlyWheelController = {
	RewardText = "",
	RewardTextChanged = v3.new(),
	Init = function(self)
		for _, moduleScript in script.Components:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local v11 = require3(moduleScript)
			v9[moduleScript.Name] = v11
		end
	end,
	GetWrappedChildSingle = function(_, p: string)
		if v10[p] then
			return v10[p][1]
		end
	end,
	AddToTree = function(self, p: string, p2)
		if not v10[p] then
			v10[p] = {}
		end

		table.insert(v10[p], p2)
	end
}

function HourlyWheelController:BuildChildren()
	for _, guiObject in main:GetDescendants() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local type = guiObject:GetAttribute("Type")

		if not type then
			continue
		end

		local v11 = v9[type]

		if v11 then
			HourlyWheelController:AddToTree(type, (v11:Init(guiObject, v8)))
		else
			print((`could not find component for {type}`))
		end
	end
end

function HourlyWheelController:Start()
	local visible = false
	main.Odds.Activated:Connect(function()
		visible = not visible

		for _, guiObject in main.Spinner:GetDescendants() do
			if guiObject.Name == "Odds" and guiObject:IsA("GuiObject") then
				guiObject.Visible = visible
			end
		end
	end)
	v8 = v2.Client:WaitReplion("Data")

	while not v8:Get(v5.ReplionPath) do
		task.wait(1)
	end

	HourlyWheelController:BuildChildren()
	main.CloseButton.Activated:Connect(function()
		v4:Close(hourlyWheel.Name)
	end)

	for _, child in spinner.Luck.Rewards:GetChildren() do
		local v12 = child
		child.Claim.Activated:Connect(function()
			remoteEvent:FireServer(v12.Name)
		end)
	end

	local v12 = {
		[0] = 0,
		[0.25] = 0.245,
		[0.5] = 0.475,
		[0.75] = 0.705,
		[1] = 1
	}

	local function getInterpolatedValue(p)
		if v12[p] then
			return v12[p]
		end

		local v13 = 0
		local v14 = 1

		for k, _ in pairs(v12) do
			if k < p and v13 < k then
				v13 = k
			elseif p < k and k < v14 then
				v14 = k
			end
		end

		local v15 = v12[v13]
		local v16 = v12[v14]
		return v15 + (p - v13) / (v14 - v13) * (v16 - v15)
	end

	local streakHoursRewards = v5.StreakHoursRewards

	local function getTimeLeft(p)
		for _, streakHoursReward in streakHoursRewards do
			if p <= streakHoursReward.TimeStamp then
				return streakHoursReward.TimeStamp - p
			end
		end

		return streakHoursRewards[1].TimeStamp - p
	end

	for _, child in spinner.Luck.Rewards:GetChildren() do
		local name = tonumber(child.Name) or 0
		child.Spin.Text = `x{v5.StreakHoursRewards[name].Reward.Value} Spins`
	end

	local v13 = v8:Get((`{v5.ReplionPath}.TimeStreak`)) or 0
	local lastTime = os.clock()
	v8:OnChange(`{v5.ReplionPath}.TimeStreak`, function(value)
		v13 = value or 0
		lastTime = os.clock()
	end)
	local v14 = nil
	v6.Thread.Every(1, function()
		local timeNow = getTimeNow() -- equivalent call inferred; original call site unknown
		local universalTime = timeNow:ToUniversalTime()
		local v15 = 3600 - (universalTime.Minute * 60 + universalTime.Second)
		local v16 = string.format("%02i:%02i", math.min(v15 / 60), (math.round(v15 % 60)))
		spinner.BottomButtons.Spin.Fade.Label.Text = `Next Spin in {v16}`
		self.RewardText = v8:Get((`{v5.ReplionPath}.Amount`)) > 0 and "NOW!" or v6.ValueConvertor:FormatTimeWithDays(v15)
		self.RewardTextChanged:Fire(self.RewardText)
		local hour = universalTime.Hour

		if v14 ~= hour then
			v14 = hour
		end

		local v17 = v13 + math.floor(os.clock() - lastTime)
		local v18 = 0

		for _, guiObject in spinner.Luck.Rewards:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local name = tonumber(guiObject.Name) or 0
			local streakHoursReward = v5.StreakHoursRewards[name]

			if not streakHoursReward then
				continue
			end

			local v19 = streakHoursReward.TimeStamp <= v17
			local v20 = v8:Get((`{v5.ReplionPath}.ClaimedStreakHours.Reward{guiObject.Name}`)) or false
			guiObject.Claim.Visible = v19 and not v20
			local child = spinner.Luck.HourLabels:FindFirstChild((tostring(name)))
			child.Visible = v20 or not v19

			if v19 then
				v18 = math.max(v18, name)
			end

			local v21 = v8:Get((`{v5.ReplionPath}.DailyStamp`))

			if not child then
				continue
			end

			if v20 then
				local v22 = 86400 - (os.time() - v21)

				if v22 > 0 then
					child.Text = v6.ValueConvertor:FormatTime(v22 + streakHoursReward.TimeStamp)
				else
					child.Text = "RESETTING"
				end
			else
				child.Text = v6.ValueConvertor:FormatTime(streakHoursReward.TimeStamp - v17)
			end
		end

		main.Title.Countdown.Text = `EVENT ENDS IN {v6.ValueConvertor:FormatTimeWithDaysFull(v5.End.UnixTimestamp - timeNow.UnixTimestamp)}`
		getInterpolatedValue(math.min(1, v17 / 14400))
		spinner.Luck.LoggedHours.Text = math.min(math.floor(v17 / 3600), #v5.StreakHoursRewards) .. "/" .. #v5.StreakHoursRewards
	end)
	v4:OnGuiOpen("HourlyWheel", function()
		v7.IsUICovered:SetTag("HourlyWheel", true)
	end)
	v4:OnGuiClose("HourlyWheel", function()
		v7.IsUICovered:SetTag("HourlyWheel", false)
	end)
end

return HourlyWheelController