local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local parent = script.Parent
local uDim = UDim2.new(2.5, 0, 2.5, 0)
local uDim2 = UDim2.new(2, 0, 2, 0)
local elastic = Enum.EasingStyle.Elastic
local tweenInfo = TweenInfo.new(0.5, elastic, Enum.EasingDirection.Out, 0, false, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function createTween(uDim3)
	return (TweenService:Create(parent, tweenInfo, {
		Size = uDim3
	}))
end

if not RunService:IsRunning() then
	return
end

parent.Size = uDim2

while true do
	local tween = createTween(uDim) -- equivalent call inferred; original call site unknown
	tween:Play()
	tween.Completed:Wait()
	local tween2 = createTween(uDim2) -- equivalent call inferred; original call site unknown
	tween2:Play()
	tween2.Completed:Wait()
end