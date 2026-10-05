game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
return function(instance)
	local v = BaseInteractable.new()
	instance.PrimaryPart = instance:FindFirstChild(script.Example.PrimaryPart.Name)
	local clone = script.Example:Clone()
	clone:PivotTo(instance:GetPivot())
	clone.Parent = instance.Parent
	clone.Name = instance.Name
	instance:Destroy()

	function v.Run(p)
		if p.State then
			clone.Frame.LightBulb.PointLight.Enabled = true
			clone.Frame.Shade.Material = Enum.Material.Neon
			clone.Frame.LightBulb.Material = Enum.Material.Neon
		else
			clone.Frame.LightBulb.PointLight.Enabled = false
			clone.Frame.Shade.Material = Enum.Material.Sand
			clone.Frame.LightBulb.Material = Enum.Material.SmoothPlastic
		end
	end

	for _, parent in { clone.Button, clone.Frame.Shade } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end