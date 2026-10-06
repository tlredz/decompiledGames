local createVector = vector.create
local TweenService = game:GetService("TweenService")
return function()
	local parent = script.Parent
	parent.CFrame = CFrame.new(parent.CFrame.p + createVector(0, 2.5, 0))
	parent.Parent = workspace.Effects
	parent.Transparency = 0.4
	parent.Size = createVector(49.849, 5.894, 49.85)
	TweenService:Create(parent, TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = parent.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	TweenService:Create(parent, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(89.013756, 7.7297497, 89.013756)
	}):Play()
	task.spawn(function()
		wait(0.125)
		TweenService:Create(parent, TweenInfo.new(1.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	_G.PU:Dust(parent, 2)
end