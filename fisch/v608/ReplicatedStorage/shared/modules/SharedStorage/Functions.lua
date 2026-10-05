local RunService = game:GetService("RunService")
local v = {}
RunService:IsStudio()

if RunService:IsServer() then
	function v.GetProximityPrompt(items)
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Style = Enum.ProximityPromptStyle.Custom

		for k, item in items do
			proximityPrompt[k] = item
		end

		return proximityPrompt
	end

	function v.GetParentSafe(model)
		if not model:IsA("Model") then
			return model
		end

		local basePart = model:FindFirstChildWhichIsA("BasePart")
		assert(basePart, "No BasePart found in model.")
		return basePart
	end
end

RunService:IsClient()
return table.freeze(v)