local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRService = game:GetService("VRService")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local userFlag = FlagUtil.getUserFlag("UserCameraInputDt")
local localPlayer = Players.LocalPlayer
local value = Enum.ContextActionPriority.Medium.Value
local v = Vector2.new(1, 0.77) * 0.06981317007977318
local v2 = Vector2.new(1, 0.77) * 0.008726646259971648
local v3 = Vector2.new(1, 0.77) * 0.12217304763960307
local v4 = Vector2.new(1, 0.66) * 0.017453292519943295

if userFlag then
	v *= 60
end

local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserResetTouchStateOnMenuOpen")
end)
local v5 = success and result
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserClearPanOnCameraDisable")
end)
local v6 = success2 and result2
local success3, result3 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixGamepadSensitivity")
end)
local v7 = success3 and result3
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
	local v8 = (math.exp((math.abs(p) - 0.1) / 0.9 * 2) - 1) / 6.38905609893065
	return math.sign(p) * math.clamp(v8, 0, 1)
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

	local v8 = (1 - (math.abs(eulerAnglesYXZ) * 2 / 3.141592653589793) ^ 0.75) * 0.75 + 0.25
	return Vector2.new(1, v8) * move
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
	local v8 = absolutePosition + dynamicThumbstickFrame.AbsoluteSize
	return position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= v8.X and position.Y <= v8.Y
end

