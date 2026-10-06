local SavedPreferences = require(game.ReplicatedStorage:WaitForChild("SavedPreferences"))
SavedPreferences.Load()
local v = true
local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local panel = parent.Panel
local general = panel.Pages.General
local music = panel.Pages.Music

local function volume(value)
	local volume2 = math.clamp(value, 0, 0.5)
	localPlayer:SetAttribute("MusicVolume", volume2)

	if not v then
		SavedPreferences.Set("MusicVolume", volume2)
	end

	local backgroundMusic = game.SoundService:FindFirstChild("BackgroundMusic")

	if backgroundMusic then
		backgroundMusic.Volume = volume2
	end

	music.VolumeValue.Text = math.floor(volume2 * 100 + 0.5) .. "%"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function boombox(p)
	localPlayer:SetAttribute("MuteBoomboxMusic", not p)

	if not v then
		SavedPreferences.Set("MuteBoomboxMusic", not p)
	end

	music.BoomboxMusic.Text = "Boombox music: " .. (p and "On" or "Off")
end

music.BoomboxMusic.Activated:Connect(function()
	local muteBoomboxMusic = localPlayer:GetAttribute("MuteBoomboxMusic") == true
	boombox(muteBoomboxMusic) -- equivalent call inferred; original call site unknown
end)
boombox(localPlayer:GetAttribute("MuteBoomboxMusic") ~= true) -- equivalent call inferred; original call site unknown

-- equivalent calls inferred from this helper; original call sites unknown
local function itemSounds(p)
	localPlayer:SetAttribute("MuteItemSounds", not p)

	if not v then
		SavedPreferences.Set("MuteItemSounds", not p)
	end

	music.ItemSounds.Text = "Item sounds: " .. (p and "On" or "Off")
end

music.ItemSounds.Activated:Connect(function()
	local muteItemSounds = localPlayer:GetAttribute("MuteItemSounds") == true
	itemSounds(muteItemSounds) -- equivalent call inferred; original call site unknown
end)
itemSounds(localPlayer:GetAttribute("MuteItemSounds") ~= true) -- equivalent call inferred; original call site unknown

local function size(interfaceScale)
	localPlayer:SetAttribute("InterfaceScale", interfaceScale)

	if not v then
		SavedPreferences.Set("InterfaceScale", interfaceScale)
	end

	for k, v4 in pairs({
		Compact = 0.85,
		Default = 1,
		Large = 1.1
	}) do
		general[k].BackgroundColor3 = interfaceScale == v4 and Color3.fromRGB(73, 97, 131) or Color3.fromRGB(46, 51, 60)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function motion(reducedMotion)
	localPlayer:SetAttribute("ReducedMotion", reducedMotion)

	if not v then
		SavedPreferences.Set("ReducedMotion", reducedMotion)
	end

	general.ReducedMotion.Text = "Reduced motion: " .. (reducedMotion and "On" or "Off")
end

parent.SettingsButton.Activated:Connect(function()
	MenuFade.Set(panel, "Visible", not MenuFade.IsOpen(panel, "Visible"))
end)
panel.Close.Activated:Connect(function()
	MenuFade.Set(panel, "Visible", false)
end)
music.VolumeDown.Activated:Connect(function()
	volume((localPlayer:GetAttribute("MusicVolume") or 0.06) - 0.05)
end)
music.VolumeUp.Activated:Connect(function()
	volume((localPlayer:GetAttribute("MusicVolume") or 0.06) + 0.05)
end)

for k, v4 in pairs({
	Compact = 0.85,
	Default = 1,
	Large = 1.1
}) do
	local v5 = v4
	general[k].Activated:Connect(function()
		size(v5)
	end)
end

general.ReducedMotion.Activated:Connect(function()
	motion(not localPlayer:GetAttribute("ReducedMotion")) -- equivalent call inferred; original call site unknown
end)
general.Reset.Activated:Connect(function()
	volume(0.06)
	size(1)
	motion(false) -- equivalent call inferred; original call site unknown
	boombox(true) -- equivalent call inferred; original call site unknown
	itemSounds(true) -- equivalent call inferred; original call site unknown
end)
local v4 = "General"

local function selectTab(p)
	v4 = p

	for _, v5 in ipairs({ "General", "Map", "Music" }) do
		panel.Pages[v5].Visible = v5 == p
		panel.Tabs[v5].BackgroundColor3 = v5 == p and Color3.fromRGB(73, 97, 131) or Color3.fromRGB(46, 51, 60)
	end
