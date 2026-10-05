local CameraShakeUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraShaker = require(ReplicatedStorage.Modules.Client.Camera.CameraShaker)
require(ReplicatedStorage.Modules.Client.Camera.CameraShaker.CameraShakePresets)
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(cframe: CFrame)
	game.Workspace.CurrentCamera.CFrame *= cframe
end, "ReusableShaker")

function CameraShakeUtil.GetShakePresets()
	return CameraShaker.Presets
end

function CameraShakeUtil.GetCameraShaker()
	return v
end

return CameraShakeUtil