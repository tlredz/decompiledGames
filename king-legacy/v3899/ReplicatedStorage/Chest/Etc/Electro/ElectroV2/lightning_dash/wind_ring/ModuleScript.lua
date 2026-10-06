local TweenService = game:GetService("TweenService")
return function(p)
	local parent = script.Parent
	parent.Mesh.Scale = -Vector3.new(p, 32, p) * 0.8
	local Animate = require(parent.Animate)
	Animate()
	TweenService:Create(parent, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = parent.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
	}):Play()
	TweenService:Create(parent.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = -Vector3.new(p, 32, p)
	}):Play()
end