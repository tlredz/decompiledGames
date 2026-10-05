game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
return function(folder)
	local v = BaseInteractable.new()
	local clone = script.Example:Clone()
	clone:PivotTo(folder:GetPivot())
	clone.Parent = folder.Parent
	clone.Name = folder.Name

	local function FindMatchingPart(part)
		for _, descendant in folder:GetDescendants() do
			if descendant.Name == part.Name and descendant.ClassName == part.ClassName then
				return descendant
			end
		end

		return nil
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local part2 = FindMatchingPart(part)

		if not (part2 and part2:IsA("BasePart")) then
			continue
		end

		part.Color = part2.Color
		part.Material = part2.Material
		part.MaterialVariant = part2.MaterialVariant
	end

	folder:Destroy()

	function v.Run(p)
		if p.State then
			clone.Frame.BrightShade.Transparency = 0
			clone.Frame.Light.PointLight.Enabled = true
			clone.Frame.Glass.Material = Enum.Material.Neon
			clone.Frame.Light.Material = Enum.Material.Neon
		else
			clone.Frame.BrightShade.Transparency = 1
			clone.Frame.Light.PointLight.Enabled = false
			clone.Frame.Glass.Material = Enum.Material.SmoothPlastic
			clone.Frame.Light.Material = Enum.Material.SmoothPlastic
		end
	end

	for _, parent in { clone.Button, clone.Frame.Base } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end