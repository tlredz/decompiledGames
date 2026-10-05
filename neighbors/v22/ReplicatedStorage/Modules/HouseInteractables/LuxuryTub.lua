local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
return function(instance)
	local v = BaseInteractable.new()
	local clone = script.Example:Clone()
	clone:PivotTo(instance:GetPivot())
	clone.Parent = instance.Parent
	clone.Name = instance.Name
	instance:Destroy()
	local v2 = {
		Handle = {
			Motor = clone.Hinge.ShowerLever,
			Offset = CFrame.Angles(1.5707963267948966, 0, 0)
		}
	}
	local C0s = {}

	for k, v3 in v2 do
		C0s[k] = v3.Motor.C0
	end

	function v.Run(p)
		if p.State then
			for _, v3 in v2 do
				TweenService:Create(v3.Motor, tweenInfo, {
					C0 = v3.Motor.C0 * v3.Offset
				}):Play()
			end

			clone.Showerhead.ShowerSound:Play()
			clone.Showerhead.Faucet.ParticleEmitter.Enabled = true
		else
			for k, v3 in v2 do
				TweenService:Create(v3.Motor, tweenInfo, {
					C0 = C0s[k]
				}):Play()
			end

			clone.Showerhead.ShowerSound:Stop()
			clone.Showerhead.Faucet.ParticleEmitter.Enabled = false
		end
	end

	for _, parent in { clone.ShowerLever } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end