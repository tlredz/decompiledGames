game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
game:GetService("VRService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserPSTextboxResetCameraInput")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsSupportTVRemoteKeycodes")
local cameraContext = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("CameraContext")
local cameraRotationAction = cameraContext:WaitForChild("CameraRotationAction")
local cameraZoomAction = cameraContext:WaitForChild("CameraZoomAction")
local gamepadBinding = cameraRotationAction:WaitForChild("GamepadBinding")
local microGamepadBinding

if userFlag2 then
	microGamepadBinding = cameraRotationAction:WaitForChild("MicroGamepadBinding")
else
	microGamepadBinding = nil
end

local mouseBinding = cameraRotationAction:WaitForChild("MouseBinding")
local trackpadBinding = cameraRotationAction:WaitForChild("TrackpadBinding")
local cameraToggleAction = cameraContext:WaitForChild("CameraToggleAction")
local cameraPanActiveAction = cameraContext:WaitForChild("CameraPanActiveAction")
local v = 1

local function updateCameraYInvert()
	local cameraYInvertValue = UserGameSettings:GetCameraYInvertValue()

	if cameraYInvertValue == v then
		return
	end

	v = cameraYInvertValue

	for _, inputBinding in cameraRotationAction:GetChildren() do
		if not inputBinding:IsA("InputBinding") then
			continue
		end

		local vector2Scale = inputBinding.Vector2Scale
		inputBinding.Vector2Scale = Vector2.new(vector2Scale.X, -vector2Scale.Y)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateGamepadCameraSensitivity()
	gamepadBinding.Scale = UserGameSettings.GamepadCameraSensitivity

	if userFlag2 and microGamepadBinding then
		microGamepadBinding.Scale = UserGameSettings.GamepadCameraSensitivity
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateMouseCameraSensitivity()
	local mouseSensitivity = UserGameSettings.MouseSensitivity
	mouseBinding.Scale = mouseSensitivity
	trackpadBinding.Scale = mouseSensitivity
end

UserGameSettings:GetPropertyChangedSignal("GamepadCameraSensitivity"):Connect(updateGamepadCameraSensitivity)
updateGamepadCameraSensitivity() -- equivalent call inferred; original call site unknown
UserGameSettings:GetPropertyChangedSignal("MouseSensitivity"):Connect(updateMouseCameraSensitivity)
updateMouseCameraSensitivity() -- equivalent call inferred; original call site unknown
updateCameraYInvert()

local function adjustTouchPitchSensitivity(point: Vector2)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return point
	end

	local eulerAnglesYXZ = currentCamera.CFrame:ToEulerAnglesYXZ()

	if point.Y * eulerAnglesYXZ >= 0 then
		return point
	end

	local v2 = (1 - (math.abs(eulerAnglesYXZ) * 2 / 3.141592653589793) ^ 0.75) * 0.75 + 0.25
	return Vector2.new(1, v2) * point
end

