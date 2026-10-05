game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
game:GetService("Players")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
game:GetService("VRService")
local GuiService = game:GetService("GuiService")
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

local function incPanInputCount()
	v2 = math.max(0, v2 + 1)
end

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
	end,
	getRotation = function(p)
		updateCameraYInvert()
		local v3 = cameraRotationAction:GetState() * p

		if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			return (adjustTouchPitchSensitivity(v3))
		end

		return v3
	end,
	getZoomDelta = function(p)
		return cameraZoomAction:GetState() * p
	end
}
cameraPanActiveAction.Pressed:Connect(incPanInputCount)
cameraPanActiveAction.Released:Connect(decPanInputCount)
local v3 = false

function CameraInput.setInputEnabled(p)
	if v3 == p then
		return
	end

	v3 = p
	v2 = 0

	if v3 then
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
	return v3
end

UserInputService.WindowFocused:Connect(resetPanInputCount)
UserInputService.WindowFocusReleased:Connect(resetPanInputCount)
GuiService.MenuOpened:Connect(resetPanInputCount)

if userFlag then
	UserInputService.TextBoxFocusReleased:Connect(resetPanInputCount)
end

local v4 = false
local v5 = false
local now = 0

function CameraInput.getHoldPan()
	return v4
end

function CameraInput.getTogglePan()
	return v5
end

function CameraInput.getPanning()
	return v5 or v4
end

function CameraInput.setTogglePan(flag: boolean)
	v5 = flag
end

local flag = false
cameraToggleAction.Pressed:Connect(function()
	v4 = true
	now = tick()
end)
cameraToggleAction.Released:Connect(function()
	v4 = false

	if tick() - now < 0.3 and (v5 or UserInputService:GetMouseDelta().Magnitude < 2) then
		v5 = not v5
	end
end)

function CameraInput.enableCameraToggleInput()
	if flag then
		return
	end

	flag = true
	v4 = false
	v5 = false
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