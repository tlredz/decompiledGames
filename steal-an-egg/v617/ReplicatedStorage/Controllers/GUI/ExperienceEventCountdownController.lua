local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local EventBoardView = require(ReplicatedStorage.Shared.Modules.EventBoardView)
local Log = require(ReplicatedStorage.Packages.Log)
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 82, 82)
local v = Log.new()
local random = Random.new()
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function now()
	return Workspace:GetServerTimeNow()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remainingSeconds()
	local v6 = v4

	if v6 == nil then
		return nil
	end

	return v6.StartsAt - Workspace:GetServerTimeNow()
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function inShowWindow(p: number?)
	return p ~= nil and p > 0 and p <= 3600
end

local function nextPollSeconds(p, p2: number)
	if p == nil then
		return 3600
	end

	if p.StartsAt - p2 > 3600 then
		return 1800
	end

	return 300
end

local function formatClock(p: number)
	local v6 = math.ceil(p)
	local v7 = v6 // 3600
	local v8 = v6 % 3600 // 60
	local v9 = v6 % 60

	if v7 > 0 then
		return string.format("%d:%02d:%02d", v7, v8, v9)
	end

	if v6 < 60 then
		return (tostring(v6))
	end

	return string.format("%02d:%02d", v8, v9)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setText(p, text: string)
	p.TimeLabel.Text = text

	if p.ShadowLabel ~= nil then
		p.ShadowLabel.Text = text
	end
end

local function punch(state, punchScale: number)
	local punch2 = state.Punch

	if punch2 == nil then
		return
	end

	if state.PunchTween ~= nil then
		state.PunchTween:Cancel()
	end

	punch2.Scale = punchScale
	local tween = TweenService:Create(punch2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	})
	state.PunchTween = tween
	tween:Play()
	state.ShakeUntil = os.clock() + 0.18
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playTick(p: number)
	local v6 = 1 - math.clamp(p / 10, 0, 1)
	Audio.Play("rbxassetid://125937767292519", script, {
		PlaybackSpeed = v6 * 0.85 + 0.85,
		Volume = 0.7
	})
end

local function fadeOut(data)
	if v5 ~= data then
		return
	end

	v5 = nil

	if renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	local shadowLabels = { data.TimeLabel, data.TitleLabel }

	if data.ShadowLabel ~= nil then
		table.insert(shadowLabels, data.ShadowLabel)
	end

	for _, v6 in shadowLabels do
		TweenService:Create(v6, tweenInfo, {
			TextTransparency = 1
		}):Play()
		local uIStroke = v6:FindFirstChildOfClass("UIStroke")

		if uIStroke ~= nil then
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	task.delay(0.6, function()
		data.Gui:Destroy()
	end)
end

local function applyShake(data)
	local holder = data.Holder

	if os.clock() < data.ShakeUntil then
		local currentCamera = Workspace.CurrentCamera

		if currentCamera == nil then
			return
		end

		local viewportSize = currentCamera.ViewportSize
		holder.Position = data.BasePosition + UDim2.fromScale(
			random:NextInteger(-6, 6) / viewportSize.X,
			random:NextInteger(-6, 6) / viewportSize.Y
		)
	elseif holder.Position ~= data.BasePosition then
		holder.Position = data.BasePosition
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyScale(state, p: number, p2: number)
	state.Scale += (p - state.Scale) * math.min(p2 * 5, 1)
	local baseSize = state.BaseSize
	state.Holder.Size = UDim2.fromScale(baseSize.X.Scale * state.Scale, baseSize.Y.Scale * state.Scale)
end

local function step(p: number)
	local v6 = v5

	if v6 == nil then
		return
	end

	local v7 = remainingSeconds() -- equivalent call inferred; original call site unknown
	local v8 = v4

	if not inShowWindow(v7) or v8 == nil or v7 == nil then
		fadeOut(v6)
		return
	end

	if v6.TitleLabel.Text ~= v8.Title then
		v6.TitleLabel.Text = v8.Title
	end

	local lastWholeSecond = math.ceil(v7)

	if v7 > 10 then
		setText(v6, formatClock(v7)) -- equivalent call inferred; original call site unknown
		v6.TimeLabel.TextColor3 = v6.CalmColor
		applyScale(v6, 0.55, p) -- equivalent call inferred; original call site unknown
	else
		if not v6.RiserPlayed then
			v6.RiserPlayed = true
			Audio.Play(v3, script)
		end

		local v11 = 1 - math.clamp(v7 / 10, 0, 1)
		v6.TimeLabel.TextColor3 = v6.CalmColor:Lerp(v6.UrgentColor, v11)
		local v12

		if v7 > 6 then
			v12 = tostring(lastWholeSecond)
		else
			v12 = string.format("%.1f", v7)
		end

		setText(v6, v12) -- equivalent call inferred; original call site unknown

		if lastWholeSecond ~= v6.LastWholeSecond then
			punch(v6, v6.PunchScale)
			playTick(lastWholeSecond) -- equivalent call inferred; original call site unknown
		end

		applyScale(v6, 1, p) -- equivalent call inferred; original call site unknown
	end

	v6.LastWholeSecond = lastWholeSecond
	applyShake(v6)
