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
game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local gameSettings = UserSettings().GameSettings
local Lighting = game:GetService("Lighting")

if not Players.LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	local _ = Players.LocalPlayer
end

local currentCamera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local currentCamera2 = Workspace.CurrentCamera

	if currentCamera2 then
		currentCamera = currentCamera2
	end
end)
local depthOfFieldEffect = nil
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserExitFreecamBreaksWithShiftlock")
end)
local v = success and result
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserShowGuiHideToggles")
end)
local v2 = success2 and result2
local success3, result3 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixFreecamDeltaTimeCalculation")
end)
local v3 = success3 and result3
local success4, result4 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixFreecamGuiChangeVisibility")
end)
local v4 = success4 and result4
local success5, result5 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamControlSpeed")
end)
local v5 = success5 and result5
local success6, result6 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamTiltControl")
end)
local v6 = success6 and result6
local success7, result7 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamSmoothnessControl")
end)
local v7 = success7 and result7
local success8, result8 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamGuiDestabilization")
end)
local v8 = success8 and result8
local success9, result9 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamDepthOfFieldEffect")
end)
local v9 = success9 and result9
local _ = Enum.ContextActionPriority.Low.Value
local value = Enum.ContextActionPriority.High.Value
local _ = { Enum.KeyCode.LeftShift, Enum.KeyCode.P }
local v10 = {
	[Enum.KeyCode.Z] = true,
	[Enum.KeyCode.C] = true
}
local v11 = {
	[Enum.KeyCode.ButtonL1] = true,
	[Enum.KeyCode.ButtonR1] = true
}
local v12 = {
	[Enum.KeyCode.BackSlash] = true
}
local v13 = Vector2.new(0.75, 1) * 8
local v14 = 5
local v15 = 5
local v16 = 4
local v17 = 5
local nows = {}
local v18 = 0
local depthOfFieldEffects = {}
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
	local v19 = self.f * 2 * 3.141592653589793
	local p3 = self.p
	local v20 = self.v
	local v21 = p2 - p3
	local v23 = exp(-v19 * p)
	local v24 = p2 + (v20 * p - v21 * (v19 * p + 1)) * v23
	local v25 = (v19 * p * (v21 * v19 - v20) + v20) * v23
	self.p = v24
	self.v = v25
	return v24
end

function class:SetFreq(p2)
	self.f = p2
end

function class:Reset(p2)
	self.p = p2
	self.v = p2 * 0
end

local vector2 = Vector3.new()
local vector3

if v6 then
	vector3 = Vector3.new()
else
	vector3 = Vector2.new()
end

local fieldOfView = 0
local v19 = class.new(v14, (Vector3.new()))
local v20 = class.new(v15, Vector2.new())
local v21 = class.new(v16, 0)
local v22 = class.new(v17, 0)
local v23 = {}

local function fCurve(p)
	return (exp(2 * p) - 1) / 6.38905609893065
end

local function fDeadzone(p)
	return (exp(2 * ((p - 0.15) / 0.85)) - 1) / 6.38905609893065
end

local function thumbstickCurve(p)
	return sign(p) * clamp((exp(2 * ((abs(p) - 0.15) / 0.85)) - 1) / 6.38905609893065, 0, 1)
end

