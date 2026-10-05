local createVector = vector.create
local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		local state = p2.State

		if (p.Union.Size - createVector(10.61, 9, 0.6)).Magnitude >= 0.5 or (p.Union.Size - createVector(1.061, 9, 0.6)).Magnitude >= 0.5 then
			if state then
				p.Union.Close:Play()
				TweenService:Create(p.Union, tweenInfo, {
					Size = createVector(10.61, 9, 0.6),
					CFrame = p.Union.CFrame * CFrame.new(-4.5, 0, 0)
				}):Play()
			else
				p.Union.Open:Play()
				TweenService:Create(p.Union, tweenInfo, {
					Size = createVector(1.061, 9, 0.6),
					CFrame = p.Union.CFrame * CFrame.new(4.5, 0, 0)
				}):Play()
			end
		end
	end

	for _, parent in { p.Union } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end