end

local function show()
	if v5 ~= nil then
		return
	end

	local clone = v2:Clone()
	clone.Name = "EventCountdownGuiActive"
	clone.Enabled = true
	local holder = clone:FindFirstChild("Holder")
	local v6

	if holder == nil then
		v6 = false
	else
		v6 = holder:IsA("Frame")
	end

	assert(v6, "EventCountdownGui needs a Holder Frame")
	local time = holder:FindFirstChild("Time")
	local title = holder:FindFirstChild("Title")
	local v7

	if time == nil then
		v7 = false
	else
		v7 = time:IsA("TextLabel")
	end

	assert(v7, "EventCountdownGui.Holder needs a Time TextLabel")
	local v8

	if title == nil then
		v8 = false
	else
		v8 = title:IsA("TextLabel")
	end

	assert(v8, "EventCountdownGui.Holder needs a Title TextLabel")
	local shadow = holder:FindFirstChild("Shadow")
	local punch2 = holder:FindFirstChild("Punch")
	local calmColor = holder:GetAttribute("CalmColor")
	local urgentColor = holder:GetAttribute("UrgentColor")

	if shadow == nil or not shadow:IsA("TextLabel") then
		shadow = nil
	end

	if punch2 == nil or not punch2:IsA("UIScale") then
		punch2 = nil
	end

	local v9 = {
		Gui = clone,
		Holder = holder,
		TimeLabel = time,
		TitleLabel = title,
		ShadowLabel = shadow,
		Punch = punch2,
		BaseSize = holder.Size,
		BasePosition = holder.Position,
		CalmColor = 0,
		UrgentColor = 0,
		PunchScale = 0,
		Scale = 0.55,
		ShakeUntil = 0,
		LastWholeSecond = nil,
		RiserPlayed = false,
		PunchTween = nil
	}

	if typeof(calmColor) ~= "Color3" then
		calmColor = color
	end

	v9.CalmColor = calmColor

	if typeof(urgentColor) ~= "Color3" then
		urgentColor = color2
	end

	v9.UrgentColor = urgentColor
	v9.PunchScale = tonumber(holder:GetAttribute("PunchScale")) or 1.3
	setText(v9, "") -- equivalent call inferred; original call site unknown
	v9.TitleLabel.Text = ""
	v5 = v9
	clone.Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if renderSteppedConnection == nil then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fetchUpcoming()
	local success, upcomingExperienceEventsAsync = pcall(SocialService.GetUpcomingExperienceEventsAsync, SocialService)

	if success then
		v4 = EventBoardView.Pick(upcomingExperienceEventsAsync, now())
	else
		v:AtWarning():Log((`[ExperienceEventCountdown] failed to fetch experience events: {upcomingExperienceEventsAsync}`))
	end
end

return {
	Start = function()
		local eventCountdownGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EventCountdownGui")
		assert(eventCountdownGui:IsA("ScreenGui"), "EventCountdownGui must be a ScreenGui")
		v2 = eventCountdownGui
		local cinematicRiser = ReplicatedStorage.Assets.Sounds:FindFirstChild("CinematicRiser")
		local v6

		if cinematicRiser == nil then
			v6 = false
		else
			v6 = cinematicRiser:IsA("Sound")
		end

		assert(v6, "Missing ReplicatedStorage.Assets.Sounds.CinematicRiser")
		v3 = cinematicRiser
		task.spawn(function()
			task.wait(Random.new():NextNumber(1, 120))

			while true do
				fetchUpcoming() -- equivalent call inferred; original call site unknown
				local v7 = v4
				local v8 = now() -- equivalent call inferred; original call site unknown
				task.wait(v7 == nil and 3600 or v7.StartsAt - v8 > 3600 and 1800 or 300)
			end
		end)
		task.spawn(function()
			while true do
				if v5 == nil then
					local v7 = remainingSeconds() -- equivalent call inferred; original call site unknown

					if inShowWindow(v7) then
						show()
					end
				end

				task.wait(1)
			end
		end)
	end
}