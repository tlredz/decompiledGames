local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local parent = script.Parent
local uIGradient = parent:FindFirstChildOfClass("UIGradient")
local vector = Vector2.new(1, 0)
local vector2 = Vector2.new(-1, 0)
local linear = Enum.EasingStyle.Linear
local tweenInfo = TweenInfo.new(1, linear, Enum.EasingDirection.InOut, 0, false, 0)

if not (parent:IsA("GuiObject") and uIGradient) then
	warn("ColorCycler Script: Requires a GuiObject parent and a UIGradient child to work.")
	return
end

parent.BackgroundTransparency = 0.25

-- equivalent calls inferred from this helper; original call sites unknown
local function createTween()
	return (TweenService:Create(uIGradient, tweenInfo, {
		Offset = vector2
	}))
end

if not RunService:IsRunning() then
	return
end

uIGradient.Offset = vector

while true do
	local tween = createTween() -- equivalent call inferred; original call site unknown
	tween:Play()
	tween.Completed:Wait()
	uIGradient.Offset = vector
end