local v24 = {
	ButtonX = 0,
	ButtonY = 0,
	DPadDown = 0,
	DPadUp = 0,
	DPadLeft = 0,
	DPadRight = 0,
	ButtonL2 = 0,
	ButtonR2 = 0,
	ButtonL1 = 0,
	ButtonR1 = 0,
	Thumbstick1 = Vector2.new(),
	Thumbstick2 = Vector2.new()
}
local v25 = {
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
	Left = 0,
	Right = 0,
	LeftShift = 0,
	RightShift = 0,
	Z = 0,
	C = 0,
	Comma = 0,
	Period = 0,
	LeftBracket = 0,
	RightBracket = 0,
	Semicolon = 0,
	Quote = 0,
	V = 0,
	B = 0,
	N = 0,
	M = 0,
	BackSlash = 0,
	Minus = 0,
	Equals = 0
}
local v26 = {
	Delta = Vector2.new(),
	MouseWheel = 0
}
local v27 = Vector2.new(1, 1) * 0.04908738521234052
local v28 = v27 / 60
local v29 = Vector2.new(1, 1) * 0.39269908169872414
local v30 = {
	FarIntensity = {
		ADJ = 0.1,
		MIN = 0,
		MAX = 1
	},
	NearIntensity = {
		ADJ = 0.1,
		MIN = 0,
		MAX = 1
	},
	FocusDistance = {
		ADJ = 20,
		MIN = 0,
		MAX = 200
	},
	FocusRadius = {
		ADJ = 5,
		MIN = 0,
		MAX = 50
	}
}
local v31 = 1
local v32 = 1
local v33 = 1

function v23.Vel(p)
	if v5 then
		v31 = clamp(v31 + p * (v25.Up - v25.Down + v24.DPadUp - v24.DPadDown) * 0.75, 0.01, 4)
	else
		v31 = clamp(v31 + p * (v25.Up - v25.Down) * 0.75, 0.01, 4)
	end

	local v34 = Vector3.new(
		thumbstickCurve(v24.Thumbstick1.X),
		thumbstickCurve(v24.ButtonR2) - thumbstickCurve(v24.ButtonL2),
		thumbstickCurve(-v24.Thumbstick1.Y)
	) * createVector(1, 1, 1)
	local v35 = Vector3.new(v25.D - v25.A + v25.K - v25.H, v25.E - v25.Q + v25.I - v25.Y, v25.S - v25.W + v25.J - v25.U) * createVector(
		1,
		1,
		1
	)
	local v36 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	return (v34 + v35) * (v31 * (v36 and 0.25 or 1))
end

function v23.Pan(p)
	local v34 = Vector2.new(thumbstickCurve(v24.Thumbstick2.Y), thumbstickCurve(-v24.Thumbstick2.X)) * v29
	local v35 = v26.Delta * v27

	if v3 and p > 0 then
		v35 = v26.Delta / p * v28
	end

	v26.Delta = Vector2.new()
	return v34 + v35
end

function v23.Fov(p)
	if v5 then
		v33 = clamp(v33 + p * (v25.Right - v25.Left + v24.DPadRight - v24.DPadLeft) * 0.75, 0.01, 4)
	end

	local v34 = (v24.ButtonX - v24.ButtonY) * 0.25
	local v35 = v26.MouseWheel * 1

	if v3 and p > 0 then
		v35 = v26.MouseWheel / p * 0.016666666666666666
	end

	v26.MouseWheel = 0

	if v5 then
		return (v34 + v35) * v33
	end

	return v34 + v35
end

function v23.Roll(p)
	v32 = clamp(v32 + p * (v25.Period - v25.Comma) * 0.75, 0.01, 4)
	return ((v24.ButtonR1 - v24.ButtonL1) * 1 + (v25.C - v25.Z) * 1) * v32
end

function v23.SpringControl(p)
	if v9 then
		local v34 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		local v35 = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

		if v34 or v35 then
			return
		end
	end

	v14 = clamp(v14 + p * (v25.RightBracket - v25.LeftBracket) * 0.75, 0.01, 10)
	v19:SetFreq(v14)
	v15 = clamp(v15 + p * (v25.Quote - v25.Semicolon) * 0.75, 0.01, 10)
	v20:SetFreq(v15)
	v16 = clamp(v16 + p * (v25.B - v25.V) * 0.75, 0.01, 10)
	v21:SetFreq(v16)
	v17 = clamp(v17 + p * (v25.M - v25.N) * 0.75, 0.01, 10)
	v22:SetFreq(v17)
end

