local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
module:WaitInitialization()
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
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer

if not localPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	localPlayer = Players.LocalPlayer
end

local playerGui = nil
local freecam = nil
local currentCamera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local currentCamera2 = Workspace.CurrentCamera

	if currentCamera2 then
		currentCamera = currentCamera2
	end
end)
local depthOfFieldEffect = nil
local textLabel = nil
local v = nil
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserExitFreecamBreaksWithShiftlock")
end)
local v2 = success and result
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserShowGuiHideToggles")
end)
local v3 = success2 and result2
local success3, result3 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixFreecamDeltaTimeCalculation")
end)
local v4 = success3 and result3
local success4, result4 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixFreecamGuiChangeVisibility2")
end)
local v5 = success4 and result4
local success5, result5 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamControlSpeed")
end)
local v6 = success5 and result5
local success6, result6 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamTiltControl")
end)
local v7 = success6 and result6
local success7, result7 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamSmoothnessControl")
end)
local v8 = success7 and result7
local success8, result8 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamGuiDestabilization")
end)
local v9 = success8 and result8
local success9, result9 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamDepthOfFieldEffect3")
end)
local v10 = success9 and result9
local success10, result10 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamPlayerLock2")
end)
local v11 = success10 and result10
local success11, result11 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamPlayerLockResetHeight")
end)
local v12 = success11 and result11
local success12, result12 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFreecamCustomGui")
end)
local v13 = success12 and result12
local value = Enum.ContextActionPriority.Low.Value
local value2 = Enum.ContextActionPriority.High.Value
local v14 = { Enum.KeyCode.LeftShift, Enum.KeyCode.P }
local v15 = {
	[Enum.KeyCode.Z] = true,
	[Enum.KeyCode.C] = true
}
local v16 = {
	[Enum.KeyCode.ButtonL1] = true,
	[Enum.KeyCode.ButtonR1] = true
}
local v17 = {
	[Enum.KeyCode.BackSlash] = true
}
local v18 = {
	[Enum.KeyCode.Slash] = true
}
local v19 = {
	[Enum.KeyCode.R] = true,
	[Enum.KeyCode.T] = true
}
local v20 = {
	[Enum.KeyCode.G] = true
}
local v21 = {
	[Enum.KeyCode.X] = true
}
local v22 = {
	[Enum.KeyCode.L] = true
}
local v23 = Vector2.new(0.75, 1) * 8
local v24 = 1.5
local v25 = 1
local v26 = 4
local v27 = 1
local nows = {}
local v28 = 0
local depthOfFieldEffects = {}
local childAddedConnection = nil
local childAddedConnection2 = nil
local childAddedConnection3 = nil
local playerAddedConnection = nil
local playerRemovingConnection = nil
local v29 = false
local v30 = 20
local v31 = 0
local players = {}
local v32 = 1
local v33 = nil
local enabled = false
local v35 = false
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
	local v36 = self.f * 2 * 3.141592653589793
	local p3 = self.p
	local v37 = self.v
	local v38 = p2 - p3
	local v40 = exp(-v36 * p)
	local v41 = p2 + (v37 * p - v38 * (v36 * p + 1)) * v40
	local v42 = (v36 * p * (v38 * v36 - v37) + v37) * v40
	self.p = v41
	self.v = v42
	return v41
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

if v7 then
	vector3 = Vector3.new()
else
	vector3 = Vector2.new()
end

local fieldOfView = 0
local v36 = class.new(v24, (Vector3.new()))
local v37 = class.new(v25, Vector2.new())
local v38 = class.new(v26, 0)
local v39 = class.new(v27, 0)
local v40 = {}

local function fCurve(p)
	return (exp(2 * p) - 1) / 6.38905609893065
end

local function fDeadzone(p)
	return (exp(2 * ((p - 0.15) / 0.85)) - 1) / 6.38905609893065
end

local function thumbstickCurve(p)
	return sign(p) * clamp((exp(2 * ((abs(p) - 0.15) / 0.85)) - 1) / 6.38905609893065, 0, 1)
end

