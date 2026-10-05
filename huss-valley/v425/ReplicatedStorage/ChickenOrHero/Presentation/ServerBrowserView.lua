local ValleyTheme = require(script.Parent.ValleyTheme)
local ServerBrowserView = {
	styleCountry = function(p, p2)
		ValleyTheme.button(p, p2 and ValleyTheme.Mint or ValleyTheme.Blue)
		p.BackgroundTransparency = p2 and 0.05 or 0.35
		p.TextColor3 = p2 and ValleyTheme.Mint or ValleyTheme.Paper
		p.Font = Enum.Font.GothamBold
		p.TextScaled = true
		p.TextWrapped = true
	end
}

local function make(className, parent, name, items)
	local instance = parent:FindFirstChild(name)

	if not instance then
		instance = Instance.new(className)
		instance.Name = name
		instance.Parent = parent
	end

	for k, item in items do
		instance[k] = item
	end

	return instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function label(p, textSize, textColor, p2)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.Active = false
	p.TextScaled = false
	p.TextSize = textSize
	p.TextColor3 = textColor
	p.Font = p2 and Enum.Font.GothamBold or Enum.Font.Gotham
	p.TextXAlignment = Enum.TextXAlignment.Left
	p.TextYAlignment = Enum.TextYAlignment.Center
	p.TextWrapped = false
	p.TextTruncate = Enum.TextTruncate.AtEnd
end

local function cleanLegacy(folder)
	folder:SetAttribute("UIProportionalGroup", nil)

	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("UITextSizeConstraint") or descendant:IsA("UIAspectRatioConstraint") or descendant:IsA("UISizeConstraint") or descendant:IsA("UIPadding") or descendant:IsA("UIScale") and descendant.Name == "ProportionalScale") then
			continue
		end

		descendant:Destroy()
	end
end

function ServerBrowserView:styleRow(p)
	local current = p and p.current
	local mint = current and ValleyTheme.Mint or ValleyTheme.Blue
	ValleyTheme.surface(self, ValleyTheme.Ink:Lerp(mint, current and 0.075 or 0.035), mint, 5, current and 0.42 or 0.8)
	self.BackgroundTransparency = 0
	self.Accent.BackgroundColor3 = mint
	self.Accent.BackgroundTransparency = current and 0.12 or 0.65
	ValleyTheme.button(self.Join, mint, ValleyTheme.Ink:Lerp(mint, 0.14))
	self.Join.TextTransparency = current and 0.1 or self.Join.Active and 0 or 0.45
	self.Title.TextColor3 = current and ValleyTheme.Mint or ValleyTheme.Paper
end

