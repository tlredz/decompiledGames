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

local vectorsByName = {
	Thumbstick2 = Vector2.new()
}
local v6 = {
	Left = 0,
	Right = 0,
	I = 0,
	O = 0
}
local v7 = {
	Movement = Vector2.new(),
	Wheel = 0,
	Pan = Vector2.new(),
	Pinch = 0
}
local v8 = {
	Move = Vector2.new(),
	Pinch = 0
}
local bindableEvent3 = Instance.new("BindableEvent")
local CameraInput = {
	gamepadZoomPress = bindableEvent3.Event
}
local v9

if userFlag3 then
	v9 = Instance.new("BindableEvent")
	CameraInput.gamepadReset = v9.Event
else
	v9 = VRService.VREnabled and Instance.new("BindableEvent") or nil

	if VRService.VREnabled then
		CameraInput.gamepadReset = v9.Event
	end
end

function CameraInput.getRotationActivated()
	return v5 > 0 or vectorsByName.Thumbstick2.Magnitude > 0
end

function CameraInput.getRotation(p, flag: boolean?)
	local vector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
	local vector2 = Vector2.new(v6.Right - v6.Left, 0) * p
	local v10 = vectorsByName.Thumbstick2 * UserGameSettings.GamepadCameraSensitivity * p
	local movement = v7.Movement
	local pan = v7.Pan
	local v11 = adjustTouchPitchSensitivity(v8.Move)

	if flag then
		vector2 = Vector2.new()
	end

	return (vector2 * 2.0943951023931953 + v10 * v + movement * v2 + pan * v3 + v11 * v4) * vector
end

function CameraInput.getZoomDelta()
	local v10 = v6.O - v6.I
	local v11 = -v7.Wheel + v7.Pinch
	local v12 = -v8.Pinch
	return v10 * 0.1 + v11 * 1 + v12 * 0.04
end

local function thumbstick(_, _, p)
	local position = p.Position
	vectorsByName[p.KeyCode.Name] = Vector2.new(thumbstickCurve(position.X), -thumbstickCurve(position.Y))
	return Enum.ContextActionResult.Pass
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mouseMovement(p)
	local delta = p.Delta
	v7.Movement = Vector2.new(delta.X, delta.Y)
end

local function mouseWheel(_, _, p)
	v7.Wheel = p.Position.Z
	return Enum.ContextActionResult.Pass
end

local function keypress(_, p, p2)
	v6[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
end

local function gamepadZoomPress(_, p, _)
	if p == Enum.UserInputState.Begin then
		bindableEvent3:Fire()
	end
end

local function gamepadReset(_, p, _)
	if p == Enum.UserInputState.Begin then
		v9:Fire()
	end
end

local function resetInputDevices()
	for _, v11 in pairs({
		vectorsByName,
		v6,
		v7,
		v8
	}) do
		for k, v12 in pairs(v11) do
			if type(v12) == "boolean" then
				v11[k] = false
			else
				v11[k] *= 0
			end
		end
	end

	v5 = 0
end

local v10 = {}
local v11 = nil
local v12 = nil

local function touchBegan(data, flag: boolean)
	assert(data.UserInputType == Enum.UserInputType.Touch)
	assert(data.UserInputState == Enum.UserInputState.Begin)

	if v11 == nil and isInDynamicThumbstickArea(data.Position) and not flag then
		v11 = data
		return
	end

	if not flag then
		incPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v10[data] = flag
end

local function touchEnded(p, _: boolean)
	assert(p.UserInputType == Enum.UserInputType.Touch)
	assert(p.UserInputState == Enum.UserInputState.End)

	if p == v11 then
		v11 = nil
	end

	if v10[p] == false then
		v12 = nil
		decPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v10[p] = nil
end

local function touchChanged(data, p)
	assert(data.UserInputType == Enum.UserInputType.Touch)
	assert(data.UserInputState == Enum.UserInputState.Change)

	if data == v11 then
		return
	end

	if v10[data] == nil then
		if userFlag then
			v10[data] = true
		else
			v10[data] = p
		end
	end

	local v13 = {}

	for k, v14 in pairs(v10) do
		if not v14 then
			table.insert(v13, k)
		end
	end

	if #v13 == 1 and v10[data] == false then
		local delta = data.Delta
		v8.Move += Vector2.new(delta.X, delta.Y)
	end

	if #v13 ~= 2 then
		v12 = nil
		return
	end

	local magnitude = (v13[1].Position - v13[2].Position).Magnitude

	if v12 then
		v8.Pinch += magnitude - v12
	end

	v12 = magnitude
end

local function resetTouchState()
	v10 = {}
	v11 = nil
	v12 = nil
	v5 = 0
end

local function pointerAction(wheel, pan, p, p2)
	if not p2 then
		v7.Wheel = wheel
		v7.Pan = pan
		v7.Pinch = -p
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

local v13 = false

function CameraInput.setInputEnabled(p)
	if v13 == p then
		return
	end

	v13 = p
	resetInputDevices()
	resetTouchState()

	if v13 then
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
		table.insert(connections, GuiService.MenuOpened:connect(resetTouchState))
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
	return v13
end

function CameraInput.resetInputForFrameEnd()
	v7.Movement = Vector2.new()
	v8.Move = Vector2.new()
	v8.Pinch = 0
	v7.Wheel = 0
	v7.Pan = Vector2.new()
	v7.Pinch = 0
end

UserInputService.WindowFocused:Connect(resetInputDevices)
UserInputService.WindowFocusReleased:Connect(resetInputDevices)

if userFlag2 then
	UserInputService.TextBoxFocusReleased:Connect(resetInputDevices)
end

local v14 = false
local v15 = false
local now = 0

function CameraInput.getHoldPan()
	return v14
end

function CameraInput.getTogglePan()
	return v15
end

function CameraInput.getPanning()
	return v15 or v14
end

function CameraInput.setTogglePan(flag: boolean)
	v15 = flag
end

local flag = false
local connection = nil
local connection2 = nil

function CameraInput.enableCameraToggleInput()
	if flag then
		return
	end

	flag = true
	v14 = false
	v15 = false

	if connection then
		connection:Disconnect()
	end

	if connection2 then
		connection2:Disconnect()
	end

	connection = event:Connect(function()
		v14 = true
		now = tick()
	end)
	connection2 = event2:Connect(function()
		v14 = false

		if tick() - now < 0.3 and (v15 or UserInputService:GetMouseDelta().Magnitude < 2) then
			v15 = not v15
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