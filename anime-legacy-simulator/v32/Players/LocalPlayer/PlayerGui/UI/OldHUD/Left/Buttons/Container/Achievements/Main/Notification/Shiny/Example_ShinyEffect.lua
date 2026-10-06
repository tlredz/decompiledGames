local parent = script.Parent
local uIGradient = parent.UIGradient
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function getTime()
	return parent.AbsoluteSize.X / 300
end

while true do
	local time = getTime() -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(uIGradient, TweenInfo.new(time, Enum.EasingStyle.Linear), {
		Offset = Vector2.new(1, 0)
	})
	uIGradient.Offset = Vector2.new(-1, 0)
	tween:Play()
	tween.Completed:Wait()
	task.wait(2.5)
end