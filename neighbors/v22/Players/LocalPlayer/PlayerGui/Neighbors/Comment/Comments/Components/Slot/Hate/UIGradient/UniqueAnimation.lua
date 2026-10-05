local TweenService = game:GetService("TweenService")
local parent = script.Parent
local vector = Vector2.new(-1, 0)
local tween = TweenService:Create(parent, TweenInfo.new(0.4, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
	Offset = Vector2.new(1, 0)
})
parent.Offset = vector

-- equivalent calls inferred from this helper; original call sites unknown
local function animate()
	tween:Play()
	tween.Completed:Wait()
	parent.Offset = vector
	task.wait(0)
end

while true do
	animate() -- equivalent call inferred; original call site unknown
end