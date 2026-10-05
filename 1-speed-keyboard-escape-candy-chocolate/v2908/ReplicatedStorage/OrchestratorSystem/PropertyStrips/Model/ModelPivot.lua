local parent = script.Parent.Parent.Parent
local PropertyStripBuilder = require(parent.PropertyStripBuilder)
local OrchestratorUtils = require(parent.OrchestratorUtils)
return PropertyStripBuilder.Create({
	Type = "ModelPivot",
	DisplayName = "CFrame",
	CanAutoCapture = true,
	Supports = function(model)
		return model:IsA("Model")
	end,
	ValidateValue = function(cframe: CFrame)
		if typeof(cframe) == "CFrame" then
			return true, nil
		end

		return false, "ModelPivot keyframes must contain a CFrame Value."
	end,
	Capture = function(instance)
		return OrchestratorUtils.WorldToParentSpace(instance, instance:GetPivot())
	end,
	Interpolate = function(cframe: CFrame, cframe2: CFrame, p: number)
		return cframe:Lerp(cframe2, p)
	end,
	Apply = function(instance, cframe: CFrame, _)
		instance:PivotTo(OrchestratorUtils.ParentToWorldSpace(instance, cframe))
	end
})