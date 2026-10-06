local UserInputService = game:GetService("UserInputService")
local MobileCatalogLayout = {}
local v = {}
local v2 = "Browse"
local v3 = nil
local buttons = {}
local v4 = false
local v5 = nil
local v6 = nil

local function set(p, p2, p3)
	if not p or p[p2] == p3 then
		return
	end

	v[p] = v[p] or {}

	if v[p][p2] == nil then
		v[p][p2] = { p[p2] }
	end

	p[p2] = p3
end

local function box(p, p2, p3, p4, p5)
	if not p then
		return
	end

	set(p, "AnchorPoint", Vector2.zero)
	set(p, "Position", UDim2.fromOffset(p2, p3))
	set(p, "Size", UDim2.fromOffset(p4, p5))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function font(p, p2)
	if p then
		set(p, "TextSize", p2)
		set(p, "TextScaled", false)
	end
end

local function unscale(instance)
	for _, child in instance:GetChildren() do
		if child:IsA("UIScale") then
			set(child, "Scale", 1)
		elseif child:IsA("UISizeConstraint") then
			set(child, "MinSize", Vector2.zero)
			set(child, "MaxSize", Vector2.new(4096, 4096))
		end
	end
end

local function restore()
	for k, v7 in v do
		if not k.Parent then
			continue
		end

		for k2, v8 in v7 do
			k[k2] = v8[1]
		end
	end

	v = {}

	if v3 then
		v3.Visible = false
	end

	if v6 then
		v6.Visible = false
	end
end

local function layoutOverlays(panel, p, p2, p3)
	for _, v7 in { panel.FilterPanel, panel.Details, panel:FindFirstChild("BodyEditorPanel") } do
		if v7 then
			box(v7, 0, 0, p, p2)
		end
	end

	local filterPanel = panel.FilterPanel
	box(filterPanel.Heading, 12, 6, p - 108, 44)
	font(filterPanel.Heading, 22) -- equivalent call inferred; original call site unknown
	box(filterPanel.Close, p - 88, 6, 76, 44)
	box(filterPanel.Fields, 12, 58, p - 24, math.max(40, p2 - 122))
	box(filterPanel.Clear, 12, p2 - 56, (p - 32) / 2, 44)
	box(filterPanel.Apply, p / 2 + 4, p2 - 56, (p - 32) / 2, 44)
	local fields = filterPanel.Fields
	local v7 = p - 24
	box(fields.SortOptions, 0, 30, v7 - 4, 148)
	local uIGridLayout = fields.SortOptions:FindFirstChildOfClass("UIGridLayout")

	if uIGridLayout then
		set(uIGridLayout, "CellSize", UDim2.new(0.5, -6, 0, 44))
		set(uIGridLayout, "CellPadding", UDim2.fromOffset(8, 6))
	end

	box(fields.CreatorLabel, 0, 188, v7, 24)
	box(fields.CreatorType, 0, 218, 80, 44)
	box(fields.Creator, 88, 218, v7 - 92, 44)
	box(fields.PriceLabel, 0, 272, v7, 24)
	box(fields.MinPrice, 0, 302, (v7 - 8) / 2, 44)
	box(fields.MaxPrice, (v7 + 8) / 2, 302, (v7 - 8) / 2, 44)
	box(fields.OffSale, 0, 356, v7 - 4, 44)
	box(fields.BudgetLabel, 0, 412, v7 - 4, 26)

	for k, childName in {
		"BudgetFree",
		"Budget50",
		"Budget100",
		"Budget250"
	} do
		box(fields:FindFirstChild(childName), (k - 1) * v7 / 4, 444, v7 / 4 - 6, 44)
	end

	box(fields.Hint, 0, 498, v7 - 4, 64)
	set(fields, "CanvasSize", UDim2.fromOffset(0, 574))
	local details = panel.Details
	box(details.Heading, 12, 6, p - 108, 44)
	font(details.Heading, 22) -- equivalent call inferred; original call site unknown
	box(details.Back, p - 88, 6, 76, 44)
	box(details.Body, 12, 58, p - 24, p2 - 66)
	local preview = details.Body.Preview
	local info = details.Body.Info
	local v8 = p - 24
	local v9 = p3 and v8 >= 320
	local v10 = v9 and math.floor(v8 * 0.4) or v8 - 6
	local v11 = v9 and math.clamp(p2 - 74, 184, 280) or 280
	local v12 = v11 - 112
	box(preview, 0, 0, v10, v11)
	box(info, not v9 and 0 or v10 + 16 or 0, v9 and 0 or 296, v9 and v8 - v10 - 22 or v8 - 6, v9 and 666 or 860)
	set(details.Body, "CanvasSize", UDim2.fromOffset(0, v9 and 674 or 1168))
	box(preview.Thumbnail, 8, 8, v10 - 16, v12)
	box(preview.Avatar, 8, 8, v10 - 16, v12)
	box(preview.ImageMode, 8, v12 + 16, (v10 - 22) / 2, 44)
	box(preview.AvatarMode, v10 / 2 + 3, v12 + 16, (v10 - 22) / 2, 44)
	box(preview.RotateLeft, 8, v12 + 64, (v10 - 22) / 2, 44)
	box(preview.RotateRight, v10 / 2 + 3, v12 + 64, (v10 - 22) / 2, 44)
	box(preview:FindFirstChild("FavoriteStar"), v10 - 52, 12, 44, 44)

	if not v9 then
		set(info.Reset, "Size", UDim2.new(1, 0, 0, 44))
	end

	if v9 then
		local v13 = v8 - v10 - 22
		box(info.ItemName, 0, 0, v13, 42)
		font(info.ItemName, 16) -- equivalent call inferred; original call site unknown
		box(info.Creator, 0, 46, v13, 30)
		font(info.Creator, 12) -- equivalent call inferred; original call site unknown
		box(info.Price, 0, 78, v13, 24)
		font(info.Price, 16) -- equivalent call inferred; original call site unknown
		box(info.TryOn, 0, 110, (v13 - 8) / 2, 40)
		font(info.TryOn, 13) -- equivalent call inferred; original call site unknown
		box(info.Buy, (v13 + 8) / 2, 110, (v13 - 8) / 2, 40)
		font(info.Buy, 12) -- equivalent call inferred; original call site unknown
		box(info.Reset, 0, 156, v13, 40)
		font(info.Reset, 13) -- equivalent call inferred; original call site unknown
		box(info.Message, 0, 202, v13, 56)
		font(info.Message, 12) -- equivalent call inferred; original call site unknown
		box(info.DescriptionScroll, 0, 266, v13, 132)
		box(info.RelatedHeading, 0, 408, v13, 28)
		font(info.RelatedHeading, 14) -- equivalent call inferred; original call site unknown
		box(info.Related, 0, 444, v13, 210)
	end
