local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRService = game:GetService("VRService")
game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer
local value = Enum.ContextActionPriority.Default.Value
local v = Vector2.new(1, 0.77) * 0.008726646259971648
local v2 = Vector2.new(1, 0.77) * 0.12217304763960307
local v3 = Vector2.new(1, 0.66) * 0.017453292519943295
local v4 = Vector2.new(1, 0.77) * 0.06981317007977318

local function fn()
	local s_Sensitivity = localPlayer:GetAttribute("S_Sensitivity")

	if s_Sensitivity and localPlayer:GetAttribute("Console") then
		local v5 = s_Sensitivity - 1
		v4 = Vector2.new(1, 0.77) * math.rad(4 + v5)
	else
		v4 = Vector2.new(1, 0.77) * 0.06981317007977318
	end
end

fn()
localPlayer:GetAttributeChangedSignal("S_Sensitivity"):Connect(fn)
localPlayer:GetAttributeChangedSignal("Console"):Connect(fn)
fn()
local v5 = Vector2.new(1, 0.66) * 0.017453292519943295

local function fn2()
	local s_MobileSensitivity = localPlayer:GetAttribute("S_MobileSensitivity")
	v3 = v5 * math.max(
		0.1,
		1 + ((typeof(s_MobileSensitivity) ~= "number" or s_MobileSensitivity ~= s_MobileSensitivity) and 0 or s_MobileSensitivity) / 2
	)
end

local s_MobileSensitivity = localPlayer:GetAttribute("S_MobileSensitivity")
v3 = v5 * math.max(
	0.1,
	1 + ((typeof(s_MobileSensitivity) ~= "number" or s_MobileSensitivity ~= s_MobileSensitivity) and 0 or s_MobileSensitivity) / 2
)
localPlayer:GetAttributeChangedSignal("S_MobileSensitivity"):Connect(fn2)
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserResetTouchStateOnMenuOpen")
end)
local v6 = success and result
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local event = bindableEvent.Event
local event2 = bindableEvent2.Event
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
		bindableEvent:Fire()
	end
end)
UserInputService.InputEnded:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		bindableEvent2:Fire()
	end
end)

local function thumbstickCurve(p)
	local v7 = (math.exp((math.abs(p) - 0.1) / 0.9 * 2) - 1) / 6.38905609893065
	return math.sign(p) * math.clamp(v7, 0, 1)
end

local function adjustTouchPitchSensitivity(move: Vector2)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return move
	end

	local eulerAnglesYXZ = currentCamera.CFrame:ToEulerAnglesYXZ()

	if move.Y * eulerAnglesYXZ >= 0 then
		return move
	end

	local v7 = (1 - (math.abs(eulerAnglesYXZ) * 2 / 3.141592653589793) ^ 0.75) * 0.75 + 0.25
	return Vector2.new(1, v7) * move
end

local function isInDynamicThumbstickArea(position: Vector3)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchControlFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local dynamicThumbstickFrame = touchControlFrame and touchControlFrame:FindFirstChild("DynamicThumbstickFrame")

	if not (dynamicThumbstickFrame and touchGui.Enabled) then
		return false
	end

	local absolutePosition = dynamicThumbstickFrame.AbsolutePosition
	local v7 = absolutePosition + dynamicThumbstickFrame.AbsoluteSize
	return position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= v7.X and position.Y <= v7.Y
end

