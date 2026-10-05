local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRService = game:GetService("VRService")
game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer
local value = Enum.ContextActionPriority.Medium.Value
local v = Vector2.new(1, 0.77) * 0.008726646259971648
local v2 = Vector2.new(1, 0.77) * 0.12217304763960307
local v3 = Vector2.new(1, 0.66) * 0.017453292519943295
local v4 = Vector2.new(1, 0.77) * 0.06981317007977318
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserResetTouchStateOnMenuOpen")
end)
local v5 = success and result
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
	local v6 = (math.exp((math.abs(p) - 0.1) / 0.9 * 2) - 1) / 6.38905609893065
	return math.sign(p) * math.clamp(v6, 0, 1)
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

	local v6 = (1 - (math.abs(eulerAnglesYXZ) * 2 / 3.141592653589793) ^ 0.75) * 0.75 + 0.25
	return Vector2.new(1, v6) * move
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
	local v6 = absolutePosition + dynamicThumbstickFrame.AbsoluteSize
	return position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= v6.X and position.Y <= v6.Y
end

local v6 = 0.016666666666666666
RunService.Stepped:Connect(function(_, dt)
	v6 = dt
end)
local connections = {}
local v7 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function incPanInputCount()
	v7 = math.max(0, v7 + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decPanInputCount()
	v7 = math.max(0, v7 - 1)
end

local function resetPanInputCount()
	v7 = 0
end

local vectorsByName = {
	Thumbstick2 = Vector2.new()
}
local v8 = {
	Left = 0,
	Right = 0,
	I = 0,
	O = 0
}
local v9 = {
	Movement = Vector2.new(),
	Wheel = 0,
	Pan = Vector2.new(),
	Pinch = 0
}
local v10 = {
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
	return v7 > 0 or vectorsByName.Thumbstick2.Magnitude > 0
end

function CameraInput.getRotation(flag: boolean?)
	local vector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
	local vector2 = Vector2.new(v8.Right - v8.Left, 0) * v6
	local thumbstick2 = vectorsByName.Thumbstick2
	local movement = v9.Movement
	local pan = v9.Pan
	local v11 = adjustTouchPitchSensitivity(v10.Move)

	if flag then
		vector2 = Vector2.new()
	end

	return (vector2 * 2.0943951023931953 + thumbstick2 * v4 * UserGameSettings.GamepadCameraSensitivity * 4 + movement * v + pan * v2 + v11 * v3) * vector
end

function CameraInput.getZoomDelta()
	local v11 = v8.O - v8.I
	local v12 = -v9.Wheel + v9.Pinch
	local v13 = -v10.Pinch
	return v11 * 0.1 + v12 * 1 + v13 * 0.04
end

local function thumbstick(_, _, p)
	local position = p.Position
	vectorsByName[p.KeyCode.Name] = Vector2.new(thumbstickCurve(position.X), -thumbstickCurve(position.Y))
	return Enum.ContextActionResult.Pass
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mouseMovement(p)
	local delta = p.Delta
	v9.Movement = Vector2.new(delta.X, delta.Y)
end

local function mouseWheel(_, _, p)
	v9.Wheel = p.Position.Z
	return Enum.ContextActionResult.Pass
end

local function keypress(_, p, p2)
	v8[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
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
	for _, v12 in pairs({
		vectorsByName,
		v8,
		v9,
		v10
	}) do
		for k, v13 in pairs(v12) do
			if type(v13) == "boolean" then
				v12[k] = false
			else
				v12[k] *= 0
			end
		end
	end
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
		v11[data] = p
	end

	local v14 = {}

	for k, v15 in pairs(v11) do
		if not v15 then
			table.insert(v14, k)
		end
	end

	if #v14 == 1 and v11[data] == false then
		local delta = data.Delta
		v10.Move += Vector2.new(delta.X, delta.Y)
	end

	if #v14 ~= 2 then
		v13 = nil
		return
	end

	local magnitude = (v14[1].Position - v14[2].Position).Magnitude

	if v13 then
		v10.Pinch += magnitude - v13
	end

	v13 = magnitude
end

local function resetTouchState()
	v11 = {}
	v12 = nil
	v13 = nil

	if v5 then
		v7 = 0
	end
end

local function pointerAction(wheel, pan, p, p2)
	if not p2 then
		v9.Wheel = wheel
		v9.Pan = pan
		v9.Pinch = -p
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

		if v5 then
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
	return v14
end

function CameraInput.resetInputForFrameEnd()
	v9.Movement = Vector2.new()
	v10.Move = Vector2.new()
	v10.Pinch = 0
	v9.Wheel = 0
	v9.Pan = Vector2.new()
	v9.Pinch = 0
end

UserInputService.WindowFocused:Connect(resetInputDevices)
UserInputService.WindowFocusReleased:Connect(resetInputDevices)
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