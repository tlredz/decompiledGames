local createVector = vector.create
local abs = math.abs
local clamp = math.clamp
local exp = math.exp
local rad = math.rad
local sign = math.sign
local sqrt = math.sqrt
local tan = math.tan
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local gameSettings = UserSettings().GameSettings
local localPlayer = Players.LocalPlayer

if not localPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	localPlayer = Players.LocalPlayer
end

local currentCamera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local currentCamera2 = Workspace.CurrentCamera

	if currentCamera2 then
		currentCamera = currentCamera2
	end
end)
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserExitFreecamBreaksWithShiftlock")
end)
local v = success and result
local value = Enum.ContextActionPriority.Low.Value
local value2 = Enum.ContextActionPriority.High.Value
local v2 = { Enum.KeyCode.LeftShift, Enum.KeyCode.P }
local v3 = Vector2.new(0.75, 1) * 8
local class = {}
class.__index = class

function class.new(p, p2)
	local self = setmetatable({}, class)
	self.f = p
	self.p = p2
	self.v = p2 * 0
	return self
end

function class:Update(p, p2)
	local v4 = self.f * 2 * 3.141592653589793
	local p3 = self.p
	local v5 = self.v
	local v6 = p2 - p3
	local v8 = exp(-v4 * p)
	local v9 = p2 + (v5 * p - v6 * (v4 * p + 1)) * v8
	local v10 = (v4 * p * (v6 * v4 - v5) + v5) * v8
	self.p = v9
	self.v = v10
	return v9
end

function class:Reset(p2)
	self.p = p2
	self.v = p2 * 0
end

local vector2 = Vector3.new()
local vector3 = Vector2.new()
local fieldOfView = 0
local v4 = class.new(1.5, (Vector3.new()))
local v5 = class.new(1, Vector2.new())
local v6 = class.new(4, 0)
local v7 = {}

local function fCurve(p)
	return (exp(2 * p) - 1) / 6.38905609893065
end

local function fDeadzone(p)
	return (exp(2 * ((p - 0.15) / 0.85)) - 1) / 6.38905609893065
end

local function thumbstickCurve(p)
	return sign(p) * clamp((exp(2 * ((abs(p) - 0.15) / 0.85)) - 1) / 6.38905609893065, 0, 1)
end

local v8 = {
	ButtonX = 0,
	ButtonY = 0,
	DPadDown = 0,
	DPadUp = 0,
	ButtonL2 = 0,
	ButtonR2 = 0,
	Thumbstick1 = Vector2.new(),
	Thumbstick2 = Vector2.new()
}
local v9 = {
	W = 0,
	A = 0,
	S = 0,
	D = 0,
	E = 0,
	Q = 0,
	U = 0,
	H = 0,
	J = 0,
	K = 0,
	I = 0,
	Y = 0,
	Up = 0,
	Down = 0,
	LeftShift = 0,
	RightShift = 0
}
local v10 = {
	Delta = Vector2.new(),
	MouseWheel = 0
}
local v11 = Vector2.new(1, 1) * 0.04908738521234052
local v12 = Vector2.new(1, 1) * 0.39269908169872414
local v13 = 1

function v7.Vel(p)
	v13 = clamp(v13 + p * (v9.Up - v9.Down) * 0.75, 0.01, 4)
	local v15 = Vector3.new(
		thumbstickCurve(v8.Thumbstick1.X),
		thumbstickCurve(v8.ButtonR2) - thumbstickCurve(v8.ButtonL2),
		thumbstickCurve(-v8.Thumbstick1.Y)
	) * createVector(1, 1, 1)
	local v16 = Vector3.new(v9.D - v9.A + v9.K - v9.H, v9.E - v9.Q + v9.I - v9.Y, v9.S - v9.W + v9.J - v9.U) * createVector(
		1,
		1,
		1
	)
	local v17 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	return (v15 + v16) * (v13 * (v17 and 0.25 or 1))
end

function v7.Pan(_)
	local v14 = Vector2.new(thumbstickCurve(v8.Thumbstick2.Y), thumbstickCurve(-v8.Thumbstick2.X)) * v12
	local v15 = v10.Delta * v11
	v10.Delta = Vector2.new()
	return v14 + v15
end

function v7.Fov(_)
	local v14 = (v8.ButtonX - v8.ButtonY) * 0.25
	local v15 = v10.MouseWheel * 1
	v10.MouseWheel = 0
	return v14 + v15
end