local v2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function incPanInputCount()
	v2 = math.max(0, v2 + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decPanInputCount()
	v2 = math.max(0, v2 - 1)
end

local function resetPanInputCount()
	v2 = 0
end

local CameraInput = {
	getRotationActivated = function()
		return v2 > 0 or cameraRotationAction:GetState().Magnitude > 0
	end,
	getPanActivated = function()
		return v2 > 0
	end
}
local zero = Vector2.zero

function CameraInput.addRotation(point: Vector2)
	zero += point
end

function CameraInput.getAssistRotation()
	return zero
end

function CameraInput.resetAssistRotation()
	zero = Vector2.zero
end

local vector = nil
local count = 0

local function sunkMouseRotation(state: Vector2, p: number)
	if UserInputService.PreferredInput == Enum.PreferredInput.Touch or UserInputService:GetLastInputType() ~= Enum.UserInputType.MouseMovement then
		count = 0
		return Vector2.zero
	end

	local mouseDelta = UserInputService:GetMouseDelta()

	if mouseDelta.Magnitude == 0 then
		count = 0
		return Vector2.zero
	end

	if state.Magnitude > 0 then
		count = 0
		local v3 = state * p
		local v4 = vector or Vector2.zero
		local X

		if mouseDelta.X == 0 or v3.X == 0 then
			X = v4.X
		else
			X = v3.X / mouseDelta.X
		end

		local v5

		if mouseDelta.Y == 0 or v3.Y == 0 then
			v5 = v4.Y
		else
			v5 = v3.Y / mouseDelta.Y
		end

		vector = Vector2.new(X, v5)
		return Vector2.zero
	else
		count += 1

		if count < 2 or vector == nil or not cameraRotationAction.Enabled then
			return Vector2.zero
		end

		return Vector2.new(mouseDelta.X * vector.X, mouseDelta.Y * vector.Y)
	end
end

local v3 = Vector2.new(1, 0.66) * 0.017453292519943295
local localPlayer = Players.LocalPlayer

local function isInDynamicThumbstickArea(position: Vector3)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchControlFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local dynamicThumbstickFrame = touchControlFrame and touchControlFrame:FindFirstChild("DynamicThumbstickFrame")

	if not (dynamicThumbstickFrame and touchGui.Enabled) then
		return false
	end

	local absolutePosition = dynamicThumbstickFrame.AbsolutePosition
	local v4 = absolutePosition + dynamicThumbstickFrame.AbsoluteSize
	return position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= v4.X and position.Y <= v4.Y
end

for _, inputBinding in cameraRotationAction:GetChildren() do
	if not (inputBinding:IsA("InputBinding") and string.find(inputBinding.Name, "Touch") ~= nil) then
		continue
	end

	inputBinding.Scale = 0
end

local v4 = {}
local v5 = nil
local zero2 = Vector2.zero

-- equivalent calls inferred from this helper; original call sites unknown
local function isAimFinger(p)
	return Platform_Handler.SkillDragTurnsCamera() and Platform_Handler.AimInput() == p
end

local function freeFingerCount()
	local count2 = 0

	for _, v6 in v4 do
		if not v6 then
			count2 += 1
		end
	end

	return count2
end

local function pansNow(p)
	local count2 = 0

	for _, v6 in v4 do
		if not v6 then
			count2 += 1
		end
	end

	if v4[p] == false then
		return count2 == 1
	end

	return count2 == 0 and isAimFinger(p)
end

local function resetTouchState()
	for _, v6 in v4 do
		if v6 then
			continue
		end

		decPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v4 = {}
	v5 = nil
	zero2 = Vector2.zero
end

UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if v5 == nil and not gameProcessed and isInDynamicThumbstickArea(input.Position) then
		v5 = input
		return
	end

	if not gameProcessed then
		incPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v4[input] = gameProcessed
end)
UserInputService.InputChanged:Connect(function(input, gameProcessed: boolean)
	if input.UserInputType ~= Enum.UserInputType.Touch or input == v5 then
		return
	end

	if v4[input] == nil then
		v4[input] = gameProcessed
	end

	local count2 = 0

	for _, v6 in v4 do
		if not v6 then
			count2 += 1
		end
	end

	local v6

	if v4[input] == false then
		v6 = count2 == 1
	elseif count2 == 0 then
		v6 = isAimFinger(input)
	else
		v6 = false
	end

	if v6 then
		zero2 += Vector2.new(input.Delta.X, input.Delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if input == v5 then
		v5 = nil
	end

	if v4[input] == false then
		decPanInputCount() -- equivalent call inferred; original call site unknown
	end

	v4[input] = nil
end)
UserInputService.WindowFocusReleased:Connect(resetTouchState)
GuiService.MenuOpened:Connect(resetTouchState)

function CameraInput.getRotation(p)
	updateCameraYInvert()
	local state = cameraRotationAction:GetState()
	local v6 = state * p + sunkMouseRotation(state, p)

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		v6 = adjustTouchPitchSensitivity(v6)
	end

	local v7 = adjustTouchPitchSensitivity(zero2) * v3
	local vector2 = Vector2.new(v7.X, v7.Y * UserGameSettings:GetCameraYInvertValue())
	zero2 = Vector2.zero
	return v6 + vector2
end

function CameraInput.peekUserRotation(p)
	local v6 = cameraRotationAction:GetState() * p

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		v6 = adjustTouchPitchSensitivity(v6)
	end

	local v7 = adjustTouchPitchSensitivity(zero2) * v3
	return v6 + Vector2.new(v7.X, v7.Y * UserGameSettings:GetCameraYInvertValue())
end

function CameraInput.getZoomDelta(p)
	return cameraZoomAction:GetState() * p
end

cameraPanActiveAction.Pressed:Connect(incPanInputCount)
cameraPanActiveAction.Released:Connect(decPanInputCount)
local v6 = false

function CameraInput.setInputEnabled(p)
	if v6 == p then
		return
	end

	v6 = p
	v2 = 0

	if v6 then
		cameraZoomAction.Enabled = true
		cameraRotationAction.Enabled = true
		cameraPanActiveAction.Enabled = true
	else
		cameraZoomAction.Enabled = false
		cameraRotationAction.Enabled = false
		cameraPanActiveAction.Enabled = false
	end
end

function CameraInput.getInputEnabled()
	return v6
end

UserInputService.WindowFocused:Connect(resetPanInputCount)
UserInputService.WindowFocusReleased:Connect(resetPanInputCount)
GuiService.MenuOpened:Connect(resetPanInputCount)

if userFlag then
	UserInputService.TextBoxFocusReleased:Connect(resetPanInputCount)
end

local v7 = false
local v8 = false
local now = 0

function CameraInput.getHoldPan()
	return v7
end

function CameraInput.getTogglePan()
	return v8
end

function CameraInput.getPanning()
	return v8 or v7
end

function CameraInput.setTogglePan(flag: boolean)
	v8 = flag
end

local flag = false
cameraToggleAction.Pressed:Connect(function()
	v7 = true
	now = tick()
end)
cameraToggleAction.Released:Connect(function()
	v7 = false

	if tick() - now < 0.3 and (v8 or UserInputService:GetMouseDelta().Magnitude < 2) then
		v8 = not v8
	end
end)

function CameraInput.enableCameraToggleInput()
	if flag then
		return
	end

	flag = true
	v7 = false
	v8 = false
	cameraToggleAction.Enabled = true
end

function CameraInput.disableCameraToggleInput()
	if not flag then
		return
	end

	flag = false
	cameraToggleAction.Enabled = false
end

return CameraInput