local ValleyPanels = require(script.Parent.ValleyPanels)
local HudIcons = require(script.Parent.HudIcons)
local ValleyTheme = require(script.Parent.ValleyTheme)
local ValleyHudView = {
	Ink = ValleyTheme.Ink,
	Paper = ValleyTheme.Paper,
	Gold = ValleyTheme.Gold,
	Mint = ValleyTheme.Mint,
	Blue = ValleyTheme.Blue,
	Order = {
		"Shop",
		"Inventory",
		"Journey",
		"AFK",
		"Settings"
	},
	Labels = {
		Shop = "SHOP",
		Inventory = "KNIVES",
		Spectate = "SPECTATE",
		Journey = "JOURNEY",
		AFK = "AFK · OFF",
		Settings = "SETTINGS",
		Music = "MUSIC · ON",
		Servers = "SERVERS",
		Updates = "UPDATE LOG"
	}
}
ValleyHudView.Colors = {
	Shop = ValleyHudView.Gold,
	Inventory = ValleyHudView.Mint,
	Spectate = ValleyHudView.Blue,
	Journey = Color3.fromRGB(190, 171, 235),
	AFK = ValleyHudView.Paper,
	Settings = ValleyHudView.Paper,
	Music = ValleyHudView.Mint,
	Servers = ValleyHudView.Blue,
	Updates = ValleyHudView.Gold
}

local function make(...)
	return ValleyPanels.make(...)
end

function ValleyHudView.tile(p, p2, p3)
	local button = ValleyPanels.button(p, p2, "", 0, 0, p3 and 208 or 100, p3 and 34 or 58, ValleyHudView.Ink)
	button.BackgroundTransparency = 0.12
	button.AutoButtonColor = false
	button.Corner.CornerRadius = UDim.new(0, 5)
	ValleyPanels.stroke(button, Color3.fromRGB(92, 124, 115), 0.62)
	local backgroundColor = ValleyHudView.Colors[p2] or ValleyHudView.Gold
	local v2 = HudIcons.draw(button, p2, backgroundColor)
	v2.Position = UDim2.fromOffset(p3 and 11 or 12, p3 and 5 or 9)

	if p3 then
		v2.Size = UDim2.fromOffset(24, 24)
	end

	local text = ValleyPanels.text(
		button,
		"Caption",
		ValleyHudView.Labels[p2],
		p3 and 44 or 11,
		p3 and 6 or 38,
		p3 and 150 or 84,
		20,
		14,
		ValleyHudView.Paper
	)
	text.Font = Enum.Font.GothamBold
	text.TextWrapped = false
	make("Frame", button, "Accent", {
		Position = UDim2.new(0, 11, 1, -2),
		Size = UDim2.fromOffset(p3 and 186 or 78, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = 0.18
	})
	make("Frame", button, "StateDot", {
		Position = UDim2.new(1, -13, 0, 10),
		Size = UDim2.fromOffset(4, 4),
		BorderSizePixel = 0,
		BackgroundColor3 = backgroundColor,
		Visible = false
	})
	return button
end

local function panel(p, p2, p3, p4, p5, p6)
	local v = make("Frame", p, p2 .. "Shade", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.38,
		BorderSizePixel = 0,
		Visible = false,
		Active = false
	})
	ValleyPanels.fullscreenShade(p, v)
	local v2 = make("Frame", v, "Panel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(p3, p4),
		BackgroundColor3 = ValleyHudView.Ink,
		BorderSizePixel = 0,
		Active = false
	})
	ValleyPanels.corner(v2, 8)
	ValleyPanels.stroke(v2, ValleyHudView.Gold, 0.55)
	make("UIScale", v2, "Scale", {})
	make("Frame", v2, "TopRule", {
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = ValleyHudView.Gold,
		BorderSizePixel = 0
	})
	ValleyPanels.text(v2, "Eyebrow", p6, 24, 20, p3 - 110, 18, 11, ValleyHudView.Gold)
	local text = ValleyPanels.text(v2, "Heading", p5, 24, 44, p3 - 90, 36, 28, ValleyHudView.Paper)
	text.Font = Enum.Font.GothamBold
	local button = ValleyPanels.button(v2, "Close", "×", p3 - 64, 20, 42, 42, ValleyHudView.Ink)
	button.Modal = true
	button.TextSize = 27
	make("Frame", v2, "Rule", {
		Position = UDim2.fromOffset(24, 96),
		Size = UDim2.new(1, -48, 0, 1),
		BackgroundColor3 = ValleyHudView.Gold,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0
	})
	return v2
