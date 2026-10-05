game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
return function(instance)
	local v = BaseInteractable.new()
	local clone = script.Example:Clone()
	clone:PivotTo(instance:GetPivot())
	clone.Parent = instance.Parent
	clone.Name = instance.Name
	instance:Destroy()

	function v.Run(p)
		if p.State then
			clone.Frame.LightBulb.PointLight.Enabled = true
			clone.Frame.LightBulb.Material = Enum.Material.Neon
		else
			clone.Frame.LightBulb.PointLight.Enabled = false
			clone.Frame.LightBulb.Material = Enum.Material.SmoothPlastic
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