function v23.DoF(p)
	local v34 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	local v35 = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

	if v34 then
		depthOfFieldEffect.FarIntensity = clamp(
			depthOfFieldEffect.FarIntensity + p * (v25.RightBracket - v25.LeftBracket) * v30.FarIntensity.ADJ,
			v30.FarIntensity.MIN,
			v30.FarIntensity.MAX
		)
		depthOfFieldEffect.InFocusRadius = clamp(
			depthOfFieldEffect.InFocusRadius + p * (v25.Equals - v25.Minus) * v30.FocusRadius.ADJ,
			v30.FocusRadius.MIN,
			v30.FocusRadius.MAX
		)
	elseif v35 then
		depthOfFieldEffect.NearIntensity = clamp(
			depthOfFieldEffect.NearIntensity + p * (v25.RightBracket - v25.LeftBracket) * v30.NearIntensity.ADJ,
			v30.NearIntensity.MIN,
			v30.NearIntensity.MAX
		)
	else
		depthOfFieldEffect.FocusDistance = clamp(
			depthOfFieldEffect.FocusDistance + p * (v25.Equals - v25.Minus) * v30.FocusDistance.ADJ,
			v30.FocusDistance.MIN,
			v30.FocusDistance.MAX
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetKeys(items, p)
	for k, _ in pairs(items) do
		if p[k.Name] then
			p[k.Name] = 0
		end
	end
end

local function handleDoubleTapReset(keyCode)
	local now = os.clock()
	local v34 = nows[keyCode]
	local v35 = not v34 and -1 or now - v34 or -1

	if v34 and v35 <= 0.25 and now - v18 >= 0.1 then
		vector3 = Vector3.new(vector3.x, vector3.y, 0)
		v22:Reset(0)

		if v9 then
			resetKeys(v11, v24) -- equivalent call inferred; original call site unknown
			resetKeys(v10, v25) -- equivalent call inferred; original call site unknown
		else
			v24.ButtonL1 = 0
			v24.ButtonR1 = 0
			v25.C = 0
			v25.Z = 0
		end

		v18 = now
	end

	nows[keyCode] = now
end

local function Keypress(_, p, p2)
	v25[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0

	if v6 and v10[p2.KeyCode] and p2.UserInputState == Enum.UserInputState.Begin then
		handleDoubleTapReset(p2.KeyCode)
	end

	if not v9 or not v12[p2.KeyCode] or p2.UserInputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Sink
	end

	if depthOfFieldEffect.Enabled then
		for _, v34 in ipairs(depthOfFieldEffects) do
			if v34.Parent then
				v34.Enabled = true
			end
		end

		depthOfFieldEffects = {}
	else
		depthOfFieldEffects = {}

		for _, depthOfFieldEffect2 in ipairs(currentCamera:GetChildren()) do
			if not (depthOfFieldEffect2:IsA("DepthOfFieldEffect") and depthOfFieldEffect2.Enabled) then
				continue
			end

			depthOfFieldEffects[#depthOfFieldEffects + 1] = depthOfFieldEffect2
			depthOfFieldEffect2.Enabled = false
		end

		for _, depthOfFieldEffect2 in ipairs(Lighting:GetChildren()) do
			if not (depthOfFieldEffect2:IsA("DepthOfFieldEffect") and depthOfFieldEffect2.Enabled) then
				continue
			end

			depthOfFieldEffects[#depthOfFieldEffects + 1] = depthOfFieldEffect2
			depthOfFieldEffect2.Enabled = false
		end

		currentCamera.ChildAdded:Connect(function(depthOfFieldEffect2)
			if depthOfFieldEffect2:IsA("DepthOfFieldEffect") and depthOfFieldEffect2.Enabled then
				depthOfFieldEffects[#depthOfFieldEffects + 1] = depthOfFieldEffect2
				depthOfFieldEffect2.Enabled = false
			end
		end)
		Lighting.ChildAdded:Connect(function(depthOfFieldEffect2)
			if depthOfFieldEffect2:IsA("DepthOfFieldEffect") and depthOfFieldEffect2.Enabled then
				depthOfFieldEffects[#depthOfFieldEffects + 1] = depthOfFieldEffect2
				depthOfFieldEffect2.Enabled = false
			end
		end)
	end

	depthOfFieldEffect.Enabled = not depthOfFieldEffect.Enabled
	resetKeys(v12, v25) -- equivalent call inferred; original call site unknown
	return Enum.ContextActionResult.Sink
end

local function GpButton(_, p, p2)
	v24[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0

	if v6 and v11[p2.KeyCode] and p2.UserInputState == Enum.UserInputState.Begin then
		handleDoubleTapReset(p2.KeyCode)
	end

	return Enum.ContextActionResult.Sink
end

local function MousePan(_, _, p)
	local delta = p.Delta
	v26.Delta = Vector2.new(-delta.y, -delta.x)
	return Enum.ContextActionResult.Sink
end

local function Thumb(_, _, p)
	v24[p.KeyCode.Name] = p.Position
	return Enum.ContextActionResult.Sink
end

local function Trigger(_, _, p)
	v24[p.KeyCode.Name] = p.Position.z
	return Enum.ContextActionResult.Sink
end

local function MouseWheel(_, _, p)
	v26[p.UserInputType.Name] = -p.Position.z
	return Enum.ContextActionResult.Sink
end

local function Zero(items)
	for k, item in pairs(items) do
		items[k] = item * 0
	end
end

function v23.StartCapture()
	if v5 then
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboard",
			Keypress,
			false,
			value,
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
			Enum.KeyCode.Y
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardControlSpeed",
			Keypress,
			false,
			value,
			Enum.KeyCode.Up,
			Enum.KeyCode.Down,
			Enum.KeyCode.Left,
			Enum.KeyCode.Right
		)
		ContextActionService:BindActionAtPriority(
			"FreecamGamepadControlSpeed",
			GpButton,
			false,
			value,
			Enum.KeyCode.DPadUp,
			Enum.KeyCode.DPadDown,
			Enum.KeyCode.DPadLeft,
			Enum.KeyCode.DPadRight
		)
	else
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboard",
			Keypress,
			false,
			value,
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
	end

	if v6 then
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardTiltControl",
			Keypress,
			false,
			value,
			Enum.KeyCode.Z,
			Enum.KeyCode.C
		)
		ContextActionService:BindActionAtPriority(
			"FreecamGamepadTiltControl",
			GpButton,
			false,
			value,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardTiltControlSpeed",
			Keypress,
			false,
			value,
			Enum.KeyCode.Comma,
			Enum.KeyCode.Period
		)

		if v7 then
			ContextActionService:BindActionAtPriority(
				"FreecamKeyboardSmoothnessControl",
				Keypress,
				false,
				value,
				Enum.KeyCode.LeftBracket,
				Enum.KeyCode.RightBracket,
				Enum.KeyCode.Semicolon,
				Enum.KeyCode.Quote,
				Enum.KeyCode.V,
				Enum.KeyCode.B,
				Enum.KeyCode.N,
				Enum.KeyCode.M
			)
		end
	end

	if v9 then
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardDoFToggle",
			Keypress,
			false,
			value,
			Enum.KeyCode.BackSlash
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardDoFControls",
			Keypress,
			false,
			value,
			Enum.KeyCode.Minus,
			Enum.KeyCode.Equals
		)
	end

	ContextActionService:BindActionAtPriority(
		"FreecamMousePan",
		MousePan,
		false,
		value,
		Enum.UserInputType.MouseMovement
	)
	ContextActionService:BindActionAtPriority(
		"FreecamMouseWheel",
		MouseWheel,
		false,
		value,
		Enum.UserInputType.MouseWheel
	)
	ContextActionService:BindActionAtPriority(
		"FreecamGamepadButton",
		GpButton,
		false,
		value,
		Enum.KeyCode.ButtonX,
		Enum.KeyCode.ButtonY
	)
	ContextActionService:BindActionAtPriority(
		"FreecamGamepadTrigger",
		Trigger,
		false,
		value,
		Enum.KeyCode.ButtonR2,
		Enum.KeyCode.ButtonL2
	)
	ContextActionService:BindActionAtPriority(
		"FreecamGamepadThumbstick",
		Thumb,
		false,
		value,
		Enum.KeyCode.Thumbstick1,
		Enum.KeyCode.Thumbstick2
	)
end

function v23.StopCapture()
	v31 = 1

	if v5 then
		v33 = 1
	end

	if v6 then
		v32 = 1
	end

	local v34 = v24

	for k, v35 in pairs(v34) do
		v34[k] = v35 * 0
	end

	local v35 = v25

	for k, v36 in pairs(v35) do
		v35[k] = v36 * 0
	end

	local v36 = v26

	for k, v37 in pairs(v36) do
		v36[k] = v37 * 0
	end

	ContextActionService:UnbindAction("FreecamKeyboard")

	if v5 then
		ContextActionService:UnbindAction("FreecamKeyboardControlSpeed")
		ContextActionService:UnbindAction("FreecamGamepadControlSpeed")
	end

	if v6 then
		ContextActionService:UnbindAction("FreecamKeyboardTiltControl")
		ContextActionService:UnbindAction("FreecamGamepadTiltControl")
		ContextActionService:UnbindAction("FreecamKeyboardTiltControlSpeed")

		if v7 then
			ContextActionService:UnbindAction("FreecamKeyboardSmoothnessControl")
		end
	end

	if v9 then
		ContextActionService:UnbindAction("FreecamKeyboardDoFToggle")
		ContextActionService:UnbindAction("FreecamKeyboardDoFControls")
	end

	ContextActionService:UnbindAction("FreecamMousePan")
	ContextActionService:UnbindAction("FreecamMouseWheel")
	ContextActionService:UnbindAction("FreecamGamepadButton")
	ContextActionService:UnbindAction("FreecamGamepadTrigger")
	ContextActionService:UnbindAction("FreecamGamepadThumbstick")
end

local function GetFocusDistance(data)
	local viewportSize = currentCamera.ViewportSize
	local v35 = tan(fieldOfView / 2) * 2
	local v36 = viewportSize.x / viewportSize.y * v35
	local rightVector = data.rightVector
	local upVector = data.upVector
	local lookVector = data.lookVector
	local vector4 = Vector3.new()
	local v37 = 512

	for i = 0, 1, 0.5 do
		for i2 = 0, 1, 0.5 do
			local v38 = (i - 0.5) * v36
			local v39 = (i2 - 0.5) * v35
			local v40 = rightVector * v38 - upVector * v39 + lookVector
			local v41 = data.p + v40 * 0.1
			local _, v42 = Workspace:FindPartOnRay(Ray.new(v41, v40.unit * v37))
			local magnitude = (v42 - v41).magnitude

			if not (magnitude < v37) then
				continue
			end

			vector4 = v40.unit
			v37 = magnitude
		end
	end

	return lookVector:Dot(vector4) * v37
end

local function StepFreecam(p)
	if v7 then
		v23.SpringControl(p)
	end

	if v9 and depthOfFieldEffect and depthOfFieldEffect.Parent then
		v23.DoF(p)
	end

	local v34 = v19:Update(p, v23.Vel(p))
	local v35 = v20:Update(p, v23.Pan(p))
	local v36 = v21:Update(p, v23.Fov(p))
	local v37

	if v6 then
		v37 = v22:Update(p, v23.Roll(p))
	end

	local v41 = sqrt(0.7002075382097097 / tan((rad(fieldOfView / 2))))
	fieldOfView = clamp(fieldOfView + v36 * 300 * (p / v41), 1, 120)
	local cFrame2

	if v6 then
		local v44 = v35 * v13 * (p / v41)
		vector3 += Vector3.new(v44.X, v44.Y, v37 * -1.5707963267948966 * (p / v41))

		if v7 then
			vector3 = Vector3.new(
				vector3.x % 6.283185307179586,
				vector3.y % 6.283185307179586,
				vector3.z % 6.283185307179586
			)
		else
			local x = vector3.x
			vector3 = Vector3.new(
				clamp(x, -1.5707963267948966, 1.5707963267948966),
				vector3.y % 6.283185307179586,
				vector3.z
			)
		end

		cFrame2 = CFrame.new(vector2) * CFrame.fromOrientation(vector3.x, vector3.y, vector3.z) * CFrame.new(v34 * createVector(
			50,
			50,
			50
		) * p)
	else
		vector3 += v35 * v13 * (p / v41)
		vector3 = Vector2.new(clamp(vector3.x, -1.5707963267948966, 1.5707963267948966), vector3.y % 6.283185307179586)
		cFrame2 = CFrame.new(vector2) * CFrame.fromOrientation(vector3.x, vector3.y, 0) * CFrame.new(v34 * createVector(
			50,
			50,
			50
		) * p)
	end

	vector2 = cFrame2.p
	currentCamera.CFrame = cFrame2
	currentCamera.Focus = cFrame2 * CFrame.new(0, 0, -GetFocusDistance(cFrame2))
	currentCamera.FieldOfView = fieldOfView
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckMouseLockAvailability()
	local devEnableMouseLock = Players.LocalPlayer.DevEnableMouseLock
	local v34 = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local v35 = gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local v36 = gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	return devEnableMouseLock and v35 and not v36 and not v34
end

local v34 = {}
local default = nil
local mouseIconEnabled = nil
local cameraType = nil
local focus = nil
local cFrame = nil
local fieldOfView2 = nil
local v35 = {}
local _ = {
	Backpack = true,
	Chat = true,
	Health = true,
	PlayerList = true
}
local _ = {
	BadgesNotificationsActive = true,
	PointsNotificationsActive = true
}

function v34.Push()
	fieldOfView2 = currentCamera.FieldOfView
	currentCamera.FieldOfView = 70
	cameraType = currentCamera.CameraType
	currentCamera.CameraType = Enum.CameraType.Custom
	cFrame = currentCamera.CFrame
	focus = currentCamera.Focus
	mouseIconEnabled = UserInputService.MouseIconEnabled
	UserInputService.MouseIconEnabled = true

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

function v34.Pop()
	if v4 then
		v35 = {}
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
	if not v8 and v2 then
		script:SetAttribute("FreecamEnabled", true)
	end

	local cFrame2 = currentCamera.CFrame

	if v6 then
		vector3 = Vector3.new(cFrame2:toEulerAnglesYXZ())
	else
		vector3 = Vector2.new(cFrame2:toEulerAnglesYXZ())
	end

	vector2 = cFrame2.p
	fieldOfView = currentCamera.FieldOfView
	v19:Reset((Vector3.new()))
	v20:Reset(Vector2.new())
	v21:Reset(0)

	if v6 then
		v22:Reset(0)
	end

	if v7 then
		v14 = 1.5
		v15 = 1
		v16 = 4
		v17 = 1
	end

	v34.Push()

	if v9 and not (depthOfFieldEffect and depthOfFieldEffect.Parent) then
		depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
		depthOfFieldEffect.Enabled = false
		depthOfFieldEffect.Name = "FreecamDepthOfField"
		depthOfFieldEffect.Parent = currentCamera
	end

	RunService:BindToRenderStep("CustomFreecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	v23.StartCapture()
end

local function StopFreecam()
	if not v8 and v2 then
		script:SetAttribute("FreecamEnabled", false)
	end

	if v9 and depthOfFieldEffect and depthOfFieldEffect.Parent then
		if depthOfFieldEffect.Enabled then
			for _, v36 in ipairs(depthOfFieldEffects) do
				if v36.Parent then
					v36.Enabled = true
				end
			end

			depthOfFieldEffects = {}
		end

		depthOfFieldEffect.Enabled = false
	end

	v23.StopCapture()
	RunService:UnbindFromRenderStep("CustomFreecam")
	v34.Pop()
end

local v36 = false
script:WaitForChild("Toggle").Event:Connect(function(p)
	if p and not v36 then
		StartFreecam()
	elseif not p and v36 then
		StopFreecam()
	end

	v36 = p
end)