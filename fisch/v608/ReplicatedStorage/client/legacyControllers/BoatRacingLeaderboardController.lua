local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local Net = require(ReplicatedStorage.packages.Net)
local HudController = require(legacyControllers.HudController)
local DropdownController = require(legacyControllers.DropdownController)
local BoatRacingTracks = require(ReplicatedStorage.shared.modules.BoatRacingTracks)
local locations = require(ReplicatedStorage.shared.modules.library.locations)
local remoteEvent = Net:RemoteEvent("JetskiRacing/OpenLeaderboard", -1)
local localPlayer = Players.LocalPlayer
local boatRacing = HudController:GetSafeZone().BoatRacing
local dropdownOverlay = boatRacing.DropdownOverlay
local label = boatRacing.Header.Label
local BG = boatRacing.BG
local container = boatRacing.Main.Container
local scrollingFrame = container.List.ScrollingFrame
local categories = container.Top.Categories
local textBox = container.Top.Search.TextBox
local player = script.Player
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
local v = { Color3.fromRGB(255, 232, 139), Color3.fromRGB(211, 207, 235), Color3.fromRGB(232, 158, 105) }
local v2 = nil
local v3 = ""
local v4 = nil
local v5 = {}

local function toggleOverlay(flag: boolean)
	TweenService:Create(dropdownOverlay, tweenInfo, {
		BackgroundTransparency = flag and 0.15 or 1
	}):Play()
	local uIGradient = dropdownOverlay.UIGradient
	uIGradient.Offset = Vector2.new(0, flag and -0.5 or 0)
	TweenService:Create(uIGradient, tweenInfo, {
		Offset = Vector2.new(0, flag and 0 or -0.5)
	}):Play()
	dropdownOverlay.Active = flag
	dropdownOverlay.Selectable = flag
	dropdownOverlay.Interactable = flag
end

local function applySearch()
	local lower = textBox.Text:match("^%s*(.-)%s*$"):lower()

	for _, frame in scrollingFrame:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = frame:GetAttribute("SearchName"):find(lower, 1, true) ~= nil
		end
	end
end

local function refreshRows()
	for _, frame in scrollingFrame:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	if not v4 then
		return
	end

	local v6 = "RaceBest_" .. v4
	local v7 = {}

	for _, player2 in Players:GetPlayers() do
		local attribute = player2:GetAttribute(v6)

		if typeof(attribute) == "number" then
			table.insert(v7, {
				player = player2,
				time = attribute
			})
		end
	end

	table.sort(v7, function(a, b)
		return a.time < b.time
	end)

	for k, v8 in v7 do
		local clone = player:Clone()
		clone.Name = v8.player.Name
		clone.LayoutOrder = k
		clone:SetAttribute("SearchName", string.lower((`{v8.player.DisplayName} {v8.player.Name}`)))
		clone.Player.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v8.player.UserId}&w=48&h=48`
		local textColor = v[k] or Color3.new(1, 1, 1)
		clone.Player.Label.Text = v8.player.DisplayName
		clone.Player.Label.TextColor3 = textColor
		clone.Rating.Label.Text = `<font size="17" color="#{textColor:ToHex()}"><b>#{k}</b></font> - {string.format("%d:%05.2f", v8.time // 60, v8.time % 60)}`
		clone.Parent = scrollingFrame
	end

	applySearch()
end

local function refreshIfOpen()
	if boatRacing.Visible then
		refreshRows()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTrack(p: string)
	local _ = BoatRacingTracks[p].Name
	local boatRacingTrack = BoatRacingTracks[p]
	local displayName = boatRacingTrack.DisplayName or boatRacingTrack.Name
	local location = locations[displayName]
	v4 = p
	label.Text = `Boat Racing - {displayName}`
	categories.Label.Text = displayName
	BG.Image = not location and "" or location.Banner
	BG.Visible = location ~= nil
	refreshRows()
end

local function getVisibleTracks(p: string)
	local result = {}

	for k, boatRacingTrack in BoatRacingTracks do
		if not boatRacingTrack.Hidden or k == p or localPlayer:GetAttribute("RaceBest_" .. k) ~= nil then
			table.insert(result, k)
		end
	end

	table.sort(result, function(a, b)
		return BoatRacingTracks[a].Name < BoatRacingTracks[b].Name
	end)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTrackName(item: string)
	local boatRacingTrack = BoatRacingTracks[item]
	return boatRacingTrack.DisplayName or boatRacingTrack.Name
end

local function rebuildDropdown(visibleTracks)
	if v2 then
		v2:Hide()
		v2:Destroy()
		v2.Container:Destroy()
	end

	local tabs = {}

	for _, item in visibleTracks do
		local boatRacingTrack = BoatRacingTracks[item]
		local trackName = getTrackName(item) -- equivalent call inferred; original call site unknown
		local location = locations[trackName]
		table.insert(tabs, {
			Name = item,
			DisplayName = trackName,
			Icon = boatRacingTrack.Icon,
			Color = boatRacingTrack.Color,
			Background = location and location.Banner
		})
	end

	local v7 = DropdownController.new({
		Tabs = tabs,
		Parent = categories,
		ScaleWithParent = true
	})
	v7.Switched:Connect(function(p: string, flag: boolean?)
		if flag then
			v7:Hide()
		end

		setTrack(p) -- equivalent call inferred; original call site unknown
	end)
	v7.Toggled:Connect(toggleOverlay)
	v2 = v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackPlayer(p)
	v5[p] = p.AttributeChanged:Connect(function(p2: string)
		if v4 and p2 == "RaceBest_" .. v4 and boatRacing.Visible then
			refreshRows()
		end
	end)
end

local BoatRacingLeaderboardController = {
	Open = function(self, p: string)
		if not BoatRacingTracks[p] then
			return
		end

		local visibleTracks = getVisibleTracks(p)
		local joined = table.concat(visibleTracks, ",")

		if joined ~= v3 then
			v3 = joined
			rebuildDropdown(visibleTracks)
		end

		boatRacing.Visible = true

		if v2 then
			v2:Select(p)
		end
	end
}

function BoatRacingLeaderboardController.Start(_)
	categories.Activated:Connect(function()
		if v2 then
			v2:Toggle()
		end
	end)
	dropdownOverlay.Activated:Connect(function()
		if v2 then
			v2:Hide()
		end
	end)
	boatRacing:GetPropertyChangedSignal("Visible"):Connect(function()
		if not boatRacing.Visible and v2 then
			v2:Hide()
		end
	end)
	textBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

	for _, v6 in Players:GetPlayers() do
		trackPlayer(v6) -- equivalent call inferred; original call site unknown
	end

	Players.PlayerAdded:Connect(trackPlayer)
	Players.PlayerRemoving:Connect(function(player2)
		local connection = v5[player2]

		if connection then
			connection:Disconnect()
			v5[player2] = nil
		end

		task.defer(refreshIfOpen)
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string)
		BoatRacingLeaderboardController:Open(p)
	end)
end

return BoatRacingLeaderboardController