local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		if p2.State then
			p.Hinge.Open:Play()
			TweenService:Create(p.Hinge, tweenInfo, {
				CFrame = p.Hinge.CFrame * CFrame.Angles(0, 2.007128639793479, 0)
			}):Play()
		else
			p.Hinge.Close:Play()
			TweenService:Create(p.Hinge, tweenInfo, {
				CFrame = p.Hinge.CFrame * CFrame.Angles(0, -2.007128639793479, 0)
			}):Play()
		end
	end

	for _, parent in { p.Handle, p["Meshes/Fridge_Fridge.018"] } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end