local StarterGui = game:GetService("StarterGui")
local flag = true
script.Destroying:Connect(function()
	flag = false
end)
task.spawn(function()
	while flag do
		if pcall(function()
			StarterGui:SetCore("ResetButtonCallback", false)
		end) then
			break
		else
			task.wait(1)
		end
	end
end)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local presentation = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation")
local HudNavigation = require(presentation:WaitForChild("HudNavigation"))
local ValleyHudView = require(presentation:WaitForChild("ValleyHudView"))
local UpdateLogConfig = require(presentation:WaitForChild("UpdateLogConfig"))
local valleyHUD = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ValleyHUD")
ValleyHudView.ensureDrawer(valleyHUD)
local navigation = valleyHUD.DrawerClip.Panel.Navigation
local HudDrawer = require(presentation:WaitForChild("HudDrawer"))
local v = HudDrawer.new(valleyHUD, HudNavigation, ValleyHudView)
local panel = valleyHUD.SettingsShade.Panel
local panel2 = valleyHUD.UpdatesShade.Panel
local v2 = nil
local selectedObject = nil
local v3 = nil
local v4 = nil
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function connect(object, p)
	table.insert(connections, object:Connect(p))
end

local textLabel = Instance.new("TextLabel")
textLabel.Name = "HighPingBadge"
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.Position = UDim2.new(1, -6, 0, 3)
textLabel.Size = UDim2.fromOffset(22, 22)
textLabel.BackgroundColor3 = Color3.fromRGB(211, 65, 58)
textLabel.BorderSizePixel = 0
textLabel.Font = Enum.Font.GothamBlack
textLabel.Text = "!"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.ZIndex = valleyHUD.Servers.ZIndex + 1
textLabel.Parent = valleyHUD.Servers
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(1, 0)
uICorner.Parent = textLabel
local uIStroke = Instance.new("UIStroke")
uIStroke.Color = Color3.fromRGB(255, 243, 212)
uIStroke.Thickness = 1.5
uIStroke.Parent = textLabel

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePingBadge()
	textLabel.Visible = localPlayer:GetAttribute("HighPingWarning") == true
end

connect(localPlayer:GetAttributeChangedSignal("HighPingWarning"), updatePingBadge) -- equivalent call inferred; original call site unknown
updatePingBadge() -- equivalent call inferred; original call site unknown