end

local function landscapeLayout(instance, catalogGui)
	local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
	local root = catalogGui.Root
	local panel = root.Panel
	local livePreview = root.LivePreview
	local anniversaryPanel = root.AnniversaryPanel
	local absoluteSize = root.AbsoluteSize
	local v7 = absoluteSize.Y - 12
	local v8 = math.floor((absoluteSize.X - 12 - 8) * 0.27)
	local v9 = v8 + 6 + 8
	local v10 = absoluteSize.X - v9 - 6

	if v2 == "Avatar" then
		v2 = "Browse"
	end

	v3.Visible = false

	for _, v11 in { panel, livePreview, anniversaryPanel } do
		unscale(v11)
	end

	box(livePreview, 6, 6, v8, v7)
	box(panel, v9, 6, v10, v7)
	box(anniversaryPanel, v9, 6, v10, v7)
	set(livePreview, "Visible", true)
	set(panel, "Visible", v2 ~= "Specials")
	set(anniversaryPanel, "Visible", v2 == "Specials")
	local closeCatalog = catalogGui:FindFirstChild("CloseCatalog")
	box(closeCatalog, absoluteSize.X - 6 - 48, 14, 40, 44)
	font(closeCatalog, 28) -- equivalent call inferred; original call site unknown
	set(closeCatalog, "Text", "×")
	local bodyEditorPanel = panel:FindFirstChild("BodyEditorPanel")
	local v13

	if v2 == "Specials" then
		v13 = true
	else
		local visible = panel.FilterPanel.Visible or panel.Details.Visible or bodyEditorPanel and bodyEditorPanel.Visible
		v13 = not visible
	end

	set(closeCatalog, "Visible", v13)

	for _, childName in {
		"Title",
		"Hint",
		"OutfitCost",
		"EquippedHeading"
	} do
		set(livePreview:FindFirstChild(childName), "Visible", false)
	end

	local v14 = math.clamp(math.floor(v7 * 0.22), 44, 76)
	local v15 = v7 - v14 - 48
	box(livePreview.Avatar, 6, 6, v8 - 12, math.max(60, v15 - 12))
	local v16 = (v8 - 24) / 3
	box(livePreview.Tools, 6, v15, v16, 36)
	font(livePreview.Tools, 11) -- equivalent call inferred; original call site unknown
	set(livePreview.Tools, "Text", "Edit")
	box(livePreview.SaveOutfit, v16 + 12, v15, v16, 36)
	font(livePreview.SaveOutfit, 11) -- equivalent call inferred; original call site unknown
	set(livePreview.SaveOutfit, "Text", "Save")

	if not v6 then
		v6 = CatalogUI.button("MobileSpecials", livePreview, "Specials", UDim2.new(), UDim2.new())
		v6.ZIndex = livePreview.Tools.ZIndex
		v6:SetAttribute("IconNavigation", true)
		v6.Activated:Connect(function()
			v2 = v2 == "Specials" and "Browse" or "Specials"
			MobileCatalogLayout.Apply(instance)
		end)
	end

	v6.Visible = true
	v6.Text = v2 == "Specials" and "Browse" or "Specials"
	box(v6, v16 * 2 + 18, v15, v16, 36)
	font(v6, 11) -- equivalent call inferred; original call site unknown
	local equippedItems = livePreview.EquippedItems
	box(equippedItems, 6, v7 - v14 - 6, v8 - 12, v14)
	local uIGridLayout = equippedItems:FindFirstChildOfClass("UIGridLayout")
	local v18 = v14 - 4

	if uIGridLayout then
		set(uIGridLayout, "CellSize", UDim2.fromOffset(v18, v18))
		set(uIGridLayout, "CellPadding", UDim2.fromOffset(5, 0))
		set(uIGridLayout, "FillDirection", Enum.FillDirection.Vertical)
		set(uIGridLayout, "FillDirectionMaxCells", 1)
	end

	set(equippedItems, "ScrollingDirection", Enum.ScrollingDirection.X)
	set(equippedItems, "AutomaticCanvasSize", Enum.AutomaticSize.X)
	set(equippedItems, "CanvasSize", UDim2.new())

	for _, child in equippedItems:GetChildren() do
		local actions = child:FindFirstChild("Actions")

		if not actions then
			continue
		end

		font(actions:FindFirstChild("Buy"), 10) -- equivalent call inferred; original call site unknown
		font(actions:FindFirstChild("Remove"), 10) -- equivalent call inferred; original call site unknown
	end

	for _, childName in { "DefaultBackdrop", "LookBackdrop" } do
		local child = livePreview:FindFirstChild(childName)

		if not child then
			continue
		end

		set(child, "Position", livePreview.Avatar.Position)
		set(child, "Size", livePreview.Avatar.Size)
	end

	local catalogHome = panel.CatalogHome
	box(catalogHome, 0, 0, v10, v7)
	set(catalogHome.Close, "Visible", false)
	box(catalogHome.BrowseTitle, 10, 6, v10 - 64, 30)
	font(catalogHome.BrowseTitle, 20) -- equivalent call inferred; original call site unknown
	local v19 = (v10 - 36) / 3
	local v20 = (v7 - 54) / 2

	for k, childName in {
		"Popular",
		"Animations",
		"Backgrounds",
		"Hair",
		"Clothing",
		"Accessories"
	} do
		local child = catalogHome:FindFirstChild(childName)
		box(child, 10 + (k - 1) % 3 * (v19 + 8), 40 + math.floor((k - 1) / 3) * (v20 + 8), v19, v20)

		if not child then
			continue
		end

		box(child:FindFirstChild("Title"), 8, 5, v19 - 16, 24)
		font(child:FindFirstChild("Title"), 14) -- equivalent call inferred; original call site unknown
		box(child:FindFirstChild("Art"), 5, 29, v19 - 10, math.max(20, v20 - 34))
	end

	set(panel.Title, "Visible", false)
	set(panel.Subtitle, "Visible", false)
	box(panel.Close, 8, 8, 32, 44)
	font(panel.Close, 28) -- equivalent call inferred; original call site unknown
	set(panel.Close, "Text", "‹")
	box(panel.BackToCatalog, 8, 8, 32, 44)
	font(panel.BackToCatalog, 28) -- equivalent call inferred; original call site unknown
	set(panel.BackToCatalog, "Text", "‹")
	local v21 = v10 - 176
	box(panel.SearchInput, 48, 8, v21, 44)
	font(panel.SearchInput, 18) -- equivalent call inferred; original call site unknown
	set(panel.SearchInput, "PlaceholderText", "Search")
	local uIPadding = panel.SearchInput:FindFirstChildOfClass("UIPadding")

	if uIPadding then
		set(uIPadding, "PaddingRight", UDim.new(0, 48))
	end

	box(panel.Search, 48 + v21 - 40, 8, 40, 44)
	font(panel.Search, 13) -- equivalent call inferred; original call site unknown
	set(panel.Search, "Text", "Go")
	set(panel.Search, "ZIndex", panel.SearchInput.ZIndex + 1)
	box(panel.Filters, v10 - 120, 8, 64, 44)
	font(panel.Filters, 12) -- equivalent call inferred; original call site unknown
	box(panel.Tabs, 8, 60, v10 - 16, 40)
	set(panel.Tabs, "ScrollingDirection", Enum.ScrollingDirection.X)
	set(panel.Tabs, "AutomaticCanvasSize", Enum.AutomaticSize.X)
	set(panel.Tabs, "ScrollBarThickness", 3)
	local uIListLayout = panel.Tabs:FindFirstChildOfClass("UIListLayout")

	if uIListLayout then
		set(uIListLayout, "FillDirection", Enum.FillDirection.Horizontal)
		set(uIListLayout, "Wraps", false)
		set(uIListLayout, "Padding", UDim.new(0, 8))
	end

	for _, button in panel.Tabs:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		set(button, "Size", UDim2.fromOffset(math.clamp(math.ceil(#button.Text * 7.5 + 24), 64, 156), 36))
		font(button, 14) -- equivalent call inferred; original call site unknown
		set(button, "TextWrapped", false)
	end

	local v22 = not catalogHome.Visible

	if v22 then
		if panel.Status.Text == "" then
			v22 = false
		else
			v22 = not string.find(panel.Status.Text, "items loaded", 1, true)
		end
	end

	set(panel.Status, "Visible", v22)
	box(panel.Status, 8, 102, v10 - 16, 20)
	font(panel.Status, 11) -- equivalent call inferred; original call site unknown
	local v23 = v22 and 126 or 100
	local v24 = math.max(50, v7 - v23 - (panel.More.Visible and 44 or 8))
	box(panel.Results, 8, v23, v10 - 16, v24)
	box(panel.More, 8, v7 - 38, v10 - 16, 32)
	font(panel.More, 13) -- equivalent call inferred; original call site unknown
	local v25 = math.clamp(math.floor((v10 - 16 + 6) / 106), 2, 8)
	local v26 = math.floor((v10 - 24 - (v25 - 1) * 6) / v25)
	local v27 = math.min(v26 - 8, (math.max(44, math.floor((v24 - 6) / 2) - 50)))
	local v28 = v27 + 50
	local uIGridLayout2 = panel.Results:FindFirstChildOfClass("UIGridLayout")

	if uIGridLayout2 then
		set(uIGridLayout2, "CellSize", UDim2.fromOffset(v26, v28))
		set(uIGridLayout2, "CellPadding", UDim2.fromOffset(6, 6))
	end

	for _, button in panel.Results:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		box(button:FindFirstChild("Thumbnail"), 4, 4, v26 - 8, v27)
		box(button:FindFirstChild("ItemName"), 6, v27 + 5, v26 - 12, 28)
		font(button:FindFirstChild("ItemName"), 12) -- equivalent call inferred; original call site unknown
		set(button:FindFirstChild("Creator"), "Visible", false)
		set(button:FindFirstChild("VerifiedBadge"), "Visible", false)
		box(button:FindFirstChild("Price"), 6, v27 + 33, v26 - 12, 17)
		font(button:FindFirstChild("Price"), 12) -- equivalent call inferred; original call site unknown
		box(button:FindFirstChild("FavoriteStar"), 4, 4, 32, 32)
		font(button:FindFirstChild("FavoriteStar"), 26) -- equivalent call inferred; original call site unknown
	end

	layoutOverlays(panel, v10, v7, true)
	box(anniversaryPanel.Heading, 12, 6, v10 - 64, 36)
	font(anniversaryPanel.Heading, 20) -- equivalent call inferred; original call site unknown
	set(anniversaryPanel.Heading, "Text", "20th Anniversary")
	box(anniversaryPanel.Subtitle, 12, 44, v10 - 24, 24)
	font(anniversaryPanel.Subtitle, 12) -- equivalent call inferred; original call site unknown
	box(anniversaryPanel.Items, 12, 74, v10 - 24, v7 - 86)
end

function MobileCatalogLayout.IsMobile()
	local currentCamera = workspace.CurrentCamera
	return currentCamera and UserInputService.TouchEnabled and (currentCamera.ViewportSize.X < 1400 or currentCamera.ViewportSize.Y < 800)
end

function MobileCatalogLayout.Apply(instance)
	local catalogGui = instance:FindFirstChild("CatalogGui")

	if not (catalogGui and catalogGui:FindFirstChild("Root")) then
		return false
	end

	if MobileCatalogLayout.IsMobile() then
		catalogGui:SetAttribute("MobileCatalogActive", true)
		local root = catalogGui.Root
		local panel = root.Panel
		local livePreview = root.LivePreview
		local anniversaryPanel = root.AnniversaryPanel

		if root.AbsoluteSize.X < 200 or root.AbsoluteSize.Y < 180 then
			return true
		end

		local CatalogUI = require(game.ReplicatedStorage.CatalogUI)

		if not v3 then
			v3 = CatalogUI.make("Frame", "MobileCatalogNavigation", root, {
				BackgroundColor3 = CatalogUI.colors.bg,
				BorderSizePixel = 0,
				ZIndex = 90
			})
			CatalogUI.round(v3, 10)

			for k, v7 in { "Browse", "Avatar", "Specials" } do
				local button = CatalogUI.button(v7, v3, v7, UDim2.new(), UDim2.new())
				button.ZIndex = 91
				buttons[k] = button
				local v8 = v7
				button.Activated:Connect(function()
					v2 = v8
					MobileCatalogLayout.Apply(instance)
				end)
			end
		end

		if not v4 then
			v4 = true
			panel.Details:GetPropertyChangedSignal("Visible"):Connect(function()
				if panel.Details.Visible then
					v2 = "Browse"
					MobileCatalogLayout.Apply(instance)
				end
			end)
			catalogGui:GetPropertyChangedSignal("Enabled"):Connect(function()
				if catalogGui.Enabled and not catalogGui:GetAttribute("PreserveCatalogPage") then
					v2 = "Browse"
				end
			end)
		end

		local v7 = root.AbsoluteSize.X > root.AbsoluteSize.Y and root.AbsoluteSize.X >= 520 and "Landscape" or "Portrait"

		if v5 ~= v7 then
			restore()
			v5 = v7
		end

		if v7 == "Landscape" then
			landscapeLayout(instance, catalogGui)
			return true
		end

		v3.Visible = true
		local absoluteSize = root.AbsoluteSize
		local v8 = absoluteSize.X - 16
		local v9 = absoluteSize.Y - 64
		local v10 = v9 < 400
		box(v3, 8, 4, v8, 44)
		local v11 = (v8 - 88) / 3

		for k, v12 in buttons do
			box(v12, (k - 1) * (v11 + 4), 0, v11, 44)
			v12.TextSize = 13
			v12.BackgroundColor3 = v12.Text == v2 and CatalogUI.colors.accent or CatalogUI.colors.raised
		end

		local closeCatalog = catalogGui:FindFirstChild("CloseCatalog")
		box(closeCatalog, absoluteSize.X - 84, 4, 76, 44)
		font(closeCatalog, 15) -- equivalent call inferred; original call site unknown

		for _, v12 in { panel, livePreview, anniversaryPanel } do
			unscale(v12)
			box(v12, 8, 56, v8, v9)
		end

		set(panel, "Visible", v2 == "Browse")
		set(livePreview, "Visible", v2 == "Avatar")
		set(anniversaryPanel, "Visible", v2 == "Specials")
		local catalogHome = panel.CatalogHome
		box(catalogHome, 0, 0, v8, v9)
		set(catalogHome.Close, "Visible", false)
		box(catalogHome.BrowseTitle, 12, 8, v8 - 24, 36)
		font(catalogHome.BrowseTitle, 20) -- equivalent call inferred; original call site unknown
		local v12 = v10 and 3 or 2
		local v13 = 6 / v12
		local v14 = (v8 - 24 - (v12 - 1) * 10) / v12
		local v15 = (v9 - 60 - (v13 - 1) * 10) / v13

		for k, childName in {
			"Popular",
			"Animations",
			"Backgrounds",
			"Hair",
			"Clothing",
			"Accessories"
		} do
			local child = catalogHome:FindFirstChild(childName)
			box(child, 12 + (k - 1) % v12 * (v14 + 10), 48 + math.floor((k - 1) / v12) * (v15 + 10), v14, v15)

			if not child then
				continue
			end

			box(child:FindFirstChild("Title"), 8, 6, v14 - 16, 28)
			font(child:FindFirstChild("Title"), v10 and 14 or 16) -- equivalent call inferred; original call site unknown
			box(child:FindFirstChild("Art"), 6, 36, v14 - 12, math.max(20, v15 - 42))
		end

		set(panel.Title, "Visible", false)
		set(panel.Subtitle, "Visible", false)
		box(panel.Close, 10, 6, 110, 44)
		font(panel.Close, 13) -- equivalent call inferred; original call site unknown
		box(panel.BackToCatalog, 10, 6, 120, 44)
		font(panel.BackToCatalog, 13) -- equivalent call inferred; original call site unknown
		local v16 = v10 and 6 or 56
		local v17 = v10 and 52 or 60
		local v18 = v10 and 134 or 10
		set(panel.SearchInput, "PlaceholderText", "Search")
		box(panel.SearchInput, v18, v16, v8 - v18 - 158, v17)
		font(panel.SearchInput, v10 and 16 or 18) -- equivalent call inferred; original call site unknown
		box(panel.Search, v8 - 140, v16, 62, v17)
		box(panel.Filters, v8 - 72, v16, 62, v17)
		local v20 = v16 + v17 + 8
		box(panel.Tabs, 10, v20, v8 - 20, 46)

		for _, button in panel.Tabs:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			set(button, "Size", UDim2.fromOffset(math.max(80, #button.Text * 7 + 20), 44))
			font(button, 13) -- equivalent call inferred; original call site unknown
		end

		local v21 = v20 + 48
		local v22 = not catalogHome.Visible

		if v22 then
			if panel.Status.Text == "" then
				v22 = false
			else
				v22 = not string.find(panel.Status.Text, "items loaded", 1, true)
			end
		end

		set(panel.Status, "Visible", v22)
		local v23 = panel.More.Visible and 44 or v22 and 28 or 0
		box(panel.Status, 10, v21, v8 - (panel.More.Visible and 176 or 20), math.max(20, v23))
		font(panel.Status, 12) -- equivalent call inferred; original call site unknown
		local v24 = v21 + v23 + 2
		box(panel.Results, 10, v24, v8 - 20, math.max(40, v9 - v24 - 8))
		box(panel.More, v8 - 150, v21, 140, 44)
		font(panel.More, 14) -- equivalent call inferred; original call site unknown
		local uIGridLayout = panel.Results:FindFirstChildOfClass("UIGridLayout")
		local v25 = math.max(2, (math.floor((v8 - 20 + 6) / 108)))
		local v26 = math.floor((v8 - 28 - (v25 - 1) * 6) / v25)
		local v27 = math.min(v26 - 8, 96)
		local v28 = v27 + 50

		if uIGridLayout then
			set(uIGridLayout, "CellSize", UDim2.fromOffset(v26, v28))
			set(uIGridLayout, "CellPadding", UDim2.fromOffset(6, 6))
		end

		for _, button in panel.Results:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			box(button:FindFirstChild("Thumbnail"), 4, 4, v26 - 8, v27)
			box(button:FindFirstChild("ItemName"), 6, v27 + 5, v26 - 12, 28)
			font(button:FindFirstChild("ItemName"), 12) -- equivalent call inferred; original call site unknown
			set(button:FindFirstChild("Creator"), "Visible", false)
			set(button:FindFirstChild("VerifiedBadge"), "Visible", false)
			box(button:FindFirstChild("Price"), 6, v27 + 33, v26 - 12, 17)
			font(button:FindFirstChild("Price"), 12) -- equivalent call inferred; original call site unknown
			box(button:FindFirstChild("FavoriteStar"), v26 - 36, 4, 32, 32)
			font(button:FindFirstChild("FavoriteStar"), 26) -- equivalent call inferred; original call site unknown
		end

		layoutOverlays(panel, v8, v9, v10)

		if v10 then
			local v29 = math.floor(v8 * 0.43)
			local v30 = v29 + 16
			local v31 = v8 - v30 - 10
			box(livePreview.Title, v30, 4, v31, 28)
			font(livePreview.Title, 18) -- equivalent call inferred; original call site unknown
			box(livePreview.Tools, v30, 28, (v31 - 8) / 2, 44)
			box(livePreview.SaveOutfit, v30 + (v31 + 8) / 2, 28, (v31 - 8) / 2, 44)
			box(livePreview.Hint, 8, 2, v29, 22)
			font(livePreview.Hint, 12) -- equivalent call inferred; original call site unknown
			box(livePreview.Avatar, 8, 26, v29, v9 - 34)
			box(livePreview.OutfitCost, v30, 76, v31, 28)
			font(livePreview.OutfitCost, 12) -- equivalent call inferred; original call site unknown
			box(livePreview.EquippedHeading, v30, 106, v31, 20)
			font(livePreview.EquippedHeading, 13) -- equivalent call inferred; original call site unknown
			box(livePreview.EquippedItems, v30, 128, v31, math.max(100, v9 - 136))
		else
			box(livePreview.Title, 12, 8, v8 - 162, 36)
			font(livePreview.Title, 22) -- equivalent call inferred; original call site unknown
			box(livePreview.Tools, v8 - 144, 8, 132, 44)
			box(livePreview.SaveOutfit, v8 - 144, 60, 132, 44)
			box(livePreview.Hint, 12, 54, v8 - 170, 44)
			font(livePreview.Hint, 13) -- equivalent call inferred; original call site unknown
			box(livePreview.OutfitCost, 12, 110, v8 - 24, 36)
			font(livePreview.OutfitCost, 12) -- equivalent call inferred; original call site unknown
			box(livePreview.Avatar, 8, 152, v8 - 16, math.max(80, v9 - 296))
			box(livePreview.EquippedHeading, 12, v9 - 138, v8 - 24, 24)
			font(livePreview.EquippedHeading, 13) -- equivalent call inferred; original call site unknown
			box(livePreview.EquippedItems, 12, v9 - 108, v8 - 24, 100)
		end

		local equippedItems = livePreview.EquippedItems
		local uIGridLayout2 = equippedItems:FindFirstChildOfClass("UIGridLayout")

		if uIGridLayout2 then
			set(uIGridLayout2, "CellSize", UDim2.fromOffset(96, 96))
			set(uIGridLayout2, "CellPadding", UDim2.fromOffset(8, 0))
			set(uIGridLayout2, "FillDirection", Enum.FillDirection.Vertical)
			set(uIGridLayout2, "FillDirectionMaxCells", 1)
		end

		set(equippedItems, "ScrollingDirection", Enum.ScrollingDirection.X)
		set(equippedItems, "AutomaticCanvasSize", Enum.AutomaticSize.X)
		set(equippedItems, "CanvasSize", UDim2.new())

		for _, child in equippedItems:GetChildren() do
			local actions = child:FindFirstChild("Actions")

			if not actions then
				continue
			end

			font(actions:FindFirstChild("Buy"), 13) -- equivalent call inferred; original call site unknown
			font(actions:FindFirstChild("Remove"), 13) -- equivalent call inferred; original call site unknown
		end

		box(anniversaryPanel.Heading, 12, 8, v8 - 24, 44)
		font(anniversaryPanel.Heading, 22) -- equivalent call inferred; original call site unknown
		set(anniversaryPanel.Heading, "Text", "20th Anniversary")
		box(anniversaryPanel.Subtitle, 12, 56, v8 - 24, 26)
		box(anniversaryPanel.Items, 12, 90, v8 - 24, v9 - 102)
		local defaultBackdrop = livePreview:FindFirstChild("DefaultBackdrop")

		if defaultBackdrop then
			set(defaultBackdrop, "Position", livePreview.Avatar.Position)
			set(defaultBackdrop, "Size", livePreview.Avatar.Size)
		end

		local lookBackdrop = livePreview:FindFirstChild("LookBackdrop")

		if lookBackdrop then
			set(lookBackdrop, "Position", livePreview.Avatar.Position)
			set(lookBackdrop, "Size", livePreview.Avatar.Size)
		end

		return true
	else
		if catalogGui:GetAttribute("MobileCatalogActive") then
			catalogGui:SetAttribute("MobileCatalogActive", false)
			restore()
			v5 = nil
		end

		return false
	end
end

return MobileCatalogLayout