end

for _, v5 in ipairs({ "General", "Map", "Music" }) do
	local v6 = v5
	panel.Tabs[v5].Activated:Connect(function()
		selectTab(v6)
	end)
end

local function box(guiObject, p, p2, p3, p4, value)
	guiObject.AnchorPoint = Vector2.zero
	guiObject.Position = UDim2.fromOffset(p, p2)
	guiObject.Size = UDim2.fromOffset(p3, p4)

	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
		guiObject.TextScaled = false
		guiObject.TextSize = value or 14
	end
end

local function fit()
	local absoluteSize = parent.AbsoluteSize

	if absoluteSize.X < 1 or absoluteSize.Y < 1 then
		return
	end

	local v5 = math.max(240, (math.min(560, absoluteSize.X - 24)))
	local v6 = math.max(180, (math.min(520, absoluteSize.Y - 24)))

	for _, uIScale in panel:GetChildren() do
		if uIScale:IsA("UIScale") then
			uIScale.Scale = 1
		end
	end

	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(v5, v6)
	box(panel.Title, 16, 10, v5 - 88, 36, 24)
	box(panel.Close, v5 - 56, 10, 40, 40, 18)
	box(panel.Tabs, 16, 58, v5 - 32, 40)
	box(panel.Pages, 16, 108, v5 - 32, v6 - 124)
	local v7 = (v5 - 48) / 3

	for i, v8 in ipairs({ "General", "Map", "Music" }) do
		box(panel.Tabs[v8], (i - 1) * (v7 + 8), 0, v7, 40)
	end

	local v8 = v5 - 40
	local v9 = (v8 - 16) / 3
	box(general.SizeLabel, 0, 0, v8, 24)

	for i, v10 in ipairs({ "Compact", "Default", "Large" }) do
		box(general[v10], (i - 1) * (v9 + 8), 32, v9, 40)
	end

	box(general.ReducedMotion, 0, 84, v8, 44)
	box(general.AutoRejoin, 0, 136, v8, 44)
	box(general.Reset, 0, 192, v8, 44)
	general.CanvasSize = UDim2.fromOffset(0, 248)
	box(music.MusicToggle, 0, 0, v8, 44)
	box(music.CurrentTrack, 0, 52, v8, 36, 13)
	box(music.Volume, 0, 96, v8, 24)
	box(music.VolumeDown, 0, 126, 44, 44, 20)
	box(music.VolumeValue, 52, 126, v8 - 104, 44, 16)
	box(music.VolumeUp, v8 - 44, 126, 44, 44, 20)
	box(music.BoomboxMusic, 0, 184, v8, 44)
	box(music.ItemSounds, 0, 236, v8, 44)
	music.CanvasSize = UDim2.fromOffset(0, 292)
	local map = panel.Pages.Map
	box(map.SkyLabel, 0, 0, v8, 24)

	for i, v10 in ipairs({
		"Daylight",
		"Sunset",
		"Night",
		"Misty",
		"GreenScreen"
	}) do
		box(map["Sky_" .. v10], (i - 1) % 3 * (v9 + 8), math.floor((i - 1) / 3) * 48 + 32, v9, 40, 13)
	end

	box(map.GroundLabel, 0, 136, v8, 24)

	for i, v10 in ipairs({
		"Classic",
		"Grass",
		"Sand",
		"Snow",
		"Slate",
		"Marble",
		"GreenScreen"
	}) do
		box(map["Ground_" .. v10], (i - 1) % 3 * (v9 + 8), math.floor((i - 1) / 3) * 48 + 168, v9, 40, 13)
	end

	box(map.Reset, 0, 320, v8, 44)
	map.CanvasSize = UDim2.fromOffset(0, 376)
end

general.Reset.Text = "Reset preferences"
local ViewportLayoutWatch = require(game.ReplicatedStorage:WaitForChild("ViewportLayoutWatch"))
ViewportLayoutWatch.Bind(fit)
parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
selectTab(v4)
volume(localPlayer:GetAttribute("MusicVolume") or 0.06)
size(localPlayer:GetAttribute("InterfaceScale") or 1)
local reducedMotion = localPlayer:GetAttribute("ReducedMotion") == true
motion(reducedMotion) -- equivalent call inferred; original call site unknown
fit()
v = false