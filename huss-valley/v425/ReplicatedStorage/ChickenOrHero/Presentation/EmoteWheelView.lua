local ValleyPanels = require(script.Parent.ValleyPanels)
local ValleyTheme = require(script.Parent.ValleyTheme)
local EmoteWheelView = {}

function EmoteWheelView.build(p)
	local v = ValleyPanels.make("ScreenGui", p, "ValleyEmotes", {
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		DisplayOrder = 72,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	local button = ValleyPanels.button(v, "Open", "", 8, 180, 44, 44, ValleyTheme.Ink)
	ValleyTheme.button(button, ValleyTheme.Purple)
	button.AutoButtonColor = true
	button.BackgroundTransparency = 0.25
	local text = ValleyPanels.text(button, "Face", "☺", 0, 0, 44, 28, 23, ValleyTheme.Purple)
	text.TextXAlignment = Enum.TextXAlignment.Center
	local text_2 = ValleyPanels.text(button, "Label", "EMOTES", 0, 28, 44, 14, 8, ValleyTheme.Paper)
	text_2.TextXAlignment = Enum.TextXAlignment.Center
	local v2 = ValleyPanels.make("Frame", v, "Shade", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = ValleyTheme.Ink,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Visible = false,
		Active = false
	})
	ValleyPanels.fullscreenShade(v, v2)
	local v3 = ValleyPanels.make("Frame", v2, "Wheel", {
		Size = UDim2.fromOffset(600, 600),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1
	})
	ValleyPanels.make("UIScale", v3, "Scale", {})
	ValleyPanels.text(v3, "Eyebrow", "HUSS VALLEY  /  A LITTLE PERSONALITY", 30, 0, 500, 22, 11, ValleyTheme.Purple)
	local text_3 = ValleyPanels.text(v3, "Title", "EMOTES", 30, 24, 420, 38, 29, ValleyTheme.Paper)
	text_3.Font = Enum.Font.GothamBold
	local button2 = ValleyPanels.button(v3, "Close", "×", 526, 12, 44, 44, ValleyTheme.Ink)
	ValleyTheme.button(button2, ValleyTheme.Purple)
	button2.Modal = true
	button2.TextSize = 25
	local v4 = ValleyPanels.make("Frame", v3, "Ring", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(300, 294),
		Size = UDim2.fromOffset(400, 400),
		BackgroundTransparency = 1
	})
	ValleyPanels.corner(v4, 200)
	ValleyPanels.stroke(v4, ValleyTheme.Purple, 0.55)
	local v5 = ValleyPanels.make("Frame", v3, "Center", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = v4.Position,
		Size = UDim2.fromOffset(170, 170),
		BackgroundColor3 = ValleyTheme.Ink,
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v5, 100)
	ValleyPanels.stroke(v5, ValleyTheme.Purple, 0.45)
	local text_4 = ValleyPanels.text(v5, "Glyph", "☺", 10, 12, 150, 48, 36, ValleyTheme.Purple)
	text_4.TextXAlignment = Enum.TextXAlignment.Center
	local text_5 = ValleyPanels.text(v5, "EmoteName", "MAKE YOUR MOVE", 10, 65, 150, 48, 15, ValleyTheme.Paper)
	text_5.TextXAlignment = Enum.TextXAlignment.Center
	local button3 = ValleyPanels.button(v5, "Stop", "STOP EMOTE", 22, 118, 126, 32, ValleyTheme.Ink)
	ValleyTheme.button(button3, ValleyTheme.Purple)
	button3.TextSize = 11
	local result = {}

	for i = 1, 6 do
		local button4 = ValleyPanels.button(v3, "Slot" .. i, "", 0, 0, 146, 80, ValleyTheme.Ink)
		button4.AnchorPoint = Vector2.new(0.5, 0.5)
		ValleyTheme.button(button4, ValleyTheme.Purple)
		ValleyPanels.text(button4, "Number", tostring(i), 10, 6, 20, 18, 10, ValleyTheme.Muted)
		local text_6 = ValleyPanels.text(button4, "Caption", "", 12, 21, 122, 32, 15, ValleyTheme.Paper)
		text_6.TextXAlignment = Enum.TextXAlignment.Center
		local text_7 = ValleyPanels.text(button4, "Source", "", 8, 58, 130, 16, 9, ValleyTheme.Purple)
		text_7.TextXAlignment = Enum.TextXAlignment.Center
		result[i] = button4
	end

	local button4 = ValleyPanels.button(v3, "Previous", "‹", 132, 519, 48, 40, ValleyTheme.Ink)
	ValleyTheme.button(button4, ValleyTheme.Purple)
	button4.TextSize = 26
	local text_8 = ValleyPanels.text(v3, "Page", "1 / 3", 187, 526, 226, 24, 13, ValleyTheme.Paper)
	text_8.TextXAlignment = Enum.TextXAlignment.Center
	local button5 = ValleyPanels.button(v3, "Next", "›", 420, 519, 48, 40, ValleyTheme.Ink)
	ValleyTheme.button(button5, ValleyTheme.Purple)
	button5.TextSize = 26
	local text_9 = ValleyPanels.text(
		v3,
		"Hint",
		"CHOOSE AN EMOTE · MOVE TO STOP",
		40,
		567,
		520,
		20,
		11,
		ValleyTheme.Muted
	)
	text_9.TextXAlignment = Enum.TextXAlignment.Center
	local text_10 = ValleyPanels.text(v3, "Status", "", 40, 591, 520, 28, 12, ValleyTheme.Gold)
	text_10.TextXAlignment = Enum.TextXAlignment.Center
	return v, result
