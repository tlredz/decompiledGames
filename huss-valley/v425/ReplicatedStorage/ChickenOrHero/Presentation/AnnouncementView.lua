local ValleyPanels = require(script.Parent.ValleyPanels)
local ValleyTheme = require(script.Parent.ValleyTheme)
local AnnouncementView = {}

function AnnouncementView.build(p)
	local button = ValleyPanels.button(p, "OpenBroadcast", "ANNOUNCE", 0, 0, 114, 38, ValleyTheme.Ink)
	ValleyTheme.button(button, ValleyTheme.Gold)
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -14, 0, 130)
	button.TextSize = 11
	button.Visible = false
	local panel, v, v2 = ValleyPanels.panel(p, "Broadcast", 630, 442)
	ValleyTheme.surface(v, ValleyTheme.Ink, ValleyTheme.Gold, 8, 0.45)
	ValleyPanels.text(v, "Eyebrow", "HUSS VALLEY  /  YOUR VOICE", 24, 20, 480, 20, 11, ValleyTheme.Gold)
	local text = ValleyPanels.text(v, "Heading", "ANNOUNCEMENT", 24, 46, 460, 34, 26, ValleyTheme.Paper)
	text.Font = Enum.Font.GothamBold
	local button2 = ValleyPanels.button(v, "Server", "THIS SERVER", 24, 99, 282, 40, ValleyTheme.Ink)
	ValleyTheme.button(button2, ValleyTheme.Gold)
	local button3 = ValleyPanels.button(v, "Global", "ALL SERVERS", 318, 99, 288, 40, ValleyTheme.Ink)
	ValleyTheme.button(button3, ValleyTheme.Purple)
	ValleyPanels.text(v, "Scope", "Only players in this server will see this.", 24, 151, 580, 28, 13, ValleyTheme.Muted)
	local text_2 = ValleyPanels.text(v, "Sender", "Owner:", 24, 190, 550, 22, 15, ValleyTheme.Gold)
	text_2.Font = Enum.Font.GothamBold
	local v3 = ValleyPanels.make("TextBox", v, "Message", {
		Position = UDim2.fromOffset(24, 220),
		Size = UDim2.fromOffset(582, 98),
		BackgroundColor3 = ValleyTheme.Ink:Lerp(ValleyTheme.Gold, 0.05),
		Text = "",
		PlaceholderText = "Write your announcement…",
		PlaceholderColor3 = ValleyTheme.Muted,
		TextColor3 = ValleyTheme.Paper,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ClearTextOnFocus = false,
		MultiLine = true,
		BorderSizePixel = 0
	})
	ValleyTheme.surface(v3, v3.BackgroundColor3, ValleyTheme.Gold, 5, 0.6)
	ValleyPanels.make("UIPadding", v3, "Padding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10)
	})
	ValleyPanels.text(v, "Count", "0 / 180", 24, 328, 145, 20, 11, ValleyTheme.Muted)
	ValleyPanels.text(v, "Status", "Messages are filtered before sending.", 24, 357, 330, 59, 12, ValleyTheme.Muted)
	local button4 = ValleyPanels.button(v, "Send", "SEND TO SERVER", 366, 370, 240, 46, ValleyTheme.Ink)
	ValleyTheme.button(button4, ValleyTheme.Gold)
	ValleyTheme.button(v2, ValleyTheme.Gold)
	return button, panel, v, v2
end

function AnnouncementView.layout(p, state)
	local absoluteSize = p.AbsoluteSize
	local v

	if absoluteSize.X > absoluteSize.Y then
		v = absoluteSize.Y < 500
	else
		v = false
	end

	local v2 = absoluteSize.X < absoluteSize.Y and 440 or 630
	local v3 = v and 356 or 442
	state.Size = UDim2.fromOffset(v2, v3)
	state.Scale.Scale = math.min(1.1, absoluteSize.X * 0.94 / v2, absoluteSize.Y * 0.92 / v3)
	state.Close.Position = UDim2.fromOffset(v2 - 64, 16)
	local v4 = (v2 - 60) / 2
	state.Server.Size = UDim2.fromOffset(v4, 40)
	state.Global.Size = state.Server.Size
	state.Global.Position = UDim2.fromOffset(36 + v4, 99)
	state.Heading.Size = UDim2.fromOffset(v2 - 110, 34)
	state.Heading.TextSize = v2 < 500 and 22 or 26
	state.Eyebrow.Size = UDim2.fromOffset(v2 - 110, 20)
	state.Scope.Size = UDim2.fromOffset(v2 - 48, 28)
	state.Sender.Position = UDim2.fromOffset(24, v and 180 or 190)
	state.Message.Position = UDim2.fromOffset(24, v and 207 or 220)
	state.Message.Size = UDim2.fromOffset(v2 - 48, v and 65 or 98)
	state.Count.Position = UDim2.fromOffset(24, v and 278 or 328)
	state.Status.Position = UDim2.fromOffset(24, v and 303 or 357)
	state.Status.Size = UDim2.fromOffset(v2 - 306, v and 43 or 59)
	state.Send.Position = UDim2.fromOffset(v2 - 264, v and 291 or 370)
end

return AnnouncementView