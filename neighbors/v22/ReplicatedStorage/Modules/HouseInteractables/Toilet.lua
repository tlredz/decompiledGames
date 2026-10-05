game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
return function(instance)
	local v = BaseInteractable.new()
	local clone = script.Example:Clone()
	clone:PivotTo(instance:GetPivot())
	clone.Parent = instance.Parent
	clone.Name = instance.Name
	instance:Destroy()

	function v.Run(p)
		if not p.State then
			TweenService:Create(clone.Water, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Position = clone.TopWater.Position,
				Size = clone.TopWater.Size
			}):Play()
			return
		end

		clone.Water.FlushSound:Play()
		TweenService:Create(clone.Water, TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = clone.BottomWater.Position,
			Size = clone.BottomWater.Size
		}):Play()
		TweenService:Create(clone.Handle, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			CFrame = clone.Handle.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
		}):Play()
		task.wait(0.45)
		TweenService:Create(clone.Handle, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			CFrame = clone.Handle.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
		}):Play()
	end

	for _, parent in { clone.Lever, clone.Handle } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end