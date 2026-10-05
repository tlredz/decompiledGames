local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local concert = ReplicatedStorage:FindFirstChild("Concert")
local module = concert and require(concert)
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Signal = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Signal"))
local SettingsConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("SettingsConfig"))
local SettingsRemotes = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("SettingsRemotes"))
local WinsTrophyFlyEffect = require(ReplicatedStorage:WaitForChild("WinsTrophyFlyEffect"))
local Toggle = require(ReplicatedStorage.UISystems.Components.Toggle)
local Slider = require(ReplicatedStorage.UISystems.Components.Slider)
local SettingsUISystem = {
	SettingChanged = Signal.new(),
	DataLoaded = Signal.new()
}
local localPlayer = Players.LocalPlayer
local flag = false
local v = false
local v2 = {}
local v3 = {}
local soundGroup = SoundService:FindFirstChild("AAMusicVolumeGroup")

if not soundGroup then
	soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "AAMusicVolumeGroup"
	soundGroup.Volume = 1
	soundGroup.Parent = SoundService
end

-- equivalent calls inferred from this helper; original call sites unknown
local function assignToAAGroup(sound)
	sound.SoundGroup = soundGroup
end

local function applyAAVolume(volume)
	localPlayer:SetAttribute("AAMusicVolume", volume)
	soundGroup.Volume = volume

	for _, sound in ipairs(SoundService:GetDescendants()) do
		if not (sound:IsA("Sound") and sound:GetAttribute("IsEventSound") == true) then
			continue
		end

		assignToAAGroup(sound) -- equivalent call inferred; original call site unknown
	end
end

SoundService.DescendantAdded:Connect(function(sound)
	if sound:IsA("Sound") and sound:GetAttribute("IsEventSound") == true then
		assignToAAGroup(sound) -- equivalent call inferred; original call site unknown
	end
end)
local v5 = {
	TrophyEnabled = function(winsTrophyAnimationsEnabled)
		ClientState.WinsTrophyAnimationsEnabled = winsTrophyAnimationsEnabled

		if not winsTrophyAnimationsEnabled then
			WinsTrophyFlyEffect.clearOngoing()
		end
	end,
	MusicAAVolume = function(p)
		applyAAVolume(p / 100)
	end,
	KeycapsVolume = function(p)
		localPlayer:SetAttribute("KeyVolume", p / 100)
	end,
	SpeedrunEnabled = function(speedrunChronoEnabled)
		localPlayer:SetAttribute("SpeedrunChronoEnabled", speedrunChronoEnabled)
	end,
	HideTag = nil,
	HideGiftNotifications = nil,
	MusicConcertVolume = function(p)
		if module then
			module.SetConcertVolume(p / 100)
		end
	end,
	ConcertLyricsEnabled = function(concertLyricsEnabled)
		localPlayer:SetAttribute("ConcertLyricsEnabled", concertLyricsEnabled)
	end
}
local v6 = {
	HasGroupTag = function()
		return localPlayer:GetAttribute("GroupTagKey") ~= nil
	end
}

local function refreshRowVisibility()
	for k, v7 in pairs(SettingsConfig.SETTINGS) do
		local v8 = v7.visibleIf and v6[v7.visibleIf]

		if not v8 then
			continue
		end

		local v9 = v3[k]

		if v9 then
			v9.Instance.Visible = v8()
		end
	end
end

localPlayer:GetAttributeChangedSignal("GroupTagKey"):Connect(refreshRowVisibility)

local function currentValue(p)
	local default = v2[p]

	if default == nil then
		default = SettingsConfig.SETTINGS[p].default
	end

	return default
end

local function set(p, value, p2)
	local v7 = SettingsConfig.SETTINGS[p]

	if not v7 then
		return
	end

	local v8

	if v7.kind == "toggle" then
		v8 = value == true
	elseif type(value) == "number" then
		v8 = SettingsConfig.SnapToStep(v7, value)
	else
		return
	end

	if v2[p] == v8 then
		return
	end

	v2[p] = v8
	local v9 = v5[p]

	if v9 then
		v9(v8)
	end

	if type(ClientState.Data.Settings) ~= "table" then
		ClientState.Data.Settings = {}
	end

	ClientState.Data.Settings[p] = v8

	if not p2 and v then
		SettingsRemotes.SettingsAction:fire(p, v8)
	end

	local v10 = v3[p]

	if v10 then
		v10:Set(v8, true)
	end

	SettingsUISystem.SettingChanged:Fire(p, v8)
end

function SettingsUISystem:Set(p, p2)
	set(p, p2, false)
end

function SettingsUISystem.Get(_, p)
	local default = v2[p]

	if default == nil then
		default = SettingsConfig.SETTINGS[p].default
	end

	return default
end

local function bindExternalAttribute(attributeName, p)
	localPlayer:GetAttributeChangedSignal(attributeName):Connect(function()
		set(p, localPlayer:GetAttribute(attributeName) == true, false)
	end)
end

local v7 = "SpeedrunEnabled"
local v8 = "SpeedrunChronoEnabled"
localPlayer:GetAttributeChangedSignal("SpeedrunChronoEnabled"):Connect(function()
	set(v7, localPlayer:GetAttribute(v8) == true, false)
end)

function SettingsUISystem.OnDataUpdated(_, p)
	if type(p) ~= "table" then
		return
	end

	local v9 = not v
	v = true

	for k, v10 in pairs(SettingsConfig.SETTINGS) do
		local default = p[k]

		if default == nil then
			default = v10.default
		end

		set(k, default, true)
	end

	if v9 then
		SettingsUISystem.DataLoaded:Fire()
	end
end

function SettingsUISystem.IsLoaded(_)
	return v
end

