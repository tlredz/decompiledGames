local createVector = vector.create
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ValleyPanels = require(script.Parent.ValleyPanels)
local ValleyTheme = require(script.Parent.ValleyTheme)
local NotificationDock = require(script.Parent.NotificationDock)
local MapVoteConfig = require(script.Parent.Parent.Game.MapVoteConfig)
local game2 = script.Parent.Parent.Game
local MapVoteView = {}
MapVoteView.__index = MapVoteView

local function text(p, p2, p3, p4, p5)
	local text2 = ValleyPanels.text(p, p2, p3, 0, 0, 100, 20, p4, p5)
	text2.Active = false
	text2.TextWrapped = false
	text2.TextTruncate = Enum.TextTruncate.AtEnd
	text2.TextStrokeColor3 = ValleyTheme.Ink
	text2.TextStrokeTransparency = 0.45
	return text2
end

function MapVoteView.new(p)
	local gui = ValleyPanels.make("ScreenGui", p, "MapVoteUI", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 73,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	local shade = ValleyPanels.make("Frame", gui, "Shade", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = ValleyTheme.Ink,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		Active = false
	})
	ValleyPanels.fullscreenShade(gui, shade)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "MapVoteBlur"
	blurEffect.Size = 0
	blurEffect.Enabled = false
	blurEffect.Parent = game:GetService("Lighting")
	local panel = ValleyPanels.make("CanvasGroup", gui, "Ballot", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		GroupTransparency = 1,
		Active = false
	})
	ValleyTheme.surface(panel, ValleyTheme.Ink, ValleyTheme.Gold, 8, 1)
	panel.Border.Enabled = false
	panel.ZIndex = 2
	local paper = ValleyTheme.Paper
	local text2 = ValleyPanels.text(panel, "Heading", "Vote for the next map", 0, 0, 100, 20, 17, paper)
	text2.Active = false
	text2.TextWrapped = false
	text2.TextTruncate = Enum.TextTruncate.AtEnd
	text2.TextStrokeColor3 = ValleyTheme.Ink
	text2.TextStrokeTransparency = 0.45
	text2.Font = Enum.Font.GothamBold
	local gold = ValleyTheme.Gold
	local text3 = ValleyPanels.text(panel, "Timer", "12s", 0, 0, 100, 20, 13, gold)
	text3.Active = false
	text3.TextWrapped = false
	text3.TextTruncate = Enum.TextTruncate.AtEnd
	text3.TextStrokeColor3 = ValleyTheme.Ink
	text3.TextStrokeTransparency = 0.45
	text3.Font = Enum.Font.GothamBold
	text3.TextXAlignment = Enum.TextXAlignment.Right
	local button = ValleyPanels.button(panel, "Close", "×", 0, 0, 34, 30)
	ValleyTheme.button(button, ValleyTheme.Muted)
	button.TextSize = 21
	button.BackgroundTransparency = 0.65
	button.Modal = false
	local cards = ValleyPanels.make("ScrollingFrame", panel, "Maps", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = ValleyTheme.Gold,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ClipsDescendants = true
	})
	local muted = ValleyTheme.Muted
	local text4 = ValleyPanels.text(panel, "Footer", "Optional · no votes keeps this map", 0, 0, 100, 20, 11, muted)
	text4.Active = false
	text4.TextWrapped = false
	text4.TextTruncate = Enum.TextTruncate.AtEnd
	text4.TextStrokeColor3 = ValleyTheme.Ink
	text4.TextStrokeTransparency = 0.45
	local reveal = ValleyPanels.make("NumberValue", panel, "Reveal", {
		Value = 0
	})
	local expansion = ValleyPanels.make("NumberValue", panel, "Expansion", {
		Value = 0
	})
	local object = setmetatable({
		gui = gui,
		shade = shade,
		blur = blurEffect,
		expansion = expansion,
		expanded = false,
		panel = panel,
		heading = text2,
		timer = text3,
		cards = cards,
		footer = text4,
		reveal = reveal,
		records = {},
		connections = {},
		signature = "",
		shown = false,
		close = button
	}, MapVoteView)
	table.insert(object.connections, expansion.Changed:Connect(function()
		object:layout()
	end))
	table.insert(object.connections, reveal.Changed:Connect(function()
		object:layout()
	end))
	table.insert(object.connections, gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		object:layout()
	end))
	table.insert(object.connections, UserInputService.InputChanged:Connect(function(input)
		local press = object.press

		if press and (input == press.input or input.UserInputType == Enum.UserInputType.MouseMovement and press.input.UserInputType == Enum.UserInputType.MouseButton1) and (Vector2.new(
			input.Position.X,
			input.Position.Y
		) - press.position).Magnitude > 10 then
			press.dragged = true
		end
	end))
	object:layout()
	return object
