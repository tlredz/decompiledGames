local createVector = vector.create
local TweenService = game:GetService("TweenService")
return function()
	local parent = script.Parent
	parent.CFrame = CFrame.new(parent.CFrame.p) * CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	)
	parent.Parent = workspace.Effects
	parent.Transparency = 0.25
	parent.Size = Vector3.new()
	TweenService:Create(parent, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = parent.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	TweenService:Create(parent, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(12.309999, 0.3125, 12.309999)
	}):Play()
	task.spawn(function()
		wait(0.1)
		TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
end