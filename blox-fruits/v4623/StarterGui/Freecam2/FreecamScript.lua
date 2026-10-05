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
local value = Enum.ContextActionPriority.Low.Value
local value2 = Enum.ContextActionPriority.High.Value
local v = { Enum.KeyCode.LeftShift, Enum.KeyCode.P }
local v2 = { Enum.KeyCode.LeftShift, Enum.KeyCode.F }
local v3 = Vector2.new(0.75, 1) * 8
local v4 = false
local flag = false
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
local v7 = class.new(1, 0)
local v8 = class.new(1, 0)
local v9 = {}

local function fCurve(p)
	return (exp(2 * p) - 1) / 6.38905609893065
end

local function fDeadzone(p)
	return (exp(2 * ((p - 0.15) / 0.85)) - 1) / 6.38905609893065
end

local function thumbstickCurve(p)
	return sign(p) * clamp((exp(2 * ((abs(p) - 0.15) / 0.85)) - 1) / 6.38905609893065, 0, 1)
end

local v10 = {
	ButtonX = 0,
	ButtonY = 0,
	DPadDown = 0,
	DPadUp = 0,
	ButtonL2 = 0,
	ButtonR2 = 0,
	Thumbstick1 = Vector2.new(),
	Thumbstick2 = Vector2.new()
}
local v11 = {
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
local v12 = {
	Delta = Vector2.new(),
	MouseWheel = 0
}
local v13 = Vector2.new(1, 1) * 0.04908738521234052
local v14 = Vector2.new(1, 1) * 0.39269908169872414
local v15 = 1

function v9.Vel(p)
	v15 = clamp(v15 + p * (v11.Up - v11.Down) * 0.75, 0.01, 4)
	local v17 = Vector3.new(
		thumbstickCurve(v10.Thumbstick1.X),
		thumbstickCurve(v10.ButtonR2) - thumbstickCurve(v10.ButtonL2),
		thumbstickCurve(-v10.Thumbstick1.Y)
	) * createVector(1, 1, 1) * 1
	local v18 = Vector3.new(v11.D - v11.A + v11.K - v11.H, v11.E - v11.Q + v11.I - v11.Y, v11.S - v11.W + v11.J - v11.U) * createVector(
		1,
		1,
		1
	) * 1
	local v19 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	local isKeyDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
	local isKeyDown2 = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
	return (v17 + v18) * (v15 * (v19 and 0.25 or 1) * (isKeyDown and 4 or 1) * (isKeyDown2 and 0.1 or 1))
end

function v9.Pan(_)
	local v16 = Vector2.new(thumbstickCurve(v10.Thumbstick2.Y), thumbstickCurve(-v10.Thumbstick2.X)) * v14
	local v17 = v12.Delta * v13
	v12.Delta = Vector2.new()
	return v16 + v17
end

function v9.Fov(_)
	local v16 = (v10.ButtonX - v10.ButtonY) * 0.25
	local v17 = v12.MouseWheel * 1
	v12.MouseWheel = 0
	return v16 + v17
end

local function Keypress(_, p, p2)
	v11[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
	return Enum.ContextActionResult.Sink
end

local function GpButton(_, p, p2)
	v10[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
	return Enum.ContextActionResult.Sink
end

local function MousePan(_, _, p)
	local delta = p.Delta
	v12.Delta = Vector2.new(-delta.y, -delta.x)
	return Enum.ContextActionResult.Sink
end

local function Thumb(_, _, p)
	v10[p.KeyCode.Name] = p.Position
	return Enum.ContextActionResult.Sink
end

local function Trigger(_, _, p)
	v10[p.KeyCode.Name] = p.Position.z
	return Enum.ContextActionResult.Sink
end

local function MouseWheel(_, _, p)
	v12[p.UserInputType.Name] = -p.Position.z
	return Enum.ContextActionResult.Sink
end

local function Zero(items)
	for k, item in pairs(items) do
		items[k] = item * 0
	end
end

function v9.StartCapture()
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

function v9.StopCapture()
	v15 = 1
	local v16 = v10

	for k, v17 in pairs(v16) do
		v16[k] = v17 * 0
	end

	local v17 = v11

	for k, v18 in pairs(v17) do
		v17[k] = v18 * 0
	end

	local v18 = v12

	for k, v19 in pairs(v18) do
		v18[k] = v19 * 0
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
	local v17 = tan(fieldOfView / 2) * 2
	local v18 = viewportSize.x / viewportSize.y * v17
	local rightVector = data.rightVector
	local upVector = data.upVector
	local lookVector = data.lookVector
	local vector4 = Vector3.new()
	local v19 = 512

	for i = 0, 1, 0.5 do
		for i2 = 0, 1, 0.5 do
			local v20 = (i - 0.5) * v18
			local v21 = (i2 - 0.5) * v17
			local v22 = rightVector * v20 - upVector * v21 + lookVector
			local v23 = data.p + v22 * 0.1
			local _, v24 = Workspace:FindPartOnRay(Ray.new(v23, v22.unit * v19))
			local magnitude = (v24 - v23).magnitude

			if not (magnitude < v19) then
				continue
			end

			vector4 = v22.unit
			v19 = magnitude
		end
	end

	return lookVector:Dot(vector4) * v19
end

local function StepFreecam(p)
	local v16 = v5:Update(p, v9.Vel(p))
	local v17 = v6:Update(p, v9.Pan(p))
	local v18 = v7:Update(p, v9.Fov(p))
	local v22 = sqrt(0.7002075382097097 / tan((rad(fieldOfView / 2))))

	if flag then
		fieldOfView += (70 - fieldOfView) * p * 5
	else
		fieldOfView = clamp(fieldOfView + v18 * 600 * (p / v22), 1, 120)
	end

	vector3 += v17 * v3 * (p / v22)
	vector3 = Vector2.new(clamp(vector3.x, -1.5707963267948966, 1.5707963267948966), vector3.y % 6.283185307179586)
	local v24 = v8:Update(p, not v4 and 0 or v16.X * 0.1 or 0)
	local cFrame2 = CFrame.new(vector2) * CFrame.fromOrientation(vector3.x, vector3.y, 0) * CFrame.new(v16 * createVector(
		64,
		64,
		64
	) * p) * CFrame.Angles(0, 0, (math.clamp(v24, -0.5, 0.5)))
	vector2 = cFrame2.p
	currentCamera.CFrame = cFrame2
	currentCamera.Focus = cFrame2 * CFrame.new(0, 0, -GetFocusDistance(cFrame2))
	currentCamera.FieldOfView = fieldOfView
end

local v16 = {}
local mouseBehavior = nil
local mouseIconEnabled = nil
local cameraType = nil
local focus = nil
local cFrame = nil
local fieldOfView2 = nil
local screenGuis = {}
local v17 = {
	Backpack = true,
	Chat = true,
	Health = true,
	PlayerList = true
}
local cores = {
	BadgesNotificationsActive = true,
	PointsNotificationsActive = true
}

function v16.Push()
	for k in pairs(v17) do
		v17[k] = k ~= "Backpack" and StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[k])
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
	mouseBehavior = UserInputService.MouseBehavior
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

function v16.Pop()
	for k, v18 in pairs(v17) do
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], v18)
	end

	for k, v18 in pairs(cores) do
		StarterGui:SetCore(k, v18)
	end

	for _, v18 in pairs(screenGuis) do
		if v18.Parent then
			v18.Enabled = true
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
	UserInputService.MouseBehavior = mouseBehavior
	mouseBehavior = nil