end

function MapVoteView:setVisible(p)
	local shown = p == true

	if self.shown == shown then
		return
	end

	self.shown = shown

	if self.tween then
		self.tween:Cancel()
	end

	if shown then
		self.panel.Visible = true
	end

	local tween = TweenService:Create(
		self.reveal,
		TweenInfo.new(shown and 0.24 or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = shown and 1 or 0
		}
	)
	self.tween = tween
	tween.Completed:Once(function(p2)
		if self.tween == tween and p2 == Enum.PlaybackState.Completed then
			self.tween = nil

			if not self.shown then
				self.panel.Visible = false
			end
		end
	end)
	tween:Play()
end

function MapVoteView:setExpanded(p)
	local expanded = p == true
	self.close.Modal = expanded and self.shown

	if self.expanded == expanded then
		return
	end

	self.expanded = expanded
	self.cards.CanvasPosition = Vector2.zero

	if self.expandTween then
		self.expandTween:Cancel()
	end

	self.expandTween = TweenService:Create(
		self.expansion,
		TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = expanded and 1 or 0
		}
	)
	self.expandTween:Play()
end

function MapVoteView:layout()
	local absoluteSize = self.gui.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local value = self.expansion.Value

	local function mix(p, p2)
		return p + (p2 - p) * value
	end

	local v = math.min(420, math.max(280, absoluteSize.X * 0.55), absoluteSize.X - 28)
	local v2 = math.min(940, absoluteSize.X * 0.92)
	local v3 = math.min(530, absoluteSize.Y * 0.84)
	local v4 = v + (v2 - v) * value
	local v5 = 104 + (v3 - 104) * value
	local bottom = NotificationDock.bottom(self.gui.Parent, self.gui)
	local v6 = bottom + ((absoluteSize.Y - v3) / 2 - bottom) * value
	self.panel.Size = UDim2.fromOffset(v4, v5)
	self.panel.Position = UDim2.new(0.5, 0, 0, v6 - 12 * (1 - self.reveal.Value))
	self.panel.GroupTransparency = 1 - self.reveal.Value
	self.panel.BackgroundTransparency = 1 - 0.82 * value
	self.shade.Visible = self.reveal.Value * value > 0.005
	self.shade.Active = false
	self.shade.BackgroundTransparency = 1 - 0.19 * self.reveal.Value * value
	self.blur.Size = (MapVoteConfig.BackgroundBlurSize or 8) * self.reveal.Value * value
	self.blur.Enabled = self.blur.Size > 0.05
	self.close.Modal = self.expanded and self.shown
	self.close.Text = self.expanded and "×" or "↗"
	self.close.Size = UDim2.fromOffset(34 + 6 * value, 30 + 10 * value)
	local v7 = 0 + 18 * value
	self.heading.TextSize = 14 + ((absoluteSize.Y < 450 and 20 or 27) - 14) * value
	self.heading.Position = UDim2.fromOffset(v7 + 2, 4 + 12 * value)
	self.heading.Size = UDim2.fromOffset(v4 - 2 * v7 - 98, 22 + 14 * value)
	self.timer.TextSize = 11 + 3 * value
	self.timer.Position = UDim2.fromOffset(v4 - v7 - 94, 5 + 17 * value)
	self.timer.Size = UDim2.fromOffset(44, 20)
	self.close.Position = UDim2.fromOffset(v4 - v7 - (36 + 4 * value), 0 + 14 * value)
	local v8 = 32 + 36 * value
	local v9 = 54 + (v3 - 111 - 54) * value
	local v10 = v4 - v7 * 2
	self.cards.Position = UDim2.fromOffset(v7, v8)
	self.cards.Size = UDim2.fromOffset(v10, v9)
	self.footer.TextSize = 10 + 2 * value
	self.footer.Position = UDim2.fromOffset(v7 + 2, v5 - (16 + 13 * value))
	self.footer.Size = UDim2.fromOffset(v4 - v7 * 2 - 4, 18)
	local v11 = self.expanded and absoluteSize.X < absoluteSize.Y
	self.cards.ScrollingDirection = v11 and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X
	local v12 = v11 and v10 - 5 or math.max(190, (v10 - 10) / 2)
	local v13 = v11 and math.max(150, (v9 - 12) / 2) or v9 - 4

	for k, record in self.records do
		record.card.Position = v11 and UDim2.fromOffset(0, (k - 1) * (v13 + 10)) or UDim2.fromOffset(
			(k - 1) * (v12 + 10),
			0
		)
		record.card.Size = UDim2.fromOffset(v12, v13)
		record.card.BackgroundTransparency = 0.58 + -0.29999999999999993 * value
		record.preview.Position = UDim2.fromOffset(6 + 4 * value, 25 + -17 * value)
		record.preview.Size = UDim2.fromOffset(32 + (v12 - 20 - 32) * value, 23 + (v13 - 64 - 23) * value)
		local name = record.name
		local v14 = record.badge and 11 or 12
		name.TextSize = v14 + (17 - v14) * value
		record.name.Position = UDim2.fromOffset(8 + 6 * value, 3 + (v13 - 52 - 3) * value)
		record.name.Size = UDim2.fromOffset(v12 - (record.badge and 108 or 28) * (1 - value) - 28 * value, 23)
		record.detail.TextSize = 10 + 2 * value
		record.detail.Position = UDim2.fromOffset(44 + -30 * value, 28 + (v13 - 27 - 28) * value)
		record.detail.Size = UDim2.fromOffset(v12 - (50 + -22 * value), 20)

		if not record.badge then
			continue
		end

		record.badge.Size = UDim2.fromOffset(94 + 44 * value, 18 + 10 * value)
		record.badge.Position = UDim2.fromOffset(v12 - (100 + 46 * value), 3 + 7 * value)
		record.badge.TextSize = 10 + 4 * value
	end

	self.cards.CanvasSize = v11 and UDim2.fromOffset(0, #self.records * (v13 + 10) - 10) or UDim2.fromOffset(
		math.max(0, #self.records * (v12 + 10) - 10),
		0
	)
end

function MapVoteView:preview(state)
	local mapPreviews = game2:FindFirstChild("MapPreviews")
	local child = mapPreviews and mapPreviews:FindFirstChild(state.id)

	if not child or state.previewSource == child then
		return
	end

	state.previewSource = child
	state.preview:ClearAllChildren()
	local clone = child:Clone()
	clone.Parent = state.preview
	local boundingBox, v = clone:GetBoundingBox()
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(
		boundingBox.Position + (createVector(-0.8, 0.8, 1)).Unit * math.max(1, v.Magnitude) * 1.03,
		boundingBox.Position
	)
	camera.Parent = state.preview
	state.preview.CurrentCamera = camera
end

function MapVoteView:build(items)
	for _, record in self.records do
		for _, connection in record.connections do
			connection:Disconnect()
		end

		record.card:Destroy()
	end

	table.clear(self.records)
	self.press = nil

	for _, item in items do
		local color = Color3.new(table.unpack(item.accent))
		local v = ValleyPanels.make("TextButton", self.cards, item.id, {
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Modal = false,
			Active = true,
			BackgroundTransparency = 0.58
		})
		ValleyTheme.surface(v, ValleyTheme.Ink:Lerp(color, 0.07), color, 5, 0.72)
		local preview = ValleyPanels.make("ViewportFrame", v, "Arena", {
			BackgroundColor3 = ValleyTheme.Ink:Lerp(color, 0.12),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = false,
			Ambient = Color3.fromRGB(190, 194, 203),
			LightColor = Color3.fromRGB(255, 240, 215),
			LightDirection = createVector(-1, -1, -0.5)
		})
		local name = item.name
		local paper = ValleyTheme.Paper
		local text2 = ValleyPanels.text(v, "Name", name, 0, 0, 100, 20, 14, paper)
		text2.Active = false
		text2.TextWrapped = false
		text2.TextTruncate = Enum.TextTruncate.AtEnd
		text2.TextStrokeColor3 = ValleyTheme.Ink
		text2.TextStrokeTransparency = 0.45
		text2.Font = Enum.Font.GothamBold
		local muted = ValleyTheme.Muted
		local text3 = ValleyPanels.text(v, "Detail", "Tap to vote", 0, 0, 100, 20, 11, muted)
		text3.Active = false
		text3.TextWrapped = false
		text3.TextTruncate = Enum.TextTruncate.AtEnd
		text3.TextStrokeColor3 = ValleyTheme.Ink
		text3.TextStrokeTransparency = 0.45
		local v3

		if item.limitedTime then
			local color2 = Color3.fromRGB(255, 232, 54)
			v3 = ValleyPanels.text(v, "LimitedTime", "LIMITED TIME", 0, 0, 100, 20, 12, color2)
			v3.Active = false
			v3.TextWrapped = false
			v3.TextTruncate = Enum.TextTruncate.AtEnd
			v3.TextStrokeColor3 = ValleyTheme.Ink
			v3.TextStrokeTransparency = 0.45
			v3.Font = Enum.Font.GothamBold
			v3.TextScaled = false
			v3.TextWrapped = false
			v3.TextTruncate = Enum.TextTruncate.None
			v3.TextXAlignment = Enum.TextXAlignment.Center
			v3.TextYAlignment = Enum.TextYAlignment.Center
			v3.TextStrokeTransparency = 0.75
			v3.BackgroundColor3 = ValleyTheme.Ink
			v3.BackgroundTransparency = 0.3
			v3.ZIndex = 5
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0.25, 0)
			uICorner.Parent = v3
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = Color3.fromRGB(255, 232, 54)
			uIStroke.Thickness = 1
			uIStroke.Transparency = 0.45
			uIStroke.Parent = v3
		end

		local v4 = {
			id = item.id,
			name = text2,
			detail = text3,
			badge = v3,
			card = v,
			preview = preview,
			color = color,
			connections = {}
		}
		table.insert(v4.connections, v.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.press = {
					input = input,
					button = v,
					position = Vector2.new(input.Position.X, input.Position.Y),
					canvas = self.cards.CanvasPosition
				}
			end
		end))
		local v6 = v
		local v7 = item
		table.insert(v4.connections, v.Activated:Connect(function(p)
			if not self.shown or self.result then
				return
			end

			local press = self.press

			if p and (p.UserInputType == Enum.UserInputType.Touch or p.UserInputType == Enum.UserInputType.MouseButton1) and press and press.button == v6 and (press.dragged or (self.cards.CanvasPosition - press.canvas).Magnitude > 6) then
				return
			end

			if self.onVote then
				self.onVote(v7.id)
			end
		end))
		table.insert(self.records, v4)
		self:preview(v4)
	end

	self:layout()
