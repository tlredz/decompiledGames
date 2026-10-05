local ValleyTheme = require(script.Parent.ValleyTheme)
local ChoiceView = {}

local function make(className, parent, name, items)
	local result = parent:FindFirstChild(name) or Instance.new(className)
	result.Name = name

	for k, item in items do
		result[k] = item
	end

	result.Parent = parent
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function text(title, textSize, paper, p)
	title.BackgroundTransparency = 1
	title.BorderSizePixel = 0
	title.Active = false
	title.TextScaled = false
	title.TextSize = textSize
	title.Font = p and Enum.Font.GothamBold or Enum.Font.Gotham
	title.TextColor3 = paper or ValleyTheme.Paper
	title.TextStrokeColor3 = ValleyTheme.Ink
	title.TextStrokeTransparency = 0.45
	title.TextWrapped = false
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.TextXAlignment = Enum.TextXAlignment.Left
end

function ChoiceView:card()
	self.Text = ""
	self.AutoButtonColor = false
	self.Active = true
	self.Modal = true
	self.BackgroundTransparency = 0.58
	ValleyTheme.button(self, ValleyTheme.Blue, ValleyTheme.Ink)
	self.Border.Transparency = 0.82
	self.Avatar.BackgroundTransparency = 1
	self.Avatar.Active = false
	self.Avatar.Position = UDim2.fromOffset(6, 6)
	self.Avatar.Size = UDim2.fromOffset(32, 32)
	local uICorner = self.Avatar:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 4)
	uICorner.Parent = self.Avatar
	text(self.Title, 14, ValleyTheme.Paper, true)
	text(self.Description, 10, ValleyTheme.Paper, false) -- equivalent call inferred; original call site unknown
	self.Title.Position = UDim2.fromOffset(46, 5)
	self.Title.Size = UDim2.new(1, -72, 0, 18)
	self.Description.Position = UDim2.fromOffset(46, 23)
	self.Description.Size = UDim2.new(1, -72, 0, 16)
	local v = {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(16, 24),
		Text = "›"
	}
	local choose = self:FindFirstChild("Choose") or Instance.new("TextLabel")
	choose.Name = "Choose"

	for k, v2 in v do
		choose[k] = v2
	end

	choose.Parent = self
	text(choose, 20, ValleyTheme.Blue, true) -- equivalent call inferred; original call site unknown
	choose.TextXAlignment = Enum.TextXAlignment.Center
	local avatar = self.Avatar
	local v2 = {
		Size = UDim2.fromScale(1, 1),
		Text = "?"
	}
	local fallback = avatar:FindFirstChild("Fallback") or Instance.new("TextLabel")
	fallback.Name = "Fallback"

	for k, v3 in v2 do
		fallback[k] = v3
	end

	fallback.Parent = avatar
	text(fallback, 18, ValleyTheme.Muted, true) -- equivalent call inferred; original call site unknown
	fallback.TextXAlignment = Enum.TextXAlignment.Center
	fallback.Visible = false
end

