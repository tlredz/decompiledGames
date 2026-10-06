local numberValue = Instance.new("NumberValue")
numberValue.Value = 0
spawn(function()
	while wait() do
		numberValue.Value += 1

		if numberValue.Value > 100 then
			numberValue.Value = 0
		end
	end
end)
numberValue.Changed:Connect(function()
	local uDim = UDim2.new(math.clamp(numberValue.Value / 100, 0, 1) * 0.88, 0, 0.441, 0)
	script.Parent.Percentage.Text = numberValue.Value .. "%"
	game.TweenService:Create(script.Parent.Bar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = uDim
	}):Play()
end)