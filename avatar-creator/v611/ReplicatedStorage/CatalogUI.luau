local createVector = vector.create
local CatalogUI = {}
local AtelierTheme = require(game.ReplicatedStorage.AtelierTheme)
local colors = AtelierTheme.colors

function CatalogUI.make(className, name, parent, options)
	local instance = Instance.new(className)
	instance.Name = name

	for k, v in pairs(options or {}) do
		instance[k] = v
	end

	instance.Parent = parent
	return instance
end

function CatalogUI.round(p, value)
	CatalogUI.make("UICorner", "Corner", p, {
		CornerRadius = UDim.new(0, value or 10)
	})
end

function CatalogUI.label(p, p2, text, position, size, value)
	return CatalogUI.make("TextLabel", p, p2, {
		Text = text,
		Position = position,
		Size = size,
		TextSize = value or 15,
		TextColor3 = colors.text,
		Font = Enum.Font.GothamMedium,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true
	})
end

function CatalogUI.button(p, p2, text, position, size, p6)
	local v = CatalogUI.make("TextButton", p, p2, {
		Text = text,
		Position = position,
		Size = size,
		TextSize = 14,
		TextWrapped = true,
		TextColor3 = colors.text,
		Font = Enum.Font.GothamMedium,
		BackgroundColor3 = p6 and colors.accent or colors.raised,
		BorderSizePixel = 0,
		AutoButtonColor = true
	})
	CatalogUI.round(v, 8)
	return v
end

