local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(1.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(3.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
return function(instance)
	local v = BaseInteractable.new()
	instance.PrimaryPart = instance:FindFirstChild(script.Example.PrimaryPart.Name)
	local clone = script.Example:Clone()
	clone:PivotTo(instance:GetPivot())
	clone.Parent = instance.Parent
	clone.Name = instance.Name
	instance:Destroy()
	local v2 = {
		Rotate = {
			Joint = clone.Hinge.Rotate,
			Offset = CFrame.Angles(0, -1.7453292519943295, 0)
		}
	}
	local v3 = {}

	for k, v4 in v2 do
		v3[k] = {
			C0 = v4.Joint.C0,
			C1 = v4.Joint.C1
		}
	end

	function v.Run(p)
		if p.State then
			for k, v4 in v2 do
				local C0 = v3[k].C0 * v4.Offset
				clone.Main.open:Play()
				TweenService:Create(v4.Joint, tweenInfo, {
					C0 = C0
				}):Play()
			end
		else
			for k, v4 in v2 do
				local C0 = v3[k].C0
				clone.Main.closing:Play()
				local tween = TweenService:Create(v4.Joint, tweenInfo2, {
					C0 = C0
				})
				tween:Play()
				tween.Completed:Wait()
				clone.Main.slam:Play()

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(20)
					end
				end
			end
		end
	end

	for _, parent in { clone.Click } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end