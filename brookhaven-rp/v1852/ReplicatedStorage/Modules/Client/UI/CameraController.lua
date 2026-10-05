local CameraController = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local walkSpeed = nil
local jumpPower = nil
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BasePartUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Utils"):WaitForChild("BasePartUtil"))
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = nil

local function getReferences()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	return {
		character = character,
		humanoid = character:WaitForChild("Humanoid"),
		camera = workspace.CurrentCamera
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCharacterMovement(humanoid, flag: boolean)
	if flag then
		if humanoid.WalkSpeed == 0 then
			humanoid.WalkSpeed = walkSpeed or 16
		end

		walkSpeed = nil

		if humanoid.JumpPower == 0 then
			humanoid.JumpPower = jumpPower or 50
		end

		jumpPower = nil
	else
		if humanoid.WalkSpeed > 0 then
			walkSpeed = humanoid.WalkSpeed
		end

		if humanoid.JumpPower > 0 then
			jumpPower = humanoid.JumpPower
		end

		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end
end

local function isAccessoryAdjustmentsExperimentEnabled()
	if v ~= nil then
		return v == true
	end

	local success, result = pcall(function()
		return ABTest.GetExperimentVariable("avatar-editor-camera-move", "enabled"):expect()
	end)
	v = success and result == true
	return v == true
end

function CameraController.SetCustomCamera(cFrame: CFrame, p, p2, flag: boolean?)
	local references = getReferences()
	local cameraSubject = p or references.humanoid
	setCharacterMovement(references.humanoid, flag or false) -- equivalent call inferred; original call site unknown
	references.camera.CameraSubject = cameraSubject
	references.camera.CameraType = "Scriptable"

	if p2 then
		TweenService:Create(references.camera, p2, {
			CFrame = cFrame
		}):Play()
	else
		references.camera.CFrame = cFrame
	end
end

function CameraController.SetCameraZoom(p: number)
	Players.LocalPlayer.CameraMinZoomDistance = p
	Players.LocalPlayer.CameraMaxZoomDistance = p
	Players.LocalPlayer.CameraMinZoomDistance = 0.5
	Players.LocalPlayer.CameraMaxZoomDistance = 128
end

function CameraController.SetDefaultCamera()
	local references = getReferences()
	local humanoid = references.humanoid

	if humanoid.WalkSpeed == 0 then
		humanoid.WalkSpeed = walkSpeed or 16
	end

	walkSpeed = nil

	if humanoid.JumpPower == 0 then
		humanoid.JumpPower = jumpPower or 50
	end

	jumpPower = nil
	references.camera.CameraSubject = references.humanoid
	references.camera.CameraType = "Custom"
end

function CameraController.SetAvatarEditorCamera(flag: boolean?)
	if v == nil then
		local success, result = pcall(function()
			return ABTest.GetExperimentVariable("avatar-editor-camera-move", "enabled"):expect()
		end)
		v = success and result == true
	end

	if v == true then
		return
	end

	local vector = Vector2.new(0.4, 0.46)
	local character = Players.LocalPlayer.Character
	local currentCamera = workspace.CurrentCamera
	local boundingBox, size = character:GetBoundingBox()
	local v4 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
	local position = (boundingBox * CFrame.new(0, size.Y / 2, -size.Z / 2)).Position
	local position2 = (boundingBox * CFrame.new(0, -size.Y / 2, -size.Z / 2)).Position
	local v5 = ((position.Y - position2.Y) / 2 / v4 + size.Z / 2) * 1.25
	local v6 = v5 * math.tan(math.atan(v4 * (currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y)) * 2 / 2) * 2 / currentCamera.ViewportSize.X
	local v7 = v5 * 2 * v4 / currentCamera.ViewportSize.Y
	local cFrame = boundingBox * CFrame.new(0, 0, -v5)
	local position3 = (boundingBox * CFrame.new(
		(vector.X - 0.5) * currentCamera.ViewportSize.X * v6,
		(vector.Y - 0.5) * currentCamera.ViewportSize.Y * v7,
		0
	)).Position
	local v9 = BasePartUtil.closestPoint({
		CFrame = boundingBox,
		Size = size
	}, {
		CFrame = cFrame,
		Size = Vector3.new(-currentCamera.NearPlaneZ, -currentCamera.NearPlaneZ, -currentCamera.NearPlaneZ)
	}) - boundingBox.LookVector * (size.Z / 2)
	local v10 = CFrame.new(v9, v9 + boundingBox.LookVector) * CFrame.new(0, 0, -v5)
	local cframe = CFrame.new(v10.Position, position3)
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid and humanoid:IsA("Humanoid") then
		local setCustomCamera = CameraController.SetCustomCamera
		local v11

		if flag then
			v11 = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else
			v11 = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end

		setCustomCamera(cframe, humanoid, v11)
	end
end

function CameraController.FrameworkInit() end

function CameraController.FrameworkStart() end

return CameraController