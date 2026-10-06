local createVector = vector.create
local TweenService = game:GetService("TweenService")
return function()
	local parent = script.Parent
	parent.CFrame = CFrame.new(parent.CFrame.p)
	parent.Parent = workspace.Effects
	parent.Transparency = 0.25
	parent.Size = createVector(73.3145, 11.991, 73.3145)
	TweenService:Create(parent, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = parent.CFrame * CFrame.new(0, -100, 0) * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	TweenService:Create(parent, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(29.61, 2.9355001, 29.61)
	}):Play()
	task.spawn(function()
		wait(0.05)
		TweenService:Create(parent, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
end