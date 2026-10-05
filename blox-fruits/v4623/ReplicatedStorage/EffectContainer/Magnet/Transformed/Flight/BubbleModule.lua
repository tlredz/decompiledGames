local TweenService = game:GetService("TweenService")
return {
	CreateBubble = function(cFrame, size, transparency, size2, duration, parent)
		local clone = script.Distortion:Clone()
		clone.CFrame = cFrame
		clone.Anchored = true
		clone.CanCollide = false
		clone.Massless = true
		clone.Parent = parent
		clone.Material = Enum.Material.Glass
		clone.Size = size
		clone.Transparency = transparency
		local highlight = Instance.new("Highlight")
		highlight.Enabled = false
		highlight.Parent = clone
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = size2,
				Transparency = 15
			}
		)
		tween:Play()
		tween.Completed:Wait()
		TweenService:Create(clone, TweenInfo.new(0.1), {
			Transparency = 1,
			Size = size2 * 1.1
		}):Play()
		task.wait(0.1)
		clone:Destroy()
	end
}