function ChoiceView.apply(p)
	local choices = p.MainFrame.Choices
	choices:SetAttribute("UIProportionalGroup", nil)

	for _, folder in { choices, p.Templates.ChoiceOption } do
		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("UITextSizeConstraint") or descendant:IsA("UISizeConstraint") or descendant:IsA("UIAspectRatioConstraint") or descendant:IsA("UIScale") and descendant.Name == "ProportionalScale") then
				continue
			end

			descendant:Destroy()
		end
	end

	choices.Active = false
	choices.BackgroundTransparency = 1
	ValleyTheme.surface(choices, ValleyTheme.Ink, ValleyTheme.Gold, 6, 1)
	choices.Border.Enabled = false
	local choiceScale = choices:FindFirstChild("ChoiceScale") or Instance.new("UIScale")
	choiceScale.Name = "ChoiceScale"

	for k, v in {
		Scale = 1
	} do
		choiceScale[k] = v
	end

	choiceScale.Parent = choices
	choices.HeaderBackground.Visible = false
	local topRule = choices:FindFirstChild("TopRule") or Instance.new("Frame")
	topRule.Name = "TopRule"

	for k, v in {
		Visible = false
	} do
		topRule[k] = v
	end

	topRule.Parent = choices
	local eyebrow = choices:FindFirstChild("Eyebrow") or Instance.new("TextLabel")
	eyebrow.Name = "Eyebrow"

	for k, v in {
		Text = "",
		Visible = false
	} do
		eyebrow[k] = v
	end

	eyebrow.Parent = choices
	text(eyebrow, 10, ValleyTheme.Gold, true) -- equivalent call inferred; original call site unknown
	text(choices.Title, 17, ValleyTheme.Paper, true) -- equivalent call inferred; original call site unknown
	text(choices.Hint, 11, ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	choices.Hint.Visible = false
	text(choices.Status, 11, ValleyTheme.Gold, true) -- equivalent call inferred; original call site unknown
	choices.Status.TextXAlignment = Enum.TextXAlignment.Right
	local count = choices:FindFirstChild("Count") or Instance.new("TextLabel")
	count.Name = "Count"

	for k, v in {
		Text = ""
	} do
		count[k] = v
	end

	count.Parent = choices
	text(count, 10, ValleyTheme.Paper, false) -- equivalent call inferred; original call site unknown
	local v = {
		Text = "",
		PlaceholderText = "Find a runner…",
		ClearTextOnFocus = false,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextColor3 = ValleyTheme.Paper,
		PlaceholderColor3 = ValleyTheme.Paper,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 0.58,
		BorderSizePixel = 0,
		MultiLine = false
	}
	local search = choices:FindFirstChild("Search") or Instance.new("TextBox")
	search.Name = "Search"

	for k, v2 in v do
		search[k] = v2
	end

	search.Parent = choices
	ValleyTheme.surface(search, ValleyTheme.Ink, ValleyTheme.Blue, 4, 0.8)
	local v2 = {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10)
	}
	local inset = search:FindFirstChild("Inset") or Instance.new("UIPadding")
	inset.Name = "Inset"

	for k, v3 in v2 do
		inset[k] = v3
	end

	inset.Parent = search
	local options = choices.PlayerPicker.Options
	options.Active = true
	options.BackgroundTransparency = 1
	options.ScrollingEnabled = true
	options.ScrollingDirection = Enum.ScrollingDirection.Y
	options.AutomaticCanvasSize = Enum.AutomaticSize.Y
	options.CanvasSize = UDim2.new()
	options.ClipsDescendants = true
	options.ScrollBarThickness = 3
	options.ScrollBarImageColor3 = ValleyTheme.Blue
	options.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	local layout = options:FindFirstChild("Layout")

	if layout and not layout:IsA("UIGridLayout") then
		layout:Destroy()
		layout = nil
	end

	local v3 = layout or Instance.new("UIGridLayout")
	v3.Name = "Layout"
	v3.SortOrder = Enum.SortOrder.LayoutOrder
	v3.FillDirection = Enum.FillDirection.Horizontal
	v3.FillDirectionMaxCells = 1
	v3.CellPadding = UDim2.fromOffset(0, 6)
	v3.Parent = options
	v3.CellSize = UDim2.new(1, -8, 0, 44)
	local v4 = {
		PaddingLeft = UDim.new(0, 1),
		PaddingTop = UDim.new(0, 1),
		PaddingRight = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 4)
	}
	local padding = options:FindFirstChild("Padding") or Instance.new("UIPadding")
	padding.Name = "Padding"

	for k, v5 in v4 do
		padding[k] = v5
	end

	padding.Parent = options
	local playerPicker = choices.PlayerPicker
	local v5 = {
		Size = UDim2.fromScale(1, 1),
		Text = "No matching runners.",
		Visible = false
	}
	local empty = playerPicker:FindFirstChild("Empty") or Instance.new("TextLabel")
	empty.Name = "Empty"

	for k, v6 in v5 do
		empty[k] = v6
	end

	empty.Parent = playerPicker
	text(empty, 13, ValleyTheme.Paper, false) -- equivalent call inferred; original call site unknown
	empty.TextXAlignment = Enum.TextXAlignment.Center
	choices.PlayerPicker.BackgroundTransparency = 1
	choices.RunnerChoice.BackgroundTransparency = 1
	choices.RunnerChoice.Options.BackgroundTransparency = 1
	ChoiceView.card(p.Templates.ChoiceOption)

	for _, v6 in { "Chicken", "Hero" } do
		local option = choices.RunnerChoice.Options[v6]
		option.AutoButtonColor = false
		option.Modal = true
		option.Active = true
		option.BackgroundTransparency = 0.58
		local gold3 = v6 == "Hero" and ValleyTheme.Gold or ValleyTheme.Blue
		ValleyTheme.button(option, gold3, ValleyTheme.Ink)
		option.Border.Transparency = 0.68
		text(option.Title, 17, gold3, true) -- equivalent call inferred; original call site unknown
		text(option.Description, 11, ValleyTheme.Paper, false) -- equivalent call inferred; original call site unknown
		option.Description.TextWrapped = true
		option.Description.TextTruncate = Enum.TextTruncate.None
		option.Description.TextYAlignment = Enum.TextYAlignment.Top
		option.Eyebrow.Visible = false
		option.Accent.Visible = false
	end
