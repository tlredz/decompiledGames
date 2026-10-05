game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		if p2.State then
			p.KeypadSound.Beep:Play()
			p.Display.SurfaceGui.TextBox.Text = "ON"
			p.Light.SurfaceLight.Enabled = true
			p.KeypadSound.Microwave.Playing = true
		else
			p.Display.SurfaceGui.TextBox.Text = "OFF"
			p.Light.SurfaceLight.Enabled = false
			p.KeypadSound.Microwave.Playing = false
		end
	end

	for _, parent in { p.KeypadSound } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end