local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
game:GetService("RunService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRService = game:GetService("VRService")
local GuiService = game:GetService("GuiService")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local userFlag = FlagUtil.getUserFlag("UserPSSinkUnknownTouchEvents")
local userFlag2 = FlagUtil.getUserFlag("UserPSTextboxResetCameraInput")
local userFlag3 = FlagUtil.getUserFlag("UserFixVRCameraGamepadReset")
local userFlag4 = FlagUtil.getUserFlag("UserPlayerScriptsSupportTVRemoteKeycodes")
local localPlayer = Players.LocalPlayer
local value = Enum.ContextActionPriority.Medium.Value
local v = Vector2.new(1, 0.77) * 0.06981317007977318 * 60
local v2 = Vector2.new(1, 0.77) * 0.008726646259971648
local v3 = Vector2.new(1, 0.77) * 0.12217304763960307
local v4 = Vector2.new(1, 0.66) * 0.017453292519943295
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
	local v5 = (math.exp((math.abs(p) - 0.1) / 0.9 * 2) - 1) / 6.38905609893065
	return math.sign(p) * math.clamp(v5, 0, 1)
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

	local v5 = (1 - (math.abs(eulerAnglesYXZ) * 2 / 3.141592653589793) ^ 0.75) * 0.75 + 0.25
	return Vector2.new(1, v5) * move
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
	local v5 = absolutePosition + dynamicThumbstickFrame.AbsoluteSize
	return position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= v5.X and position.Y <= v5.Y
end

local connections = {}
local v5 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function incPanInputCount()
	v5 = math.max(0, v5 + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decPanInputCount()
	v5 = math.max(0, v5 - 1)
end

local function resetPanInputCount()
	v5 = 0
end

local v6 = {
	Thumbstick2 = Vector2.new(),
	ButtonLeft = 0,
	ButtonRight = 0
}
local v7 = {
	Left = 0,
	Right = 0,
	I = 0,
	O = 0
}
local v8 = {
	Movement = Vector2.new(),
	Wheel = 0,
	Pan = Vector2.new(),
	Pinch = 0
}
local v9 = {
	Move = Vector2.new(),
	Pinch = 0
}
local bindableEvent3 = Instance.new("BindableEvent")
local CameraInput = {
	gamepadZoomPress = bindableEvent3.Event
}
local v10

if userFlag3 then
	v10 = Instance.new("BindableEvent")
	CameraInput.gamepadReset = v10.Event
else
	v10 = VRService.VREnabled and Instance.new("BindableEvent") or nil

	if VRService.VREnabled then
		CameraInput.gamepadReset = v10.Event
	end
end

function CameraInput.getRotationActivated()
	if userFlag4 then
		return v5 > 0 or v6.Thumbstick2.Magnitude > 0 or v6.ButtonRight - v6.ButtonLeft ~= 0
	end

	return v5 > 0 or v6.Thumbstick2.Magnitude > 0
end

function CameraInput.getRotation(p, flag: boolean?)
	local vector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
	local vector2 = Vector2.new(v7.Right - v7.Left, 0) * p
	local v11

	if userFlag4 then
		local vector3 = Vector2.new(v6.ButtonRight - v6.ButtonLeft, 0)
		v11 = (v6.Thumbstick2 + vector3) * UserGameSettings.GamepadCameraSensitivity * p
	else
		v11 = v6.Thumbstick2 * UserGameSettings.GamepadCameraSensitivity * p
	end

	local movement = v8.Movement
	local pan = v8.Pan
	local v12 = adjustTouchPitchSensitivity(v9.Move)

	if flag then
		vector2 = Vector2.new()
	end

	return (vector2 * 2.0943951023931953 + v11 * v + movement * v2 + pan * v3 + v12 * v4) * vector
end

function CameraInput.getZoomDelta()
	local v11 = v7.O - v7.I
	local v12 = -v8.Wheel + v8.Pinch
	local v13 = -v9.Pinch
	return v11 * 0.1 + v12 * 1 + v13 * 0.04
end

local function thumbstick(_, _, p)
	local position = p.Position
	v6[p.KeyCode.Name] = Vector2.new(thumbstickCurve(position.X), -thumbstickCurve(position.Y))
	return Enum.ContextActionResult.Pass
end

local function directionalButtons(_, p, p2)
	if p == Enum.UserInputState.Cancel then
		v6[p2.KeyCode.Name] = 0
	else
		v6[p2.KeyCode.Name] = thumbstickCurve(p2.Position.Z)
	end

	return Enum.ContextActionResult.Pass
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mouseMovement(p)
	local delta = p.Delta
	v8.Movement = Vector2.new(delta.X, delta.Y)
end

local function mouseWheel(_, _, p)
	v8.Wheel = p.Position.Z
	return Enum.ContextActionResult.Pass
end

local function keypress(_, p, p2)
	v7[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
end

local function gamepadZoomPress(_, p, _)
	if p == Enum.UserInputState.Begin then
		bindableEvent3:Fire()
	end
end

local function gamepadReset(_, p, _)
	if p == Enum.UserInputState.Begin then
		v10:Fire()
	end
end

local function resetInputDevices()
	for _, v12 in pairs({
		v6,
		v7,
		v8,
		v9
	}) do
		for k, v13 in pairs(v12) do
			if type(v13) == "boolean" then
				v12[k] = false
			else
				v12[k] *= 0
			end
		end
	end

	v5 = 0
end

local v11 = {}
local v12 = nil
local v13 = nil

local function touchBegan(data, flag: boolean)
	assert(data.UserInputType == Enum.UserInputType.Touch)
	assert(data.UserInputState == Enum.UserInputState.Begin)

	if v12 == nil and isInDynamicThumbstickArea(data.Position) and not flag then
		v12 = data
		return
	end

	if not flag then
		incPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v11[data] = flag
end

local function touchEnded(p, _: boolean)
	assert(p.UserInputType == Enum.UserInputType.Touch)
	assert(p.UserInputState == Enum.UserInputState.End)

	if p == v12 then
		v12 = nil
	end

	if v11[p] == false then
		v13 = nil
		decPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v11[p] = nil
end

local function touchChanged(data, p)
	assert(data.UserInputType == Enum.UserInputType.Touch)
	assert(data.UserInputState == Enum.UserInputState.Change)

	if data == v12 then
		return
	end

	if v11[data] == nil then
		if userFlag then
			v11[data] = true
		else
			v11[data] = p
		end
	end

	local v14 = {}

	for k, v15 in pairs(v11) do
		if not v15 then
			table.insert(v14, k)
		end
	end

	if #v14 == 1 and v11[data] == false then
		local delta = data.Delta
		v9.Move += Vector2.new(delta.X, delta.Y)
	end

	if #v14 ~= 2 then
		v13 = nil
		return
	end

	local magnitude = (v14[1].Position - v14[2].Position).Magnitude

	if v13 then
		v9.Pinch += magnitude - v13
	end

	v13 = magnitude
end

local function resetTouchState()
	v11 = {}
	v12 = nil
	v13 = nil
	v5 = 0
end

local function pointerAction(wheel, pan, p, p2)
	if not p2 then
		v8.Wheel = wheel
		v8.Pan = pan
		v8.Pinch = -p
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

local v14 = false

function CameraInput.setInputEnabled(p)
	if v14 == p then
		return
	end

	v14 = p
	resetInputDevices()
	resetTouchState()

	if v14 then
		ContextActionService:BindActionAtPriority(
			"RbxCameraThumbstick",
			thumbstick,
			false,
			value,
			Enum.KeyCode.Thumbstick2
		)

		if userFlag4 then
			ContextActionService:BindActionAtPriority(
				"RbxCameraDirectionalButtons",
				directionalButtons,
				false,
				value,
				Enum.KeyCode.ButtonLeft,
				Enum.KeyCode.ButtonRight
			)
		end

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
		table.insert(connections, GuiService.MenuOpened:connect(resetTouchState))
	else
		ContextActionService:UnbindAction("RbxCameraThumbstick")

		if userFlag4 then
			ContextActionService:UnbindAction("RbxCameraDirectionalButtons")
		end

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
	return v14
end

function CameraInput.resetInputForFrameEnd()
	v8.Movement = Vector2.new()
	v9.Move = Vector2.new()
	v9.Pinch = 0
	v8.Wheel = 0
	v8.Pan = Vector2.new()
	v8.Pinch = 0
end

UserInputService.WindowFocused:Connect(resetInputDevices)
UserInputService.WindowFocusReleased:Connect(resetInputDevices)

if userFlag2 then
	UserInputService.TextBoxFocusReleased:Connect(resetInputDevices)
end

local v15 = false
local v16 = false
local now = 0

function CameraInput.getHoldPan()
	return v15
end

function CameraInput.getTogglePan()
	return v16
end

function CameraInput.getPanning()
	return v16 or v15
end

function CameraInput.setTogglePan(flag: boolean)
	v16 = flag
end

local flag = false
local connection = nil
local connection2 = nil

function CameraInput.enableCameraToggleInput()
	if flag then
		return
	end

	flag = true
	v15 = false
	v16 = false

	if connection then
		connection:Disconnect()
	end

	if connection2 then
		connection2:Disconnect()
	end

	connection = event:Connect(function()
		v15 = true
		now = tick()
	end)
	connection2 = event2:Connect(function()
		v15 = false

		if tick() - now < 0.3 and (v16 or UserInputService:GetMouseDelta().Magnitude < 2) then
			v16 = not v16
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