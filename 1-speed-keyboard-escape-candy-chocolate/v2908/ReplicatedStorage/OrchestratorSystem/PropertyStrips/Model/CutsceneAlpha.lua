local RunService = game:GetService("RunService")
local parent = script.Parent.Parent.Parent
local CutsceneCameraController = require(parent.CutsceneCameraController)
local PropertyStripBuilder = require(parent.PropertyStripBuilder)
return PropertyStripBuilder.Create({
	Type = "CutsceneAlpha",
	DisplayName = "Cutscene Alpha",
	EditableProperties = {
		{
			Path = { "Value" },
			DisplayName = "Alpha",
			ValueType = "number",
			Min = 0,
			Max = 1,
			Step = 0.01
		}
	},
	Supports = function(model)
		return model:IsA("Model") and CutsceneCameraController.GetCameraPart(model) ~= nil
	end,
	ValidateValue = function(value: number)
		if type(value) == "number" and value == value and not (value < 0 or value > 1) then
			return true, nil
		end

		return false, "CutsceneAlpha keyframes must contain a number Value between 0 and 1."
	end,
	Capture = function(_)
		return 0
	end,
	Interpolate = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	Apply = function(p, p2: number, p3)
		if RunService:IsRunning() and p3.IsServer then
			return
		end

		local cameraPart = CutsceneCameraController.GetCameraPart(p)

		if cameraPart then
			CutsceneCameraController.SetAlpha(p, cameraPart, p2)
		else
			CutsceneCameraController.ClearAlpha(p)
		end
	end,
	OnStop = function(p)
		CutsceneCameraController.ClearAlpha(p.Target)
	end
})