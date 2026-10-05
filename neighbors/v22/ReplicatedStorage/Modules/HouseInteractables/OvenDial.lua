local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		if p2.State then
			TweenService:Create(p.Dial, tweenInfo, {
				CFrame = p.Dial.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
			}):Play()
			TweenService:Create(p.Burner, tweenInfo2, {
				Color = Color3.fromRGB(86, 36, 36)
			}):Play()
		else
			TweenService:Create(p.Dial, tweenInfo, {
				CFrame = p.Dial.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()
			TweenService:Create(p.Burner, tweenInfo2, {
				Color = Color3.fromRGB(17, 17, 17)
			}):Play()
		end
	end

	for _, parent in { p.Dial } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end