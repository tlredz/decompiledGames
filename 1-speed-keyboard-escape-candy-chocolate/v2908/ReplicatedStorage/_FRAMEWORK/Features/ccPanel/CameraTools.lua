local createVector = vector.create
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CameraManager = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.CameraManager)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Config = require(script.Parent.Config)
local Remotes = require(script.Parent.Remotes)
local v = {
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Space,
	Enum.KeyCode.LeftShift
}
local v2 = {
	[Enum.KeyCode.W] = createVector(0, 0, -1),
	[Enum.KeyCode.S] = createVector(0, 0, 1),
	[Enum.KeyCode.A] = createVector(-1, 0, 0),
	[Enum.KeyCode.D] = createVector(1, 0, 0),
	[Enum.KeyCode.E] = createVector(0, 1, 0),
	[Enum.KeyCode.Q] = createVector(0, -1, 0)
}
local v3 = nil
local flag = false
local FREECAM_DEFAULT_SPEED = Config.FREECAM_DEFAULT_SPEED
local v4 = 0
local v5 = 0
local now = os.clock()
local inputBeganConnection = nil
local CameraTools = {
	changed = Signal.new()
}

local function sinkInput()
	return Enum.ContextActionResult.Sink
end

-- equivalent calls inferred from this helper; original call sites unknown
local function freezeCharacter()
	ContextActionService:BindAction("CCPanelFreezeMovement", sinkInput, false, table.unpack(v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unfreezeCharacter()
	ContextActionService:UnbindAction("CCPanelFreezeMovement")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCamera()
	local currentCamera = Workspace.CurrentCamera
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	currentCamera.CameraType = Enum.CameraType.Custom

	if humanoid then
		currentCamera.CameraSubject = humanoid
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function followTarget(player)
	local currentCamera = Workspace.CurrentCamera
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and currentCamera.CameraSubject ~= humanoid then
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.CameraSubject = humanoid
	end
end

local function moveFreecam(p: number)
	local currentCamera = Workspace.CurrentCamera

	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		local mouseDelta = UserInputService:GetMouseDelta()
		v5 -= mouseDelta.X * Config.FREECAM_LOOK_SENSITIVITY
		v4 = math.clamp(v4 - mouseDelta.Y * Config.FREECAM_LOOK_SENSITIVITY, -1.5607963267948965, 1.5607963267948965)
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	local v6 = createVector(0, 0, 0)

	for k, v7 in v2 do
		if UserInputService:IsKeyDown(k) then
			v6 += v7
		end
	end

	local v7

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		v7 = FREECAM_DEFAULT_SPEED * Config.FREECAM_BOOST
	else
		v7 = FREECAM_DEFAULT_SPEED
	end

	local cframe = CFrame.fromEulerAnglesYXZ(v4, v5, 0)
	currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position + cframe:VectorToWorldSpace(v6 * v7 * p)) * cframe
	currentCamera.Focus = currentCamera.CFrame * CFrame.new(0, 0, -Config.FREECAM_FOCUS_DISTANCE)
end

local function onInputBegan(p, flag2: boolean)
	if not flag2 and p.KeyCode == Enum.KeyCode.Escape then
		CameraTools.disableFreecam()
	end
end

function CameraTools.bindInput()
	if inputBeganConnection == nil then
		inputBeganConnection = UserInputService.InputBegan:Connect(onInputBegan)
	end
end

function CameraTools.getSpectateTarget()
	return v3
end

function CameraTools.isFreecamActive()
	return flag
end

function CameraTools.getFreecamSpeed()
	return FREECAM_DEFAULT_SPEED
end

function CameraTools.setFreecamSpeed(value: number)
	FREECAM_DEFAULT_SPEED = math.clamp(value, Config.FREECAM_MIN_SPEED, Config.FREECAM_MAX_SPEED)
end

function CameraTools.stopSpectate()
	if v3 then
		v3 = nil
		Remotes.spectateFollow:fire(nil)
		unfreezeCharacter() -- equivalent call inferred; original call site unknown
		restoreCamera() -- equivalent call inferred; original call site unknown
		CameraTools.changed:Fire()
	end
end

function CameraTools.disableFreecam()
	if flag then
		flag = false
		CameraManager.setManualControlActive(false)
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		unfreezeCharacter() -- equivalent call inferred; original call site unknown
		restoreCamera() -- equivalent call inferred; original call site unknown
		CameraTools.changed:Fire()
	end
end

function CameraTools.startSpectate(p)
	CameraTools.disableFreecam()
	v3 = p
	freezeCharacter() -- equivalent call inferred; original call site unknown
	Remotes.spectateFollow:fire(p.UserId)
	CameraTools.changed:Fire()
end

function CameraTools.enableFreecam()
	if not flag then
		CameraTools.stopSpectate()
		freezeCharacter() -- equivalent call inferred; original call site unknown
		flag = true
		CameraManager.setManualControlActive(true)
		local currentCamera = Workspace.CurrentCamera
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.CameraType = Enum.CameraType.Scriptable
		v4, v5 = currentCamera.CFrame:ToEulerAnglesYXZ()
		CameraTools.changed:Fire()
	end
end

function CameraTools.render()
	local now2 = os.clock()
	local v6 = now2 - now
	now = now2
	local v7 = v3

	if v7 then
		if not v7.Parent then
			CameraTools.stopSpectate()
			return
		end

		followTarget(v7) -- equivalent call inferred; original call site unknown
	elseif flag and not CameraManager.cutscene.isInCutscene() then
		moveFreecam(v6)
	end
end

return CameraTools