local TweenService = game:GetService("TweenService")
return function(p)
	local parent = script.Parent
	parent.Mesh.Scale = -Vector3.new(p, 35, p) * 0.725
	local Animate = require(parent.Animate)
	Animate()
	TweenService:Create(parent, TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = parent.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
	}):Play()
	TweenService:Create(parent.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = -Vector3.new(p, 35, p)
	}):Play()
end