function ServerBrowserView.apply(p)
	local panel = p.Panel
	local serverRow = p.Templates.ServerRow
	cleanLegacy(panel)
	cleanLegacy(serverRow)
	panel.Active = false
	panel.BackgroundTransparency = 0
	ValleyTheme.surface(panel, ValleyTheme.Ink, ValleyTheme.Blue, 8, 0.55)
	local v2 = panel:FindFirstChild("Scale")

	if not v2 then
		v2 = Instance.new("UIScale")
		v2.Name = "Scale"
		v2.Parent = panel
	end

	for k, v3 in {
		Scale = 1
	} do
		v2[k] = v3
	end

	local v3 = {
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = ValleyTheme.Blue,
		BorderSizePixel = 0
	}
	local v4 = panel:FindFirstChild("TopRule")

	if not v4 then
		v4 = Instance.new("Frame")
		v4.Name = "TopRule"
		v4.Parent = panel
	end

	for k, v5 in v3 do
		v4[k] = v5
	end

	local v6 = panel:FindFirstChild("Eyebrow")

	if not v6 then
		v6 = Instance.new("TextLabel")
		v6.Name = "Eyebrow"
		v6.Parent = panel
	end

	for k, v7 in {
		Text = "HUSS VALLEY  /  FIND YOUR PEOPLE"
	} do
		v6[k] = v7
	end

	label(v6, 11, ValleyTheme.Blue, true)
	label(panel.Title, 28, ValleyTheme.Paper, true)
	panel.Title.Text = "SERVER LIST"
	label(panel.Connection, 12, ValleyTheme.Mint, true)
	local v7 = {
		BackgroundColor3 = ValleyTheme.Blue,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0
	}
	local v8 = panel:FindFirstChild("HeaderRule")

	if not v8 then
		v8 = Instance.new("Frame")
		v8.Name = "HeaderRule"
		v8.Parent = panel
	end

	for k, v9 in v7 do
		v8[k] = v9
	end

	local v11 = panel:FindFirstChild("Count")

	if not v11 then
		v11 = Instance.new("TextLabel")
		v11.Name = "Count"
		v11.Parent = panel
	end

	for k, v12 in {
		Text = "PUBLIC SERVERS"
	} do
		v11[k] = v12
	end

	label(v11, 11, ValleyTheme.Muted, true)
	local v12 = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = ValleyTheme.Blue,
		ClipsDescendants = true
	}
	local parent = panel:FindFirstChild("Countries")

	if not parent then
		parent = Instance.new("ScrollingFrame")
		parent.Name = "Countries"
		parent.Parent = panel
	end

	for k, v14 in v12 do
		parent[k] = v14
	end

	local v14 = {
		Padding = UDim.new(0, 7),
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local v15 = parent:FindFirstChild("Layout")

	if not v15 then
		v15 = Instance.new("UIListLayout")
		v15.Name = "Layout"
		v15.Parent = parent
	end

	for k, v16 in v14 do
		v15[k] = v16
	end

	local v17 = panel:FindFirstChild("PreviousPage")

	if not v17 then
		v17 = Instance.new("TextButton")
		v17.Name = "PreviousPage"
		v17.Parent = panel
	end

	for k, v18 in {
		Text = "‹ PREVIOUS"
	} do
		v17[k] = v18
	end

	local v19 = panel:FindFirstChild("NextPage")

	if not v19 then
		v19 = Instance.new("TextButton")
		v19.Name = "NextPage"
		v19.Parent = panel
	end

	for k, v20 in {
		Text = "NEXT ›"
	} do
		v19[k] = v20
	end

	local v21 = panel:FindFirstChild("PageLabel")

	if not v21 then
		v21 = Instance.new("TextLabel")
		v21.Name = "PageLabel"
		v21.Parent = panel
	end

	for k, v22 in {
		Text = "PAGE 1 / 1"
	} do
		v21[k] = v22
	end

	label(v21, 12, ValleyTheme.Paper, true)
	v21.TextXAlignment = Enum.TextXAlignment.Center

	for _, v22 in {
		"Close",
		"Refresh",
		"Sort",
		"PreviousPage",
		"NextPage"
	} do
		local v23 = panel[v22]
		v23.TextScaled = false
		v23.TextSize = v22 == "Close" and 27 or 13
		v23.BackgroundTransparency = 0
		ValleyTheme.button(v23, ValleyTheme.Blue)
		v23.TextWrapped = false
		v23.TextXAlignment = Enum.TextXAlignment.Center
	end

	panel.Close.Modal = true
	panel.Close.Text = "×"
	label(panel.Explanation, 12, ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	panel.Explanation.Text = "Your ping is live. Other pings are player averages, updated about every 20s. Locations are approximate."
	panel.Explanation.TextWrapped = true
	panel.Explanation.TextTruncate = Enum.TextTruncate.None
	label(panel.Status, 12, ValleyTheme.Gold, false) -- equivalent call inferred; original call site unknown
	panel.Status.TextWrapped = true
	panel.Status.TextTruncate = Enum.TextTruncate.None
	label(panel.Empty, 15, ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	panel.Empty.TextXAlignment = Enum.TextXAlignment.Center
	panel.Empty.TextWrapped = true
	panel.List.Active = true
	panel.List.BackgroundTransparency = 1
	panel.List.BorderSizePixel = 0
	panel.List.ClipsDescendants = true
	panel.List.ScrollingDirection = Enum.ScrollingDirection.Y
	panel.List.ScrollingEnabled = true
	panel.List.AutomaticCanvasSize = Enum.AutomaticSize.Y
	panel.List.CanvasSize = UDim2.new()
	panel.List.ScrollBarThickness = 4
	panel.List.ScrollBarImageColor3 = ValleyTheme.Blue
	panel.List.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	panel.List.Layout.Padding = UDim.new(0, 10)
	panel.List.Layout.SortOrder = Enum.SortOrder.LayoutOrder
	local list = panel.List
	local v22 = {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 1),
		PaddingRight = UDim.new(0, 8)
	}
	local v23 = list:FindFirstChild("Padding")

	if not v23 then
		v23 = Instance.new("UIPadding")
		v23.Name = "Padding"
		v23.Parent = list
	end

	for k, v24 in v22 do
		v23[k] = v24
	end

	serverRow.Size = UDim2.new(1, 0, 0, 112)
	serverRow.Active = false
	serverRow.BorderSizePixel = 0
	local v24 = {
		Position = UDim2.fromOffset(0, 12),
		Size = UDim2.new(0, 2, 1, -24),
		BorderSizePixel = 0
	}
	local v25 = serverRow:FindFirstChild("Accent")

	if not v25 then
		v25 = Instance.new("Frame")
		v25.Name = "Accent"
		v25.Parent = serverRow
	end

	for k, v26 in v24 do
		v25[k] = v26
	end

	label(serverRow.Title, 16, ValleyTheme.Paper, true) -- equivalent call inferred; original call site unknown
	label(serverRow.Details, 13, ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	label(serverRow.Region, 12, ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	label(serverRow.Ping, 12, ValleyTheme.Blue, true) -- equivalent call inferred; original call site unknown
	serverRow.Title.Position = UDim2.fromOffset(16, 12)
	serverRow.Title.Size = UDim2.new(1, -156, 0, 23)
	serverRow.Details.Position = UDim2.fromOffset(16, 40)
	serverRow.Details.Size = UDim2.new(1, -156, 0, 22)
	serverRow.Region.Position = UDim2.fromOffset(16, 82)
	serverRow.Region.Size = UDim2.new(1, -178, 0, 18)
	serverRow.Ping.AnchorPoint = Vector2.new(1, 0)
	serverRow.Ping.Position = UDim2.new(1, -14, 0, 82)
	serverRow.Ping.Size = UDim2.fromOffset(144, 18)
	serverRow.Ping.TextXAlignment = Enum.TextXAlignment.Right
	serverRow.Join.AnchorPoint = Vector2.new(1, 0)
	serverRow.Join.Position = UDim2.new(1, -14, 0, 18)
	serverRow.Join.Size = UDim2.fromOffset(116, 44)
	serverRow.Join.TextScaled = false
	serverRow.Join.TextSize = 14
	serverRow.Join.TextWrapped = false
	ServerBrowserView.styleRow(serverRow)
end

function ServerBrowserView.layout(p)
	local absoluteSize = p.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local v = absoluteSize.X / absoluteSize.Y < 1.1
	local v2 = not v and absoluteSize.Y < 500
	local v3 = v and 460 or 980
	local v4 = v and 720 or v2 and 430 or 620
	local panel = p.Panel
	panel.Size = UDim2.fromOffset(v3, v4)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	local GuiService = game:GetService("GuiService")
	local v5 = math.max(14, GuiService:GetGuiInset().Y + 6)
	local v6 = math.max(120, absoluteSize.Y - v5 - 14)
	panel.Position = UDim2.new(0.5, 0, 0, v5 + v6 * 0.5)
	panel.Scale.Scale = math.min(1.05, absoluteSize.X * 0.94 / v3, v6 / v4)
	panel.Eyebrow.Position = UDim2.fromOffset(24, v2 and 14 or 20)
	panel.Eyebrow.Size = UDim2.fromOffset(v3 - 112, 18)
	panel.Title.Position = UDim2.fromOffset(24, v2 and 34 or 44)
	panel.Title.Size = UDim2.fromOffset(v3 - 104, 38)
	panel.Close.AnchorPoint = Vector2.zero
	panel.Close.Position = UDim2.fromOffset(v3 - 68, v2 and 14 or 20)
	panel.Close.Size = UDim2.fromOffset(44, 44)
	panel.Connection.Position = UDim2.fromOffset(24, v2 and 79 or 98)
	panel.Connection.Size = UDim2.fromOffset(v3 - 48, 22)
	panel.HeaderRule.Position = UDim2.fromOffset(24, v2 and 110 or 135)
	panel.HeaderRule.Size = UDim2.fromOffset(v3 - 48, 1)
	local v7 = v2 and 120 or 148
	panel.Sort.Position = UDim2.fromOffset(24, v7)
	panel.Sort.Size = UDim2.fromOffset(v and 200 or 212, 36)
	panel.Refresh.Position = UDim2.fromOffset(v3 - 144, v7)
	panel.Refresh.Size = UDim2.fromOffset(120, 36)
	panel.Count.Visible = not v
	panel.Count.Position = UDim2.fromOffset(252, v7)
	panel.Count.Size = UDim2.fromOffset(v3 - 412, 36)
	local v8 = v2 and 168 or 196
	local countries = panel.Countries
	countries.Layout.FillDirection = v and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
	countries.AutomaticCanvasSize = v and Enum.AutomaticSize.X or Enum.AutomaticSize.Y
	countries.ScrollingDirection = v and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y
	countries.CanvasSize = UDim2.new()
	countries.Position = UDim2.fromOffset(24, v8)
	countries.Size = UDim2.fromOffset(not v and 174 or v3 - 48 or 174, v and 46 or v4 - v8 - 104)

	for _, button in countries:GetChildren() do
		if button:IsA("TextButton") then
			button.Size = v and UDim2.fromOffset(140, 38) or UDim2.new(1, -8, 0, 42)
		end
	end

	local v9 = v and 24 or 216
	local v10 = v8 + (v and 56 or 0)
	panel.List.Position = UDim2.fromOffset(v9, v10)
	panel.List.Size = UDim2.fromOffset(v3 - v9 - 24, v4 - v10 - 144)
	panel.PreviousPage.Position = UDim2.fromOffset(v9, v4 - 134)
	panel.PreviousPage.Size = UDim2.fromOffset(116, 30)
	panel.NextPage.Position = UDim2.fromOffset(v3 - 140, v4 - 134)
	panel.NextPage.Size = UDim2.fromOffset(116, 30)
	panel.PageLabel.Position = UDim2.fromOffset(v9 + 120, v4 - 134)
	panel.PageLabel.Size = UDim2.fromOffset(v3 - v9 - 264, 30)
	panel.Empty.Position = panel.List.Position
	panel.Empty.Size = panel.List.Size
	panel.Explanation.Position = UDim2.fromOffset(24, v4 - 92)
	panel.Explanation.Size = UDim2.fromOffset(v3 - 48, 38)
	panel.Status.Position = UDim2.fromOffset(24, v4 - 46)
	panel.Status.Size = UDim2.fromOffset(v3 - 48, 32)
end

return ServerBrowserView