end

function ValleyHudView.ensureDrawer(instance)
	local panel2 = instance:FindFirstChild("SettingsShade") and instance.SettingsShade:FindFirstChild("Panel")

	if panel2 and not panel2:FindFirstChild("ChatNotifications") then
		ValleyPanels.text(
			panel2,
			"ChatNotificationsLabel",
			"Chat notifications",
			24,
			341,
			280,
			34,
			15,
			ValleyHudView.Paper
		)
		ValleyPanels.button(panel2, "ChatNotifications", "ON", 368, 341, 98, 38, Color3.fromRGB(36, 56, 50))
	end

	if panel2 and not panel2:FindFirstChild("DisableBots") then
		local text_2 = ValleyPanels.text(
			panel2,
			"DisableBotsLabel",
			"Disable bots",
			24,
			341,
			280,
			34,
			15,
			ValleyHudView.Paper
		)
		text_2.Visible = false
		local button_2 = ValleyPanels.button(panel2, "DisableBots", "OFF", 368, 341, 98, 38, Color3.fromRGB(36, 56, 50))
		button_2.Visible = false
		local text_3 = ValleyPanels.text(
			panel2,
			"BotsNote",
			"Lobby: immediate. Matches: next match.",
			24,
			385,
			442,
			30,
			11,
			ValleyHudView.Paper
		)
		text_3.Visible = false
	end

	if panel2 and not panel2:FindFirstChild("ShowHitboxes") then
		local text_4 = ValleyPanels.text(
			panel2,
			"ShowHitboxesLabel",
			"Show hitboxes",
			24,
			423,
			280,
			34,
			15,
			ValleyHudView.Paper
		)
		text_4.Visible = false
		local button_3 = ValleyPanels.button(
			panel2,
			"ShowHitboxes",
			"OFF",
			368,
			423,
			98,
			38,
			Color3.fromRGB(36, 56, 50)
		)
		button_3.Visible = false
	end

	if not instance:FindFirstChild("AFKToggle") then
		local tile = ValleyHudView.tile(instance, "AFK", true)
		tile.Name = "AFKToggle"
		tile.Visible = false
	end

	if not instance:FindFirstChild("Spectate") then
		local tile_2 = ValleyHudView.tile(instance, "Spectate", true)
		tile_2.Visible = false
	end

	local navigation = instance:FindFirstChild("Navigation") or instance:FindFirstChild("DrawerClip") and instance.DrawerClip.Panel:FindFirstChild("Navigation")

	if navigation and navigation:FindFirstChild("Spectate") then
		navigation.Spectate:Destroy()
	end

	for _, childName in { "SettingsShade", "UpdatesShade" } do
		local child = instance:FindFirstChild(childName)

		if child then
			ValleyPanels.fullscreenShade(instance, child)
		end
	end

	if instance:FindFirstChild("DrawerClip") then
		return
	end

	local parent = make("Frame", make("Frame", instance, "DrawerClip", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Active = false
	}), "Panel", {
		BackgroundColor3 = ValleyHudView.Ink,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Visible = false
	})
	ValleyPanels.corner(parent, 8)
	ValleyPanels.stroke(parent, ValleyHudView.Gold, 0.75)
	instance.Navigation.Parent = parent
	local button = ValleyPanels.button(instance, "MenuToggle", "", 8, 100, 52, 58, ValleyHudView.Ink)
	button.BackgroundTransparency = 0.08
	button.AutoButtonColor = false
	button.ZIndex = 3
	button.Corner.CornerRadius = UDim.new(0, 5)
	ValleyPanels.stroke(button, ValleyHudView.Gold, 0.5)
	local text = ValleyPanels.text(button, "Arrow", "›", 0, 1, 52, 34, 28, ValleyHudView.Gold)
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.Font = Enum.Font.GothamBold
	text.ZIndex = 4
	local text2 = ValleyPanels.text(button, "Label", "MENU", 0, 35, 52, 17, 10, ValleyHudView.Paper)
	text2.TextXAlignment = Enum.TextXAlignment.Center
	text2.Font = Enum.Font.GothamBold
	text2.ZIndex = 4
	make("NumberValue", instance, "DrawerReveal", {
		Value = 0
	})
end