local v7 = 0.016666666666666666
RunService.Stepped:Connect(function(_, dt)
	v7 = dt
end)
local connections = {}
local v8 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function incPanInputCount()
	v8 = math.max(0, v8 + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decPanInputCount()
	v8 = math.max(0, v8 - 1)
end

local function resetPanInputCount()
	v8 = 0
end

local vectorsByName = {
	Thumbstick2 = Vector2.new()
}
local v9 = {
	Left = 0,
	Right = 0,
	I = 0,
	O = 0
}
local v10 = {
	Movement = Vector2.new(),
	Wheel = 0,
	Pan = Vector2.new(),
	Pinch = 0
}
local v11 = {
	Move = Vector2.new(),
	Pinch = 0
}
local bindableEvent3 = Instance.new("BindableEvent")
local CameraInput = {
	gamepadZoomPress = bindableEvent3.Event
}
local bindableEvent4 = VRService.VREnabled and Instance.new("BindableEvent") or nil

if VRService.VREnabled then
	CameraInput.gamepadReset = bindableEvent4.Event
end

function CameraInput.getRotationActivated()
	return v8 > 0 or vectorsByName.Thumbstick2.Magnitude > 0
end

function CameraInput.getRotation(flag: boolean?)
	local vector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
	local vector2 = Vector2.new(v9.Right - v9.Left, 0) * v7
	local thumbstick2 = vectorsByName.Thumbstick2
	local movement = v10.Movement
	local pan = v10.Pan
	local v12 = adjustTouchPitchSensitivity(v11.Move)

	if flag then
		vector2 = Vector2.new()
	end

	return (vector2 * 2.0943951023931953 + thumbstick2 * v4 + movement * v + pan * v2 + v12 * v3) * vector
end

function CameraInput.getZoomDelta()
	local v12 = v9.O - v9.I
	local v13 = -v10.Wheel + v10.Pinch
	local v14 = -v11.Pinch
	return v12 * 0.1 + v13 * 1 + v14 * 0.04
end

local function thumbstick(_, _, p)
	local position = p.Position
	vectorsByName[p.KeyCode.Name] = Vector2.new(thumbstickCurve(position.X), -thumbstickCurve(position.Y))
	return Enum.ContextActionResult.Pass
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mouseMovement(p)
	local delta = p.Delta
	v10.Movement = Vector2.new(delta.X, delta.Y)
end

local function mouseWheel(_, _, p)
	v10.Wheel = p.Position.Z
	return Enum.ContextActionResult.Pass
end

local function keypress(_, p, p2)
	v9[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
end

local function gamepadZoomPress(_, p, _)
	if p == Enum.UserInputState.Begin then
		bindableEvent3:Fire()
	end
end

local function gamepadReset(_, p, _)
	if p == Enum.UserInputState.Begin then
		bindableEvent4:Fire()
	end
end

local function resetInputDevices()
	for _, v13 in pairs({
		vectorsByName,
		v9,
		v10,
		v11
	}) do
		for k, v14 in pairs(v13) do
			if type(v14) == "boolean" then
				v13[k] = false
			else
				v13[k] *= 0
			end
		end
	end
end

local v12 = {}
local v13 = nil
local v14 = nil

local function touchBegan(data, flag: boolean)
	assert(data.UserInputType == Enum.UserInputType.Touch)
	assert(data.UserInputState == Enum.UserInputState.Begin)

	if v13 == nil and isInDynamicThumbstickArea(data.Position) and not flag then
		v13 = data
		return
	end

	if not flag then
		incPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v12[data] = flag
end

local function touchEnded(p, _: boolean)
	assert(p.UserInputType == Enum.UserInputType.Touch)
	assert(p.UserInputState == Enum.UserInputState.End)

	if p == v13 then
		v13 = nil
	end

	if v12[p] == false then
		v14 = nil
		decPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v12[p] = nil
end

local v15 = true

function CameraInput.changePanState(p)
	v15 = p
end

local function touchChanged(data, p)
	assert(data.UserInputType == Enum.UserInputType.Touch)
	assert(data.UserInputState == Enum.UserInputState.Change)

	if data == v13 then
		return
	end

	if v12[data] == nil then
		v12[data] = p
	end

	local v16 = {}

	for k, v17 in pairs(v12) do
		if not v17 then
			table.insert(v16, k)
		end
	end

	if #v16 == 1 and v15 and v12[data] == false then
		local delta = data.Delta
		v11.Move += Vector2.new(delta.X, delta.Y)
	end

	if #v16 ~= 2 then
		v14 = nil
		return
	end

	local magnitude = (v16[1].Position - v16[2].Position).Magnitude

	if v14 then
		v11.Pinch += magnitude - v14
	end

	v14 = magnitude
end

local function resetTouchState()
	v12 = {}
	v13 = nil
	v14 = nil

	if v6 then
		v8 = 0
	end
end

local function pointerAction(wheel, pan, p, p2)
	if not p2 then
		v10.Wheel = wheel
		v10.Pan = pan
		v10.Pinch = -p
	end
end

local function inputBegan(p, p2)
	if p.UserInputType == Enum.UserInputType.Touch then
		touchBegan(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseButton2 and not p2 then
		incPanInputCount() -- equivalent call inferred; original call site unknown
	end
end

local function inputChanged(p, p2)
	if p.UserInputType == Enum.UserInputType.Touch then
		touchChanged(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseMovement then
		mouseMovement(p) -- equivalent call inferred; original call site unknown
	end
end

local function inputEnded(p, p2)
	if p.UserInputType == Enum.UserInputType.Touch then
		touchEnded(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseButton2 then
		decPanInputCount() -- equivalent call inferred; original call site unknown
	end
end

local v16 = false

function CameraInput.setInputEnabled(p)
	if v16 == p then
		return
	end

	v16 = p
	resetInputDevices()
	resetTouchState()

	if v16 then
		ContextActionService:BindActionAtPriority(
			"RbxCameraThumbstick",
			thumbstick,
			false,
			value,
			Enum.KeyCode.Thumbstick2
		)
		ContextActionService:BindActionAtPriority(
			"RbxCameraKeypress",
			keypress,
			false,
			value,
			Enum.KeyCode.Left,
			Enum.KeyCode.Right,
			Enum.KeyCode.I,
			Enum.KeyCode.O
		)

		if VRService.VREnabled then
			ContextActionService:BindAction("RbxCameraGamepadReset", gamepadReset, false, Enum.KeyCode.ButtonL3)
		end

		ContextActionService:BindAction("RbxCameraGamepadZoom", gamepadZoomPress, false, Enum.KeyCode.ButtonR3)
		table.insert(connections, UserInputService.InputBegan:Connect(inputBegan))
		table.insert(connections, UserInputService.InputChanged:Connect(inputChanged))
		table.insert(connections, UserInputService.InputEnded:Connect(inputEnded))
		table.insert(connections, UserInputService.PointerAction:Connect(pointerAction))

		if v6 then
			local GuiService = game:GetService("GuiService")
			table.insert(connections, GuiService.MenuOpened:connect(resetTouchState))
		end
	else
		ContextActionService:UnbindAction("RbxCameraThumbstick")
		ContextActionService:UnbindAction("RbxCameraMouseMove")
		ContextActionService:UnbindAction("RbxCameraMouseWheel")
		ContextActionService:UnbindAction("RbxCameraKeypress")
		ContextActionService:UnbindAction("RbxCameraGamepadZoom")

		if VRService.VREnabled then
			ContextActionService:UnbindAction("RbxCameraGamepadReset")
		end

		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		connections = {}
	end
end

function CameraInput.getInputEnabled()
	return v16
end

function CameraInput.resetInputForFrameEnd()
	v10.Movement = Vector2.new()
	v11.Move = Vector2.new()
	v11.Pinch = 0
	v10.Wheel = 0
	v10.Pan = Vector2.new()
	v10.Pinch = 0
end

UserInputService.WindowFocused:Connect(resetInputDevices)
UserInputService.WindowFocusReleased:Connect(resetInputDevices)
local v17 = false
local v18 = false
local now = 0

function CameraInput.getHoldPan()
	return v17
end

function CameraInput.getTogglePan()
	return v18
end

function CameraInput.getPanning()
	return v18 or v17
end

function CameraInput.setTogglePan(flag: boolean)
	v18 = flag
end

local flag = false
local connection = nil
local connection2 = nil

function CameraInput.enableCameraToggleInput()
	if flag then
		return
	end

	flag = true
	v17 = false
	v18 = false

	if connection then
		connection:Disconnect()
	end

	if connection2 then
		connection2:Disconnect()
	end

	connection = event:Connect(function()
		v17 = true
		now = tick()
	end)
	connection2 = event2:Connect(function()
		v17 = false

		if tick() - now < 0.3 and (v18 or UserInputService:GetMouseDelta().Magnitude < 2) then
			v18 = not v18
		end
	end)
end

function CameraInput.disableCameraToggleInput()
	if not flag then
		return
	end

	flag = false

	if connection then
		connection:Disconnect()
		connection = nil
	end

	if connection2 then
		connection2:Disconnect()
		connection2 = nil
	end
end

return CameraInput