end

function EmoteWheelView.layout(p)
	local absoluteSize = p.AbsoluteSize

	if absoluteSize.X < 1 or absoluteSize.Y < 1 then
		return
	end

	local v

	if absoluteSize.X > absoluteSize.Y then
		v = absoluteSize.Y < 500
	else
		v = false
	end

	local wheel = p.Shade.Wheel
	local v2 = v and 700 or 600
	local v3 = v and 365 or 625
	wheel.Size = UDim2.fromOffset(v2, v3)
	wheel.Scale.Scale = math.min(1.1, absoluteSize.X * 0.96 / v2, absoluteSize.Y * 0.96 / v3)
	wheel.Eyebrow.Visible = not v
	wheel.Title.Position = UDim2.fromOffset(30, v and 5 or 24)
	wheel.Close.Position = UDim2.fromOffset(v2 - 66, v and 5 or 12)
	local vector = Vector2.new(v2 / 2, v and 177 or 294)
	wheel.Ring.Position = UDim2.fromOffset(vector.X, vector.Y)
	wheel.Ring.Size = UDim2.fromOffset(v and 405 or 400, v and 250 or 400)
	wheel.Center.Position = wheel.Ring.Position
	wheel.Center.Size = UDim2.fromOffset(v and 144 or 170, v and 144 or 170)
	wheel.Center.Glyph.Size = UDim2.new(1, -20, 0, v and 30 or 48)
	wheel.Center.EmoteName.Position = UDim2.fromOffset(10, v and 41 or 65)
	wheel.Center.EmoteName.Size = UDim2.new(1, -20, 0, 48)
	wheel.Center.Stop.Position = UDim2.new(0.5, -63, 1, -45)

	for i = 1, 6 do
		local v4 = -1.5707963267948966 + (i - 1) * 3.141592653589793 / 3
		local v5 = wheel["Slot" .. i]
		v5.Position = UDim2.fromOffset(
			vector.X + math.cos(v4) * (v and 232 or 212),
			vector.Y + math.sin(v4) * (v and 103 or 201)
		)
		v5.Size = UDim2.fromOffset(146, v and 70 or 80)
		v5.Caption.Position = UDim2.fromOffset(12, v and 12 or 21)
		v5.Source.Position = UDim2.fromOffset(8, v and 48 or 58)
	end

	local v4 = v and 303 or 519
	wheel.Previous.Position = UDim2.fromOffset(v2 / 2 - 168, v4)
	wheel.Next.Position = UDim2.fromOffset(v2 / 2 + 120, v4)
	wheel.Page.Position = UDim2.fromOffset(v2 / 2 - 113, v4 + 7)
	wheel.Hint.Position = UDim2.fromOffset(v2 / 2 - 260, v and 342 or 567)
	wheel.Hint.Visible = not v
	wheel.Status.Position = UDim2.fromOffset(v2 / 2 - 260, v and 343 or 591)
	wheel.Status.TextSize = v and 10 or 12
end

return EmoteWheelView