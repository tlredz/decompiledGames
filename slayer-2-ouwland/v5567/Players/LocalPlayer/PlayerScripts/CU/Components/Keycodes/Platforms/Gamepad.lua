local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local sourceSansBold = Enum.Font.SourceSansBold
local uDim = UDim.new(0.75)

local function isPadButton(p)
	if typeof(p) ~= "EnumItem" or p.EnumType ~= Enum.KeyCode then
		return false
	end

	local name = p.Name
	return name:match("^Button") ~= nil or name:match("^DPad") ~= nil or name:match("^Thumbstick") ~= nil
end

local function resolve(name: string)
	local mapping = InputHandler.GetMapping(name)

	if mapping == nil then
		return nil, nil
	end

	local input = nil
	local modifier = nil

	for _, v in mapping do
		if typeof(v) == "table" then
			if v.Alone == true and isPadButton(v.Input) then
				return v.Input, nil
			end

			if input == nil and isPadButton(v.Input) and isPadButton(v.Modifier) then
				input = v.Input
				modifier = v.Modifier
			end
		elseif isPadButton(v) then
			return v, nil
		end
	end

	return input, modifier
end

local function glyph(image: string, parent)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = image
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Parent = imageLabel
	local uIShadow = Instance.new("UIShadow")
	uIShadow.BlurRadius = uDim
	uIShadow.Transparency = 0.65
	uIShadow.Parent = imageLabel
	imageLabel.Parent = parent
	return imageLabel
end

return function(parent)
	local v, v2 = resolve(parent.Name)

	if v == nil then
		return nil
	end

	local imageForKeyCode = UserInputService:GetImageForKeyCode(v)

	if imageForKeyCode == nil or #imageForKeyCode == 0 then
		return nil
	end

	if v2 == nil then
		return (glyph(imageForKeyCode, parent))
	end

	local imageForKeyCode2 = UserInputService:GetImageForKeyCode(v2)

	if imageForKeyCode2 == nil or #imageForKeyCode2 == 0 then
		return nil
	end

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.new(2.45, 4, 1, 0)
	frame.BackgroundTransparency = 1
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0, 2)
	uIListLayout.Parent = frame

	for k, v3 in { imageForKeyCode2, imageForKeyCode } do
		local frame2 = Instance.new("Frame")
		frame2.LayoutOrder = k * 2
		frame2.Size = UDim2.fromScale(1, 1)
		frame2.SizeConstraint = Enum.SizeConstraint.RelativeYY
		frame2.BackgroundTransparency = 1
		glyph(v3, frame2)
		frame2.Parent = frame
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.LayoutOrder = 3
	textLabel.Size = UDim2.fromScale(0.45, 1)
	textLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "+"
	textLabel.TextScaled = true
	textLabel.Font = sourceSansBold
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Parent = frame
	frame.Parent = parent
	return frame
end