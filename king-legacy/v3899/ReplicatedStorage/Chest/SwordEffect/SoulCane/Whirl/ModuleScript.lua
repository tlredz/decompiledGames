local createVector = vector.create
local TweenService = game:GetService("TweenService")
return function()
	local parent = script.Parent
	parent.Size = createVector(0, 10, 0)
	parent.Transparency = 0
	parent.Attachment.Dots:Emit(35)
	parent.Attachment.Spark:Emit(2)
	parent.Attachment.Sm:Emit(15)
	parent.Attachment.sparkl1:Emit(15)
	TweenService:Create(parent, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(28.044, 27.164, 28.012)
	}):Play()
	TweenService:Create(parent, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = parent.CFrame * CFrame.new(0, -30, 0) * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	task.spawn(function()
		wait(0.2)
		TweenService:Create(parent, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
end