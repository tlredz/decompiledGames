local parent = script.Parent
local arrow = parent:WaitForChild("Arrow")
local mobilePianoGui = script:FindFirstAncestor("MobilePianoGui")
local flag = false
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
mobilePianoGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	parent.Visible = true
	task.wait(5)
	TweenService:Create(parent, tweenInfo, {
		BackgroundTransparency = 1,
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
	TweenService:Create(arrow, tweenInfo, {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
	task.wait(2.5)

	if flag then
		return
	end

	flag = true
	parent:Destroy()
end)
parent.Activated:Connect(function()
	flag = true
	parent:Destroy()
end)