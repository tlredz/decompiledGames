local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local rods = require(modules.library.rods)
local locations = require(modules.library.locations)
local NumberUtils = require(utils.NumberUtils)
local Net = require(packages.Net)
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local WorldController = require(legacyControllers.WorldController)
local FischUtils = require(utils.FischUtils)
local BestiaryGrid = require(script.Parent.Parent.BestiaryGrid)
local BestiaryLocations = require(script.Parent.Parent.BestiaryLocations)
local anno_localthought = ReplicatedStorage.events.anno_localthought
local localPlayer = Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local currentWorldIndex = WorldController:GetCurrentWorldIndex()
local remoteEvent = Net:RemoteEvent("RodJournal/ClaimRodReward")
local fishBestiary = script.Parent.FishBestiary
local template = fishBestiary.Template
local locationButton = fishBestiary.LocationButton
local locationDropdown = fishBestiary.LocationDropdown
local dropdownButton = fishBestiary.DropdownButton
local indicator = script.Indicator
local bestiaryNEW = HudController:GetSafeZone().bestiaryNEW
local category = bestiaryNEW.Header.Category
local rod = bestiaryNEW.Rod
local container = rod.Container
local textBox = container.Search.TextBox
local list = container.Scroll.List
local percent = container.Progress.Percent
local display = rod.Display
local list2 = display.List
local desc = list2.Description.desc
local location = list2.Description.location
local view = list2.View
local title = view.Info.title
local stats = view.Stats
local imageLabel = view.ImageLabel
local claimRewards = list2.ClaimRewards
local locations2 = rod.Locations
local list3 = locations2.List
local current = list3.Current
local textBox2 = locations2.Search.TextBox
local color = Color3.fromRGB(35, 35, 35)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(255, 243, 153)

-- equivalent calls inferred from this helper; original call sites unknown
local function connectActivated(button, onActivated)
	if button:IsA("GuiButton") then
		return button.Activated:Connect(onActivated)
	end

	return button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			onActivated()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rodColor(rod2)
	return rod2.Color or color2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isRodDiscovered(p: string)
	return playerDataReplicator:TryIndex({ "Rods", p }) ~= nil
end

local v = {}
local v2 = {}
local connection = nil
local v3 = nil
local v4 = nil
local v5 = "All"
local v6 = nil

for _, rod2 in rods do
	if type(rod2) ~= "table" or rod2.DEV then
		continue
	end

	local from = rod2.From

	if not from or locations[from] then
		continue
	end

	v[from] = (v[from] or 0) + 1
end

for k, v7 in v do
	if v7 >= 2 then
		v2[k] = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveLocation(rod2)
	local from = rod2.From

	if from and (locations[from] or v2[from]) then
		return from
	end

	return "None"
end

local function getRawRods(p: string)
	local result = {}

	for k, rod2 in rods do
		if type(rod2) ~= "table" or rod2.DEV or p ~= "All" and resolveLocation(rod2) ~= p then
			continue
		end

		table.insert(result, k)
	end

	return result
end

local function getRawCountedRods(p: string)
	local result = {}

	for k, rod2 in rods do
		if type(rod2) ~= "table" or (rod2.DEV or rod2.Unregistered) or p ~= "All" and resolveLocation(rod2) ~= p then
			continue
		end

		table.insert(result, k)
	end

	return result
end

local function hasClaimableReward(p: string, rod2)
	if not (rod2.DiscoveryRewards and playerDataReplicator:TryIndex({ "Rods", p }) ~= nil) then
		return false
	end

	local v7 = playerDataReplicator:TryIndex({ "RodJournal", "ClaimedRods" })
	return not (v7 and table.find(v7, p))
end

local function renderRodCard(parent, p: string)
	local rod2 = rods[p]
	local rodDiscovered = isRodDiscovered(p) -- equivalent call inferred; original call site unknown
	parent.title.Text = rodDiscovered and p or "???"
	parent.title.TextColor3 = rodDiscovered and (rod2.Color or color2) or color
	parent.ImageLabel.Image = rod2.Icon or ""
	parent.ImageLabel.ImageColor3 = rodDiscovered and color2 or Color3.fromRGB(0, 0, 0)
	local indicator2 = parent:FindFirstChild("Indicator")

	if hasClaimableReward(p, rod2) then
		if not indicator2 then
			indicator2 = indicator:Clone()
			indicator2.Parent = parent
		end

		indicator2.Visible = true
	elseif indicator2 then
		indicator2:Destroy()
	end
end

local function updateClaimButton(text: string, rod2)
	if connection then
		connection:Disconnect()
		connection = nil
	end

	local v7 = playerDataReplicator:TryIndex({ "RodJournal", "ClaimedRods" })
	local index = v7 and table.find(v7, text)

	if not rod2.DiscoveryRewards or index then
		claimRewards.Visible = false
		return
	end

	claimRewards.Visible = true
	claimRewards.Label.Text = "Claim Rewards"

	local function fn()
		remoteEvent:FireServer(text)
		claimRewards.Visible = false

		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	connection = connectActivated(claimRewards, fn) -- equivalent call inferred; original call site unknown
end