local function number(value)
	return tostring((math.max(0, (math.floor(value or 0))))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function ready()
	return localPlayer:GetAttribute("ClientReady") == true and not (localPlayer:GetAttribute("ScreenPresentationActive") or localPlayer:GetAttribute("TutorialRouting") or localPlayer:GetAttribute("TutorialSession") or localPlayer:GetAttribute("AdminRefreshActive"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function volume()
	local musicVolume = localPlayer:GetAttribute("MusicVolume")
	return type(musicVolume) == "number" and musicVolume == musicVolume and math.clamp(musicVolume, 0, 1) or 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setVolume(p)
	localPlayer:SetAttribute("MusicVolume", (math.clamp(math.floor(p * 100 + 0.5) / 100, 0, 1)))
end

local function updateSettings()
	local chatNotificationsEnabled = localPlayer:GetAttribute("ChatNotificationsEnabled") ~= false
	panel.ChatNotifications.Text = chatNotificationsEnabled and "ON" or "OFF"
	panel.ChatNotifications.BackgroundColor3 = chatNotificationsEnabled and Color3.fromRGB(65, 87, 68) or Color3.fromRGB(
		36,
		56,
		50
	)
	local privateServerHitboxesEnabled = workspace:GetAttribute("PrivateServerHitboxesEnabled") == true
	panel.ShowHitboxes.Text = privateServerHitboxesEnabled and "ON" or "OFF"
	panel.ShowHitboxes.BackgroundColor3 = privateServerHitboxesEnabled and Color3.fromRGB(65, 87, 68) or Color3.fromRGB(
		36,
		56,
		50
	)
	local privateServerBotsDisabled = workspace:GetAttribute("PrivateServerBotsDisabled") == true
	panel.DisableBots.Text = privateServerBotsDisabled and "ON" or "OFF"
	panel.DisableBots.BackgroundColor3 = privateServerBotsDisabled and Color3.fromRGB(65, 87, 68) or Color3.fromRGB(
		36,
		56,
		50
	)
	local v5 = volume() -- equivalent call inferred; original call site unknown
	local musicMuted = localPlayer:GetAttribute("MusicMuted") == true
	panel.Volume.Text = math.floor(v5 * 100 + 0.5) .. "%"
	panel.MusicSlider.Fill.Size = UDim2.new(v5, 0, 0, 6)
	panel.MusicSlider.Knob.Position = UDim2.fromScale(v5, 0.5)
	panel.Mute.Text = musicMuted and "ON" or "OFF"
	panel.Mute.BackgroundColor3 = musicMuted and Color3.fromRGB(65, 87, 68) or Color3.fromRGB(36, 56, 50)
	local spectatorHints = localPlayer:GetAttribute("SpectatorHints") ~= false
	panel.Hints.Text = spectatorHints and "ON" or "OFF"
	panel.Hints.BackgroundColor3 = spectatorHints and Color3.fromRGB(65, 87, 68) or Color3.fromRGB(36, 56, 50)
end

local function close()
	if not v2 then
		return
	end

	v2 = nil
	v4 = nil
	valleyHUD.SettingsShade.Visible = false
	valleyHUD.UpdatesShade.Visible = false
	localPlayer:SetAttribute("SettingsOpen", nil)
	localPlayer:SetAttribute("UpdateLogOpen", nil)

	if v3 ~= nil then
		pcall(function()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, v3)
		end)
		v3 = nil
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(valleyHUD) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end

local function open(p)
	if not ready() then
		return
	end

	if v2 == p then
		close()
		return
	end

	HudNavigation.opening(p)
	close()
	local success, result = pcall(function()
		return game.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
	end)
	v3 = success and result or nil
	pcall(function()
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)
	selectedObject = GuiService.SelectedObject
	v2 = p
	valleyHUD[p .. "Shade"].Visible = true
	localPlayer:SetAttribute(p == "Settings" and "SettingsOpen" or "UpdateLogOpen", true)
	localPlayer:SetAttribute("SpectateRequestedExit", os.clock())

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GuiService.SelectedObject = valleyHUD[p .. "Shade"].Panel.Close
	end
end

local v5 = {
	"StarterPackOpen",
	"LikeRewardOpen",
	"CreatorPanelOpen",
	"MapVoteOpen",
	"ReleaseCameraForUI",
	"EmoteWheelOpen",
	"AnnouncementComposerOpen",
	"ArmoryOpen",
	"JourneyOpen",
	"ServerBrowserOpen",
	"BalloonOfferOpen",
	"FairPlayNoticeOpen",
	"ConnectionQualityOpen",
	"AdminConsoleActive",
	"ChoiceSpotlightActive"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function otherMenu()
	for _, attributeName in v5 do
		if localPlayer:GetAttribute(attributeName) then
			return true
		end
	end

	return false
end

local function refresh()
	if v2 then
		if ready() then
			-- equivalent call inferred; original call site unknown
			if otherMenu() then
				close()
			end
		else
			close()
		end
	end

	local visible = ready()

	if visible then
		local v7 = otherMenu() -- equivalent call inferred; original call site unknown
		visible = not (v7 or v2 or localPlayer:GetAttribute("Spectating"))
	end

	v:setAvailable(visible)
	navigation.Visible = visible
	local spectate = valleyHUD.Spectate

	if visible then
		if HudNavigation.available.Spectate == true then
			visible = not v:isOpen()
		else
			visible = false
		end
	end

	spectate.Visible = visible
	valleyHUD.Spectate.Active = valleyHUD.Spectate.Visible
	valleyHUD.Spectate.Selectable = valleyHUD.Spectate.Visible
	valleyHUD.Servers.Visible = visible and HudNavigation.available.Servers == true
	valleyHUD.Updates.Visible = visible
	local wallet = valleyHUD.Wallet
	local visible2 = ready()

	if visible2 then
		local v8 = otherMenu() -- equivalent call inferred; original call site unknown
		visible2 = not v8

		if visible2 then
			visible2 = not v2

			if visible2 then
				visible2 = not localPlayer:GetAttribute("Spectating")
			end
		end
	end

	wallet.Visible = visible2
	navigation.CursorHint.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse

	for _, v8 in ValleyHudView.Order do
		local v9 = navigation[v8]
		local visible3 = HudNavigation.available[v8] == true
		v9.Active = visible3 and v:isOpen()
		v9.Selectable = v9.Active
		v9.Caption.TextTransparency = visible3 and 0 or 0.48
		v9.Icon.Visible = visible3
		v9.Accent.BackgroundTransparency = visible3 and 0.18 or 0.8
		v9.BackgroundTransparency = visible3 and 0.12 or 0.38
	end

	local AFK = localPlayer:GetAttribute("AFK") == true
	valleyHUD.AFKToggle.Visible = visible and not v:isOpen()
	valleyHUD.AFKToggle.Active = valleyHUD.AFKToggle.Visible and HudNavigation.available.AFK == true
	valleyHUD.AFKToggle.Selectable = valleyHUD.AFKToggle.Active
	valleyHUD.AFKToggle.Caption.Text = AFK and "AFK ON" or "AFK OFF"
	valleyHUD.AFKToggle.Caption.TextColor3 = AFK and ValleyHudView.Mint or ValleyHudView.Paper
	valleyHUD.AFKToggle.StateDot.Visible = AFK
	valleyHUD.AFKToggle.BackgroundColor3 = AFK and Color3.fromRGB(35, 65, 53) or ValleyHudView.Ink
	valleyHUD.AFKToggle.Caption.TextTransparency = valleyHUD.AFKToggle.Active and 0 or 0.48
	navigation.AFK.Caption.Text = AFK and "AFK · ON" or "AFK · OFF"
	navigation.AFK.StateDot.Visible = AFK
	navigation.AFK.Caption.TextColor3 = AFK and ValleyHudView.Mint or ValleyHudView.Paper
	local v8

	if localPlayer:GetAttribute("MusicMuted") == true then
		v8 = true
	else
		v8 = volume() == 0
	end

	navigation.Music.Caption.Text = v8 and "MUSIC · OFF" or "MUSIC · ON"
	navigation.Music.StateDot.Visible = not v8
	local wallet2 = HudNavigation.wallet
	valleyHUD.Wallet.Coins.Value.Text = not wallet2.loaded and "—" or tostring((math.max(
		0,
		(math.floor(wallet2.coins or 0))
	))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) or "—"
	valleyHUD.Wallet.Gems.Value.Text = wallet2.loaded and tostring((math.max(0, (math.floor(wallet2.gems or 0))))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) or "—"
	updateSettings()
end

for _, v6 in ValleyHudView.Order do
	local v7 = v6
	table.insert(connections, navigation[v6].Activated:Connect(function()
		HudNavigation.activate(v7)
	end))
end

HudNavigation.register("Music", function()
	if volume() ~= 0 then
		localPlayer:SetAttribute("MusicMuted", localPlayer:GetAttribute("MusicMuted") ~= true)
		return
	end

	localPlayer:SetAttribute("MusicVolume", 1)
	localPlayer:SetAttribute("MusicMuted", false)
end)
HudNavigation.setAvailable("Music", true)
table.insert(connections, valleyHUD.AFKToggle.Activated:Connect(function()
	HudNavigation.activate("AFK")
end))
table.insert(connections, valleyHUD.Spectate.Activated:Connect(function()
	HudNavigation.activate("Spectate")
end))
table.insert(connections, valleyHUD.Servers.Activated:Connect(function()
	HudNavigation.activate("Servers")
end))
table.insert(connections, valleyHUD.Updates.Activated:Connect(function()
	open("Updates")
end))
HudNavigation.register("Settings", function()
	open("Settings")
end)
HudNavigation.setAvailable("Settings", true)
table.insert(connections, HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "Settings" and p ~= "Updates" then
		close()
	end
end))
table.insert(connections, panel.ChatNotifications.Activated:Connect(function()
	localPlayer:SetAttribute("ChatNotificationsEnabled", localPlayer:GetAttribute("ChatNotificationsEnabled") == false)
	updateSettings()
end))
table.insert(connections, panel.ShowHitboxes.Activated:Connect(function()
	if workspace:GetAttribute("PrivateServerSettingsOwnerId") ~= localPlayer.UserId then
		return
	end

	local privateServerSettingsEvent = presentation:FindFirstChild("PrivateServerSettingsEvent")

	if privateServerSettingsEvent then
		privateServerSettingsEvent:FireServer(
			"Hitboxes",
			workspace:GetAttribute("PrivateServerHitboxesEnabled") ~= true
		)
	end
end))
connect(workspace:GetAttributeChangedSignal("PrivateServerHitboxesEnabled"), updateSettings) -- equivalent call inferred; original call site unknown
table.insert(connections, panel.DisableBots.Activated:Connect(function()
	if workspace:GetAttribute("PrivateServerSettingsOwnerId") ~= localPlayer.UserId then
		return
	end

	local privateServerSettingsEvent = presentation:FindFirstChild("PrivateServerSettingsEvent")

	if privateServerSettingsEvent then
		privateServerSettingsEvent:FireServer(workspace:GetAttribute("PrivateServerBotsDisabled") ~= true)
	end
end))
table.insert(connections, workspace:GetAttributeChangedSignal("PrivateServerSettingsOwnerId"):Connect(function()
	ValleyHudView.layout(valleyHUD)
	updateSettings()
end))
connect(workspace:GetAttributeChangedSignal("PrivateServerBotsDisabled"), updateSettings) -- equivalent call inferred; original call site unknown
connect(panel.Close.Activated, close) -- equivalent call inferred; original call site unknown
connect(panel2.Close.Activated, close) -- equivalent call inferred; original call site unknown
table.insert(connections, panel.Mute.Activated:Connect(function()
	localPlayer:SetAttribute("MusicMuted", localPlayer:GetAttribute("MusicMuted") ~= true)
end))
table.insert(connections, panel.Hints.Activated:Connect(function()
	localPlayer:SetAttribute("SpectatorHints", localPlayer:GetAttribute("SpectatorHints") == false)
end))
local musicSlider = panel.MusicSlider

-- equivalent calls inferred from this helper; original call sites unknown
local function slide(X)
	setVolume((X - musicSlider.AbsolutePosition.X) / math.max(musicSlider.AbsoluteSize.X, 1)) -- equivalent call inferred; original call site unknown
end

table.insert(connections, musicSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v4 = input
		slide(input.Position.X) -- equivalent call inferred; original call site unknown
	end
end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
	if v4 and (input == v4 or v4.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement) then
		slide(input.Position.X) -- equivalent call inferred; original call site unknown
	end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
	if input == v4 or input.UserInputType == Enum.UserInputType.MouseButton1 then
		v4 = nil
	end
end))
table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
	v4 = nil
end))
table.insert(connections, UserInputService.InputBegan:Connect(function(input)
	if UserInputService:GetFocusedTextBox() then
		return
	end

	if v2 and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
		close()
	elseif v2 == "Settings" and GuiService.SelectedObject == musicSlider then
		if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.DPadLeft then
			setVolume(volume() - 0.05) -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.DPadRight then
			setVolume(volume() + 0.05) -- equivalent call inferred; original call site unknown
		end
	end
end))
local TextService = game:GetService("TextService")
local entries = panel2.Entries
entries:SetAttribute("SelfManagedText", true)
entries.AutomaticCanvasSize = Enum.AutomaticSize.None
entries.Padding.PaddingBottom = UDim.new(0, 0)
entries.Padding.PaddingRight = UDim.new(0.02, 0)
local v6 = {}

