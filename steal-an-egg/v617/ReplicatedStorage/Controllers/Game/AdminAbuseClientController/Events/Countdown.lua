local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local Shake = require(ReplicatedStorage.Client.Shake)
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 82, 82)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local random = Random.new()
local v = nil
local renderSteppedConnection = nil
local v2 = nil

local function playNamedSound(childName: string)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local sounds = assets and assets:FindFirstChild("Sounds")
	local sound = sounds and sounds:FindFirstChild(childName)

	if sound == nil or not sound:IsA("Sound") then
		warn((`[Countdown] Missing ReplicatedStorage.Assets.Sounds.{childName}; the countdown continues without it`))
	else
		Audio.Play(sound, script)
	end
end

local function resolveNotificationLane()
	local notifications = playerGui:FindFirstChild("Notifications")
	local banner

	if notifications ~= nil then
		banner = notifications:FindFirstChild("Banner")
	end

	if banner == nil or not banner:IsA("Frame") then
		return nil
	end

	return banner
end

local function resolveEndsAt()
	local adminAbuseCountdownEndsAt = Workspace:GetAttribute("AdminAbuseCountdownEndsAt")

	if type(adminAbuseCountdownEndsAt) == "number" then
		return adminAbuseCountdownEndsAt
	end

	return v2
end

local function formatClock(p: number)
	local v3 = math.ceil(p)
	local v4 = v3 // 3600
	local v5 = v3 % 3600 // 60
	local v6 = v3 % 60

	if v4 > 0 then
		return string.format("%d:%02d:%02d", v4, v5, v6)
	end

	if v3 < 60 then
		return (tostring(v3))
	end

	return string.format("%02d:%02d", v5, v6)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setText(p, text: string)
	p.TimeLabel.Text = text

	if p.ShadowLabel ~= nil then
		p.ShadowLabel.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncTitle(p)
	local adminAbuseCountdownTitle = Workspace:GetAttribute("AdminAbuseCountdownTitle")

	if type(adminAbuseCountdownTitle) == "string" and p.TitleLabel.Text ~= adminAbuseCountdownTitle then
		p.TitleLabel.Text = adminAbuseCountdownTitle
	end
end

