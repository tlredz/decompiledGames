local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
return function(instance)
	local v = BaseInteractable.new()
	instance.PrimaryPart = instance:FindFirstChild(script.Example.PrimaryPart.Name)
	local v2 = v:Replace(instance, script.Example)

	function v.Run(p)
		if p.State then
			TweenService:Create(v2.OnButton, tweenInfo, {
				CFrame = v2.OnButton.CFrame * CFrame.new(0, -0.04, 0)
			}):Play()
			TweenService:Create(v2.OffButton, tweenInfo, {
				CFrame = v2.OffButton.CFrame * CFrame.new(0, 0.04, 0)
			}):Play()
			v2.Frame.Spinner.Sound:Play()
			local renderSteppedConnection = nil
			local RunService = game:GetService("RunService")
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				if not p.State then
					renderSteppedConnection:Disconnect()
					return
				end

				v2.Frame.Spinner.CFrame *= CFrame.Angles(0, math.rad(dt * 2250), 0)
			end)
		else
			v2.Frame.Spinner.Sound:Stop()
			TweenService:Create(v2.OnButton, tweenInfo, {
				CFrame = v2.OnButton.CFrame * CFrame.new(0, 0.04, 0)
			}):Play()
			TweenService:Create(v2.OffButton, tweenInfo, {
				CFrame = v2.OffButton.CFrame * CFrame.new(0, -0.04, 0)
			}):Play()
		end
	end

	for _, parent in { v2.OnButton, v2.OffButton } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end