local v41 = {
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
local v42 = {
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
	Equals = 0,
	Slash = 0,
	R = 0,
	T = 0,
	G = 0,
	X = 0,
	L = 0
}
local v43 = {
	Delta = Vector2.new(),
	MouseWheel = 0
}
local v44 = Vector2.new(1, 1) * 0.04908738521234052
local v45 = v44 / 60
local v46 = Vector2.new(1, 1) * 0.39269908169872414
local v47 = {
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
local v48 = 1
local v49 = 1
local v50 = 1

function v40.Vel(p)
	if v6 then
		v48 = clamp(v48 + p * (v42.Up - v42.Down + v41.DPadUp - v41.DPadDown) * 0.75, 0.01, 4)
	else
		v48 = clamp(v48 + p * (v42.Up - v42.Down) * 0.75, 0.01, 4)
	end

	local v51 = Vector3.new(
		thumbstickCurve(v41.Thumbstick1.X),
		thumbstickCurve(v41.ButtonR2) - thumbstickCurve(v41.ButtonL2),
		thumbstickCurve(-v41.Thumbstick1.Y)
	) * createVector(1, 1, 1)
	local v52 = Vector3.new(v42.D - v42.A + v42.K - v42.H, v42.E - v42.Q + v42.I - v42.Y, v42.S - v42.W + v42.J - v42.U) * createVector(
		1,
		1,
		1
	)
	local v53 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	return (v51 + v52) * (v48 * (v53 and 0.25 or 1))
end

function v40.Pan(p)
	local v51 = Vector2.new(thumbstickCurve(v41.Thumbstick2.Y), thumbstickCurve(-v41.Thumbstick2.X)) * v46
	local v52 = v43.Delta * v44

	if v4 and p > 0 then
		v52 = v43.Delta / p * v45
	end

	v43.Delta = Vector2.new()
	return v51 + v52
end

function v40.Fov(p)
	if v6 then
		v50 = clamp(v50 + p * (v42.Right - v42.Left + v41.DPadRight - v41.DPadLeft) * 0.75, 0.01, 4)
	end

	local v51 = (v41.ButtonX - v41.ButtonY) * 0.25
	local v52 = v43.MouseWheel * 1

	if v4 and p > 0 then
		v52 = v43.MouseWheel / p * 0.016666666666666666
	end

	v43.MouseWheel = 0

	if v6 then
		return (v51 + v52) * v50
	end

	return v51 + v52
end

function v40.Roll(p)
	v49 = clamp(v49 + p * (v42.Period - v42.Comma) * 0.75, 0.01, 4)
	return ((v41.ButtonR1 - v41.ButtonL1) * 1 + (v42.C - v42.Z) * 1) * v49
end

function v40.SpringControl(p)
	if v10 then
		local v51 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		local v52 = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

		if v51 or v52 then
			return
		end
	end

	v24 = clamp(v24 + p * (v42.RightBracket - v42.LeftBracket) * 0.75, 0.01, 10)
	v36:SetFreq(v24)
	v25 = clamp(v25 + p * (v42.Quote - v42.Semicolon) * 0.75, 0.01, 10)
	v37:SetFreq(v25)
	v26 = clamp(v26 + p * (v42.B - v42.V) * 0.75, 0.01, 10)
	v38:SetFreq(v26)
	v27 = clamp(v27 + p * (v42.M - v42.N) * 0.75, 0.01, 10)
	v39:SetFreq(v27)
end

function v40.DoF(p)
	local v51 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	local v52 = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

	if v51 then
		depthOfFieldEffect.FarIntensity = clamp(
			depthOfFieldEffect.FarIntensity + p * (v42.RightBracket - v42.LeftBracket) * v47.FarIntensity.ADJ,
			v47.FarIntensity.MIN,
			v47.FarIntensity.MAX
		)
		depthOfFieldEffect.InFocusRadius = clamp(
			depthOfFieldEffect.InFocusRadius + p * (v42.Equals - v42.Minus) * v47.FocusRadius.ADJ,
			v47.FocusRadius.MIN,
			v47.FocusRadius.MAX
		)
	elseif v52 then
		depthOfFieldEffect.NearIntensity = clamp(
			depthOfFieldEffect.NearIntensity + p * (v42.RightBracket - v42.LeftBracket) * v47.NearIntensity.ADJ,
			v47.NearIntensity.MIN,
			v47.NearIntensity.MAX
		)
	else
		depthOfFieldEffect.FocusDistance = clamp(
			depthOfFieldEffect.FocusDistance + p * (v42.Equals - v42.Minus) * v47.FocusDistance.ADJ,
			v47.FocusDistance.MIN,
			v47.FocusDistance.MAX
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
	local v51 = nows[keyCode]
	local v52 = not v51 and -1 or now - v51 or -1

	if v51 and v52 <= 0.25 and now - v28 >= 0.1 then
		vector3 = Vector3.new(vector3.x, vector3.y, 0)
		v39:Reset(0)

		if v10 then
			resetKeys(v16, v41) -- equivalent call inferred; original call site unknown
			resetKeys(v15, v42) -- equivalent call inferred; original call site unknown
		else
			v41.ButtonL1 = 0
			v41.ButtonR1 = 0
			v42.C = 0
			v42.Z = 0
		end

		v28 = now
	end

	nows[keyCode] = now
end

local function findPlayerLockRootPart(p)
	if not players or #players < 1 then
		return nil
	end

	for _ = 1, #players do
		v32 = (v32 - 1 + p) % #players + 1
		local v51 = players[v32]
		local character = v51 and v51.Character

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.RootPart then
				return humanoid.RootPart
			end
		end

		if p == 0 then
			p = 1
		end
	end

	v29 = false
	return nil
end

local function Keypress(_, p, data)
	v42[data.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0

	if v7 and v15[data.KeyCode] and data.UserInputState == Enum.UserInputState.Begin then
		handleDoubleTapReset(data.KeyCode)
	end

	if v10 and v17[data.KeyCode] and data.UserInputState == Enum.UserInputState.Begin then
		if depthOfFieldEffect.Enabled then
			for _, v51 in ipairs(depthOfFieldEffects) do
				if v51.Parent then
					v51.Enabled = true
				end
			end

			if childAddedConnection2 then
				childAddedConnection2:Disconnect()
				childAddedConnection2 = nil
			end

			if childAddedConnection3 then
				childAddedConnection3:Disconnect()
				childAddedConnection3 = nil
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

			childAddedConnection2 = currentCamera.ChildAdded:Connect(function(depthOfFieldEffect2)
				if depthOfFieldEffect2:IsA("DepthOfFieldEffect") and depthOfFieldEffect2.Enabled then
					depthOfFieldEffects[#depthOfFieldEffects + 1] = depthOfFieldEffect2
					depthOfFieldEffect2.Enabled = false
				end
			end)
			childAddedConnection3 = Lighting.ChildAdded:Connect(function(depthOfFieldEffect2)
				if depthOfFieldEffect2:IsA("DepthOfFieldEffect") and depthOfFieldEffect2.Enabled then
					depthOfFieldEffects[#depthOfFieldEffects + 1] = depthOfFieldEffect2
					depthOfFieldEffect2.Enabled = false
				end
			end)
		end

		depthOfFieldEffect.Enabled = not depthOfFieldEffect.Enabled
		resetKeys(v17, v42) -- equivalent call inferred; original call site unknown
	end

	if v11 then
		if v18[data.KeyCode] and data.UserInputState == Enum.UserInputState.Begin then
			v29 = not v29

			if v29 then
				v30 = 20

				if v12 then
					v31 = 0
				end

				v33 = findPlayerLockRootPart(0)
			end

			resetKeys(v18, v42) -- equivalent call inferred; original call site unknown
		end

		if v19[data.KeyCode] and data.UserInputState == Enum.UserInputState.Begin then
			if v29 and #players > 0 then
				v33 = findPlayerLockRootPart(v42.T - v42.R)
			end

			resetKeys(v19, v42) -- equivalent call inferred; original call site unknown
		end
	end

	if not v13 then
		return Enum.ContextActionResult.Sink
	end

	if v20[data.keyCode] and data.UserInputState == Enum.UserInputState.Begin then
		if freecam and freecam.Parent then
			freecam.Enabled = not freecam.Enabled
		end

		resetKeys(v20, v42) -- equivalent call inferred; original call site unknown
	end

	if v21[data.keyCode] and data.UserInputState == Enum.UserInputState.Begin then
		enabled = not enabled

		if v then
			local screenGuis = v.getScreenGuis()

			for _, v51 in pairs(screenGuis) do
				if v51.Parent and v51 ~= freecam then
					v51.Enabled = enabled
				end
			end
		end

		resetKeys(v21, v42) -- equivalent call inferred; original call site unknown
	end

	if not (v22[data.keyCode] and data.UserInputState == Enum.UserInputState.Begin) then
		return Enum.ContextActionResult.Sink
	end

	v35 = not v35
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, v35)
	resetKeys(v22, v42) -- equivalent call inferred; original call site unknown
	return Enum.ContextActionResult.Sink
end

local function GpButton(_, p, p2)
	v41[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0

	if v7 and v16[p2.KeyCode] and p2.UserInputState == Enum.UserInputState.Begin then
		handleDoubleTapReset(p2.KeyCode)
	end

	return Enum.ContextActionResult.Sink
end

local function MousePan(_, _, p)
	local delta = p.Delta
	v43.Delta = Vector2.new(-delta.y, -delta.x)
	return Enum.ContextActionResult.Sink
end

local function Thumb(_, _, p)
	v41[p.KeyCode.Name] = p.Position
	return Enum.ContextActionResult.Sink
end

local function Trigger(_, _, p)
	v41[p.KeyCode.Name] = p.Position.z
	return Enum.ContextActionResult.Sink
end

local function MouseWheel(_, _, p)
	v43[p.UserInputType.Name] = -p.Position.z
	return Enum.ContextActionResult.Sink
end

local function Zero(items)
	for k, item in pairs(items) do
		items[k] = item * 0
	end
end

function v40.StartCapture()
	if v6 then
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
			Enum.KeyCode.Y
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardControlSpeed",
			Keypress,
			false,
			value2,
			Enum.KeyCode.Up,
			Enum.KeyCode.Down,
			Enum.KeyCode.Left,
			Enum.KeyCode.Right
		)
		ContextActionService:BindActionAtPriority(
			"FreecamGamepadControlSpeed",
			GpButton,
			false,
			value2,
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
	end

	if v7 then
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardTiltControl",
			Keypress,
			false,
			value2,
			Enum.KeyCode.Z,
			Enum.KeyCode.C
		)
		ContextActionService:BindActionAtPriority(
			"FreecamGamepadTiltControl",
			GpButton,
			false,
			value2,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardTiltControlSpeed",
			Keypress,
			false,
			value2,
			Enum.KeyCode.Comma,
			Enum.KeyCode.Period
		)

		if v8 then
			ContextActionService:BindActionAtPriority(
				"FreecamKeyboardSmoothnessControl",
				Keypress,
				false,
				value2,
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

	if v10 then
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardDoFToggle",
			Keypress,
			false,
			value2,
			Enum.KeyCode.BackSlash
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardDoFControls",
			Keypress,
			false,
			value2,
			Enum.KeyCode.Minus,
			Enum.KeyCode.Equals
		)
	end

	if v11 then
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardPlayerLockToggle",
			Keypress,
			false,
			value2,
			Enum.KeyCode.Slash
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardPlayerLockSwitch",
			Keypress,
			false,
			value2,
			Enum.KeyCode.R,
			Enum.KeyCode.T
		)
	end

	if v13 then
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardCustomGuiToggle",
			Keypress,
			false,
			value2,
			Enum.KeyCode.G
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardPlayerGuiToggle",
			Keypress,
			false,
			value2,
			Enum.KeyCode.X
		)
		ContextActionService:BindActionAtPriority(
			"FreecamKeyboardLeaderboardToggle",
			Keypress,
			false,
			value2,
			Enum.KeyCode.L
		)
	end

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

function v40.StopCapture()
	if not v13 then
		v48 = 1

		if v6 then
			v50 = 1
		end

		if v7 then
			v49 = 1
		end
	end

	local v51 = v41

	for k, v52 in pairs(v51) do
		v51[k] = v52 * 0
	end

	local v52 = v42

	for k, v53 in pairs(v52) do
		v52[k] = v53 * 0
	end

	local v53 = v43

	for k, v54 in pairs(v53) do
		v53[k] = v54 * 0
	end

	ContextActionService:UnbindAction("FreecamKeyboard")

	if v6 then
		ContextActionService:UnbindAction("FreecamKeyboardControlSpeed")
		ContextActionService:UnbindAction("FreecamGamepadControlSpeed")
	end

	if v7 then
		ContextActionService:UnbindAction("FreecamKeyboardTiltControl")
		ContextActionService:UnbindAction("FreecamGamepadTiltControl")
		ContextActionService:UnbindAction("FreecamKeyboardTiltControlSpeed")

		if v8 then
			ContextActionService:UnbindAction("FreecamKeyboardSmoothnessControl")
		end
	end

	if v10 then
		ContextActionService:UnbindAction("FreecamKeyboardDoFToggle")
		ContextActionService:UnbindAction("FreecamKeyboardDoFControls")
	end

	if v11 then
		ContextActionService:UnbindAction("FreecamKeyboardPlayerLockToggle")
		ContextActionService:UnbindAction("FreecamKeyboardPlayerLockSwitch")
	end

	if v13 then
		ContextActionService:UnbindAction("FreecamKeyboardCustomGuiToggle")
		ContextActionService:UnbindAction("FreecamKeyboardPlayerGuiToggle")
		ContextActionService:UnbindAction("FreecamKeyboardLeaderboardToggle")
	end

	ContextActionService:UnbindAction("FreecamMousePan")
	ContextActionService:UnbindAction("FreecamMouseWheel")
	ContextActionService:UnbindAction("FreecamGamepadButton")
	ContextActionService:UnbindAction("FreecamGamepadTrigger")
	ContextActionService:UnbindAction("FreecamGamepadThumbstick")
end

function v40.getNavSpeed()
	return v48
end

function v40.getFovSpeed()
	return v50
end

function v40.getRollSpeed()
	return v49
end

local function StepFreecam(p)
	if v8 then
		v40.SpringControl(p)
	end

	if v10 and depthOfFieldEffect and depthOfFieldEffect.Parent then
		v40.DoF(p)
	end

	local v51 = v36:Update(p, v40.Vel(p))
	local v52 = v37:Update(p, v40.Pan(p))
	local v53 = v38:Update(p, v40.Fov(p))
	local v54

	if v7 then
		v54 = v39:Update(p, v40.Roll(p))
	end

	local v58 = sqrt(0.7002075382097097 / tan((rad(fieldOfView / 2))))
	fieldOfView = clamp(fieldOfView + v53 * 300 * (p / v58), 1, 120)
	local v60

	if v7 then
		local v61 = v52 * v23 * (p / v58)
		vector3 += Vector3.new(v61.X, v61.Y, v54 * -1.5707963267948966 * (p / v58))

		if v8 then
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

		v60 = CFrame.new(vector2) * CFrame.fromOrientation(vector3.x, vector3.y, vector3.z) * CFrame.new(v51 * createVector(
			64,
			64,
			64
		) * p)
	else
		vector3 += v52 * v23 * (p / v58)
		vector3 = Vector2.new(clamp(vector3.x, -1.5707963267948966, 1.5707963267948966), vector3.y % 6.283185307179586)
		v60 = CFrame.new(vector2) * CFrame.fromOrientation(vector3.x, vector3.y, 0) * CFrame.new(v51 * createVector(
			64,
			64,
			64
		) * p)
	end

	if v11 and v29 and v33 then
		local v61 = v51.Z * 64 * p
		local v62 = v51.Y * 64 * p
		v30 = clamp(v30 + v61, 5, 50)
		v31 = clamp(v31 + v62, -10, 10)
		local cframe = CFrame.new(v33.Position + Vector3.new(0, v31, 0))
		local v65

		if v7 then
			v65 = CFrame.fromOrientation(vector3.x, vector3.y, vector3.z)
		else
			v65 = CFrame.fromOrientation(vector3.x, vector3.y, 0)
		end

		v60 = cframe * v65 * CFrame.new(0, 0, v30)
	end

	if v13 and textLabel and textLabel.Parent and freecam and freecam.Parent and freecam.Enabled then
		local v61 = ""

		if p > 0 then
			local v62 = (v60.p - vector2) / p
			v61 ..= string.format("Velocity: (%.1f, %.1f, %.1f)\n", v62.X, v62.Y, v62.Z)
		end

		local text = v61 .. string.format("FOV: %.1f\n", fieldOfView)

		if v7 then
			text ..= string.format("Tilt: %.1f°\n", (math.deg(vector3.z)))
		end

		if v8 then
			text = (((text .. string.format("Stiffness (Vel): %.1f\n", v24)) .. string.format(
				"Stiffness (Pan): %.1f\n",
				v25
			)) .. string.format("Stiffness (FOV): %.1f\n", v26)) .. string.format("Stiffness (Roll): %.1f\n", v27)
		end

		if v6 then
			text = ((text .. string.format("Movement Speed: %.1f\n", v40.getNavSpeed())) .. string.format(
				"Zoom Speed: %.1f\n",
				v40.getFovSpeed()
			)) .. string.format("Tilt Speed: %.1f\n", v40.getRollSpeed())
		end

		if v10 then
			if depthOfFieldEffect and depthOfFieldEffect.Parent and depthOfFieldEffect.Enabled then
				text = ((((text .. string.format("Custom Depth Of Field: On\n")) .. string.format(
					"Custom Depth Of Field Near Intensity: %.1f\n",
					depthOfFieldEffect.NearIntensity
				)) .. string.format("Custom Depth Of Field Far Intensity: %.1f\n", depthOfFieldEffect.FarIntensity)) .. string.format(
					"Custom Depth Of Field Focus Distance: %.1f\n",
					depthOfFieldEffect.FocusDistance
				)) .. string.format("Custom Depth Of Field Focus Radius: %.1f\n", depthOfFieldEffect.InFocusRadius)
			else
				text ..= string.format("Custom Depth Of Field: Off\n")
			end
		end

		if v11 then
			if v29 and #players > 0 then
				text ..= string.format("Player Lock: %s\n", players[v32].Name)
			else
				text ..= string.format("Player Lock: Off\n")
			end
		end

		textLabel.Text = text
	end

	vector2 = v60.p
	currentCamera.CFrame = v60
	currentCamera.Focus = v60
	currentCamera.FieldOfView = fieldOfView
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckMouseLockAvailability()
	local devEnableMouseLock = Players.LocalPlayer.DevEnableMouseLock
	local v51 = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local v52 = gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local v53 = gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	return devEnableMouseLock and v52 and not v53 and not v51
end

v = {}
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

function v.Push()
	for k in pairs(coreGuiEnableds) do
		coreGuiEnableds[k] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[k])
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], false)
	end

	for k in pairs(cores) do
		cores[k] = StarterGui:GetCore(k)
		StarterGui:SetCore(k, false)
	end

	local playerGui2 = localPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui2 then
		for _, screenGui in pairs(playerGui2:GetChildren()) do
			if not (screenGui:IsA("ScreenGui") and screenGui.Enabled) then
				continue
			end

			screenGuis[#screenGuis + 1] = screenGui
			screenGui.Enabled = false
		end

		if v5 then
			childAddedConnection = playerGui2.ChildAdded:Connect(function(screenGui)
				if screenGui:IsA("ScreenGui") and screenGui.Enabled then
					screenGuis[#screenGuis + 1] = screenGui

					if v13 then
						screenGui.Enabled = enabled
					else
						screenGui.Enabled = false
					end
				end
			end)
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

	if v2 then
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

function v.Pop()
	for k, v51 in pairs(coreGuiEnableds) do
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], v51)
	end

	for k, v51 in pairs(cores) do
		StarterGui:SetCore(k, v51)
	end

	for _, v51 in pairs(screenGuis) do
		if v13 then
			if v51.Parent and v51 ~= freecam then
				v51.Enabled = true
			end
		elseif v51.Parent then
			v51.Enabled = true
		end
	end

	if v5 then
		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end

		screenGuis = {}
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

