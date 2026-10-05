local TweenService = game:GetService("TweenService")
return function(instance, p, cframe: CFrame)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = instance:GetPivot()
	local tween = TweenService:Create(cFrameValue, p, {
		Value = cframe
	})
	cFrameValue.Changed:Connect(function(cframe2: CFrame)
		instance:PivotTo(cframe2)
	end)
	tween.Completed:Once(function()
		tween:Destroy()
		cFrameValue:Destroy()
	end)
	return tween
end