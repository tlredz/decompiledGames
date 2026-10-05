local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Remotes = require(ReplicatedStorage.CCPanel.Remotes)
local CameraManager = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.CameraManager)
local localPlayer = Players.LocalPlayer
local CameraTools = {}

local function freezeChar()
	local function sink()
		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindAction(
		"CCPanelFreezeMovement",
		sink,
		false,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D,
		Enum.KeyCode.Space,
		Enum.KeyCode.LeftShift
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unfreezeChar()
	ContextActionService:UnbindAction("CCPanelFreezeMovement")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCamera()
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Custom
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		currentCamera.CameraSubject = humanoid
	end
end

local v = nil
local thread = nil
local characterAddedConnection = nil

function CameraTools.getSpectateTarget()
	return v
end

function CameraTools.stopSpectate()
	if not v then
		return
	end

	v = nil

	if thread then
		task.cancel(thread)
		thread = nil
	end

	if characterAddedConnection then
		characterAddedConnection:Disconnect()
		characterAddedConnection = nil
	end

	Remotes.SpectateFollow:fire(nil)
	unfreezeChar() -- equivalent call inferred; original call site unknown
	restoreCamera() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attachCamera(player)
	if thread then
		task.cancel(thread)
	end

	thread = task.spawn(function()
		while v == player do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				local currentCamera = workspace.CurrentCamera
				currentCamera.CameraType = Enum.CameraType.Custom
				currentCamera.CameraSubject = humanoid
				thread = nil
				break
			else
				task.wait(0.1)
			end
		end
	end)
end

function CameraTools.startSpectate(player)
	if CameraTools.isFreecamActive() then
		CameraTools.disableFreecam()
	end

	CameraTools.stopSpectate()
	v = player
	freezeChar()
	Remotes.SpectateFollow:fire(player.UserId)
	characterAddedConnection = player.CharacterAdded:Connect(function()
		if v == player then
			attachCamera(player) -- equivalent call inferred; original call site unknown
		end
	end)
	attachCamera(player) -- equivalent call inferred; original call site unknown
end

local flag = false
local renderSteppedConnection = nil
local v2 = 20

function CameraTools.isFreecamActive()
	return flag
end

function CameraTools.getFreecamSpeed()
	return v2
end

function CameraTools.addFreecamSpeed(p: number)
	v2 = math.clamp(v2 + p, 5, 200)
	return v2
end

function CameraTools.disableFreecam()
	if not flag then
		return
	end

	flag = false
	CameraManager.setManualControlActive(false)

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	unfreezeChar() -- equivalent call inferred; original call site unknown
	restoreCamera() -- equivalent call inferred; original call site unknown
end

function CameraTools.enableFreecam()
	if flag then
		return
	end

	if v then
		CameraTools.stopSpectate()
	end

	freezeChar()
	flag = true
	CameraManager.setManualControlActive(true)
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CameraType = Enum.CameraType.Scriptable
	local eulerAnglesYXZ, v3, _ = currentCamera.CFrame:ToEulerAnglesYXZ()
	local v4 = eulerAnglesYXZ
	local v5 = v3
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if CameraManager.cutscene.isInCutscene() then
			return
		end

		local currentCamera2 = workspace.CurrentCamera

		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			local mouseDelta = UserInputService:GetMouseDelta()
			v5 -= mouseDelta.X * 0.003
			v4 -= mouseDelta.Y * 0.003
			v4 = math.clamp(v4, -1.5607963267948965, 1.5607963267948965)
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end

		local v6 = createVector(0, 0, 0)

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			v6 += createVector(0, 0, -1)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			v6 += createVector(0, 0, 1)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			v6 += createVector(-1, 0, 0)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			v6 += createVector(1, 0, 0)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.E) then
			v6 += createVector(0, 1, 0)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			v6 += createVector(0, -1, 0)
		end

		local v7 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and v2 * 3 or v2
		local cframe = CFrame.fromEulerAnglesYXZ(v4, v5, 0)
		currentCamera2.CFrame = CFrame.new(currentCamera2.CFrame.Position + cframe:VectorToWorldSpace(v6 * v7 * dt)) * cframe
		currentCamera2.Focus = currentCamera2.CFrame * CFrame.new(0, 0, -10)
	end)
end

return CameraTools