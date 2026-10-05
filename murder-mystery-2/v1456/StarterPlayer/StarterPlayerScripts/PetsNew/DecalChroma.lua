return function(p)
	local TweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	local v = {
		TweenService:Create(p, tweenInfo, {
			Color3 = Color3.fromRGB(255, 0, 0)
		}),
		TweenService:Create(p, tweenInfo, {
			Color3 = Color3.fromRGB(255, 255, 0)
		}),
		TweenService:Create(p, tweenInfo, {
			Color3 = Color3.fromRGB(0, 255, 0)
		}),
		TweenService:Create(p, tweenInfo, {
			Color3 = Color3.fromRGB(0, 255, 255)
		}),
		TweenService:Create(p, tweenInfo, {
			Color3 = Color3.fromRGB(0, 0, 255)
		}),
		TweenService:Create(p, tweenInfo, {
			Color3 = Color3.fromRGB(255, 0, 255)
		})
	}

	while task.wait() do
		for _, v2 in pairs(v) do
			v2:Play()
			task.wait(1)
		end
	end
end