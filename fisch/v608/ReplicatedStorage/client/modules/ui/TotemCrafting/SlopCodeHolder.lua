local Lighting = game:GetService("Lighting")
return function(instance, callback, p, p2)
	instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if instance.Visible then
			task.wait()
			callback(workspace.CurrentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				FieldOfView = 60
			})
			callback(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 10
				}
			)
			callback(
				Lighting:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = -0.07,
					TintColor = Color3.fromRGB(184, 184, 184),
					Saturation = -0.3
				}
			)
		else
			callback(workspace.CurrentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				FieldOfView = 70
			})
			callback(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 0
				}
			)
			callback(
				Lighting:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255),
					Saturation = 0
				}
			)
		end

		p2.topbar.Visible = not instance.Visible
		p.backpack.Enabled = not instance.Visible
	end)
end