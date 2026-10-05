local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local parent = script.Parent.Parent.Parent
local CutsceneCameraController = require(parent.CutsceneCameraController)
local PropertyStripBuilder = require(parent.PropertyStripBuilder)
return PropertyStripBuilder.Create({
	Type = "CutsceneFOV",
	DisplayName = "Cutscene FOV",
	EditableProperties = {
		{
			Path = { "Value" },
			DisplayName = "FOV",
			ValueType = "number",
			Min = 1,
			Max = 120,
			Step = 0.1
		}
	},
	Supports = function(model)
		return model:IsA("Model") and CutsceneCameraController.GetCameraPart(model) ~= nil
	end,
	ValidateValue = function(value: number)
		if type(value) == "number" and value == value and not (value < 1 or value > 120) then
			return true, nil
		end

		return false, "CutsceneFOV keyframes must contain a number Value between 1 and 120."
	end,
	Capture = function(_)
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			return currentCamera.FieldOfView
		end

		return 70
	end,
	Interpolate = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	Apply = function(p, p2: number, p3)
		if RunService:IsRunning() and p3.IsServer then
			return
		end

		CutsceneCameraController.SetFOV(p, p2)
	end,
	OnStop = function(p)
		CutsceneCameraController.ClearFOV(p.Target)
	end
})