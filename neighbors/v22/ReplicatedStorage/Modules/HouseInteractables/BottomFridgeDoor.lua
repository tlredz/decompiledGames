local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		if p2.State then
			TweenService:Create(p.Hinge, tweenInfo, {
				CFrame = p.Hinge.CFrame * CFrame.new(-2.3, 0, 0)
			}):Play()
			TweenService:Create(p.LittleDrawer, tweenInfo, {
				CFrame = p.LittleDrawer.CFrame * CFrame.new(-1.15, 0, 0)
			}):Play()
		else
			TweenService:Create(p.Hinge, tweenInfo, {
				CFrame = p.Hinge.CFrame * CFrame.new(2.3, 0, 0)
			}):Play()
			TweenService:Create(p.LittleDrawer, tweenInfo, {
				CFrame = p.LittleDrawer.CFrame * CFrame.new(1.15, 0, 0)
			}):Play()
		end
	end

	for _, parent in { p.Handle, p["Meshes/Fridge_Fridge.013"] } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end