local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 214, 120), Color3.fromRGB(255, 138, 61))
local colorSequence2 = ColorSequence.new(Color3.fromRGB(214, 0, 0), Color3.fromRGB(109, 0, 0))
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)

local function defaulted(p, p2)
	if p == nil then
		return p2
	end

	return p
end

local function closeButton(instance)
	local v = create("Frame")
	local v2 = {
		Name = "CloseButtonFrame",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Position = UDim2.fromScale(0.9, 0.02),
		Size = UDim2.fromScale(0.1, 0.12)
	}
	local showClose = instance.ShowClose
	v2.Visible = showClose == nil or showClose
	do local _values = table.pack(create("UIGradient")({
	Color = colorSequence2,
	Rotation = 90
}), create("UIStroke")({
	Color = Color3.fromRGB(84, 0, 0),
	Thickness = 0.05,
	StrokeSizingMode = 1
}), create("UICorner")({
	CornerRadius = UDim.new(0.2, 0)
}), create("UIAspectRatioConstraint")({
	AspectRatio = 1
}), create("TextButton")({
	Name = "CloseButton",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	FontFace = rbxassetfontsfamiliesGothamSSmjson,
	Text = "X",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextScaled = true,
	MouseButton1Click = instance.OnClose,
	create("UIStroke")({
		Color = Color3.fromRGB(84, 0, 0),
		Thickness = 0.03,
		StrokeSizingMode = 1
	}),
	create("UICorner")({
		CornerRadius = UDim.new(0.2, 0)
	})
})); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end

local function ModalShell(instance, p)
	local source = Vide.source(Vector2.new(972, 648))

	local function studTileSize()
		local v = math.max(source().Y / 6, 1)
		return UDim2.fromOffset(v, v)
	end

	local v = create("ImageLabel")
	local v2 = {
		Name = instance.Name or "ModalShell"
	}
	local backgroundImage = instance.BackgroundImage
	v2.Image = backgroundImage == nil and "rbxassetid://16280131699" or backgroundImage
	local backgroundImageTransparency = instance.BackgroundImageTransparency
	v2.ImageTransparency = backgroundImageTransparency == nil and 0.7 or backgroundImageTransparency
	v2.ScaleType = Enum.ScaleType.Tile
	local tileSize = instance.TileSize

	if tileSize == nil then
		tileSize = studTileSize
	end

	v2.TileSize = tileSize
	v2[1] = (Vide.changed("AbsoluteSize", source))
	v2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	v2.AnchorPoint = Vector2.new(0.5, 0.5)
	local position = instance.Position
	local uDim = UDim2.fromScale(0.5, 0.45)

	if position == nil then
		position = uDim
	end

	v2.Position = position
	local size = instance.Size
	local uDim2 = UDim2.fromScale(0.75, 0.6)

	if size == nil then
		size = uDim2
	end

	v2.Size = size
	local visible = instance.Visible
	v2.Visible = visible == nil or visible
	v2.ZIndex = instance.ZIndex or 1
	v2.Parent = instance.Parent
	local v3 = create("UIAspectRatioConstraint")
	local aspectRatio = instance.AspectRatio
	local v5 = v3({
		AspectRatio = aspectRatio == nil and 1.5 or aspectRatio
	})
	local v6 = create("UICorner")
	local cornerRadius = instance.CornerRadius
	local uDim3 = UDim.new(0.05, 0)

	if cornerRadius ~= nil then
		uDim3 = cornerRadius
	end

	local v8 = v6({
		CornerRadius = uDim3
	})
	local v9 = create("UIGradient")
	local gradientColor = instance.GradientColor
	local v11 = colorSequence

	if gradientColor == nil then
		gradientColor = v11
	end

	local gradientRotation = instance.GradientRotation
	local v12 = v9({
		Color = gradientColor,
		Rotation = gradientRotation == nil and 90 or gradientRotation
	})
	local v13 = create("UIStroke")
	local strokeColor = instance.StrokeColor
	local color = Color3.fromRGB(74, 46, 0)

	if strokeColor ~= nil then
		color = strokeColor
	end

	local strokeThickness = instance.StrokeThickness
	local v15 = v13({
		Color = color,
		Thickness = strokeThickness == nil and 0.02 or strokeThickness,
		StrokeSizingMode = 1
	})
	local v16 = create("TextLabel")
	local v17 = {
		Name = "Title",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 5),
		Size = UDim2.fromScale(0.5, 0.13),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		LineHeight = 1
	}
	local title = instance.Title
	v17.Text = title == nil and "" or title
	local titleColor = instance.TitleColor
	local color2 = Color3.fromRGB(255, 255, 255)

	if titleColor ~= nil then
		color2 = titleColor
	end

	v17.TextColor3 = color2
	v17.TextScaled = true
	local v18 = create("UIStroke")
	local titleStrokeColor = instance.TitleStrokeColor
	local color3 = Color3.fromRGB(74, 46, 0)

	if titleStrokeColor == nil then
		titleStrokeColor = color3
	end

	do local _values = table.pack(v18({
	Color = titleStrokeColor,
	Thickness = 0.1,
	StrokeSizingMode = 1
})); for _k = 1, _values.n do v17[_k] = _values[_k] end end
	do local _values = table.pack(v5, v8, v12, v15, v16(v17), closeButton(instance), create("Frame")({
	Name = "Content",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.5, 0.17),
	Size = UDim2.fromScale(0.9, 0.79),
	BackgroundTransparency = 1,
	p
})); for _k = 1, _values.n do v2[1 + _k] = _values[_k] end end
	return v(v2)
end

return ModalShell