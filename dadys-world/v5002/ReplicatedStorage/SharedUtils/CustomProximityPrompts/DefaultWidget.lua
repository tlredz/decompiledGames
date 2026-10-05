local TextService = game:GetService("TextService")
local DefaultWidget = {}
local gothamBold = Enum.Font.GothamBold
local vector = Vector2.new(1000, 1000)
local color = Color3.fromRGB(0, 0, 0)
local color2 = Color3.fromRGB(20, 20, 20)
local color3 = Color3.fromRGB(255, 255, 255)
local color4 = Color3.fromRGB(255, 255, 255)
local color5 = Color3.fromRGB(220, 220, 220)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.4999, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 0)
})
local numberSequence2 = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.4999, 0),
	NumberSequenceKeypoint.new(0.5, 1),
	NumberSequenceKeypoint.new(1, 1)
})

function DefaultWidget.measure(p)
	local v = 0

	if p.ActionText ~= "" then
		v = math.max(v, TextService:GetTextSize(p.ActionText, 19, gothamBold, vector).X)
	end

	if p.ObjectText ~= "" then
		v = math.max(v, TextService:GetTextSize(p.ObjectText, 14, gothamBold, vector).X)
	end

	local v2 = 56

	if v > 0 then
		v2 = v2 + v + 8
	end

	return v2, 56
end

local function buildHalf(frame, p)
	local frame2 = Instance.new("Frame")
	frame2.Name = p and "RightHalf" or "LeftHalf"
	frame2.Size = UDim2.fromScale(0.5, 1)
	frame2.Position = p and UDim2.fromScale(0.5, 0) or UDim2.fromScale(0, 0)
	frame2.BackgroundTransparency = 1
	frame2.ClipsDescendants = true
	frame2.ZIndex = 1
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "Fill"
	frame3.Size = UDim2.fromScale(2, 1)
	frame3.Position = p and UDim2.fromScale(-1, 0) or UDim2.fromScale(0, 0)
	frame3.BackgroundColor3 = color3
	frame3.BorderSizePixel = 0
	frame3.ZIndex = 1
	frame3.Parent = frame2
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame3
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = p and numberSequence or numberSequence2
	uIGradient.Rotation = 0
	uIGradient.Parent = frame3
	return uIGradient
end

function DefaultWidget.build(data)
	local measured, v = DefaultWidget.measure(data)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "CustomProximityPrompt"
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.ResetOnSpawn = false
	billboardGui.Size = UDim2.fromOffset(measured + math.abs(data.UIOffset.X) * 2, v + math.abs(data.UIOffset.Y) * 2)
	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, data.UIOffset.X, 0.5, data.UIOffset.Y)
	frame.Size = UDim2.fromOffset(measured, v)
	frame.BackgroundTransparency = 1
	frame.Parent = billboardGui
	local frame2 = Instance.new("Frame")
	frame2.Name = "Background"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = color
	frame2.BackgroundTransparency = 0.5
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 0
	frame2.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 8)
	uICorner.Parent = frame2
	local frame3 = Instance.new("Frame")
	frame3.Name = "InputFrame"
	frame3.AnchorPoint = Vector2.new(0, 0.5)
	frame3.Position = UDim2.new(0, 8, 0.5, 0)
	frame3.Size = UDim2.fromOffset(40, 40)
	frame3.BackgroundTransparency = 1
	frame3.ZIndex = 1
	frame3.Parent = frame
	local frame4 = Instance.new("Frame")
	frame4.Name = "HoldRing"
	frame4.Size = UDim2.fromScale(1, 1)
	frame4.BackgroundTransparency = 1
	frame4.ZIndex = 1
	frame4.Parent = frame3
	local half = buildHalf(frame4, true)
	local half2 = buildHalf(frame4, false)
	local frame5 = Instance.new("Frame")
	frame5.Name = "KeyBackground"
	frame5.AnchorPoint = Vector2.new(0.5, 0.5)
	frame5.Position = UDim2.fromScale(0.5, 0.5)
	frame5.Size = UDim2.fromScale(0.84, 0.84)
	frame5.BackgroundColor3 = color2
	frame5.BorderSizePixel = 0
	frame5.ZIndex = 2
	frame5.Parent = frame3
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(1, 0)
	uICorner2.Parent = frame5
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ButtonImage"
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(0.8, 0.8)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Visible = false
	imageLabel.ZIndex = 3
	imageLabel.Parent = frame5
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "ButtonText"
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Size = UDim2.fromScale(0.9, 0.9)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = gothamBold
	textLabel.TextColor3 = color4
	textLabel.TextScaled = true
	textLabel.Text = ""
	textLabel.Visible = false
	textLabel.ZIndex = 3
	textLabel.Parent = frame5
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "ObjectText"
	textLabel2.AnchorPoint = Vector2.new(0, 1)
	textLabel2.Position = UDim2.new(0, 56, 0.5, 0)
	textLabel2.Size = UDim2.new(1, -64, 0, 16)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = gothamBold
	textLabel2.TextSize = 14
	textLabel2.TextColor3 = color5
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Text = data.ObjectText
	textLabel2.ZIndex = 1
	textLabel2.Parent = frame
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "ActionText"
	textLabel3.AnchorPoint = Vector2.new(0, 0)
	textLabel3.Position = UDim2.new(0, 56, 0.5, 0)
	textLabel3.Size = UDim2.new(1, -64, 0, 21)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Font = gothamBold
	textLabel3.TextSize = 19
	textLabel3.TextColor3 = color4
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.Text = data.ActionText
	textLabel3.ZIndex = 1
	textLabel3.Parent = frame

	if data.ObjectText == "" then
		textLabel3.AnchorPoint = Vector2.new(0, 0.5)
		textLabel3.Position = UDim2.new(0, 56, 0.5, 0)
	elseif data.ActionText == "" then
		textLabel2.AnchorPoint = Vector2.new(0, 0.5)
		textLabel2.Position = UDim2.new(0, 56, 0.5, 0)
	end

	return billboardGui, {
		container = frame,
		background = frame2,
		inputFrame = frame3,
		keyBackground = frame5,
		buttonImage = imageLabel,
		buttonText = textLabel,
		actionText = textLabel3,
		objectText = textLabel2,
		holdRing = frame4,
		holdFill = nil,
		_rightGradient = half,
		_leftGradient = half2
	}
end

function DefaultWidget:setProgress(value)
	local v = math.clamp(value, 0, 1)

	if self._rightGradient and self._leftGradient then
		self._rightGradient.Rotation = math.min(v, 0.5) * 2 * 180
		self._leftGradient.Rotation = math.max(v - 0.5, 0) * 2 * 180
	end

	local holdFill = self.holdFill

	if holdFill then
		local size = holdFill.Size
		holdFill.Size = UDim2.new(v, size.X.Offset, size.Y.Scale, size.Y.Offset)
	end
end

function DefaultWidget:resize(p2, p3)
	local measured, v = DefaultWidget.measure(p3)
	self.Size = UDim2.fromOffset(measured + math.abs(p3.UIOffset.X) * 2, v + math.abs(p3.UIOffset.Y) * 2)

	if p2.container then
		p2.container.Size = UDim2.fromOffset(measured, v)
	end
end

return DefaultWidget