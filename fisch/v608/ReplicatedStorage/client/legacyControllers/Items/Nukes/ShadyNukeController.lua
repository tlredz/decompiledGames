local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("SoundService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages:WaitForChild("Trove"))
local Promise = require(packages:WaitForChild("Promise"))
local Input = require(packages:WaitForChild("Input"))
local Net = require(packages:WaitForChild("Net"))
local Signal = require(packages:WaitForChild("Signal"))
local localPlayer = Players.LocalPlayer
Trove.new()
local maid = nil
local v = nil
local nukeCharacterIdle = ReplicatedStorage:WaitForChild("resources"):WaitForChild("animations"):WaitForChild("minigames"):WaitForChild("NukeCharacterIdle")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("models"):WaitForChild("Shady Nuke")
local track = nil
local v2 = false
local count = 0
local v3 = { 0.001, 0.2 }
local v4 = { -30, 30 }
local v5 = { 70, 40 }
local v6 = { -90, 90 }
local _ = { 1, 2.5 }
local v7 = v5[1]
local v8 = 0
local v9 = v3[2]
local total = 0.1
local serverTimeNow = 0
local enabledsByScreenGui = {}
local serverTimeNow2 = 0
local v10 = nil
local nukeMinigame = localPlayer.PlayerGui:WaitForChild("NukeMinigame")
local center = nukeMinigame:WaitForChild("Center")
local pointer = center:WaitForChild("Marker"):WaitForChild("Pointer")
local left = center:WaitForChild("Left")
local right = center:WaitForChild("Right")
local timer = nukeMinigame:WaitForChild("Timer")
local secondTimer = center:WaitForChild("SecondTimer")
local finished = center:WaitForChild("Finished")
local bip = nukeMinigame.Bip
local success = nukeMinigame.Success
local fail = nukeMinigame.Fail
local tick = nukeMinigame.Tick
local v11 = {}
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quint)
v11.Instance = center
v11.Positions = {}
v11.Positions[true] = center.Position
v11.Positions[false] = UDim2.fromScale(center.Position.X.Scale, center.Position.Y.Scale + 2)
local module = require("../../PlayerController")
local module2 = require("../../NotificationController")
local ShadyNukeController = {
	StartMinigame = Signal.new()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function SetFov(fieldOfView: number)
	workspace.CurrentCamera.FieldOfView = fieldOfView
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetEffectSize(p: number)
	local background = nukeMinigame:WaitForChild("Background")
	background.Size = UDim2.fromScale(p, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetPointerRotation(rotation: number)
	pointer.Rotation = rotation
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IncreaseAngle(p: number)
	v8 = math.clamp(v8 + p, v4[1], v4[2])
end

local function StopMinigame(flag: boolean?)
	if flag ~= nil then
		module2:Notify(
			flag == true and "You prevented the <font color='#805e5e'>Shady Nuke</font> from exploding & stored it in your <font color='#805e5e'>Inventory</font>." or "You've triggered the <font color='#805e5e'>Shady Nuke</font>!",
			5,
			flag == true and success or fail
		)
	end

	for k, enabled in enabledsByScreenGui do
		k.Enabled = enabled
	end

	SetPointerRotation(0) -- equivalent call inferred; original call site unknown
	SetEffectSize(2) -- equivalent call inferred; original call site unknown
	SetFov(v5[1]) -- equivalent call inferred; original call site unknown
	enabledsByScreenGui = {}
	v2 = false
	timer.Visible = false
	secondTimer.Visible = false
	ProximityPromptService.Enabled = true
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Custom
	localPlayer.CameraMinZoomDistance = 0
	local character = localPlayer.Character

	if character then
		for _, tool in character:GetChildren() do
			if tool:IsA("Tool") and tool.Name ~= "Atomic Nuke" then
				tool.Parent = localPlayer.Backpack
			end
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid then
			currentCamera.CameraSubject = humanoid
			humanoid.AutoRotate = true
		end
	end

	module:ToggleControls(true)

	if maid then
		maid:Destroy()
	end

	if v then
		v:Destroy()
		v = nil
	end

	if track then
		track:Stop()
		track = nil
	end

	local tween = TweenService:Create(v11.Instance, tweenInfo, {
		Position = v11.Positions[false]
	})
	tween:Play()
	tween.Completed:Once(function()
		nukeMinigame.Enabled = false
	end)
end

local function SuccessMinigame()
	return Promise.new(function(callback, _, _)
		finished.Visible = false
		callback()
	end)
end

local function FailMinigame()
	return Promise.new(function(callback, _, _)
		if track then
			track:Stop()
		end

		if v then
			v:Destroy()
			v = nil
		end

		SetEffectSize(2) -- equivalent call inferred; original call site unknown
		Net:RemoteEvent("ShadyNuke"):FireServer()
		callback()
	end)
end

local function LoopMinigame(dt: number)
	track:AdjustSpeed(0)
	local serverTimeNow3 = workspace:GetServerTimeNow()
	local v12 = serverTimeNow3 - serverTimeNow

	if v9 <= v12 then
		local v13 = serverTimeNow3 - serverTimeNow
		total += 0.01 * v13
		serverTimeNow = serverTimeNow3
		v9 = math.clamp(v9 - 1.5 * v13, v3[1], v3[2])
		local v14

		if v8 == 0 then
			v14 = math.random() == 0 and -1 or 1
		else
			v14 = v8 < 0 and -1 or 1
		end

		IncreaseAngle(v14 * total) -- equivalent call inferred; original call site unknown
	end

	local v13 = (v8 - v4[1]) / (v4[2] - v4[1])
	track.TimePosition = v13 * (track.Length or 0)
	SetPointerRotation(v6[1] + (v6[2] - v6[1]) * v13) -- equivalent call inferred; original call site unknown
	SetEffectSize(math.sin(v13 * 3.141592653589793) + 1) -- equivalent call inferred; original call site unknown
	local v16 = (v5[1] - v5[2]) * math.sin(v13 * 3.141592653589793) + v5[2]
	v7 += (v16 - v7) * dt
	SetFov(v7) -- equivalent call inferred; original call site unknown

	if serverTimeNow3 - serverTimeNow2 >= 10 then
		secondTimer.Visible = false
		v2 = false
		return Promise.new(function(callback, _, _)
			finished.Visible = false
			callback()
		end):andThen(function()
			StopMinigame(true)
		end)
	else
		local text = math.floor(serverTimeNow2 + 10 - serverTimeNow3)
		secondTimer.Text = text
		secondTimer.Visible = true

		if text ~= v10 then
			v10 = text
			tick:Play()
		end

		if v8 ~= v4[1] and v8 ~= v4[2] then
			return
		end

		local timePosition = v4[1] == v8 and v4[1] * 0.01 or v4[2] * 0.99
		track.TimePosition = timePosition
		v2 = false
		return Promise.new(function(callback, _, _)
			if track then
				track:Stop()
			end

			if v then
				v:Destroy()
				v = nil
			end

			SetEffectSize(2) -- equivalent call inferred; original call site unknown
			Net:RemoteEvent("ShadyNuke"):FireServer()
			callback()
		end):andThen(function()
			StopMinigame(false)
		end)
	end
end

local function StartMinigame()
	if v2 == true then
		return
	end

	local character = localPlayer.Character

	if not character then
		StopMinigame()
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		StopMinigame()
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		StopMinigame()
		return
	end

	if not character:FindFirstChild("Torso") then
		StopMinigame()
		return
	end

	count += 1
	enabledsByScreenGui = {}

	for _, screenGui in localPlayer.PlayerGui:GetChildren() do
		if not (screenGui:IsA("ScreenGui") and screenGui ~= nukeMinigame) then
			continue
		end

		enabledsByScreenGui[screenGui] = screenGui.Enabled
		screenGui.Enabled = false
	end

	v2 = true
	nukeMinigame.Enabled = true
	secondTimer.Visible = false
	ProximityPromptService.Enabled = false
	humanoid.AutoRotate = false
	localPlayer.CameraMinZoomDistance = 5
	module:ToggleControls(false)
	maid = Trove.new()
	serverTimeNow = workspace:GetServerTimeNow()
	v8 = 0
	v9 = v3[2]
	v7 = v5[1]
	total = 0.1
	SetPointerRotation(0) -- equivalent call inferred; original call site unknown
	SetEffectSize(2) -- equivalent call inferred; original call site unknown
	SetFov(v5[1]) -- equivalent call inferred; original call site unknown
	track = humanoid.Animator:LoadAnimation(nukeCharacterIdle)
	track.Looped = false
	track:Play()

	while track.Length == 0 do
		task.wait()
	end

	track:AdjustSpeed(0)
	track.TimePosition = track.Length / 2
	TweenService:Create(v11.Instance, tweenInfo, {
		Position = v11.Positions[true]
	}):Play()
	local current = Input.PreferredInput.Current
	local text, text2

	if current == "MouseKeyboard" then
		text = "Q"
		text2 = "E"
	elseif current == "Touch" then
		text = "TAP"
		text2 = "TAP"
	else
		text = "L2"
		text2 = "R2"
	end

	local platform = left:WaitForChild("Background"):WaitForChild("Platform")
	platform.Text = text
	local platform_2 = right:WaitForChild("Background"):WaitForChild("Platform")
	platform_2.Text = text2
	left.UIScale.Scale = current == "Touch" and 1.5 or 1
	right.UIScale.Scale = current == "Touch" and 1.5 or 1
	timer.Visible = true
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1.5, -12) * CFrame.Angles(0, 3.141592653589793, 0)
	bip:Play()
	serverTimeNow2 = workspace:GetServerTimeNow()
	v10 = nil
	timer.Visible = false
	local keyboard = Input.Keyboard.new(true)
	maid:Add(keyboard, "Destroy")
	maid:Add(keyboard.KeyDown:Connect(function(p)
		local v15 = p == Enum.KeyCode.E and 1 or p == Enum.KeyCode.Q and -1 or nil

		if not v15 then
			return
		end

		IncreaseAngle(v15 * 5) -- equivalent call inferred; original call site unknown
	end))
	local gamepad = Input.Gamepad.new()
	maid:Add(gamepad, "Destroy")
	maid:Add(gamepad.ButtonDown:Connect(function(p)
		local v15 = p == Enum.KeyCode.ButtonR2 and 1 or p == Enum.KeyCode.ButtonL2 and -1 or nil

		if not v15 then
			return
		end

		IncreaseAngle(v15 * 5) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(left.Activated:Connect(function(p)
		IncreaseAngle(-(p.UserInputType == Enum.UserInputType.Touch and math.abs(v8) > 10 and 2 or 1) * 5) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(right.Activated:Connect(function(p)
		IncreaseAngle((p.UserInputType == Enum.UserInputType.Touch and math.abs(v8) > 10 and 2 or 1) * 5) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(RunService.RenderStepped:Connect(function(dt)
		if v2 == false then
			return
		end

		local character2 = localPlayer.Character

		if not character2 then
			StopMinigame()
			return
		end

		if not character2:FindFirstChild("Humanoid") then
			StopMinigame()
			return
		end

		local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			StopMinigame()
			return
		end

		if not character2:FindFirstChild("Torso") then
			StopMinigame()
			return
		end

		local currentCamera2 = workspace.CurrentCamera
		currentCamera2.CameraType = Enum.CameraType.Scriptable
		currentCamera2.CFrame = humanoidRootPart2.CFrame * CFrame.new(0, 1.5, -12) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		LoopMinigame(dt)
	end))
end

function ShadyNukeController.Start(_)
	Net:RemoteEvent("ShadyNuke").OnClientEvent:Connect(function()
		task.spawn(function()
			StartMinigame()
		end)
	end)
	ShadyNukeController.StartMinigame:Connect(function()
		task.spawn(function()
			StartMinigame()
		end)
	end)
end

return ShadyNukeController