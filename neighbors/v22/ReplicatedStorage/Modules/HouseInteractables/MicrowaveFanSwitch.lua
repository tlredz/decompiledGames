local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		if p2.State then
			p.Fan.FanSound:Play()
			TweenService:Create(p.FanSwitch, tweenInfo, {
				CFrame = p.FanSwitch.CFrame * CFrame.Angles(0.5235987755982988, 0, 0)
			}):Play()
			TweenService:Create(p.FanLight, tweenInfo2, {
				Color = Color3.fromRGB(140, 0, 0)
			}):Play()
		else
			p.Fan.FanSound:Stop()
			TweenService:Create(p.FanSwitch, tweenInfo, {
				CFrame = p.FanSwitch.CFrame * CFrame.Angles(-0.5235987755982988, 0, 0)
			}):Play()
			TweenService:Create(p.FanLight, tweenInfo2, {
				Color = Color3.fromRGB(58, 58, 58)
			}):Play()
		end
	end

	for _, parent in { p.FanSwitch } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end