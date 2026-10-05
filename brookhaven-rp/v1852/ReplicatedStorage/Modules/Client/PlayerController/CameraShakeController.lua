local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local CameraShakeController = {}
local currentCamera = workspace.CurrentCamera
CameraShakeController.CamShake = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(p)
	currentCamera.CFrame *= p
end)

function CameraShakeController.FrameworkInit()
	CameraShakeController.CamShake:Start()
end

function CameraShakeController.FrameworkStart() end

return CameraShakeController