local function Keypress(_, p, p2)
	v9[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
	return Enum.ContextActionResult.Sink
end

local function GpButton(_, p, p2)
	v8[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
	return Enum.ContextActionResult.Sink
end

local function MousePan(_, _, p)
	local delta = p.Delta
	v10.Delta = Vector2.new(-delta.y, -delta.x)
	return Enum.ContextActionResult.Sink
end

local function Thumb(_, _, p)
	v8[p.KeyCode.Name] = p.Position
	return Enum.ContextActionResult.Sink
end

local function Trigger(_, _, p)
	v8[p.KeyCode.Name] = p.Position.z
	return Enum.ContextActionResult.Sink
end

local function MouseWheel(_, _, p)
	v10[p.UserInputType.Name] = -p.Position.z
	return Enum.ContextActionResult.Sink
end

local function Zero(items)
	for k, item in pairs(items) do
		items[k] = item * 0
	end
end

function v7.StartCapture()
	ContextActionService:BindActionAtPriority(
		"FreecamKeyboard",
		Keypress,
		false,
		value2,
		Enum.KeyCode.W,
		Enum.KeyCode.U,
		Enum.KeyCode.A,
		Enum.KeyCode.H,
		Enum.KeyCode.S,
		Enum.KeyCode.J,
		Enum.KeyCode.D,
		Enum.KeyCode.K,
		Enum.KeyCode.E,
		Enum.KeyCode.I,
		Enum.KeyCode.Q,
		Enum.KeyCode.Y,
		Enum.KeyCode.Up,
		Enum.KeyCode.Down
	)
	ContextActionService:BindActionAtPriority(
		"FreecamMousePan",
		MousePan,
		false,
		value2,
		Enum.UserInputType.MouseMovement
	)
	ContextActionService:BindActionAtPriority(
		"FreecamMouseWheel",
		MouseWheel,
		false,
		value2,
		Enum.UserInputType.MouseWheel
	)
	ContextActionService:BindActionAtPriority(
		"FreecamGamepadButton",
		GpButton,
		false,
		value2,
		Enum.KeyCode.ButtonX,
		Enum.KeyCode.ButtonY
	)
	ContextActionService:BindActionAtPriority(
		"FreecamGamepadTrigger",
		Trigger,
		false,
		value2,
		Enum.KeyCode.ButtonR2,
		Enum.KeyCode.ButtonL2
	)
	ContextActionService:BindActionAtPriority(
		"FreecamGamepadThumbstick",
		Thumb,
		false,
		value2,
		Enum.KeyCode.Thumbstick1,
		Enum.KeyCode.Thumbstick2
	)
end

function v7.StopCapture()
	v13 = 1
	local v14 = v8

	for k, v15 in pairs(v14) do
		v14[k] = v15 * 0
	end

	local v15 = v9

	for k, v16 in pairs(v15) do
		v15[k] = v16 * 0
	end

	local v16 = v10

	for k, v17 in pairs(v16) do
		v16[k] = v17 * 0
	end

	ContextActionService:UnbindAction("FreecamKeyboard")
	ContextActionService:UnbindAction("FreecamMousePan")
	ContextActionService:UnbindAction("FreecamMouseWheel")
	ContextActionService:UnbindAction("FreecamGamepadButton")
	ContextActionService:UnbindAction("FreecamGamepadTrigger")
	ContextActionService:UnbindAction("FreecamGamepadThumbstick")
end

local function GetFocusDistance(data)
	local viewportSize = currentCamera.ViewportSize
	local v15 = tan(fieldOfView / 2) * 2
	local v16 = viewportSize.x / viewportSize.y * v15
	local rightVector = data.rightVector
	local upVector = data.upVector
	local lookVector = data.lookVector
	local vector4 = Vector3.new()
	local v17 = 512

	for i = 0, 1, 0.5 do
		for i2 = 0, 1, 0.5 do
			local v18 = (i - 0.5) * v16
			local v19 = (i2 - 0.5) * v15
			local v20 = rightVector * v18 - upVector * v19 + lookVector
			local v21 = data.p + v20 * 0.1
			local _, v22 = Workspace:FindPartOnRay(Ray.new(v21, v20.unit * v17))
			local magnitude = (v22 - v21).magnitude

			if not (magnitude < v17) then
				continue
			end

			vector4 = v20.unit
			v17 = magnitude
		end
	end

	return lookVector:Dot(vector4) * v17
end

local function StepFreecam(p)
	local v14 = v4:Update(p, v7.Vel(p))
	local v15 = v5:Update(p, v7.Pan(p))
	local v16 = v6:Update(p, v7.Fov(p))
	local v20 = sqrt(0.7002075382097097 / tan((rad(fieldOfView / 2))))
	fieldOfView = clamp(fieldOfView + v16 * 300 * (p / v20), 1, 120)
	vector3 += v15 * v3 * (p / v20)
	vector3 = Vector2.new(clamp(vector3.x, -1.5707963267948966, 1.5707963267948966), vector3.y % 6.283185307179586)
	local cFrame2 = CFrame.new(vector2) * CFrame.fromOrientation(vector3.x, vector3.y, 0) * CFrame.new(v14 * createVector(
		64,
		64,
		64
	) * p)
	vector2 = cFrame2.p
	currentCamera.CFrame = cFrame2
	currentCamera.Focus = cFrame2 * CFrame.new(0, 0, -GetFocusDistance(cFrame2))
	currentCamera.FieldOfView = fieldOfView
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckMouseLockAvailability()
	local devEnableMouseLock = Players.LocalPlayer.DevEnableMouseLock
	local v14 = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local v15 = gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local v16 = gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	return devEnableMouseLock and v15 and not v16 and not v14
end

local v14 = {}
local default = nil
local mouseIconEnabled = nil
local cameraType = nil
local focus = nil
local cFrame = nil
local fieldOfView2 = nil
local screenGuis = {}
local coreGuiEnableds = {
	Backpack = true,
	Chat = true,
	Health = true,
	PlayerList = true
}
local cores = {
	BadgesNotificationsActive = true,
	PointsNotificationsActive = true
}

function v14.Push()
	for k in pairs(coreGuiEnableds) do
		coreGuiEnableds[k] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[k])
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], false)
	end

	for k in pairs(cores) do
		cores[k] = StarterGui:GetCore(k)
		StarterGui:SetCore(k, false)
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		for _, screenGui in pairs(playerGui:GetChildren()) do
			if not (screenGui:IsA("ScreenGui") and screenGui.Enabled) then
				continue
			end

			screenGuis[#screenGuis + 1] = screenGui
			screenGui.Enabled = false
		end
	end

	fieldOfView2 = currentCamera.FieldOfView
	currentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
	cameraType = currentCamera.CameraType
	currentCamera.CameraType = Enum.CameraType.Custom
	cFrame = currentCamera.CFrame
	focus = currentCamera.Focus
	mouseIconEnabled = UserInputService.MouseIconEnabled
	UserInputService.MouseIconEnabled = false

	if v then
		if CheckMouseLockAvailability() then
			default = Enum.MouseBehavior.Default
		else
			default = UserInputService.MouseBehavior
		end
	else
		default = UserInputService.MouseBehavior
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

function v14.Pop()
	for k, v15 in pairs(coreGuiEnableds) do
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], v15)
	end

	for k, v15 in pairs(cores) do
		StarterGui:SetCore(k, v15)
	end

	for _, v15 in pairs(screenGuis) do
		if v15.Parent then
			v15.Enabled = true
		end
	end

	currentCamera.FieldOfView = fieldOfView2
	fieldOfView2 = nil
	currentCamera.CameraType = cameraType
	cameraType = nil
	currentCamera.CFrame = cFrame
	cFrame = nil
	currentCamera.Focus = focus
	focus = nil
	UserInputService.MouseIconEnabled = mouseIconEnabled
	mouseIconEnabled = nil
	UserInputService.MouseBehavior = default
	default = nil
end

local function StartFreecam()
	local cFrame2 = currentCamera.CFrame
	vector3 = Vector2.new(cFrame2:toEulerAnglesYXZ())
	vector2 = cFrame2.p
	fieldOfView = currentCamera.FieldOfView
	v4:Reset((Vector3.new()))
	v5:Reset(Vector2.new())
	v6:Reset(0)
	v14.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	v7.StartCapture()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopFreecam()
	v7.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	v14.Pop()
end

local v15 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function ToggleFreecam()
	if v15 then
		StopFreecam() -- equivalent call inferred; original call site unknown
	else
		StartFreecam()
	end

	v15 = not v15
end

local function CheckMacro(list)
	for i = 1, #list - 1 do
		if not UserInputService:IsKeyDown(list[i]) then
			return
		end
	end

	ToggleFreecam() -- equivalent call inferred; original call site unknown
end

local function HandleActivationInput(_, p, p2)
	if p == Enum.UserInputState.Begin and p2.KeyCode == v2[#v2] then
		CheckMacro(v2)
	end

	return Enum.ContextActionResult.Pass
end

ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, value, v2[#v2])
script:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not script.Enabled then
		StopFreecam() -- equivalent call inferred; original call site unknown
		warn("h")
	end
end)