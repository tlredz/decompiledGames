local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		if p2.State then
			TweenService:Create(p.Button, tweenInfo2, {
				Color = Color3.fromRGB(162, 0, 0)
			}):Play()
			TweenService:Create(p.BottomHeater, tweenInfo, {
				Color = Color3.fromRGB(86, 36, 36)
			}):Play()
			TweenService:Create(p.TopHeater, tweenInfo, {
				Color = Color3.fromRGB(86, 36, 36)
			}):Play()
		else
			TweenService:Create(p.Button, tweenInfo2, {
				Color = Color3.fromRGB(40, 40, 40)
			}):Play()
			TweenService:Create(p.BottomHeater, tweenInfo, {
				Color = Color3.fromRGB(40, 40, 40)
			}):Play()
			TweenService:Create(p.TopHeater, tweenInfo, {
				Color = Color3.fromRGB(40, 40, 40)
			}):Play()
		end
	end

	for _, parent in { p.Button } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end