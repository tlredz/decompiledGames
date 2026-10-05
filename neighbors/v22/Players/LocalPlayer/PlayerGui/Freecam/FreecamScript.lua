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
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserShowGuiHideToggles")
end)
local v2 = success2 and result2
local value = Enum.ContextActionPriority.Low.Value
local value2 = Enum.ContextActionPriority.High.Value
local v3 = { Enum.KeyCode.LeftAlt, Enum.KeyCode.LeftShift, Enum.KeyCode.P }
local v4 = Vector2.new(0.75, 1) * 8
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
	local v5 = self.f * 2 * 3.141592653589793
	local p3 = self.p
	local v6 = self.v
	local v7 = p2 - p3
	local v9 = exp(-v5 * p)
	local v10 = p2 + (v6 * p - v7 * (v5 * p + 1)) * v9
	local v11 = (v5 * p * (v7 * v5 - v6) + v6) * v9
	self.p = v10
	self.v = v11
	return v10
end

function class:Reset(p2)
	self.p = p2
	self.v = p2 * 0
end

local vector2 = Vector3.new()
local vector3 = Vector2.new()
local fieldOfView = 0
local v5 = class.new(1.5, (Vector3.new()))
local v6 = class.new(1, Vector2.new())
local v7 = class.new(4, 0)
local v8 = {}

local function fCurve(p)
	return (exp(2 * p) - 1) / 6.38905609893065
end

local function fDeadzone(p)
	return (exp(2 * ((p - 0.15) / 0.85)) - 1) / 6.38905609893065
end

local function thumbstickCurve(p)
	return sign(p) * clamp((exp(2 * ((abs(p) - 0.15) / 0.85)) - 1) / 6.38905609893065, 0, 1)
end

