local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local OverlayRoot = require(script.Parent.OverlayRoot)
local v = {
	template = ReplicatedStorage.Assets.UI.Misc.ShockSphere,
	seconds = 0.8,
	startTransparency = 0.1,
	coverage = 0.55,
	minPeak = 4,
	maxPeak = 200,
	fallbackScreenFactor = 16
}
local tweenInfo = TweenInfo.new(v.seconds, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(v.seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- equivalent calls inferred from this helper; original call sites unknown
local function midpoint(p)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return UDim2.fromOffset(absolutePosition.X + absoluteSize.X * 0.5, absolutePosition.Y + absoluteSize.Y * 0.5)
end

local function peakScaleFor(p, p2: number)
	local v2 = math.max(p.AbsoluteSize.Magnitude, 1)
	local currentCamera = workspace.CurrentCamera
	local v3

	if currentCamera then
		v3 = currentCamera.ViewportSize.Magnitude
	else
		v3 = v2 * v.fallbackScreenFactor
	end

	return (math.clamp(v3 / v2 * v.coverage * p2, v.minPeak, v.maxPeak))
end

local function timed(data, duration: number)
	if duration == data.Time then
		return data
	end

	return (TweenInfo.new(duration, data.EasingStyle, data.EasingDirection))
end

local function pulseOf(parent)
	local uIScale = parent:FindFirstChildOfClass("UIScale")

	if uIScale and uIScale:IsA("UIScale") then
		return uIScale
	end

	local uIScale2 = Instance.new("UIScale")
	uIScale2.Parent = parent
	return uIScale2
end

return function(instance, p: number?, p2: number?, value: number?)
	local v2 = p or v.seconds
	local clone = v.template:Clone()
	local v3 = clone:FindFirstChildOfClass("UIScale")

	if not (v3 and v3:IsA("UIScale")) then
		v3 = Instance.new("UIScale")
		v3.Parent = clone
	end

	v3.Scale = 0
	clone.ImageTransparency = p2 or v.startTransparency
	clone.Position = midpoint(instance)
	clone.Size = UDim2.fromOffset(instance.AbsoluteSize.X, instance.AbsoluteSize.Y)
	clone.Parent = OverlayRoot()

	local function recentre()
		clone.Position = midpoint(instance)
	end

	local v4 = {
		instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(recentre),
		instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(recentre)
	}
	clone.Destroying:Once(function()
		for _, connection in v4 do
			connection:Disconnect()
		end
	end)
	local tweenInfo3 = tweenInfo2

	if v2 ~= tweenInfo3.Time then
		tweenInfo3 = TweenInfo.new(v2, tweenInfo3.EasingStyle, tweenInfo3.EasingDirection)
	end

	TweenService:Create(clone, tweenInfo3, {
		ImageTransparency = 1
	}):Play()
	local tweenInfo4 = tweenInfo

	if v2 ~= tweenInfo4.Time then
		tweenInfo4 = TweenInfo.new(v2, tweenInfo4.EasingStyle, tweenInfo4.EasingDirection)
	end

	local v9 = math.max(instance.AbsoluteSize.Magnitude, 1)
	local currentCamera = workspace.CurrentCamera
	local v10

	if currentCamera then
		v10 = currentCamera.ViewportSize.Magnitude
	else
		v10 = v9 * v.fallbackScreenFactor
	end

	local v11 = TweenService:Create(v3, tweenInfo4, {
		Scale = math.clamp(v10 / v9 * v.coverage * (value or 1), v.minPeak, v.maxPeak)
	})
	v11.Completed:Once(function()
		clone:Destroy()
	end)
	v11:Play()
	return clone
end