end

function ChoiceView:selected(p)
	self.BackgroundColor3 = p and ValleyTheme.Ink:Lerp(ValleyTheme.Mint, 0.15) or ValleyTheme.Ink
	self.Border.Color = p and ValleyTheme.Mint or ValleyTheme.Blue
	self.Border.Transparency = p and 0.2 or 0.82

	if self:FindFirstChild("Choose") then
		self.Choose.Text = p and "✓" or "›"
		self.Choose.TextColor3 = p and ValleyTheme.Mint or ValleyTheme.Blue
	end
end

function ChoiceView.layout(p, p2)
	local choices = p.MainFrame.Choices
	local absoluteSize = p.MainFrame.AbsoluteSize

	if absoluteSize.X < 1 or absoluteSize.Y < 1 then
		return
	end

	local v = p2 == "choice"
	local v2 = v and math.min(420, math.max(300, absoluteSize.X * 0.4), absoluteSize.X - 32) or math.min(
		360,
		absoluteSize.X - 56
	)
	local v3 = v and 124 or math.min(258, (math.max(176, absoluteSize.Y * 0.34)))
	local notificationsF = p.MainFrame.NotificationsF
	local v4 = math.max(
		8,
		notificationsF.AbsolutePosition.Y + notificationsF.AbsoluteSize.Y - p.MainFrame.AbsolutePosition.Y + 10
	)
	local v5 = math.min(1, (absoluteSize.X - 24) / v2, (absoluteSize.Y - 24) / v3)
	choices.Size = UDim2.fromOffset(v2, v3)
	choices.AnchorPoint = Vector2.new(0.5, 0)
	choices.Position = UDim2.new(
		0.5,
		0,
		0,
		(math.clamp(
			math.max(v4, absoluteSize.Y * 0.42 - v3 * v5 * 0.5),
			8,
			(math.max(8, absoluteSize.Y - v3 * v5 - 12))
		))
	)
	choices.ChoiceScale.Scale = v5 * (choices.Reveal.Value or 1)
	choices.Hint.Visible = false
	choices.Eyebrow.Visible = false
	choices.TopRule.Visible = false
	choices.Title.Position = UDim2.fromOffset(2, 0)
	choices.Title.Size = UDim2.fromOffset(v2 - 106, 24)
	choices.Title.TextSize = 17
	choices.Status.Position = UDim2.fromOffset(v2 - 100, 2)
	choices.Status.Size = UDim2.fromOffset(98, 22)
	choices.Status.TextSize = 11
	choices.Search.Visible = not v and p2 == "select"
	choices.Count.Visible = not v and p2 == "select"
	choices.Search.Position = UDim2.fromOffset(0, 28)
	choices.Search.Size = UDim2.fromOffset(v2, 30)
	choices.PlayerPicker.Position = UDim2.fromOffset(0, 66)
	choices.PlayerPicker.Size = UDim2.fromOffset(v2, v3 - 88)
	choices.Count.Position = UDim2.fromOffset(2, v3 - 18)
	choices.Count.Size = UDim2.fromOffset(v2 - 4, 16)
	choices:SetAttribute("PickerColumns", 1)
	local runnerChoice = choices.RunnerChoice
	runnerChoice.Position = UDim2.fromOffset(0, 32)
	runnerChoice.Size = UDim2.fromOffset(v2, 84)

	for k, v6 in { "Chicken", "Hero" } do
		local option = runnerChoice.Options[v6]
		option.Position = UDim2.new((k - 1) * 0.5, (k - 1) * 4, 0, 0)
		option.Size = UDim2.new(0.5, -4, 1, 0)
		option.Title.Position = UDim2.fromOffset(12, 9)
		option.Title.Size = UDim2.new(1, -24, 0, 22)
		option.Description.Position = UDim2.fromOffset(12, 37)
		option.Description.Size = UDim2.new(1, -24, 0, 38)
		option.Description.Text = v6 == "Hero" and "Cross solo.\nSafe? Skip the group run." or "Cross together\nwith the other runners."
	end
end

return ChoiceView