local function punch(state, scale: number)
	local punch2 = state.Punch

	if punch2 == nil then
		return
	end

	if state.PunchTween ~= nil then
		state.PunchTween:Cancel()
	end

	punch2.Scale = scale
	local tween = TweenService:Create(punch2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	})
	state.PunchTween = tween
	tween:Play()
	state.ShakeUntil = os.clock() + 0.18
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playTick(p: number)
	local v3 = 1 - math.clamp(p / 10, 0, 1)
	Audio.Play("rbxassetid://125937767292519", script, {
		PlaybackSpeed = v3 * 0.85 + 0.85,
		Volume = 0.7
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardown()
	if renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	local v3 = v
	v = nil

	if v3 ~= nil then
		v3.Gui:Destroy()
	end
end

local function fadeOut(data)
	if v ~= data then
		return
	end

	v = nil

	if renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	for _, v3 in { data.TimeLabel, data.TitleLabel } do
		TweenService:Create(v3, tweenInfo, {
			TextTransparency = 1
		}):Play()
		local uIStroke = v3:FindFirstChildOfClass("UIStroke")

		if uIStroke ~= nil then
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	if data.ShadowLabel ~= nil then
		TweenService:Create(data.ShadowLabel, tweenInfo, {
			TextTransparency = 1
		}):Play()
	end

	task.delay(0.6, function()
		data.Gui:Destroy()
	end)
end

local function applyPosition(state, p: number)
	local lane = state.Lane

	if lane == nil then
		state.BasePosition = state.LoweredPosition
		return
	end

	local Y = lane.AbsolutePosition.Y
	local v3 = Y
	local flag = false

	for _, guiObject in lane:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
			continue
		end

		flag = true
		local v4 = guiObject.AbsolutePosition.Y + guiObject.AbsoluteSize.Y

		if v3 < v4 then
			v3 = v4
		end
	end

	if flag then
		Y = v3 + state.LaneGap
	end

	local restY = state.RestY

	if restY ~= nil then
		local v4 = restY < Y and 18 or 5
		Y = restY + (Y - restY) * math.min(p * v4, 1)
	end

	state.RestY = Y
	local loweredPosition = state.LoweredPosition
	state.BasePosition = UDim2.new(
		loweredPosition.X.Scale,
		loweredPosition.X.Offset,
		0,
		Y - state.Gui.AbsolutePosition.Y
	)
end

local function applyShake(data)
	local holder = data.Holder

	if os.clock() < data.ShakeUntil then
		holder.Position = data.BasePosition + UDim2.fromOffset(random:NextInteger(-6, 6), random:NextInteger(-6, 6))
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

local function startFinale(state)
	state.FinaleAt = os.clock()
	setText(state, "0") -- equivalent call inferred; original call site unknown
	state.TimeLabel.TextColor3 = state.UrgentColor
	punch(state, 1.45)
	playNamedSound("CinematicBoom")
	Shake.Play({
		Seconds = 0.35,
		Magnitude = 0.35
	})
	task.delay(1.4, function()
		fadeOut(state)
	end)
end

local function step(p: number)
	local v3 = v

	if v3 == nil then
		return
	end

	if v3.Gui.Parent == nil then
		teardown() -- equivalent call inferred; original call site unknown
	else
		syncTitle(v3) -- equivalent call inferred; original call site unknown

		if v3.FinaleAt == nil then
			local adminAbuseCountdownEndsAt = Workspace:GetAttribute("AdminAbuseCountdownEndsAt")

			if type(adminAbuseCountdownEndsAt) ~= "number" then
				adminAbuseCountdownEndsAt = v2
			end

			if adminAbuseCountdownEndsAt == nil then
				fadeOut(v3)
				return
			end

			local v4 = adminAbuseCountdownEndsAt - Workspace:GetServerTimeNow()

			if v4 <= 0 then
				startFinale(v3)
				return
			end

			local lastWholeSecond = math.ceil(v4)

			if v4 > 10 then
				setText(v3, formatClock(v4)) -- equivalent call inferred; original call site unknown
				v3.TimeLabel.TextColor3 = v3.CalmColor
				applyScale(v3, 0.55, p) -- equivalent call inferred; original call site unknown
			else
				if not v3.RiserPlayed then
					v3.RiserPlayed = true
					playNamedSound("CinematicRiser")
				end

				local v6 = 1 - math.clamp(v4 / 10, 0, 1)
				v3.TimeLabel.TextColor3 = v3.CalmColor:Lerp(v3.UrgentColor, v6)
				local v7

				if v4 > 6 then
					v7 = tostring(lastWholeSecond)
				else
					v7 = string.format("%.1f", v4)
				end

				setText(v3, v7) -- equivalent call inferred; original call site unknown

				if lastWholeSecond ~= v3.LastWholeSecond then
					punch(v3, v3.PunchScale)
					playTick(lastWholeSecond) -- equivalent call inferred; original call site unknown
				end

				applyScale(v3, 1, p) -- equivalent call inferred; original call site unknown
			end

			v3.LastWholeSecond = lastWholeSecond
			applyPosition(v3, p)
			applyShake(v3)
		else
			applyScale(v3, 1, p) -- equivalent call inferred; original call site unknown
			applyPosition(v3, p)
			applyShake(v3)
		end
	end
end

local function show()
	if v ~= nil then
		return
	end

	local countdownGui = playerGui:WaitForChild("CountdownGui", 10)

	if countdownGui == nil or not countdownGui:IsA("ScreenGui") then
		warn("[Countdown] Missing StarterGui.CountdownGui; the countdown has no display")
		return
	end

	if v ~= nil then
		return
	end

	local clone = countdownGui:Clone()
	clone.Name = "CountdownGuiActive"
	clone.Enabled = true
	local holder = clone:FindFirstChild("Holder")
	local time

	if holder ~= nil then
		time = holder:FindFirstChild("Time")
	end

	if holder == nil or not holder:IsA("Frame") or time == nil or not time:IsA("TextLabel") then
		warn("[Countdown] CountdownGui needs Holder and Holder.Time; the countdown has no display")
		clone:Destroy()
	else
		local title = holder:FindFirstChild("Title")
		local v3

		if title == nil then
			v3 = false
		else
			v3 = title:IsA("TextLabel")
		end

		assert(v3, "CountdownGui.Holder needs a Title TextLabel")
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

		local v4 = {
			Gui = clone,
			Holder = holder,
			TimeLabel = time,
			TitleLabel = title,
			ShadowLabel = shadow,
			Punch = punch2,
			BaseSize = holder.Size,
			BasePosition = holder.Position,
			LoweredPosition = holder.Position,
			LaneGap = tonumber(holder:GetAttribute("LaneGapPixels")) or 8,
			RestY = nil,
			Lane = 0,
			CalmColor = 0,
			UrgentColor = 0,
			PunchScale = 0,
			Scale = 0.55,
			ShakeUntil = 0,
			LastWholeSecond = nil,
			RiserPlayed = false,
			FinaleAt = nil,
			PunchTween = nil
		}
		local notifications = playerGui:FindFirstChild("Notifications")
		local banner

		if notifications ~= nil then
			banner = notifications:FindFirstChild("Banner")
		end

		if banner == nil or not banner:IsA("Frame") then
			banner = nil
		end

		v4.Lane = banner

		if typeof(calmColor) ~= "Color3" then
			calmColor = color
		end

		v4.CalmColor = calmColor

		if typeof(urgentColor) ~= "Color3" then
			urgentColor = color2
		end

		v4.UrgentColor = urgentColor
		v4.PunchScale = tonumber(holder:GetAttribute("PunchScale")) or 1.3
		setText(v4, "") -- equivalent call inferred; original call site unknown
		v4.TitleLabel.Text = ""
		syncTitle(v4) -- equivalent call inferred; original call site unknown
		v = v4
		clone.Parent = playerGui

		if renderSteppedConnection == nil then
			renderSteppedConnection = RunService.RenderStepped:Connect(step)
		end
	end
end

local Countdown = {
	StartEvent = function(_, p: number, _)
		v2 = Workspace:GetServerTimeNow() + p
		show()
	end,
	StopEvent = function(_)
		v2 = nil
		local v3 = v

		if v3 ~= nil and v3.FinaleAt == nil then
			fadeOut(v3)
		end
	end
}

local function onEndsAtChanged()
	if type(Workspace:GetAttribute("AdminAbuseCountdownEndsAt")) == "number" then
		show()
		return
	end

	local v3 = v

	if v3 ~= nil and v3.FinaleAt == nil then
		fadeOut(v3)
	end
end

Workspace:GetAttributeChangedSignal("AdminAbuseCountdownEndsAt"):Connect(onEndsAtChanged)

if type(Workspace:GetAttribute("AdminAbuseCountdownEndsAt")) == "number" then
	show()
else
	local v3 = v

	if v3 ~= nil and v3.FinaleAt == nil then
		fadeOut(v3)
	end
end

return Countdown