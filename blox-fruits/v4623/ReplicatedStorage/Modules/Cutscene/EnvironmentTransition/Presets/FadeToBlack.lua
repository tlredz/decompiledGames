local v = {
	Players = game:GetService("Players"),
	TweenService = game:GetService("TweenService")
}
local parentModule = require(script.Parent.Parent)
require(script.Parent.Parent.Parent.Types)

local function getDuration(p, p2: string, p3: number)
	local v2 = p[p2]

	if v2 == nil then
		return p3
	end

	local v3

	if typeof(v2) == "number" then
		v3 = v2 >= 0
	else
		v3 = false
	end

	assert(v3, (`{p2} must be a non-negative number`))
	return v2
end

local function createOverlay(data)
	local v2 = assert(v.Players.LocalPlayer, "FadeToBlack requires a LocalPlayer")
	local playerGui = v2:FindFirstChildOfClass("PlayerGui") or v2:WaitForChild("PlayerGui", 5)
	assert(playerGui and playerGui:IsA("PlayerGui"), "FadeToBlack requires PlayerGui")
	local cutsceneEnvironmentTransition = playerGui:FindFirstChild("CutsceneEnvironmentTransition")

	if cutsceneEnvironmentTransition then
		cutsceneEnvironmentTransition:Destroy()
	end

	local displayOrder = data.DisplayOrder or 1000
	local v3

	if typeof(displayOrder) == "number" then
		v3 = displayOrder % 1 == 0
	else
		v3 = false
	end

	assert(v3, "DisplayOrder must be an integer")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CutsceneEnvironmentTransition"
	screenGui.DisplayOrder = displayOrder
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.Parent = playerGui
	local color = data.Color or Color3.new(0, 0, 0)
	assert(typeof(color) == "Color3", "Color must be a Color3")
	local frame = Instance.new("Frame")
	frame.Name = "Cover"
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Position = UDim2.fromScale(0, 0)
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = screenGui
	return screenGui, frame
end

local function fade(maid, p, duration: number, backgroundTransparency: number, easingStyle, easingDirection)
	if duration == 0 then
		p.BackgroundTransparency = backgroundTransparency
		return true
	end

	local v2 = v.TweenService:Create(p, TweenInfo.new(duration, easingStyle, easingDirection), {
		BackgroundTransparency = backgroundTransparency
	})
	maid:GiveTask(v2)
	v2:Play()
	local v3 = maid:Wait(duration)

	if v3 and p.Parent then
		p.BackgroundTransparency = backgroundTransparency
	end

	return v3
end

return parentModule.new():Run(function(maid, data)
	local fadeOutDuration = data.FadeOutDuration

	if fadeOutDuration == nil then
		fadeOutDuration = 0.35
	else
		local v2

		if typeof(fadeOutDuration) == "number" then
			v2 = fadeOutDuration >= 0
		else
			v2 = false
		end

		assert(v2, "FadeOutDuration must be a non-negative number")
	end

	local fadeInDuration = data.FadeInDuration

	if fadeInDuration == nil then
		fadeInDuration = 0.35
	else
		local v2

		if typeof(fadeInDuration) == "number" then
			v2 = fadeInDuration >= 0
		else
			v2 = false
		end

		assert(v2, "FadeInDuration must be a non-negative number")
	end

	local holdDuration = data.HoldDuration

	if holdDuration == nil then
		holdDuration = 0
	else
		local v2

		if typeof(holdDuration) == "number" then
			v2 = holdDuration >= 0
		else
			v2 = false
		end

		assert(v2, "HoldDuration must be a non-negative number")
	end

	local easingStyle = data.EasingStyle or Enum.EasingStyle.Linear
	local easingDirection = data.EasingDirection or Enum.EasingDirection.Out
	local v2

	if typeof(easingStyle) == "EnumItem" then
		v2 = easingStyle.EnumType == Enum.EasingStyle
	else
		v2 = false
	end

	assert(v2, "EasingStyle must be an EasingStyle")
	local v3

	if typeof(easingDirection) == "EnumItem" then
		v3 = easingDirection.EnumType == Enum.EasingDirection
	else
		v3 = false
	end

	assert(v3, "EasingDirection must be an EasingDirection")
	local overlay, v4 = createOverlay(data)
	maid:GiveTask(overlay)

	if not fade(maid, v4, fadeOutDuration, 0, easingStyle, easingDirection) then
		return
	end

	local v5 = maid:SwapEnvironment()
	local atBlack = data.AtBlack
	assert(atBlack == nil or typeof(atBlack) == "function", "AtBlack must be a function")

	if atBlack then
		atBlack(v5)
	end

	if not maid:Wait(holdDuration) then
		return
	end

	fade(maid, v4, fadeInDuration, 1, easingStyle, easingDirection)
end)