local v8 = 0.016666666666666666
RunService.Stepped:Connect(function(_, dt)
	v8 = dt
end)
local connections = {}
local v9 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function incPanInputCount()
	v9 = math.max(0, v9 + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decPanInputCount()
	v9 = math.max(0, v9 - 1)
end

local function resetPanInputCount()
	v9 = 0
end

local vectorsByName = {
	Thumbstick2 = Vector2.new()
}
local v10 = {
	Left = 0,
	Right = 0,
	I = 0,
	O = 0
}
local v11 = {
	Movement = Vector2.new(),
	Wheel = 0,
	Pan = Vector2.new(),
	Pinch = 0
}
local v12 = {
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
	return v9 > 0 or vectorsByName.Thumbstick2.Magnitude > 0
end

function CameraInput.getRotation(p, flag: boolean?)
	local vector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
	local vector2

	if userFlag then
		vector2 = Vector2.new(v10.Right - v10.Left, 0) * p
	else
		vector2 = Vector2.new(v10.Right - v10.Left, 0) * v8
	end

	local thumbstick2

	if v7 then
		thumbstick2 = vectorsByName.Thumbstick2 * UserGameSettings.GamepadCameraSensitivity
	else
		thumbstick2 = vectorsByName.Thumbstick2
	end

	if userFlag then
		thumbstick2 *= p
	end

	local movement = v11.Movement
	local pan = v11.Pan
	local v13 = adjustTouchPitchSensitivity(v12.Move)

	if flag then
		vector2 = Vector2.new()
	end

	return (vector2 * 2.0943951023931953 + thumbstick2 * v + movement * v2 + pan * v3 + v13 * v4) * vector
end

function CameraInput.getZoomDelta()
	local v13 = v10.O - v10.I
	local v14 = -v11.Wheel + v11.Pinch
	local v15 = -v12.Pinch
	return v13 * 0.1 + v14 * 1 + v15 * 0.04
end

local function thumbstick(_, _, p)
	local position = p.Position
	vectorsByName[p.KeyCode.Name] = Vector2.new(thumbstickCurve(position.X), -thumbstickCurve(position.Y))
	return Enum.ContextActionResult.Pass
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mouseMovement(p)
	local delta = p.Delta
	v11.Movement = Vector2.new(delta.X, delta.Y)
end

local function mouseWheel(_, _, p)
	v11.Wheel = p.Position.Z
	return Enum.ContextActionResult.Pass
end

local function keypress(_, p, p2)
	v10[p2.KeyCode.Name] = p == Enum.UserInputState.Begin and 1 or 0
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
	for _, v14 in pairs({
		vectorsByName,
		v10,
		v11,
		v12
	}) do
		for k, v15 in pairs(v14) do
			if type(v15) == "boolean" then
				v14[k] = false
			else
				v14[k] *= 0
			end
		end
	end

	if v6 then
		v9 = 0
	end
end

local v13 = {}
local v14 = nil
local v15 = nil

local function touchBegan(data, flag: boolean)
	assert(data.UserInputType == Enum.UserInputType.Touch)
	assert(data.UserInputState == Enum.UserInputState.Begin)

	if v14 == nil and isInDynamicThumbstickArea(data.Position) and not flag then
		v14 = data
		return
	end

	if not flag then
		incPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v13[data] = flag
end

local function touchEnded(p, _: boolean)
	assert(p.UserInputType == Enum.UserInputType.Touch)
	assert(p.UserInputState == Enum.UserInputState.End)

	if p == v14 then
		v14 = nil
	end

	if v13[p] == false then
		v15 = nil
		decPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v13[p] = nil
end

local function touchChanged(data, p)
	assert(data.UserInputType == Enum.UserInputType.Touch)
	assert(data.UserInputState == Enum.UserInputState.Change)

	if data == v14 then
		return
	end

	if v13[data] == nil then
		v13[data] = p
	end

	local v16 = {}

	for k, v17 in pairs(v13) do
		if not v17 then
			table.insert(v16, k)
		end
	end

	if #v16 == 1 and v13[data] == false then
		local delta = data.Delta
		v12.Move += Vector2.new(delta.X, delta.Y)
	end

	if #v16 ~= 2 then
		v15 = nil
		return
	end

	local magnitude = (v16[1].Position - v16[2].Position).Magnitude

	if v15 then
		v12.Pinch += magnitude - v15
	end

	v15 = magnitude
end

local function resetTouchState()
	v13 = {}
	v14 = nil
	v15 = nil

	if v5 then
		v9 = 0
	end
end

local function pointerAction(wheel, pan, p, p2)
	if not p2 then
		v11.Wheel = wheel
		v11.Pan = pan
		v11.Pinch = -p
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
	return v16
end

function CameraInput.resetInputForFrameEnd()
	v11.Movement = Vector2.new()
	v12.Move = Vector2.new()
	v12.Pinch = 0
	v11.Wheel = 0
	v11.Pan = Vector2.new()
	v11.Pinch = 0
end

UserInputService.WindowFocused:Connect(resetInputDevices)
UserInputService.WindowFocusReleased:Connect(resetInputDevices)
local v17 = false
local v18 = false
local now = 0
local v19 = nil
local v20 = nil
local v21 = nil
task.spawn(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local sharedUtils = ReplicatedStorage:WaitForChild("SharedUtils", 60)
	local menuManager = sharedUtils and sharedUtils:WaitForChild("MenuManager", 30)

	if menuManager then
		local success4, result4 = pcall(require, menuManager)

		if success4 then
			v19 = result4
		end
	end

	local cameraAuthority = sharedUtils and sharedUtils:WaitForChild("CameraAuthority", 30)

	if cameraAuthority then
		local success4, result4 = pcall(require, cameraAuthority)

		if success4 and type(result4) == "table" and type(result4.isRotationEnabled) == "function" then
			v21 = result4
		end
	end

	local modules = ReplicatedStorage:WaitForChild("Modules", 60)
	local windowHandler = modules and modules:WaitForChild("WindowHandler", 30)

	if windowHandler then
		local success4, result4 = pcall(require, windowHandler)

		if success4 and type(result4) == "table" and type(result4.isAnyOpen) == "function" then
			v20 = result4
		end
	end
end)

function CameraInput.candyMenuIsOpen()
	local success4, result4 = pcall(function()
		if v19 and v19:IsAnyOpen() or v20 and v20.isAnyOpen() or v21 and not v21.isRotationEnabled() then
			return true
		end

		return false
	end)
	return success4 and result4 == true
end

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
			if v18 then
				v18 = not v18
			else
				local success4, result4 = pcall(function()
					if v19 and v19:IsAnyOpen() or v20 and v20.isAnyOpen() or v21 and not v21.isRotationEnabled() then
						return true
					end

					return false
				end)

				if not success4 or result4 ~= true then
					v18 = not v18
				end
			end
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