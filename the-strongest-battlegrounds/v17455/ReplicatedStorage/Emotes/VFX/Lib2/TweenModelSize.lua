return function(instance, p: number, p2)
	local tweenInfo = p2.TweenInfo or TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local startSize = p2.StartSize or instance:GetScale()
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = startSize
	local changedConnection = numberValue.Changed:Connect(function(p3)
		instance:ScaleTo(p3)
	end)
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = p
	})
	tween:Play()
	local completedConnection = nil
	completedConnection = tween.Completed:Connect(function()
		numberValue:Destroy()
		completedConnection:Disconnect()
		changedConnection:Disconnect()
	end)
	return tween
end