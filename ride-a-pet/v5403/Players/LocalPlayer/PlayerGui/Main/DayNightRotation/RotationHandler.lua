local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DayNight = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("DayNight"))
local parent = script.Parent
local timeImage = parent:WaitForChild("TimeImage")
local timerLabel = parent:WaitForChild("TimerLabel")
local showOnDayTime = parent:WaitForChild("ShowOnDayTime")
local total = 0
local v = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatCountdown(p: number)
	local v3 = math.max(math.ceil(p), 0)

	if v3 < 60 then
		return string.format("in %ds", v3)
	end

	return string.format("in %dm %ds", v3 // 60, v3 % 60)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Refresh()
	local isNight = DayNight.IsNight()

	if isNight ~= v2 then
		v2 = isNight
		timeImage.Image = isNight and "rbxassetid://106891725078200" or "rbxassetid://94969857695475"
		showOnDayTime.Visible = not isNight
	end

	local text = FormatCountdown(DayNight.SecondsUntilNextPhase()) -- equivalent call inferred; original call site unknown

	if text ~= v then
		v = text
		timerLabel.Text = text
	end
end

Refresh() -- equivalent call inferred; original call site unknown
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0
	Refresh() -- equivalent call inferred; original call site unknown
end)