local function selectRod(text: string)
	v3 = text
	local rod2 = rods[text]

	if not rod2 then
		return
	end

	local rodDiscovered = isRodDiscovered(text) -- equivalent call inferred; original call site unknown
	display.Visible = true
	local textColor = rodColor(rod2) -- equivalent call inferred; original call site unknown
	view.Gradient.BackgroundColor3 = rodDiscovered and textColor or color
	view.UIStroke.Color = rodDiscovered and textColor or color
	view.corner.ImageColor3 = rodDiscovered and textColor or color
	local from = rod2.From
	local v8 = from and locations[from]

	if from and from ~= "None" then
		local location2 = location

		if v8 then
			from = v8.Name or from
		end

		location2.Text = `From: {from}`
	else
		location.Text = "From: Unspecified"
	end

	imageLabel.Image = rod2.Icon or ""

	if rodDiscovered then
		title.Text = text
		title.TextColor3 = textColor
		desc.Text = rod2.Description or ""
		imageLabel.ImageColor3 = color2
		stats.Visible = true
		local v9 = (rod2.Lure or 0) + (100 - (rod2.LureSpeed or 0))
		stats.Luck.Text = `Luck: {rod2.Luck or 0}%`
		stats.LureSpeed.Text = `Lure Speed: {v9}%`
		stats.Control.Text = `Control: {math.round((rod2.Control or 0) * 1000) / 1000}`
		stats.Resilience.Text = `Resilience: {rod2.Resilience or 0}%`
		stats.Strength.Text = `Max Kg: {NumberUtils:Comma(rod2.Strength or 0)}kg`
		updateClaimButton(text, rod2)
	else
		title.Text = "???"
		title.TextColor3 = textColor
		desc.Text = rod2.Hint or "???"
		imageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
		stats.Visible = false
		claimRewards.Visible = false

		if connection then
			connection:Disconnect()
			connection = nil
		end
	end
end

local function updateProgress()
	local counted = v4:GetCounted(v5)
	local location2 = locations[v5]
	local name = location2 and location2.Name or v5
	local count = #counted
	local count2 = 0

	for _, v7 in counted do
		if isRodDiscovered(v7) then
			count2 += 1
		end
	end

	percent.Text = `{count > 0 and math.floor(count2 / count * 1000) / 10 or 0}% Completed [{name}]`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildPage(currentLocation: string)
	v5 = currentLocation
	local location2 = locations[currentLocation]
	local v7 = category
	local v9

	if location2 then
		v9 = location2.Name or currentLocation
	else
		v9 = currentLocation
	end

	v7.Text = `[{v9}]`
	v6:SetKeys(v4:GetEntries(currentLocation))
	updateProgress()
end

local function searchPredicate(value: string)
	local text = textBox.Text:lower()
	return text == "" or value:lower():find(text, 1, true) ~= nil
end

local function resolveCurrentLocation()
	local zoneMeta = FischUtils.GetZoneMeta(localPlayer)
	local zone = BestiaryLocations.ResolveZone(zoneMeta.Bestiary)

	if zone then
		return zone
	end

	local zonesAt = FischUtils.GetZonesAt(localPlayer)

	for _, v7 in zonesAt do
		local zone2 = BestiaryLocations.ResolveZone(v7)

		if zone2 then
			return zone2
		end
	end

	return nil
end

return {
	Init = function(_)
		display.Visible = false
		v6 = BestiaryGrid.new({
			scroll = list,
			cardTemplate = template,
			columns = 4,
			widthScale = 0.235,
			heightScale = 0.268,
			columnGapScale = 0.012,
			rowGapScale = 0.0165,
			bottomPaddingScale = 0.0915,
			renderCard = renderRodCard,
			onSelect = selectRod,
			comparator = function(p, p2)
				return p < p2
			end
		})
		local new = BestiaryLocations.new
		local v7 = {
			listFrame = list3,
			currentButton = current,
			searchBox = textBox2,
			buttonTemplate = locationButton,
			dropdownTemplate = locationDropdown,
			dropdownButtonTemplate = dropdownButton,
			getRawEntries = getRawRods,
			getRawCounted = getRawCountedRods,
			isEntryDiscovered = isRodDiscovered,
			entriesGovernAll = true,
			onSelect = buildPage,
			worldIndex = currentWorldIndex,
			supportsLimited = false,
			includeAll = true,
			includeRegionless = true,
			hideEmpty = true,
			extraLocations = 0,
			highlightColor = 0
		}
		local extraLocations = {}

		for k in v2 do
			table.insert(extraLocations, k)
		end

		v7.extraLocations = extraLocations
		v7.highlightColor = color3
		v4 = new(v7)
		v4:SetMode("Base")
		playerDataReplicator:Observe({ "Rods" }, function()
			v6:RefreshVisuals()
			v4:RefreshDiscovery()
			updateProgress()

			if v3 then
				selectRod(v3)
			end
		end)
		playerDataReplicator:Observe({ "RodJournal" }, function()
			v6:RefreshVisuals()

			if v3 then
				selectRod(v3)
			end
		end)
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			v6:ApplySearch(searchPredicate)
		end)
		local button = current

		local function onActivated()
			local currentLocation = resolveCurrentLocation()

			if currentLocation then
				if v5 ~= currentLocation then
					buildPage(currentLocation) -- equivalent call inferred; original call site unknown
				end
			else
				anno_localthought:Fire("Oops! Couldn't find location data for your current location!")
			end
		end

		if button:IsA("GuiButton") then
			button.Activated:Connect(onActivated)
		else
			button.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					onActivated()
				end
			end)
		end

		rod:GetPropertyChangedSignal("Visible"):Connect(function()
			if rod.Visible then
				local location2 = locations[v5]
				category.Text = `[{location2 and location2.Name or v5}]`
				v6:Refresh(true)
			end
		end)
		task.defer(function()
			v6:Refresh(true)
		end)
	end
}