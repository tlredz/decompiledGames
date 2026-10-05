local Shiny = {}
Shiny.__index = Shiny
local TweenService = game:GetService("TweenService")

local function createShimmer(guiObject)
	local frame = Instance.new("Frame")
	frame.Name = "Shiny"
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0
	frame.ClipsDescendants = true
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.BorderSizePixel = 0
	frame.ZIndex = 10
	frame.Visible = false
	frame.Parent = guiObject

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCornerRadius()
		if frame.Parent:FindFirstChildOfClass("UICorner") then
			local uICorner = frame.Parent:FindFirstChildOfClass("UICorner")
			local uICorner2 = Instance.new("UICorner")
			uICorner2.CornerRadius = uICorner.CornerRadius
			uICorner2.Parent = frame
		end
	end

	updateCornerRadius() -- equivalent call inferred; original call site unknown
	local updatePaddingOffset

	updatePaddingOffset = function()
		if frame.Parent:FindFirstChildOfClass("UIPadding") then
			local uIPadding = frame.Parent:FindFirstChildOfClass("UIPadding")
			local v = uIPadding.PaddingLeft.Scale + uIPadding.PaddingRight.Scale
			local v2 = uIPadding.PaddingTop.Scale + uIPadding.PaddingBottom.Scale
			local v3 = uIPadding.PaddingLeft.Offset + uIPadding.PaddingRight.Offset
			local v4 = uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset
			local v5 = uIPadding.PaddingTop.Offset - uIPadding.PaddingBottom.Offset
			local v6 = uIPadding.PaddingLeft.Offset - uIPadding.PaddingRight.Offset
			local v7 = 1 / (1 - v)
			local v8 = 1 / (1 - v2)
			frame.Size = UDim2.new(v7, v3, v8, v4)
			frame.Position = UDim2.new(0.5, -v6 / 2, 0.5, -v5 / 2)
			uIPadding:GetPropertyChangedSignal("PaddingLeft"):Connect(updatePaddingOffset)
			uIPadding:GetPropertyChangedSignal("PaddingRight"):Connect(updatePaddingOffset)
			uIPadding:GetPropertyChangedSignal("PaddingTop"):Connect(updatePaddingOffset)
			uIPadding:GetPropertyChangedSignal("PaddingBottom"):Connect(updatePaddingOffset)
		end
	end

	updatePaddingOffset()
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 45
	uIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 1),
		NumberSequenceKeypoint.new(0.5, 0.55),
		NumberSequenceKeypoint.new(0.85, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Offset = Vector2.new(-1, 0)
	uIGradient.Parent = frame
	return frame
end

Shiny.PlaybackState = nil

function Shiny.new(guiObject, value: number?, p, p2, value2: number?, flag: boolean?, value3: number?)
	local v

	if typeof(guiObject) == "Instance" then
		v = guiObject:IsA("GuiObject")
	else
		v = false
	end

	assert(v, "Invalid parent argument. Expected GuiObject.")
	local v2 = value or 1
	assert(typeof(v2) == "number", "Invalid time argument. Expected number.")
	local v3 = p or Enum.EasingStyle.Linear
	local v4

	if typeof(v3) == "EnumItem" then
		v4 = v3.EnumType == Enum.EasingStyle
	else
		v4 = false
	end

	assert(v4, "Invalid style argument. Expected EasingStyle enum.")
	local v5 = p2 or Enum.EasingDirection.InOut
	local v6

	if typeof(v5) == "EnumItem" then
		v6 = v5.EnumType == Enum.EasingDirection
	else
		v6 = false
	end

	assert(v6, "Invalid direction argument. Expected EasingDirection enum.")
	local v7 = value2 or -1
	assert(typeof(v7) == "number", "Invalid repeatCount argument. Expected number.")
	local v8 = flag or false
	assert(typeof(v8) == "boolean", "Invalid reverses argument. Expected boolean.")
	local v9 = value3 or 0
	assert(typeof(v9) == "number", "Invalid delayTime argument. Expected number.")
	local object = setmetatable({}, Shiny)
	local v10 = v3 or Enum.EasingStyle.Linear
	local v11 = v5 or Enum.EasingDirection.InOut
	local shimmer = createShimmer(guiObject)
	object._frame = shimmer
	object._gradient = shimmer:FindFirstChildOfClass("UIGradient")
	object._corner = shimmer:FindFirstChildOfClass("UICorner")
	object._tween = TweenService:Create(
		object._gradient,
		TweenInfo.new(v2 or 1, v10, v11, v7 or -1, v8 or false, v9 or 0),
		{
			Offset = Vector2.new(1, 0)
		}
	)
	object._tween.Completed:Connect(function()
		object:_TweenCompleted()
	end)
	return object
end

function Shiny:_TweenCompleted()
	self._frame.Visible = false
	self.PlaybackState = Enum.PlaybackState.Completed
end

function Shiny:GetFrame()
	return self._frame
end

function Shiny:GetGradient()
	return self._gradient
end

function Shiny:GetCorner()
	return self._corner
end

function Shiny:Play()
	self.PlaybackState = Enum.PlaybackState.Begin
	self._frame.Visible = true
	self._tween:Play()
	self.PlaybackState = Enum.PlaybackState.Playing
end

function Shiny:Pause()
	if self.PlaybackState == Enum.PlaybackState.Playing then
		self._tween:Pause()
		self.PlaybackState = Enum.PlaybackState.Paused
	end
end

function Shiny:Cancel()
	self._tween:Cancel()

	if self._frame then
		self._frame:Destroy()
	end

	self.PlaybackState = Enum.PlaybackState.Cancelled
end

return Shiny