function ValleyHudView.positionDrawer(instance)
	local drawerWidth = instance:GetAttribute("DrawerWidth") or 220
	local drawerTop = instance:GetAttribute("DrawerTop") or 90
	local value = instance.DrawerReveal.Value
	instance.DrawerClip.Panel.Position = UDim2.fromOffset(-drawerWidth - 4 + (drawerWidth + 72) * value, drawerTop)
	instance.MenuToggle.Position = UDim2.fromOffset(8, (instance:GetAttribute("DrawerCenter") or 180) - 22)
end

function ValleyHudView.build(p)
	local v = make("ScreenGui", p, "ValleyHUD", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 62,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	local v2 = make("Frame", v, "Navigation", {
		Size = UDim2.fromOffset(208, 232),
		BackgroundTransparency = 1
	})
	make("UIScale", v2, "Scale", {})

	for k, v3 in ValleyHudView.Order do
		local tile_2 = ValleyHudView.tile(v2, v3)
		tile_2.Position = UDim2.fromOffset((k - 1) % 2 * 108, math.floor((k - 1) / 2) * 66)
	end

	local tile_3 = ValleyHudView.tile(v2, "Music", true)
	tile_3.Position = UDim2.fromOffset(0, 198)
	local text_2 = ValleyPanels.text(
		v2,
		"CursorHint",
		"ALT  ·  CURSOR",
		0,
		239,
		208,
		16,
		10,
		Color3.fromRGB(194, 210, 202)
	)
	text_2.TextXAlignment = Enum.TextXAlignment.Center
	local v3 = make("Frame", v, "Wallet", {
		Size = UDim2.fromOffset(220, 100),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1)
	})
	make("UIScale", v3, "Scale", {})

	for k, v4 in { "Coins", "Gems" } do
		local v5 = make("Frame", v3, v4, {
			Position = UDim2.fromOffset(0, (k - 1) * 50),
			Size = UDim2.fromOffset(220, 44),
			BackgroundColor3 = ValleyHudView.Ink,
			BackgroundTransparency = 0.24,
			BorderSizePixel = 0
		})
		ValleyPanels.corner(v5, 5)
		ValleyPanels.stroke(v5, v4 == "Coins" and ValleyHudView.Gold or ValleyHudView.Mint, 0.72)
		local draw = HudIcons.draw(v5, v4, v4 == "Coins" and ValleyHudView.Gold or ValleyHudView.Mint)
		draw.Position = UDim2.fromOffset(10, 10)
		local text = ValleyPanels.text(
			v5,
			"Value",
			"—",
			45,
			3,
			166,
			26,
			23,
			v4 == "Coins" and ValleyHudView.Gold or ValleyHudView.Mint
		)
		text.Font = Enum.Font.GothamBold
		text.TextScaled = true
		text.TextWrapped = false
		make("UITextSizeConstraint", text, "TextLimits", {
			MinTextSize = 11,
			MaxTextSize = 23
		})
		ValleyPanels.text(v5, "Label", v4:upper(), 46, 27, 165, 12, 9, Color3.fromRGB(183, 203, 192))
	end

	local tile = ValleyHudView.tile(v, "Servers", true)
	tile.AnchorPoint = Vector2.new(0.2, 0)
	tile.Position = UDim2.fromScale(0.652729392, 0.016025955)
	make("UIScale", tile, "Scale", {})
	local tile2 = ValleyHudView.tile(v, "Updates", true)
	tile2.AnchorPoint = Vector2.new(1, 0)
	make("UIScale", tile2, "Scale", {})
	local text = ValleyPanels.text(v, "Notice", "", 0, 0, 208, 34, 13, ValleyHudView.Paper)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamMedium
	text.TextStrokeColor3 = ValleyHudView.Ink
	text.TextStrokeTransparency = 0.4
	text.Visible = false
	local v4 = panel(v, "Settings", 490, 378, "SETTINGS", "HUSS VALLEY  /  MAKE YOURSELF AT HOME")
	local text_3 = ValleyPanels.text(v4, "MusicLabel", "MUSIC VOLUME", 24, 117, 300, 24, 14, ValleyHudView.Paper)
	text_3.Font = Enum.Font.GothamBold
	local text_4 = ValleyPanels.text(v4, "Volume", "100%", 379, 117, 84, 24, 14, ValleyHudView.Mint)
	text_4.TextXAlignment = Enum.TextXAlignment.Right
	local v5 = make("TextButton", v4, "MusicSlider", {
		Text = "",
		Position = UDim2.fromOffset(24, 152),
		Size = UDim2.fromOffset(442, 44),
		BackgroundTransparency = 1,
		AutoButtonColor = false
	})
	make("Frame", v5, "Track", {
		Position = UDim2.new(0, 0, 0.5, -3),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = Color3.fromRGB(55, 74, 69),
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v5.Track, 3)
	make("Frame", v5, "Fill", {
		Position = v5.Track.Position,
		Size = v5.Track.Size,
		BackgroundColor3 = ValleyHudView.Mint,
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v5.Fill, 3)
	local v6 = make("Frame", v5, "Knob", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = ValleyHudView.Paper,
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v6, 10)
	ValleyPanels.text(v4, "Zero", "0", 24, 194, 40, 16, 10, ValleyHudView.Paper)
	local text_5 = ValleyPanels.text(v4, "Max", "100", 426, 194, 40, 16, 10, ValleyHudView.Paper)
	text_5.TextXAlignment = Enum.TextXAlignment.Right
	ValleyPanels.text(v4, "MuteLabel", "Mute music", 24, 226, 260, 34, 15, ValleyHudView.Paper)
	ValleyPanels.button(v4, "Mute", "OFF", 368, 224, 98, 38, Color3.fromRGB(36, 56, 50))
	ValleyPanels.text(v4, "HintsLabel", "Spectator control hints", 24, 286, 320, 34, 15, ValleyHudView.Paper)
	ValleyPanels.button(v4, "Hints", "ON", 368, 284, 98, 38, Color3.fromRGB(36, 56, 50))
	ValleyPanels.text(v4, "Footer", "Sound effects stay on.", 24, 341, 440, 18, 11, Color3.fromRGB(155, 180, 168))
	local v8 = make(
		"ScrollingFrame",
		panel(v, "Updates", 590, 542, "FIELD NOTES", "HUSS VALLEY  /  UPDATE LOG"),
		"Entries",
		{
			Position = UDim2.fromOffset(24, 113),
			Size = UDim2.new(1, -48, 1, -133),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = ValleyHudView.Gold,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = true,
			ClipsDescendants = true
		}
	)
	make("UIListLayout", v8, "List", {
		Padding = UDim.new(0.025, 0),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	make("UIPadding", v8, "Padding", {
		PaddingBottom = UDim.new(0.02, 0),
		PaddingRight = UDim.new(0.02, 0)
	})
	ValleyHudView.ensureDrawer(v)
	return v
end

function ValleyHudView.layout(instance)
	ValleyHudView.ensureDrawer(instance)
	local absoluteSize = instance.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local v = absoluteSize.Y < 500
	local UserInputService = game:GetService("UserInputService")
	local touchEnabled = UserInputService.TouchEnabled
	local v2 = absoluteSize.X < absoluteSize.Y
	local scale = math.clamp(math.min(absoluteSize.X / 1380, absoluteSize.Y / 760), v and 0.74 or 0.82, 1.15)
	local navigation = instance.DrawerClip.Panel.Navigation

	for k, v4 in ValleyHudView.Order do
		local v5 = navigation[v4]
		v5.Size = UDim2.fromOffset(100, v and 49 or 58)
		v5.Position = UDim2.fromOffset((k - 1) % 2 * 108, math.floor((k - 1) / 2) * (v and 55 or 66))
		v5.Icon.Position = UDim2.fromOffset(12, v and 4 or 9)
		v5.Caption.Position = UDim2.fromOffset(11, v and 28 or 38)
	end

	navigation.Settings.Size = UDim2.fromOffset(208, v and 49 or 58)
	navigation.Settings.Accent.Size = UDim2.fromOffset(186, 2)
	local v4 = v and 165 or 198
	navigation.Music.Position = UDim2.fromOffset(0, v4)
	navigation.Size = UDim2.fromOffset(208, v4 + 34)
	navigation.Scale.Scale = scale
	navigation.Position = UDim2.fromOffset(12, 12)
	local v5 = navigation.Size.X.Offset * scale + 24
	local v6 = (navigation.Size.Y.Offset + (touchEnabled and 0 or 25)) * scale + 24
	local v7 = math.clamp(absoluteSize.Y * 0.38 - 22, 12, (math.max(12, absoluteSize.Y - 290))) + 22
	instance.MenuToggle.Size = UDim2.fromOffset(44, 44)
	instance.MenuToggle.Arrow.Position = UDim2.fromOffset(0, 0)
	instance.MenuToggle.Arrow.Size = UDim2.fromOffset(44, 28)
	instance.MenuToggle.Arrow.TextSize = 24
	instance.MenuToggle.Label.Position = UDim2.fromOffset(0, 28)
	instance.MenuToggle.Label.Size = UDim2.fromOffset(44, 14)
	instance.MenuToggle.Label.TextSize = 8
	local v8 = math.max(58, (math.min(v7 - v6 * 0.5, absoluteSize.Y - v6 - 16)))
	instance.DrawerClip.Panel.Size = UDim2.fromOffset(v5, v6)
	instance:SetAttribute("DrawerWidth", v5)
	instance:SetAttribute("DrawerTop", v8)
	instance:SetAttribute("DrawerCenter", v7)
	ValleyHudView.positionDrawer(instance)
	local aFKToggle = instance.AFKToggle
	aFKToggle.Size = UDim2.fromOffset(44, 44)
	aFKToggle.Position = UDim2.fromOffset(8, v7 + 78)
	aFKToggle.Icon.Size = UDim2.fromOffset(22, 22)
	aFKToggle.Icon.Position = UDim2.fromOffset(11, 4)
	aFKToggle.Caption.Position = UDim2.fromOffset(0, 28)
	aFKToggle.Caption.Size = UDim2.fromOffset(44, 14)
	aFKToggle.Caption.TextSize = 8
	aFKToggle.Caption.TextXAlignment = Enum.TextXAlignment.Center
	aFKToggle.Accent.Visible = false
	aFKToggle.BackgroundTransparency = 0.25
	local spectate = instance.Spectate
	spectate.Size = UDim2.fromOffset(44, 44)
	spectate.Position = UDim2.fromOffset(8, v7 + 128)
	spectate.Icon.Size = UDim2.fromOffset(22, 22)
	spectate.Icon.Position = UDim2.fromOffset(11, 4)
	spectate.Caption.Position = UDim2.fromOffset(0, 28)
	spectate.Caption.Size = UDim2.fromOffset(44, 14)
	spectate.Caption.TextSize = 8
	spectate.Caption.TextXAlignment = Enum.TextXAlignment.Center
	spectate.Accent.Visible = false
	spectate.BackgroundTransparency = 0.25
	navigation.CursorHint.Position = UDim2.fromOffset(0, v4 + 41)
	instance.Wallet.Scale.Scale = scale
	instance.Wallet.Position = UDim2.new(0, 14, 1, -14)

	if v then
		instance.Wallet.Size = UDim2.fromOffset(285, 44)

		for k, v9 in { "Coins", "Gems" } do
			local v10 = instance.Wallet[v9]
			v10.Position = UDim2.fromOffset((k - 1) * 146, 0)
			v10.Size = UDim2.fromOffset(139, 44)
			v10.Value.Size = UDim2.fromOffset(88, 26)
			v10.Value.TextSize = 19
			v10.Label.Size = UDim2.fromOffset(88, 12)
		end
	else
		instance.Wallet.Size = UDim2.fromOffset(220, 100)

		for k, v9 in { "Coins", "Gems" } do
			local v10 = instance.Wallet[v9]
			v10.Position = UDim2.fromOffset(0, (k - 1) * 50)
			v10.Size = UDim2.fromOffset(220, 44)
			v10.Value.Size = UDim2.fromOffset(166, 26)
			v10.Value.TextSize = 23
			v10.Label.Size = UDim2.fromOffset(165, 12)
		end
	end

	if touchEnabled then
		instance.Wallet.Position = UDim2.new(0, v and 125 or 116, 1, v and -32 or -14)

		if not v then
			instance.Wallet.Size = UDim2.fromOffset(180, 100)

			for _, v9 in { "Coins", "Gems" } do
				local v10 = instance.Wallet[v9]
				v10.Size = UDim2.fromOffset(180, 44)
				v10.Value.Size = UDim2.fromOffset(126, 26)
				v10.Label.Size = UDim2.fromOffset(125, 12)
			end
		end
	end

	for _, v9 in { "Servers", "Updates" } do
		local v10 = instance[v9]
		v10.Size = UDim2.fromOffset(164, 38)
		v10.Scale.Scale = scale
		v10.AnchorPoint = Vector2.new(1, 0)
		v10.Caption.Size = UDim2.new(1, -48, 1, -10)
		v10.Accent.Size = UDim2.new(1, -22, 0, 2)
	end

	instance.Updates.Position = UDim2.new(1, -14, 0, 10)
	instance.Servers.Position = UDim2.new(1, -14 - scale * 172, 0, 10)

	if absoluteSize.X < 600 then
		instance.Servers.Position = UDim2.new(1, -14, 0, 10)
		instance.Updates.Position = UDim2.new(1, -14, 0, scale * 46 + 10)
	end

	instance.Notice.Position = UDim2.fromOffset(80, (math.max(4, v8 - 39)))
	instance.Notice.Size = UDim2.fromOffset(v5 - 24, 34)
	instance.Notice.TextSize = v and 12 or 13
	local panel2 = instance.SettingsShade.Panel
	local v9 = v2 and 430 or 490
	local privateServerSettingsOwnerId = workspace:GetAttribute("PrivateServerSettingsOwnerId")
	local visible

	if type(privateServerSettingsOwnerId) == "number" and privateServerSettingsOwnerId > 0 then
		visible = privateServerSettingsOwnerId == game.Players.LocalPlayer.UserId
	else
		visible = false
	end

	panel2.DisableBots.Visible = visible
	panel2.DisableBotsLabel.Visible = visible
	panel2.BotsNote.Visible = visible
	panel2.DisableBots.Position = UDim2.fromOffset(v9 - 122, 401)
	panel2.DisableBotsLabel.Position = UDim2.fromOffset(24, 401)
	panel2.BotsNote.Position = UDim2.fromOffset(24, 445)
	panel2.ChatNotifications.Position = UDim2.fromOffset(v9 - 122, 341)
	panel2.ChatNotificationsLabel.Size = UDim2.fromOffset(v9 - 160, 34)
	panel2.DisableBotsLabel.Size = UDim2.fromOffset(v9 - 160, 34)
	panel2.BotsNote.Size = UDim2.fromOffset(v9 - 48, 30)
	panel2.ShowHitboxes.Visible = visible
	panel2.ShowHitboxesLabel.Visible = visible
	panel2.ShowHitboxes.Position = UDim2.fromOffset(v9 - 122, 483)
	panel2.ShowHitboxesLabel.Position = UDim2.fromOffset(24, 483)
	panel2.ShowHitboxesLabel.Size = UDim2.fromOffset(v9 - 160, 34)
	panel2.Footer.Position = UDim2.fromOffset(24, visible and 537 or 401)
	panel2.Size = UDim2.fromOffset(v9, visible and 574 or 438)
	panel2.Close.Position = UDim2.fromOffset(v9 - 64, 20)
	panel2.Volume.Position = UDim2.fromOffset(v9 - 111, 117)
	panel2.MusicSlider.Size = UDim2.fromOffset(v9 - 48, 44)
	panel2.Max.Position = UDim2.fromOffset(v9 - 64, 194)
	panel2.Mute.Position = UDim2.fromOffset(v9 - 122, 224)
	panel2.Hints.Position = UDim2.fromOffset(v9 - 122, 284)
	panel2.HintsLabel.Size = UDim2.fromOffset(v9 - 160, 34)
	panel2.Footer.Size = UDim2.fromOffset(v9 - 48, 18)
	local panel3 = instance.UpdatesShade.Panel
	panel3.Scale.Scale = 1
	panel3.Size = UDim2.fromScale(
		v2 and 0.92 or touchEnabled and 0.88 or 0.42,
		v2 and 0.78 or touchEnabled and 0.86 or 0.68
	)
	panel3.Eyebrow.Position = UDim2.fromScale(0.045, 0.035)
	panel3.Eyebrow.Size = UDim2.fromScale(0.75, 0.035)
	panel3.Eyebrow.TextScaled = true
	panel3.Heading.Position = UDim2.fromScale(0.045, 0.085)
	panel3.Heading.Size = UDim2.fromScale(0.78, 0.07)
	panel3.Heading.TextScaled = true
	panel3.Close.Position = UDim2.fromScale(0.88, 0.035)
	panel3.Close.Size = UDim2.fromScale(0.08, 0.075)
	panel3.Close.TextScaled = true
	panel3.Rule.Position = UDim2.fromScale(0.045, 0.175)
	panel3.Rule.Size = UDim2.fromScale(0.91, 0.002)
	panel3.TopRule.Size = UDim2.fromScale(1, 0.006)
	panel3.Entries.Position = UDim2.fromScale(0.045, 0.2)
	panel3.Entries.Size = UDim2.fromScale(0.91, 0.76)
	panel3.Entries.ScrollBarThickness = 0
	local offset = panel2.Size.X.Offset
	local offset2 = panel2.Size.Y.Offset
	panel2.Scale.Scale = math.min(1.1, absoluteSize.X * 0.94 / offset, absoluteSize.Y * 0.9 / offset2)
end

return ValleyHudView