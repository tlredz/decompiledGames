local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.SharedUtils.Signal)
local CameraAuthority = require(ReplicatedStorage.SharedUtils.CameraAuthority)
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function takeCamera()
	if v then
		CameraAuthority.reassert()
	else
		v = CameraAuthority.claim("CameraController", {
			priority = 50
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function giveBackCamera()
	if v then
		v:release()
		v = nil
	end
end

local v2 = nil
local v3 = nil
local completedConnection = nil
local v4 = "Idle"
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getCamera()
	return workspace.CurrentCamera
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSubjectPart()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupActiveTween()
	if completedConnection then
		completedConnection:Disconnect()
		completedConnection = nil
	end

	if v2 then
		v2:Cancel()
		v2:Destroy()
		v2 = nil
	end

	if v3 then
		v3:Fire(false)
		v3:Destroy()
		v3 = nil
	end
end

local CameraController = {}

function CameraController.TweenTo(_, cframe: CFrame, duration: number, p, p2)
	cleanupActiveTween() -- equivalent call inferred; original call site unknown
	local camera = getCamera() -- equivalent call inferred; original call site unknown

	if not camera then
		return nil
	end

	takeCamera() -- equivalent call inferred; original call site unknown
	v4 = "Tweening"
	local v5 = p or Enum.EasingStyle.Quad
	local v6 = p2 or Enum.EasingDirection.InOut
	local v7 = Signal.new()
	v3 = v7
	local tween = TweenService:Create(camera, TweenInfo.new(duration, v5, v6), {
		CFrame = cframe
	})
	v2 = tween
	completedConnection = tween.Completed:Connect(function()
		if v2 ~= tween then
			return
		end

		completedConnection:Disconnect()
		completedConnection = nil
		v2:Destroy()
		v2 = nil
		v4 = "Scriptable"
		local v8 = v3
		v3 = nil

		if v8 then
			v8:Fire(true)
			v8:Destroy()
		end
	end)
	tween:Play()
	return v7
end

function CameraController.SetCFrame(_, cFrame: CFrame)
	cleanupActiveTween() -- equivalent call inferred; original call site unknown
	local camera = getCamera() -- equivalent call inferred; original call site unknown

	if not camera then
		return
	end

	takeCamera() -- equivalent call inferred; original call site unknown
	camera.CFrame = cFrame
	v4 = "Scriptable"
end

function CameraController.FitPartInView(_, instance, value: number?)
	local camera = getCamera() -- equivalent call inferred; original call site unknown

	if not camera then
		return
	end

	camera.FieldOfView = 1
	local v5 = instance.Size * 0.5
	local v6 = {
		instance.CFrame * CFrame.new(v5.X, v5.Y, v5.Z),
		instance.CFrame * CFrame.new(-v5.X, v5.Y, v5.Z),
		instance.CFrame * CFrame.new(v5.X, -v5.Y, v5.Z),
		instance.CFrame * CFrame.new(-v5.X, -v5.Y, v5.Z),
		instance.CFrame * CFrame.new(v5.X, v5.Y, -v5.Z),
		instance.CFrame * CFrame.new(-v5.X, v5.Y, -v5.Z),
		instance.CFrame * CFrame.new(v5.X, -v5.Y, -v5.Z),
		instance.CFrame * CFrame.new(-v5.X, -v5.Y, -v5.Z)
	}
	local v7 = value or 5

	while true do
		camera.FieldOfView += 1
		local v8 = true

		for _, v10 in v6 do
			local _, v11 = camera:WorldToViewportPoint(v10.Position)

			if v11 then
				continue
			end

			v8 = false
			break
		end

		if not (v8 or camera.FieldOfView >= 120) then
			continue
		end

		camera.FieldOfView += v7
		break
	end
end

function CameraController.LockOrientation(_)
	if flag then
		return true
	end

	local camera = getCamera() -- equivalent call inferred; original call site unknown
	local subjectPart = getSubjectPart() -- equivalent call inferred; original call site unknown

	if not (camera and subjectPart) then
		return false
	end

	cleanupActiveTween() -- equivalent call inferred; original call site unknown
	local v5 = camera.CFrame.Position - subjectPart.Position
	local v6 = camera.CFrame - camera.CFrame.Position
	takeCamera() -- equivalent call inferred; original call site unknown
	flag = true
	v4 = "OrientationLocked"
	RunService:BindToRenderStep("CameraControllerOrientationLock", Enum.RenderPriority.Camera.Value + 1, function()
		local camera2 = getCamera() -- equivalent call inferred; original call site unknown

		if not camera2 or v and not v:isActive() then
			return
		end

		local subjectPart2 = getSubjectPart() -- equivalent call inferred; original call site unknown

		if not subjectPart2 then
			return
		end

		camera2.CFrame = v6 + (subjectPart2.Position + v5)
	end)
	return true
end

function CameraController:UnlockOrientation()
	if not flag then
		return
	end

	self:Reset()
end

function CameraController.IsOrientationLocked(_)
	return flag
end

function CameraController.Interrupt(_)
	if v4 ~= "Tweening" then
		return
	end

	cleanupActiveTween() -- equivalent call inferred; original call site unknown
	v4 = "Scriptable"
end

function CameraController:Reset()
	cleanupActiveTween() -- equivalent call inferred; original call site unknown

	if flag then
		flag = false
		pcall(function()
			RunService:UnbindFromRenderStep("CameraControllerOrientationLock")
		end)
	end

	local camera = getCamera() -- equivalent call inferred; original call site unknown

	if not camera then
		return
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	camera.CameraSubject = character and character:FindFirstChild("Humanoid")
	giveBackCamera() -- equivalent call inferred; original call site unknown
	v4 = "Idle"
end

function CameraController.GetState(_)
	return v4
end

function CameraController.IsActive(_)
	return v4 ~= "Idle"
end

return CameraController