end

local function StartFreecam()
	local cFrame2 = currentCamera.CFrame
	vector3 = Vector2.new(cFrame2:toEulerAnglesYXZ())
	vector2 = cFrame2.p
	fieldOfView = currentCamera.FieldOfView
	v5:Reset((Vector3.new()))
	v6:Reset(Vector2.new())
	v7:Reset(0)
	v16.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	v9.StartCapture()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopFreecam()
	v9.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	v16.Pop()
end

local v18 = false

local function ToggleFreecam()
	if v18 then
		StopFreecam() -- equivalent call inferred; original call site unknown
	else
		StartFreecam()
	end

	v18 = not v18
end

local function CheckMacro(list, callback)
	for i = 1, #list - 1 do
		if not UserInputService:IsKeyDown(list[i]) then
			return
		end
	end

	callback()
	return true
end

local function HandleActivationInput(_, p, p2)
	if p == Enum.UserInputState.Begin then
		if p2.KeyCode == v[#v] then
			CheckMacro(v, ToggleFreecam)
		elseif p2.KeyCode == v2[#v2] and not CheckMacro(v2, function()
			v4 = not v4
		end) then
			flag = true
		end
	elseif p == Enum.UserInputState.End and p2.KeyCode == Enum.KeyCode.F then
		flag = false
	end

	return Enum.ContextActionResult.Pass
end

ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, value, v[#v], v2[#v2])