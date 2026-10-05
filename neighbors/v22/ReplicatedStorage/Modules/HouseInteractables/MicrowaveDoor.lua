local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		if p2.State then
			TweenService:Create(p.Hinge, tweenInfo, {
				CFrame = p.Hinge.CFrame * CFrame.Angles(0, -2.0943951023931953, 0)
			}):Play()
		else
			TweenService:Create(p.Hinge, tweenInfo, {
				CFrame = p.Hinge.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
			}):Play()
		end
	end

	for _, parent in { p.Handle, p.Latch, p.Part } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end