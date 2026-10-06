local createVector = vector.create
local TweenService = game:GetService("TweenService")
return function()
	local clone = script.Parent:Clone()
	clone.Parent = workspace.Effects
	clone.Mesh.Scale = createVector(-81, -112.5, -81)
	local Animate = require(clone.Animate)
	Animate()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
	}):Play()
	TweenService:Create(clone.Mesh, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(-90, -125, -90)
	}):Play()
	_G.PU:Dust(clone, 2)
end