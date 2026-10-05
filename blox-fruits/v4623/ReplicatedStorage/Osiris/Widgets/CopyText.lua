local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Common = require(game.ReplicatedStorage.Osiris.Common)
local v = { "Text", "Label", "Wrapped" }
local internal = Common.Internal
local utility = Common.Utility

local function selectAll(p)
	p.CursorPosition = #p.Text + 1
	p.SelectionStart = #p.Text > 0 and 1 or -1
end

local events = {
	hovered = utility.EVENTS.hover(function(p)
		return p.Field
	end),
	focused = {
		Init = function(_) end,
		Get = function(p)
			return p.lastFocusedTick == internal._cycleTick
		end
	}
}
Common.assertNoShadowedEvents("CopyText", events, {})

if internal._widgets.CopyText == nil then
	local widgetConstructor = internal.WidgetConstructor
	local args = {}
	local v4 = {
		hasState = false,
		hasChildren = false,
		Args = 0,
		Events = 0,
		Generate = 0,
		Update = 0,
		Discard = 0
	}

	for k, v6 in v do
		args[v6] = k
	end

	v4.Args = args
	v4.Events = events

	function v4:Generate()
		local config = Common.config()
		local frame = Instance.new("Frame")
		frame.Name = "Iris_CopyText"
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		local uIListLayout = utility.UIListLayout(
			frame,
			Enum.FillDirection.Horizontal,
			UDim.new(0, config.ItemInnerSpacing.X)
		)
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		local textBox = Instance.new("TextBox")
		textBox.Name = "Field"
		textBox.Size = UDim2.new(config.ContentWidth, UDim.new(0, 0))
		textBox.AutomaticSize = Enum.AutomaticSize.Y
		textBox.BackgroundColor3 = config.FrameBgColor
		textBox.BackgroundTransparency = config.FrameBgTransparency
		textBox.ClearTextOnFocus = false
		textBox.TextEditable = false
		textBox.MultiLine = false
		textBox.TextWrapped = false
		textBox.TextTruncate = Enum.TextTruncate.None
		textBox.TextXAlignment = Enum.TextXAlignment.Left
		textBox.Text = ""
		textBox.LayoutOrder = 0
		utility.applyFrameStyle(textBox)
		utility.applyTextStyle(textBox)
		textBox.TextColor3 = config.TextColor
		textBox.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Caption"
		textLabel.AutomaticSize = Enum.AutomaticSize.XY
		textLabel.Size = UDim2.fromOffset(0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.LayoutOrder = 1
		utility.applyTextStyle(textLabel)
		textLabel.Parent = frame
		self.Root = frame
		self.Field = textBox
		self.Caption = textLabel
		self.Text = ""
		self.lastFocusedTick = -1
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			if textBox.Text ~= self.Text then
				textBox.Text = self.Text
			end
		end)
		textBox.Focused:Connect(function()
			self.lastFocusedTick = internal._cycleTick + 1
			task.defer(selectAll, textBox)
		end)
		textBox.FocusLost:Connect(function()
			if textBox.Text ~= self.Text then
				textBox.Text = self.Text
			end
		end)
		return frame
	end

	function v4:Update()
		local arguments = self.arguments
		local config = Common.config()
		local text = typeof(arguments.Text) ~= "string" and "" or arguments.Text
		local text2 = typeof(arguments.Label) ~= "string" and "" or arguments.Label
		local wrapped = arguments.Wrapped == true
		self.Text = text

		if self.Field.Text ~= text then
			self.Field.Text = text
		end

		self.Field.TextWrapped = wrapped
		self.Field.MultiLine = wrapped
		local field = self.Field
		local v8

		if text2 == "" then
			v8 = UDim.new(1, 0)
		else
			v8 = config.ContentWidth
		end

		field.Size = UDim2.new(v8, UDim.new(0, 0))
		self.Caption.Text = text2
		self.Caption.Visible = text2 ~= ""
	end

	function v4.Discard(p)
		p.Root:Destroy()
	end

	widgetConstructor("CopyText", v4)
end

local function CopyText(p)
	if p.Id ~= nil then
		Osiris.SetNextWidgetID(p.Id)
	end

	return (internal._Insert("CopyText", Common.toArguments(v, p.Arguments), nil))
end

return CopyText