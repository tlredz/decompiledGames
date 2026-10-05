script.Parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if script.Parent.Enabled then
		return
	end

	task.wait(3)

	if not game.Lighting.cc2.Enabled then
		return
	end

	local TweenService = game:GetService("TweenService")
	TweenService:Create(
		workspace.CurrentCamera,
		TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
		{
			FieldOfView = 70
		}
	):Play()
	game.Lighting.cc2.Enabled = false
end)