for k, entry in UpdateLogConfig.Entries do
	local frame = Instance.new("Frame")
	frame.Name = "Entry" .. k
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = k
	frame.Parent = entries
	local rows = {}

	local function text(name, text2, factor, textColor, p2)
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = name
		textLabel2:SetAttribute("SelfManagedText", true)
		textLabel2.TextScaled = false
		textLabel2.TextWrapped = true
		textLabel2.TextTruncate = Enum.TextTruncate.None
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.TextYAlignment = Enum.TextYAlignment.Top
		textLabel2.BackgroundTransparency = 1
		textLabel2.Font = p2 and Enum.Font.GothamBold or Enum.Font.Gotham
		textLabel2.TextColor3 = textColor
		textLabel2.Text = text2
		textLabel2.Parent = frame
		table.insert(rows, {
			label = textLabel2,
			factor = factor
		})
	end

	text("Date", entry.Date, 0.72, ValleyHudView.Gold, true)
	text("Title", entry.Title, 1.4, ValleyHudView.Paper, true)

	for k2, item in entry.Items do
		text("Note" .. k2, "•  " .. item, 1, Color3.fromRGB(196, 210, 201), false)
	end

	table.insert(v6, {
		card = frame,
		rows = rows
	})
end

local v7 = nil

local function layoutLog()
	local absoluteSize = entries.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 or absoluteSize == v7 then
		return
	end

	v7 = absoluteSize
	local v8 = math.max(1, (math.floor(absoluteSize.Y * 0.045 + 0.5)))
	local v9 = math.max(1, absoluteSize.X * 0.98)
	local v10 = absoluteSize.Y * 0.008
	local v11 = absoluteSize.Y * 0.035
	local total = 0

	for _, v12 in v6 do
		local total2 = 0

		for _, row in v12.rows do
			local label = row.label
			label.TextSize = math.max(1, (math.floor(v8 * row.factor + 0.5)))
			local textSize = TextService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(v9, 1000000))
			row.height = math.max(label.TextSize, textSize.Y) + label.TextSize * 0.15
			row.top = total2
			total2 += row.height + v10
		end

		v12.height = total2
		total += total2
	end

	local v12 = total + (math.max(0, #v6 - 1) * v11 + absoluteSize.Y * 0.02)
	local v13 = math.max(absoluteSize.Y, v12)
	entries.CanvasSize = UDim2.fromScale(0, v13 / absoluteSize.Y)
	entries.List.Padding = UDim.new(v11 / v13, 0)

	for _, v14 in v6 do
		v14.card.Size = UDim2.fromScale(1, v14.height / v13)

		for _, row in v14.rows do
			row.label.Position = UDim2.fromScale(0, row.top / v14.height)
			row.label.Size = UDim2.fromScale(1, row.height / v14.height)
		end
	end
end

connect(entries:GetPropertyChangedSignal("AbsoluteSize"), layoutLog) -- equivalent call inferred; original call site unknown
layoutLog()
panel2.Heading.Text = UpdateLogConfig.Title
local count = 0
local v8 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function clearNotice()
	count += 1

	if v8 then
		v8:Cancel()
		v8 = nil
	end

	valleyHUD.Notice.Visible = false
end

connect(HudNavigation.Opening.Event, clearNotice) -- equivalent call inferred; original call site unknown
table.insert(connections, navigation:GetPropertyChangedSignal("Visible"):Connect(function()
	if not navigation.Visible then
		clearNotice() -- equivalent call inferred; original call site unknown
	end
end))
table.insert(connections, HudNavigation.Notice.Event:Connect(function(text)
	clearNotice() -- equivalent call inferred; original call site unknown

	if not (navigation.Visible and v:isOpen()) then
		return
	end

	local v9 = count
	valleyHUD.Notice.Text = text
	valleyHUD.Notice.TextTransparency = 1
	valleyHUD.Notice.TextStrokeTransparency = 1
	valleyHUD.Notice.Visible = true
	v8 = TweenService:Create(valleyHUD.Notice, TweenInfo.new(0.16), {
		TextTransparency = 0,
		TextStrokeTransparency = 0.4
	})
	v8:Play()
	task.delay(2.6, function()
		if count ~= v9 then
			return
		end

		v8 = TweenService:Create(valleyHUD.Notice, TweenInfo.new(0.3), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		})
		v8:Play()
		task.delay(0.3, function()
			if count == v9 then
				valleyHUD.Notice.Visible = false
			end
		end)
	end)
end))

for _, childName in {
	"Shop",
	"Inventory",
	"Spectate",
	"Journey",
	"AFK",
	"Settings",
	"Music",
	"Servers",
	"Updates"
} do
	local v9 = navigation:FindFirstChild(childName) or valleyHUD:FindFirstChild(childName)

	if not v9 then
		continue
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local v10 = v9

	local function hover(p)
		if v10.Active then
			TweenService:Create(v10, TweenInfo.new(0.12), {
				BackgroundColor3 = p and Color3.fromRGB(29, 51, 47) or ValleyHudView.Ink
			}):Play()
		end
	end

	local hover2 = hover
	table.insert(connections, v9.MouseEnter:Connect(function()
		hover2(true)
	end))
	local v11 = v9
	table.insert(connections, v9.MouseLeave:Connect(function()
		hover(false) -- equivalent call inferred; original call site unknown
	end))
	local v12 = v9
	table.insert(connections, v9.SelectionGained:Connect(function()
		hover(true) -- equivalent call inferred; original call site unknown
	end))
	local v13 = v9
	table.insert(connections, v9.SelectionLost:Connect(function()
		hover(false) -- equivalent call inferred; original call site unknown
	end))
end

for _, v9 in {
	"ClientReady",
	"InMatch",
	"GameRole",
	"ScreenPresentationActive",
	"TutorialRouting",
	"TutorialSession",
	"AdminRefreshActive",
	"Spectating",
	"AFK",
	"MusicMuted",
	"MusicVolume",
	"SpectatorHints",
	"SettingsOpen",
	"UpdateLogOpen"
} do
	connect(localPlayer:GetAttributeChangedSignal(v9), refresh) -- equivalent call inferred; original call site unknown
end

for _, v9 in v5 do
	connect(localPlayer:GetAttributeChangedSignal(v9), refresh) -- equivalent call inferred; original call site unknown
end

table.insert(connections, localPlayer:GetAttributeChangedSignal("InMatch"):Connect(function()
	if localPlayer:GetAttribute("InMatch") then
		close()
	end
end))
connect(UserInputService:GetPropertyChangedSignal("PreferredInput"), refresh) -- equivalent call inferred; original call site unknown
connect(HudNavigation.Changed.Event, refresh) -- equivalent call inferred; original call site unknown
table.insert(connections, valleyHUD:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	ValleyHudView.layout(valleyHUD)
end))

