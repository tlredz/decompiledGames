local TweenService = game:GetService("TweenService")
local PresetAnimations = {}

function PresetAnimations.InfSpin1(p)
	local circle = p.Instance.Circle
	p.Rotation = 320
	local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local total = 0
	local total2 = 90
	local v = nil
	local RunService = game:GetService("RunService")
	return (RunService.RenderStepped:Connect(function(dt)
		total += 100 * dt
		circle.Rotation = total

		if v == nil or v.PlaybackState == Enum.PlaybackState.Completed then
			v = TweenService:Create(p.Instance, tweenInfo, {
				Rotation = total2
			})
			v:Play()
			total2 += 90
		end
	end))
end

function PresetAnimations.InfSpin2(p)
	local RunService = game:GetService("RunService")
	return (RunService.RenderStepped:Connect(function(dt)
		p.Rotation += 80 * dt
	end))
end

function PresetAnimations.InfSpin3(p)
	local circle = p.Instance.Circle
	local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local total = 0
	local total2 = 90
	local v = nil
	local RunService = game:GetService("RunService")
	return (RunService.RenderStepped:Connect(function(dt)
		total += 100 * dt
		circle.Rotation = total
		p.Rotation = total

		if v == nil or v.PlaybackState == Enum.PlaybackState.Completed then
			v = TweenService:Create(p.Instance, tweenInfo, {
				Rotation = total2
			})
			v:Play()
			total2 += 90
		end
	end))
end

return PresetAnimations