function v.getScreenGuis()
	return screenGuis
end

local function removePlayerFromList(p)
	for i, v51 in ipairs(players) do
		if v51 ~= p then
			continue
		end

		table.remove(players, i)

		if v32 == i and v29 then
			v29 = false
			v32 = 1
		end

		if i < v32 then
			v32 -= 1
		end

		if v32 > #players or v32 < 1 then
			v32 = 1
			break
		else
			break
		end
	end
end

local function initializePlayerList()
	players = Players:GetPlayers()

	for i, player in ipairs(players) do
		if player ~= localPlayer then
			continue
		end

		v32 = i
		break
	end

	playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		table.insert(players, player)
	end)
	playerRemovingConnection = Players.PlayerRemoving:Connect(removePlayerFromList)
end

local function StartFreecam()
	if v11 then
		initializePlayerList()
	end

	if not v9 and v3 then
		script:SetAttribute("FreecamEnabled", true)
	end

	local cFrame2 = currentCamera.CFrame

	if v7 then
		vector3 = Vector3.new(cFrame2:toEulerAnglesYXZ())
	else
		vector3 = Vector2.new(cFrame2:toEulerAnglesYXZ())
	end

	vector2 = cFrame2.p
	fieldOfView = currentCamera.FieldOfView
	v36:Reset((Vector3.new()))
	v37:Reset(Vector2.new())
	v38:Reset(0)

	if v7 then
		v39:Reset(0)
	end

	if not v13 and v8 then
		v24 = 1.5
		v25 = 1
		v26 = 4
		v27 = 1
	end

	if v13 then
		playerGui = localPlayer:WaitForChild("PlayerGui")
		freecam = playerGui:WaitForChild("Freecam")

		if not (textLabel and textLabel.Parent) then
			textLabel = Instance.new("TextLabel")
			textLabel.Name = "FreecamCustomGui"
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.Font = Enum.Font.SourceSansBold
			textLabel.TextSize = 20
			textLabel.TextStrokeTransparency = 0
			textLabel.BackgroundTransparency = 1
			textLabel.TextWrapped = true
			textLabel.TextXAlignment = Enum.TextXAlignment.Right
			textLabel.AutomaticSize = Enum.AutomaticSize.Y
			textLabel.AnchorPoint = Vector2.new(1, 1)
			textLabel.Position = UDim2.new(1, -10, 1, -10)
			textLabel.Size = UDim2.new(0, 400, 0, 0)
			textLabel.Parent = freecam
		end
	end

	v.Push()

	if v10 and not (depthOfFieldEffect and depthOfFieldEffect.Parent) then
		depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
		depthOfFieldEffect.Enabled = false
		depthOfFieldEffect.Name = "FreecamDepthOfField"
		depthOfFieldEffect.Parent = currentCamera
	end

	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	v40.StartCapture()