local function updateBoostLabels()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v9 in {
		Coins = { "CoinBoostEndsAt", "AdminCoinBoostEndsAt" },
		Gems = { "GemBoostEndsAt", "AdminGemBoostEndsAt" }
	} do
		local v10 = math.max(localPlayer:GetAttribute(v9[1]) or 0, workspace:GetAttribute(v9[2]) or 0)
		local v11 = (type(v10) ~= "number" or v10 ~= v10 or not (v10 < 1e999)) and 0 or math.max(
			0,
			(math.ceil(v10 - serverTimeNow))
		) or 0
		local label = valleyHUD.Wallet[k].Label
		label.TextScaled = true
		label.TextWrapped = false
		label.Text = v11 > 0 and string.format("%s [2X - %02d:%02d]", k:upper(), math.floor(v11 / 60), v11 % 60) or k:upper()
		local label2 = valleyHUD:FindFirstChild("2x" .. k .. "Timer")

		if not (label2 and label2:IsA("TextLabel")) then
			continue
		end

		local attribute = workspace:GetAttribute(v9[2])
		local v12 = (type(attribute) ~= "number" or attribute ~= attribute or not (attribute < 1e999)) and 0 or math.max(
			0,
			(math.ceil(attribute - serverTimeNow))
		) or 0
		label2.Visible = v12 > 0
		label2.Text = v12 > 0 and string.format("2x %s: %dm %ds", k, math.floor(v12 / 60), v12 % 60) or ""
	end
end

connect(localPlayer:GetAttributeChangedSignal("CoinBoostEndsAt"), updateBoostLabels) -- equivalent call inferred; original call site unknown
connect(localPlayer:GetAttributeChangedSignal("GemBoostEndsAt"), updateBoostLabels) -- equivalent call inferred; original call site unknown
connect(workspace:GetAttributeChangedSignal("AdminCoinBoostEndsAt"), updateBoostLabels) -- equivalent call inferred; original call site unknown
connect(workspace:GetAttributeChangedSignal("AdminGemBoostEndsAt"), updateBoostLabels) -- equivalent call inferred; original call site unknown
local total = 0
local RunService = game:GetService("RunService")
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total >= 0.2 then
		total = 0
		updateBoostLabels()
	end
end))
updateBoostLabels()
ValleyHudView.layout(valleyHUD)
refresh()
script.Destroying:Connect(function()
	close()
	v:destroy()

	for _, connection in connections do
		connection:Disconnect()
	end
end)