local v9 = {
	ButtonX = 0,
	ButtonY = 0,
	DPadDown = 0,
	DPadUp = 0,
	ButtonL2 = 0,
	ButtonR2 = 0,
	Thumbstick1 = Vector2.new(),
	Thumbstick2 = Vector2.new()
}
local v10 = {
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
local v11 = {
	Delta = Vector2.new(),
	MouseWheel = 0
}
local v12 = Vector2.new(1, 1) * 0.04908738521234052
local v13 = Vector2.new(1, 1) * 0.39269908169872414
local v14 = 1

function v8.Vel(p)
	v14 = clamp(v14 + p * (v10.Up - v10.Down) * 0.75, 0.01, 4)
	local v16 = Vector3.new(
		thumbstickCurve(v9.Thumbstick1.X),
		thumbstickCurve(v9.ButtonR2) - thumbstickCurve(v9.ButtonL2),
		thumbstickCurve(-v9.Thumbstick1.Y)
	) * createVector(1, 1, 1)
	local v17 = Vector3.new(v10.D - v10.A + v10.K - v10.H, v10.E - v10.Q + v10.I - v10.Y, v10.S - v10.W + v10.J - v10.U) * createVector(
		1,
		1,
		1
	)
	local v18 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	return (v16 + v17) * (v14 * (v18 and 0.25 or 1))
end

function v8.Pan(_)
	local v15 = Vector2.new(thumbstickCurve(v9.Thumbstick2.Y), thumbstickCurve(-v9.Thumbstick2.X)) * v13
	local v16 = v11.Delta * v12
	v11.Delta = Vector2.new()
	return v15 + v16
end

function v8.Fov(_)
	local v15 = (v9.ButtonX - v9.ButtonY) * 0.25
	local v16 = v11.MouseWheel * 1
	v11.MouseWheel = 0
	return v15 + v16
end

local function Keypress(_, p, p2)
	v10[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
	return Enum.ContextActionResult.Sink
end

local function GpButton(_, p, p2)
	v9[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
	return Enum.ContextActionResult.Sink
end

local function MousePan(_, _, p)
	local delta = p.Delta
	v11.Delta = Vector2.new(-delta.y, -delta.x)
	return Enum.ContextActionResult.Sink
end

local function Thumb(_, _, p)
	v9[p.KeyCode.Name] = p.Position
	return Enum.ContextActionResult.Sink
end

local function Trigger(_, _, p)
	v9[p.KeyCode.Name] = p.Position.z
	return Enum.ContextActionResult.Sink
end

local function MouseWheel(_, _, p)
	v11[p.UserInputType.Name] = -p.Position.z
	return Enum.ContextActionResult.Sink
end

local function Zero(items)
	for k, item in pairs(items) do
		items[k] = item * 0
	end
end

function v8.StartCapture()
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

function v8.StopCapture()
	v14 = 1
	local v15 = v9

	for k, v16 in pairs(v15) do
		v15[k] = v16 * 0
	end

	local v16 = v10

	for k, v17 in pairs(v16) do
		v16[k] = v17 * 0
	end

	local v17 = v11

	for k, v18 in pairs(v17) do
		v17[k] = v18 * 0
	end

	ContextActionService:UnbindAction("FreecamKeyboard")
	ContextActionService:UnbindAction("FreecamMousePan")
	ContextActionService:UnbindAction("FreecamMouseWheel")
	ContextActionService:UnbindAction("FreecamGamepadButton")
	ContextActionService:UnbindAction("FreecamGamepadTrigger")
	ContextActionService:UnbindAction("FreecamGamepadThumbstick")
end

local function StepFreecam(p)
	local v15 = v5:Update(p, v8.Vel(p))
	local v16 = v6:Update(p, v8.Pan(p))
	local v17 = v7:Update(p, v8.Fov(p))
	local v21 = sqrt(0.7002075382097097 / tan((rad(fieldOfView / 2))))
	fieldOfView = clamp(fieldOfView + v17 * 300 * (p / v21), 1, 120)
	vector3 += v16 * v4 * (p / v21)
	vector3 = Vector2.new(clamp(vector3.x, -1.5707963267948966, 1.5707963267948966), vector3.y % 6.283185307179586)
	local v23 = CFrame.new(vector2) * CFrame.fromOrientation(vector3.x, vector3.y, 0) * CFrame.new(v15 * createVector(
		64,
		64,
		64
	) * p)
	vector2 = v23.p
	currentCamera.CFrame = v23
	currentCamera.Focus = v23
	currentCamera.FieldOfView = fieldOfView
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckMouseLockAvailability()
	local devEnableMouseLock = Players.LocalPlayer.DevEnableMouseLock
	local v15 = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local v16 = gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local v17 = gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	return devEnableMouseLock and v16 and not v17 and not v15
end

local v15 = {}
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

function v15.Push()
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
	currentCamera.FieldOfView = 70
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

function v15.Pop()
	for k, v16 in pairs(coreGuiEnableds) do
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], v16)
	end

	for k, v16 in pairs(cores) do
		StarterGui:SetCore(k, v16)
	end

	for _, v16 in pairs(screenGuis) do
		if v16.Parent then
			v16.Enabled = true
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
	if v2 then
		script:SetAttribute("FreecamEnabled", true)
	end

	local cFrame2 = currentCamera.CFrame
	vector3 = Vector2.new(cFrame2:toEulerAnglesYXZ())
	vector2 = cFrame2.p
	fieldOfView = currentCamera.FieldOfView
	v5:Reset((Vector3.new()))
	v6:Reset(Vector2.new())
	v7:Reset(0)
	v15.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	v8.StartCapture()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopFreecam()
	if v2 then
		script:SetAttribute("FreecamEnabled", false)
	end

	v8.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	v15.Pop()
end

local v16 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function ToggleFreecam()
	if v16 then
		StopFreecam() -- equivalent call inferred; original call site unknown
	else
		StartFreecam()
	end

	v16 = not v16
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
	if p == Enum.UserInputState.Begin and p2.KeyCode == v3[#v3] then
		CheckMacro(v3)
	end

	return Enum.ContextActionResult.Pass
end

ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, value, v3[#v3])

if v2 then
	script:SetAttribute("FreecamEnabled", v16)
	script:GetAttributeChangedSignal("FreecamEnabled"):Connect(function()
		local freecamEnabled = script:GetAttribute("FreecamEnabled")

		if typeof(freecamEnabled) ~= "boolean" then
			script:SetAttribute("FreecamEnabled", v16)
		elseif freecamEnabled ~= v16 then
			if freecamEnabled then
				StartFreecam()
				v16 = true
			else
				StopFreecam() -- equivalent call inferred; original call site unknown
				v16 = false
			end
		end
	end)
end