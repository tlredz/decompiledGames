local createVector = vector.create
local TweenService = game:GetService("TweenService")
return function()
	local parent = script.Parent
	parent.CFrame = CFrame.new(parent.CFrame.p - createVector(0, 5, 0))
	parent.Parent = workspace.Effects
	parent.Transparency = 0.4
	parent.Size = createVector(42.37165, 5.0099, 42.3725)
	parent.Specs:Emit(30)
	TweenService:Create(parent, TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = parent.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	TweenService:Create(parent, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(63.581253, 5.52125, 63.581253)
	}):Play()
	task.spawn(function()
		wait(0.05)
		TweenService:Create(parent, TweenInfo.new(1.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	_G.PU:Dust(parent, 2)
end