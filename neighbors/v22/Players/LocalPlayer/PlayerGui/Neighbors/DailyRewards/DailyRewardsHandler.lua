local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local dayList = parent.DayList
local Daily = require(ReplicatedStorage.Assets.Data.Daily)
local Network = require(ReplicatedStorage.Modules.Network)
local Client = require(ReplicatedStorage.Modules.GameConfig.Client)
local localPlayer = Players.LocalPlayer
local prompts = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Prompts")
local now = 0
parent.Visible = false

local function Hours(p: number)
	return p * 60 * 60
end

local v = 54000
parent.Close.MouseButton1Click:Connect(function()
	parent.Visible = false
	now = tick()
	Network:fire("GetDailyReward")
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatSeconds(p: number)
	local v2 = math.max(p, 0)
	local v3 = math.floor(v2 / 3600)
	local v4 = math.floor(v2 % 3600 / 60)
	local v5 = v2 % 60
	return (string.format("%02d:%02d:%02d", v3, v4, v5))
end

local function GetAdjustedCanvasPositionToCenterFrame(p, dayList2)
	local absoluteSize = p.AbsoluteSize
	local absoluteSize2 = dayList2.AbsoluteSize
	local canvasPosition = dayList2.CanvasPosition
	local v2 = p.AbsolutePosition - dayList2.AbsolutePosition + Vector2.new(canvasPosition.X, canvasPosition.Y)
	local v3 = (absoluteSize2.X - absoluteSize.X) / 2
	local v4 = (absoluteSize2.Y - absoluteSize.Y) / 2
	return (Vector2.new(math.max(0, v2.X - v3), (math.max(0, v2.Y + v4))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateDay(i: number)
	local clone = dayList.Template:Clone()
	clone.Day.Text = `Day {i + 1}`
	clone.Visible = true
	return clone
end

local function ShouldOpenMenu()
	if Client:GetValue("DailyRewardType") == "NoReward" or prompts.UpdateLog.Visible then
		return false
	end

	local lastReward = localPlayer:GetAttribute("LastReward") or 1e999
	local v3 = v <= os.time() - lastReward
	return not (tick() - now < 2) and v3
end

local function CreateDayList()
	for _, frame in dayList:GetChildren() do
		if frame:IsA("Frame") and frame.Visible and frame.Name == "Template" then
			frame:Destroy()
		end
	end

	if ShouldOpenMenu() then
		script.Parent.Visible = true
	end

	local streak = localPlayer:GetAttribute("Streak")
	local v2 = nil
	local v3 = nil

	for i = streak - 7, streak + 7 do
		if not (i >= 0) then
			continue
		end

		local day = CreateDay(i) -- equivalent call inferred; original call site unknown
		local localRewardData = Daily:GetLocalRewardData(i)

		if localRewardData.Amount then
			day.Amount.Text = localRewardData.Amount
		end

		if i == streak then
			v3 = day
		end

		local renderSteppedConnection

		if i == streak then
			if v < os.time() - (localPlayer:GetAttribute("LastReward") or 0) then
				day.Claim.Button.BackgroundColor3 = Color3.new(0.333333, 1, 0.498039)
				day.Claim.Button.MouseButton1Click:Connect(function()
					Network:fire("GetDailyReward")
				end)
			elseif i < streak then
				if i == streak - 1 then
					v2 = day
				end

				day.Claim.Button.AutoButtonColor = false
				day.Claim.Title.Text = "Claimed"
			elseif streak <= i then
				day.Claim.Button.AutoButtonColor = false
				local v6 = i
				local day2 = day
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					local lastReward = localPlayer:GetAttribute("LastReward")

					if not lastReward or lastReward == 0 then
						lastReward = os.time()
					end

					local v8 = os.time() - lastReward
					local v10 = lastReward + v * (v6 - streak + 1) - os.time()
					local title = day2.Claim.Title
					title.Text = FormatSeconds(v10)
				end)
				local connection = renderSteppedConnection
				day.Destroying:Once(function()
					connection:Disconnect()
				end)
			end
		elseif i < streak then
			if i == streak - 1 then
				v2 = day
			end

			day.Claim.Button.AutoButtonColor = false
			day.Claim.Title.Text = "Claimed"
		elseif streak <= i then
			day.Claim.Button.AutoButtonColor = false
			local v5 = i
			local day2 = day
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local lastReward = localPlayer:GetAttribute("LastReward")

				if not lastReward or lastReward == 0 then
					lastReward = os.time()
				end

				local v8 = os.time() - lastReward
				local v10 = lastReward + v * (v5 - streak + 1) - os.time()
				local title = day2.Claim.Title
				title.Text = FormatSeconds(v10)
			end)
			local connection = renderSteppedConnection
			day.Destroying:Once(function()
				connection:Disconnect()
			end)
		end

		day.Parent = dayList
	end

	if v2 then
		dayList.CanvasPosition = GetAdjustedCanvasPositionToCenterFrame(v2, dayList)
	end

	local canvasPosition = GetAdjustedCanvasPositionToCenterFrame(v3, dayList)
	TweenService:Create(dayList, TweenInfo.new(1), {
		CanvasPosition = canvasPosition
	}):Play()
end

Network:listen("DailyRewardSuccess", function()
	return script.Success:Play()
end)
parent:GetPropertyChangedSignal("Visible"):connect(function()
	if parent.Visible then
		script.Open:Play()
	end
end)
prompts.UpdateLog:GetPropertyChangedSignal("Visible"):Connect(function()
	if not prompts.UpdateLog.Visible and ShouldOpenMenu() then
		task.wait(0.5)
		CreateDayList()
	end
end)
localPlayer:GetAttributeChangedSignal("Streak"):Connect(CreateDayList)
localPlayer:GetAttributeChangedSignal("LastReward"):connect(CreateDayList)

if localPlayer:GetAttribute("Streak") then
	CreateDayList()
end