end

function MapVoteView:render(data, p)
	local signature = ""

	for _, v2 in data.options or {} do
		signature ..= v2.id .. "|" .. v2.name .. "|" .. tostring(v2.limitedTime) .. "|"
	end

	if signature ~= self.signature then
		self.signature = signature
		self:build(data.options or {})
	end

	local v2 = data.votes and data.votes[tostring(p)]
	self.result = data.phase == "Result"

	for _, record in self.records do
		self:preview(record)
		local v3 = self.result and data.winner == record.id and true or not self.result and v2 == record.id
		record.card.Border.Transparency = v3 and 0.18 or 0.72
		record.card.BackgroundColor3 = ValleyTheme.Ink:Lerp(record.color, v3 and 0.2 or 0.07)
		local v4 = (data.counts or {})[record.id] or 0
		local detail = record.detail
		local v5

		if self.result then
			v5 = data.winner == record.id and "NEXT MAP" or "Voting ended"
		else
			v5 = v2 == record.id and "✓ Your vote" or data.current == record.id and "Current map" or "Tap to vote"
		end

		detail.Text = v5 .. " · " .. v4
		record.detail.TextColor3 = v3 and record.color or ValleyTheme.Muted
	end

	self.heading.Text = self.result and "NEXT MAP" or self.expanded and "CHOOSE A MAP" or "Vote for the next map"
	self.footer.Text = self.result and "Taking the lobby with us." or v2 and "Vote counted · tap another map to change" or self.expanded and "Optional · close to explore, then reopen from the top" or "Optional · tap a map to vote · ↗ expand"
end

function MapVoteView.clock(p, p2, p3)
	p.timer.Text = p3 and "PAUSED" or p.result and "✓" or p2 .. "s"
end

function MapVoteView.destroy(data)
	if data.tween then
		data.tween:Cancel()
	end

	if data.expandTween then
		data.expandTween:Cancel()
	end

	data.blur:Destroy()

	for _, connection in data.connections do
		connection:Disconnect()
	end

	for _, record in data.records do
		for _, connection in record.connections do
			connection:Disconnect()
		end
	end

	data.gui:Destroy()
end

return MapVoteView