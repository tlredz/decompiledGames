local parent = script.Parent
parent:WaitForChild("Background")
local leftFrame = parent:WaitForChild("LeftFrame")
local rightFrame = parent:WaitForChild("RightFrame")
local tweenNumber = parent.TweenNumber
tweenNumber.Value = 1
tweenNumber.Changed:Connect(function()
	wait()
	local rotation = math.min(tweenNumber.Value * 360, 180)
	rightFrame.Label.UIGradient.Rotation = rotation
	leftFrame.Label.UIGradient.Rotation = math.min(math.max(tweenNumber.Value - 0.5, 0) * 360, 180) + -180
end)