local function findTaggedInGui(tag)
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	for _, v9 in ipairs(CollectionService:GetTagged(tag)) do
		if v9:IsDescendantOf(playerGui) then
			return v9
		end
	end

	return nil
end

local function createTitle(parent, text, layoutOrder)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title_" .. text
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 0.12)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.Text = text
	textLabel.LayoutOrder = layoutOrder
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0.035, 0)
	uIPadding.Parent = textLabel
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(55, 56, 103)
	uIStroke.Thickness = 0.075
	uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	uIStroke.Parent = textLabel
	textLabel.Parent = parent
end

local function buildRows(scrollingFrame)
	local separator = scrollingFrame:FindFirstChild("Separator")

	if separator then
		separator.Visible = false
	end

	local count = 0

	local function nextOrder()
		count += 1
		return count
	end

	for i, v9 in ipairs(SettingsConfig.MAP) do
		if v9.kind == "title" then
			if i > 1 and separator then
				local clone = separator:Clone()
				clone.Name = "Separator_" .. v9.text
				clone.Visible = true
				count += 1
				clone.LayoutOrder = count
				clone.Parent = scrollingFrame
			end

			local text = v9.text
			count += 1
			createTitle(scrollingFrame, text, count)
		elseif v9.kind == "toggle" then
			local v10 = v3
			local key = v9.key
			local create = Toggle.Create
			local v11 = {
				parent = scrollingFrame,
				name = v9.key,
				layoutOrder = 0,
				label = 0,
				initial = 0,
				onChanged = 0
			}
			count += 1
			v11.layoutOrder = count
			v11.label = v9.label
			local key2 = v9.key
			local default = v2[key2]

			if default == nil then
				default = SettingsConfig.SETTINGS[key2].default
			end

			v11.initial = default
			local v12 = v9

			function v11.onChanged(p)
				set(v12.key, p, false)
			end

			v10[key] = create(v11)
		elseif v9.kind == "slider" then
			local v10 = v3
			local key = v9.key
			local create = Slider.Create
			local v11 = {
				parent = scrollingFrame,
				name = v9.key,
				layoutOrder = 0,
				label = 0,
				min = 0,
				max = 0,
				step = 0,
				suffix = 0,
				initial = 0,
				onChanged = 0
			}
			count += 1
			v11.layoutOrder = count
			v11.label = v9.label
			v11.min = v9.min
			v11.max = v9.max
			v11.step = v9.step
			v11.suffix = v9.suffix
			local key2 = v9.key
			local default = v2[key2]

			if default == nil then
				default = SettingsConfig.SETTINGS[key2].default
			end

			v11.initial = default
			local v12 = v9

			function v11.onChanged(p, p2)
				local v13 = v5[v12.key]

				if v13 then
					v13(p)
				end

				if p2 then
					set(v12.key, p, false)
				end
			end

			v10[key] = create(v11)
		end
	end
end

local function setupCanvas(scrollingFrame)
	local uIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")

	if not uIListLayout then
		warn("[SettingsUISystem] UIListLayout introuvable dans la ScrollingFrame")
		return
	end

	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCanvas()
		scrollingFrame.CanvasSize = UDim2.fromOffset(0, uIListLayout.AbsoluteContentSize.Y)
	end

	local function resizeRows()
		local Y = scrollingFrame.AbsoluteSize.Y

		for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local rowScaleY = guiObject:GetAttribute("RowScaleY") or guiObject.Size.Y.Scale

			if not (rowScaleY > 0) then
				continue
			end

			guiObject:SetAttribute("RowScaleY", rowScaleY)
			guiObject.Size = UDim2.new(guiObject.Size.X.Scale, guiObject.Size.X.Offset, 0, (math.round(rowScaleY * Y)))
		end

		updateCanvas() -- equivalent call inferred; original call site unknown
	end

	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
	scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeRows)
	resizeRows()
end

function SettingsUISystem:InitLogic()
	if flag then
		return
	end

	local taggedInGui = findTaggedInGui("SettingsModal")

	if not taggedInGui then
		warn("[SettingsUISystem] Modal taggé 'SettingsModal' introuvable")
		return
	end

	local scrollingFrame = taggedInGui:FindFirstChild("ScrollingFrame")

	if not scrollingFrame then
		warn("[SettingsUISystem] ScrollingFrame introuvable dans le modal Settings")
		return
	end

	flag = true
	buildRows(scrollingFrame)
	setupCanvas(scrollingFrame)

	for _, button in ipairs(CollectionService:GetTagged("SettingsCloseButton")) do
		if button:IsDescendantOf(taggedInGui) and button:IsA("GuiButton") then
			button.Activated:Connect(function()
				ClientState:CloseCurrentModal()
			end)
		end
	end

	refreshRowVisibility()
end

function SettingsUISystem:UpdateDisplay()
	for k, v9 in pairs(v3) do
		local default = v2[k]

		if default == nil then
			default = SettingsConfig.SETTINGS[k].default
		end

		v9:Set(default, true)
	end

	refreshRowVisibility()
end

function SettingsUISystem:ToggleModal()
	self:InitLogic()
	local taggedInGui = findTaggedInGui("SettingsModal")

	if not taggedInGui then
		return
	end

	ClientState:ToggleModal(taggedInGui, self)
	self:UpdateDisplay()
end

local function wireOpenButton(button)
	if not button:IsA("GuiButton") then
		return
	end

	button.Activated:Connect(function()
		SettingsUISystem:ToggleModal()
	end)
end

for _, button in ipairs(CollectionService:GetTagged("SettingsButton")) do
	if button:IsA("GuiButton") then
		button.Activated:Connect(function()
			SettingsUISystem:ToggleModal()
		end)
	end
end

CollectionService:GetInstanceAddedSignal("SettingsButton"):Connect(wireOpenButton)
return SettingsUISystem