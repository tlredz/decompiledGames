local parent = script.Parent
local TweenService = game:GetService("TweenService")
local uIStroke = parent:WaitForChild("UIStroke")
local tween = TweenService:Create(uIStroke, TweenInfo.new(2), {
	Transparency = 1
})
local tween2 = TweenService:Create(parent, TweenInfo.new(2), {
	TextTransparency = 1
})
local thread = nil
parent:GetPropertyChangedSignal("Text"):Connect(function()
	if thread then
		task.cancel(thread)
		tween2:Cancel()
		tween:Cancel()
		thread = nil
	end

	parent.TextTransparency = 0
	uIStroke.Transparency = 0
	thread = task.spawn(function()
		task.wait(5)
		tween2:Play()
		tween:Play()
		task.wait(2)
		parent.Text = ""
	end)
end)
game.ReplicatedStorage.Remotes.Reusable.GameWarning.OnClientEvent:Connect(function(text)
	parent.Text = text
end)