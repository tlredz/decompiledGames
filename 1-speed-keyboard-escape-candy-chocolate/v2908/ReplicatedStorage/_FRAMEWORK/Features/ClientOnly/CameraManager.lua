local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
require(script.Cutscene)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local CameraManager = {
	cutscene = require(script.Cutscene)
}
local v = false

function CameraManager.setManualControlActive(flag: boolean)
	v = flag
end

function CameraManager.isManualControlActive()
	return v
end

function CameraManager.resetFOV()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		currentCamera.FieldOfView = 70
	end
end

function CameraManager.getFOVOverwrite()
	if CameraManager.cutscene.isInCutscene() then
		return CameraManager.cutscene.getCutsceneFOV()
	end

	return nil
end

function CameraManager.getCFrameOverwrite()
	return CameraManager.cutscene.getCurrentCutsceneCFrame()
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsServer() then
			return
		end

		CameraManager.cutscene.onCutsceneStateChanged:Connect(function(p)
			if not p then
				CameraManager.resetFOV()
			end
		end)
	end,
	OnRender = function()
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			if v or CameraManager.cutscene.isInCutscene() then
				currentCamera.CameraType = Enum.CameraType.Scriptable
			else
				currentCamera.CameraType = Enum.CameraType.Custom
			end

			local cFrameOverwrite = CameraManager.getCFrameOverwrite()

			if cFrameOverwrite then
				currentCamera.CFrame = cFrameOverwrite
				currentCamera.Focus = cFrameOverwrite
			end

			local fOVOverwrite = CameraManager.getFOVOverwrite()

			if fOVOverwrite then
				currentCamera.FieldOfView = fOVOverwrite
			end
		end
	end
})
return CameraManager