function CatalogUI.input(p, p2, placeholderText, position, size)
	local v = CatalogUI.make("TextBox", p, p2, {
		Text = "",
		PlaceholderText = placeholderText,
		PlaceholderColor3 = colors.muted,
		Position = position,
		Size = size,
		TextSize = 15,
		TextColor3 = colors.text,
		Font = Enum.Font.Gotham,
		BackgroundColor3 = colors.surface,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	CatalogUI.round(v, 8)
	CatalogUI.make("UIPadding", "Inset", v, {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12)
	})
	return v
end

function CatalogUI.build(p)
	local v = CatalogUI.make("Frame", "Root", p, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Active = true
	})
	local v2 = CatalogUI.make("Frame", "Panel", v, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.95, 0, 0.95, 0),
		BackgroundColor3 = colors.bg,
		BorderSizePixel = 0
	})
	CatalogUI.round(v2, 16)
	CatalogUI.make("UISizeConstraint", "Limit", v2, {
		MaxSize = Vector2.new(1120, 780)
	})
	CatalogUI.make("UIStroke", "Outline", v2, {
		Color = colors.raised,
		Thickness = 1
	})
	local label_2 = CatalogUI.label("Title", v2, "Catalog", UDim2.fromOffset(20, 12), UDim2.new(1, -170, 0, 34), 27)
	label_2.Visible = false
	local label = CatalogUI.label(
		"Subtitle",
		v2,
		"Discover your next look",
		UDim2.fromOffset(20, 45),
		UDim2.new(1, -170, 0, 20),
		13
	)
	label.TextColor3 = colors.muted
	label.Visible = false
	CatalogUI.button("Close", v2, "Close", UDim2.new(1, -88, 0, 19), UDim2.fromOffset(68, 34))
	local input = CatalogUI.input("SearchInput", v2, "Search", UDim2.fromOffset(20, 18), UDim2.new(1, -284, 0, 88))
	input.TextSize = 22
	CatalogUI.button("Search", v2, "Search", UDim2.new(1, -222, 0, 64), UDim2.fromOffset(96, 44), true)
	CatalogUI.button("Filters", v2, "Filters", UDim2.new(1, -118, 0, 64), UDim2.fromOffset(98, 44))
	local v3 = CatalogUI.make("ScrollingFrame", "Tabs", v2, {
		Position = UDim2.fromOffset(20, 120),
		Size = UDim2.new(1, -40, 0, 44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 2
	})
	CatalogUI.make("UIListLayout", "Layout", v3, {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	for i, v4 in ipairs({
		"Featured",
		"All",
		"Accessories",
		"Hair",
		"Clothing",
		"Classic",
		"Bundles",
		"Heads",
		"Shoes",
		"Animations",
		"Emotes"
	}) do
		local button = CatalogUI.button(v4, v3, v4, UDim2.new(), UDim2.fromOffset(#v4 * 8 + 28, 36), v4 == "Featured")
		button.LayoutOrder = i
	end

	local label_3 = CatalogUI.label(
		"Status",
		v2,
		"Featured items from Roblox",
		UDim2.fromOffset(20, 168),
		UDim2.new(1, -40, 0, 32),
		13
	)
	label_3.TextColor3 = colors.muted
	local v4 = CatalogUI.make("ScrollingFrame", "Results", v2, {
		Position = UDim2.fromOffset(20, 204),
		Size = UDim2.new(1, -40, 1, -260),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = colors.accent
	})
	CatalogUI.make("UIGridLayout", "Grid", v4, {
		CellSize = UDim2.fromOffset(150, 215),
		CellPadding = UDim2.fromOffset(12, 12),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	CatalogUI.button("More", v2, "Load more", UDim2.new(0.5, -70, 1, -44), UDim2.fromOffset(140, 32))
	local v5 = CatalogUI.make("Frame", "FilterPanel", v2, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = colors.bg,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 5
	})
	CatalogUI.round(v5, 16)
	CatalogUI.label("Heading", v5, "Filters", UDim2.fromOffset(20, 15), UDim2.new(1, -120, 0, 36), 24)
	CatalogUI.button("Close", v5, "Back", UDim2.new(1, -90, 0, 18), UDim2.fromOffset(70, 34))
	local v6 = CatalogUI.make("ScrollingFrame", "Fields", v5, {
		Position = UDim2.fromOffset(20, 65),
		Size = UDim2.new(1, -40, 1, -135),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 455),
		ScrollBarThickness = 4
	})
	CatalogUI.label("SortLabel", v6, "Sort by", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 24))
	local v7 = CatalogUI.make("Frame", "SortOptions", v6, {
		Position = UDim2.fromOffset(0, 32),
		Size = UDim2.new(1, -4, 0, 84),
		BackgroundTransparency = 1
	})
	CatalogUI.make("UIGridLayout", "Grid", v7, {
		CellSize = UDim2.new(0.3333333333333333, -8, 0, 36),
		CellPadding = UDim2.fromOffset(8, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	for i, v8 in ipairs({
		{ "Relevance", "Relevance" },
		{ "RecentlyCreated", "Newest" },
		{ "Bestselling", "Bestselling" },
		{ "MostFavorited", "Most favorited" },
		{ "PriceLowToHigh", "Price: low to high" },
		{ "PriceHighToLow", "Price: high to low" }
	}) do
		local button_2 = CatalogUI.button(v8[1], v7, v8[2], UDim2.new(), UDim2.new(), i == 1)
		button_2.LayoutOrder = i
	end

	CatalogUI.label(
		"CreatorLabel",
		v6,
		"Creator username or group name",
		UDim2.fromOffset(0, 135),
		UDim2.new(1, 0, 0, 24)
	)
	CatalogUI.button("CreatorType", v6, "User", UDim2.fromOffset(0, 167), UDim2.fromOffset(90, 40))
	CatalogUI.input("Creator", v6, "Exact username", UDim2.fromOffset(100, 167), UDim2.new(1, -104, 0, 40))
	CatalogUI.label("PriceLabel", v6, "Price range (Robux)", UDim2.fromOffset(0, 227), UDim2.new(1, 0, 0, 24))
	CatalogUI.input("MinPrice", v6, "Minimum", UDim2.fromOffset(0, 259), UDim2.new(0.5, -8, 0, 40))
	CatalogUI.input("MaxPrice", v6, "Maximum", UDim2.new(0.5, 4, 0, 259), UDim2.new(0.5, -8, 0, 40))
	CatalogUI.button("OffSale", v6, "Include off-sale: No", UDim2.fromOffset(0, 319), UDim2.new(1, -4, 0, 40))
	local label_4 = CatalogUI.label(
		"Hint",
		v6,
		"Leave creator and prices blank to search everyone at any price.",
		UDim2.fromOffset(0, 374),
		UDim2.new(1, -4, 0, 44),
		13
	)
	label_4.TextColor3 = colors.muted
	CatalogUI.button("Clear", v5, "Clear filters", UDim2.new(0, 20, 1, -55), UDim2.new(0.5, -30, 0, 38))
	CatalogUI.button("Apply", v5, "Apply filters", UDim2.new(0.5, 10, 1, -55), UDim2.new(0.5, -30, 0, 38), true)
	local v8 = CatalogUI.make("Frame", "Details", v2, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = colors.bg,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 7
	})
	CatalogUI.round(v8, 16)
	CatalogUI.label("Heading", v8, "Item details", UDim2.fromOffset(20, 15), UDim2.new(1, -130, 0, 36), 24)
	CatalogUI.button("Back", v8, "Back", UDim2.new(1, -90, 0, 18), UDim2.fromOffset(70, 34))
	local v9 = CatalogUI.make("ScrollingFrame", "Body", v8, {
		Position = UDim2.fromOffset(20, 68),
		Size = UDim2.new(1, -40, 1, -80),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new()
	})
	local v10 = CatalogUI.make("Frame", "Preview", v9, {
		BackgroundColor3 = colors.surface,
		BorderSizePixel = 0,
		Position = UDim2.new(),
		Size = UDim2.new(0.43, 0, 1, -4)
	})
	CatalogUI.round(v10, 12)
	CatalogUI.make("ImageLabel", "Thumbnail", v10, {
		Size = UDim2.new(1, -16, 1, -110),
		Position = UDim2.fromOffset(8, 8),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit
	})
	CatalogUI.make("ViewportFrame", "Avatar", v10, {
		Size = UDim2.new(1, -16, 1, -110),
		Position = UDim2.fromOffset(8, 8),
		BackgroundTransparency = 1,
		Visible = false,
		Ambient = Color3.fromRGB(200, 200, 215),
		LightColor = Color3.new(1, 1, 1),
		LightDirection = createVector(-1, -1, -1)
	})
	CatalogUI.button("ImageMode", v10, "Item", UDim2.new(0, 10, 1, -90), UDim2.new(0.5, -14, 0, 32))
	CatalogUI.button("AvatarMode", v10, "Avatar", UDim2.new(0.5, 4, 1, -90), UDim2.new(0.5, -14, 0, 32))
	CatalogUI.button("RotateLeft", v10, "Turn left", UDim2.new(0, 10, 1, -48), UDim2.new(0.5, -14, 0, 32))
	CatalogUI.button("RotateRight", v10, "Turn right", UDim2.new(0.5, 4, 1, -48), UDim2.new(0.5, -14, 0, 32))
	local v11 = CatalogUI.make("Frame", "Info", v9, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.46, 0, 0, 0),
		Size = UDim2.new(0.54, -4, 0, 570)
	})
	CatalogUI.label("ItemName", v11, "Loading...", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 68), 23)
	local label_5 = CatalogUI.label("Creator", v11, "", UDim2.fromOffset(0, 76), UDim2.new(1, 0, 0, 38), 14)
	label_5.TextColor3 = colors.muted
	CatalogUI.label("Price", v11, "", UDim2.fromOffset(0, 118), UDim2.new(1, 0, 0, 32), 22)
	local v12 = CatalogUI.make("ScrollingFrame", "DescriptionScroll", v11, {
		Position = UDim2.fromOffset(0, 162),
		Size = UDim2.new(1, 0, 0, 175),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3
	})
	local label2 = CatalogUI.label("Description", v12, "", UDim2.new(), UDim2.new(1, -10, 0, 0), 14)
	label2.AutomaticSize = Enum.AutomaticSize.Y
	label2.TextYAlignment = Enum.TextYAlignment.Top
	label2.Font = Enum.Font.Gotham
	label2.TextColor3 = colors.muted
	CatalogUI.button("TryOn", v11, "Try on", UDim2.fromOffset(0, 350), UDim2.new(0.5, -5, 0, 44))
	CatalogUI.button("Buy", v11, "Buy", UDim2.new(0.5, 5, 0, 350), UDim2.new(0.5, -5, 0, 44), true)
	CatalogUI.button("Reset", v11, "Reset try-on", UDim2.fromOffset(0, 405), UDim2.new(1, 0, 0, 36))
	local label3 = CatalogUI.label(
		"Message",
		v11,
		"Try-on changes your character in this game only.",
		UDim2.fromOffset(0, 451),
		UDim2.new(1, 0, 0, 80),
		13
	)
	label3.TextColor3 = colors.muted
	label3.TextYAlignment = Enum.TextYAlignment.Top
	return v
end

CatalogUI.colors = colors
return CatalogUI