end

local function StopFreecam()
	if not v9 and v3 then
		script:SetAttribute("FreecamEnabled", false)
	end

	if v11 then
		if playerAddedConnection then
			playerAddedConnection:Disconnect()
			playerAddedConnection = nil
		end

		if playerRemovingConnection then
			playerRemovingConnection:Disconnect()
			playerRemovingConnection = nil
		end

		v29 = false
		v32 = 1
		players = {}
	end

	if v10 and depthOfFieldEffect and depthOfFieldEffect.Parent then
		if depthOfFieldEffect.Enabled then
			for _, v51 in ipairs(depthOfFieldEffects) do
				if v51.Parent then
					v51.Enabled = true
				end
			end

			if childAddedConnection2 then
				childAddedConnection2:Disconnect()
				childAddedConnection2 = nil
			end

			if childAddedConnection3 then
				childAddedConnection3:Disconnect()
				childAddedConnection3 = nil
			end

			depthOfFieldEffects = {}
		end

		depthOfFieldEffect.Enabled = false
	end

	if v13 then
		if freecam and freecam.Parent then
			freecam.Enabled = false
		end

		enabled = false
		v35 = false
	end

	v40.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	v.Pop()
end

local v51 = false

local function ToggleFreecam()
	if v51 then
		StopFreecam()
	elseif module.Utils.Players.GetPlayerGroupInfo(module.Instance) < 10 then
		return
	else
		StartFreecam()
	end

	v51 = not v51

	if v9 then
		script:SetAttribute("FreecamEnabled", v51)
	end
end

local function CheckMacro(list)
	for i = 1, #list - 1 do
		if not UserInputService:IsKeyDown(list[i]) then
			return
		end
	end

	if v51 then
		StopFreecam()
	elseif module.Utils.Players.GetPlayerGroupInfo(module.Instance) < 10 then
		return
	else
		StartFreecam()
	end

	v51 = not v51

	if v9 then
		script:SetAttribute("FreecamEnabled", v51)
	end
end

local function HandleActivationInput(_, p, p2)
	if p == Enum.UserInputState.Begin and p2.KeyCode == v14[#v14] then
		CheckMacro(v14)
	end

	return Enum.ContextActionResult.Pass
end

ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, value, v14[#v14])

if v9 or v3 then
	script:SetAttribute("FreecamEnabled", v51)
	script:GetAttributeChangedSignal("FreecamEnabled"):Connect(function()
		local freecamEnabled = script:GetAttribute("FreecamEnabled")

		if typeof(freecamEnabled) ~= "boolean" then
			script:SetAttribute("FreecamEnabled", v51)
		elseif freecamEnabled ~= v51 then
			if freecamEnabled then
				StartFreecam()
				v51 = true
			else
				StopFreecam()
				v51 = false
			end
		end
	end)
end

return {}