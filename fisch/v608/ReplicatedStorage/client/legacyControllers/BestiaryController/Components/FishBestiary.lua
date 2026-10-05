local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local modules = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
local _ = ReplicatedStorage.shared.data
local modules2 = ReplicatedStorage.client.modules
local legacyControllers = ReplicatedStorage.client.legacyControllers
local Bestiary = require(modules.Bestiary)
local fish = require(modules.library.fish)
local locations = require(modules.library.locations)
local rarities = require(modules.library.rarities)
require(modules.SharedWeather)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local assets = require(utils.assets)
local FischUtils = require(utils.FischUtils)
local ViewportModule = require(modules2.ViewportModule)
local animatedgradient = require(modules.fx.animatedgradient)
local legacyLocalPlayerData = require(modules2.legacyLocalPlayerData)
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local WorldController = require(legacyControllers.WorldController)
local Trove = require(ReplicatedStorage.packages.Trove)
local Replion = require(ReplicatedStorage.packages.Replion)
local BestiaryGrid = require(script.Parent.Parent.BestiaryGrid)
local BestiaryLocations = require(script.Parent.Parent.BestiaryLocations)
local anno_localthought = ReplicatedStorage.events.anno_localthought
local localPlayer = Players.LocalPlayer
local bestiaryReplicator = DataController.BestiaryReplicator
local currentWorldIndex = WorldController:GetCurrentWorldIndex()
local v = Replion.Client:WaitReplion("LimitedStockItems")
local template = script.Template
local locationButton = script.LocationButton
local locationDropdown = script.LocationDropdown
local dropdownButton = script.DropdownButton
local bestiaryNEW = HudController:GetSafeZone().bestiaryNEW
local world = ReplicatedStorage:WaitForChild("world")
local header = bestiaryNEW.Header
local base = header.Base
local limited = header.Limited
local category = header.Category
local fish2 = bestiaryNEW.Fish
local container = fish2.Container
local textBox = container.Search.TextBox
local list = container.Scroll.List
local progress = container.Progress
local percent = progress.Percent
local shinyPercent = progress.MiscProgress.ShinyPercent
local sparklingPercent = progress.MiscProgress.SparklingPercent
local display = fish2.Display
local list2 = display.List
local desc = list2.Description.desc
local location = list2.Description.location
local info = list2.Info
local view = list2.View
local discovered = list2.Discovered
local title = view.Info.title
local rarity = view.Info.rarity
local caught = view.Stats.Caught
local largest = view.Stats.Largest
local givenBy = view.Stats.GivenBy
local sparkling = view.Stats.Sparkling
local specialExists = view.Stats.SpecialExists
local variantToggle = view.VariantToggle
local viewportFrame = view.ViewportFrame
local locations2 = fish2.Locations
local list3 = locations2.List
local current = list3.Current
local textBox2 = locations2.Search.TextBox
local color = Color3.fromRGB(218, 218, 218)
local color2 = Color3.fromRGB(140, 140, 140)
local color3 = Color3.fromRGB(35, 35, 35)
local color4 = Color3.fromRGB(255, 255, 255)
local color5 = Color3.fromRGB(255, 243, 153)
local v2 = "All"
local v3 = nil
local v4 = "Normal"
local maid = Trove.new()
local v5 = {}
local thread = nil
local v6 = nil
local v7 = nil

local function getRarityColor(p: string)
	local v8 = fish[p]
	local v9 = v8 and rarities.Rarities[v8.Rarity]
	return v9 and v9.Color or color4
end

local function applyRarityColor(colors, p: string, rarity2: string?, flag: boolean?)
	animatedgradient.clearold(colors)

	if flag then
		colors[p] = color3
		return
	end

	local v8 = rarity2 and rarities.Rarities[rarity2]

	if v8 and v8.ColorGradient then
		colors[p] = Color3.new(1, 1, 1)
		local new = animatedgradient.new(v8.ColorGradient)
		new.Parent = colors
	else
		colors[p] = v8 and v8.Color or color4
	end
end

local function isHiddenUntilDiscovered(p: string)
	local v8 = fish[p]
	return v8 ~= nil and v8.HideInBestiary == true
end

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
local function formatDate(p: number?)
	if not p or p == 0 then
		return "—"
	end

	local v8 = os.date("!*t", p)
	return string.format("%02i/%02i/%i", v8.month, v8.day, v8.year)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rarityOrder(p: string)
	local v8 = fish[p]
	local v9 = v8 and rarities.Rarities[v8.Rarity]
	return v9 and v9.Order or 1e999
end

local function getRawFish(p: string)
	return Bestiary:GetFishInBestiary(p)
end

local function getRawCounted(p: string)
	return Bestiary:GetCountedFishInBestiary(p)
end

local function isFishDiscovered(p: string, flag: boolean?)
	local v8 = bestiaryReplicator:TryIndex({ "Bestiary", p })

	if not v8 then
		return false
	end

	if flag or v8.GivenBy == nil then
		return true
	end

	return false
end

local function getDiscoveryPercentages(counted)
	local count = #counted

	if count == 0 then
		return 0, 0, 0
	end

	local count2 = 0
	local count3 = 0
	local count4 = 0

	for _, v8 in counted do
		local v9 = bestiaryReplicator:TryIndex({ "Bestiary", v8 })

		if not v9 then
			continue
		end

		count2 += 1

		if v9.Shiny ~= nil then
			count4 += 1
		end

		if v9.Sparkling ~= nil then
			count3 += 1
		end
	end

	return count2 / count * 100, count4 / count * 100, count3 / count * 100
end

local function renderViewModel(p: string, flag: boolean)
	maid:Clean()

	if not viewportFrame then
		return
	end

	local v8

	if v4 == "Shiny" and flag then
		v8 = `Shiny_{p}` or p
	else
		v8 = p
	end

	local async = assets.getAsync("fish", v8)

	if not async and v4 == "Shiny" then
		async = assets.getAsync("fish", p)
	end

	if not async then
		return
	end

	local clone = maid:Clone(async)
	clone.Name = "viewModel"

	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
			part.Material = Enum.Material.Plastic
		end
	end

	clone.Parent = viewportFrame
	local currentCamera = maid:Add(Instance.new("Camera"))
	currentCamera.Parent = viewportFrame
	viewportFrame.CurrentCamera = currentCamera
	viewportFrame.Ambient = color
	viewportFrame.LightColor = color2
	viewportFrame.ImageColor3 = flag and color4 or Color3.new(0, 0, 0)
	local v10 = ViewportModule.new(viewportFrame, currentCamera)
	local boundingBox = clone:GetBoundingBox()
	v10:SetModel(clone)
	local v11 = fish[p]
	local viewportSizeOffset = v11 and v11.ViewportSizeOffset or 1
	local v12 = v10:GetFitDistance(boundingBox.Position) * viewportSizeOffset
	local total = 0
	maid:Connect(RunService.RenderStepped, function(p2)
		total += 0.3490658503988659 * p2
		currentCamera.CFrame = CFrame.new(boundingBox.Position) * CFrame.fromEulerAnglesYXZ(
			0,
			total,
			0.4363323129985824
		) * CFrame.new(0, 0, v12)
	end)
end

local function renderFishCard(p, p2: string)
	local v8 = fish[p2]
	local v9 = bestiaryReplicator:TryIndex({ "Bestiary", p2 }) and true or false
	local rarity2 = v8 and v8.Rarity
	p.title.Text = v9 and p2 or "???"
	applyRarityColor(p.title, "TextColor3", rarity2, not v9)
	p.ImageLabel.Image = v8 and v8.Icon or ""
	p.ImageLabel.ImageColor3 = v9 and color4 or Color3.fromRGB(0, 0, 0)
end

local function clearCardGradient(p)
	animatedgradient.clearold(p.title)
end

local function selectFish(p: string)
	if v3 ~= p then
		v4 = "Normal"
	end

	v3 = p
	local v8 = fish[p]

	if not v8 then
		return
	end

	local v9 = bestiaryReplicator:TryIndex({ "Bestiary", p })
	local v10 = bestiaryReplicator:TryIndex({ "Bestiary", p }) and true or false
	local stats = legacyLocalPlayerData.fetch():WaitForChild("Stats")
	display.Visible = true
	rarity.Text = v8.Rarity or ""
	local rarity2 = v8.Rarity
	applyRarityColor(view.Gradient, "BackgroundColor3", rarity2, not v10)
	applyRarityColor(view.UIStroke, "Color", rarity2, not v10)
	applyRarityColor(view.corner, "ImageColor3", rarity2, not v10)
	applyRarityColor(rarity, "TextColor3", rarity2, not v10)
	local from = v8.From or v8.FromLimited
	local v11 = from and locations[from]

	if from and from ~= "None" and v11 then
		location.Text = `Location: {v11.Name}`
	else
		location.Text = "Location: Regionless"
	end

	local rarity3 = rarities.Rarities[rarity2]
	local hasSerial = rarity3 and rarity3.HasSerial
	specialExists.Visible = hasSerial

	if hasSerial then
		specialExists.Text = "Exists: .."
		local expect = nil
		local success, result = pcall(function()
			expect = v:GetExpect({ "Stocks", p })
		end)

		if result then
			warn(result)
		end

		local formatted = `Exists: {expect}`
		specialExists.Text = not success and "?" or formatted
	end

	if v10 then
		title.Text = `[{p}]`
		desc.Text = v8.Description or ""
		info.Visible = true
		info.Bait.Label.Text = `Preferred Bait: <font color="#f0b56d">{type(v8.FavouriteBait) == "table" and table.concat(v8.FavouriteBait, ", ") or v8.FavouriteBait or "Any"}</font>`
		info.Cycle.Label.Text = `Preferred Cycle: <font color="#fff399">{tostring(v8.FavouriteTime or "Any")}</font>`
		info.Season.Label.Text = `Preferred Season: <font color="#d0ff9d">{not v8.Seasons and "Any" or table.concat(v8.Seasons, ", ") or "Any"}</font>`
		info.Weather.Label.Text = `Preferred Weather: <font color="#83c5ff">{v8.Weather and table.concat(v8.Weather, ", ") or "Any"}</font>`

		for _, child in info:GetChildren() do
			local name = child.Name
			local label = child:FindFirstChild("Label")

			if not (label and child.Name ~= "CatchWith") then
				continue
			end

			child.Visible = not label.Text:match("None")

			if not (name == "Weather" and (label.Text:match(world.weather.Value) or label.Text:match("Any")) or name == "Cycle" and (label.Text:match(world.cycle.Value) or label.Text:match("Any")) or name == "Season" and (label.Text:match(world.season.Value) or label.Text:match("Any")) or name == "Bait" and (label.Text:match(stats.bait.Value) or label.Text:match("Any"))) then
				continue
			end

			label.Text ..= " ✅"
		end

		local highestWeight = v9 and v9.HighestWeight
		largest.Text = `Largest: {highestWeight and string.format("%.1f", highestWeight) or "0.0"}kg`
		caught.Text = `Caught: {not (v9 and v9.Total) and 0 or NumberUtils:Comma(v9.Total) or 0}`
		variantToggle.Visible = v9 ~= nil and v9.Shiny ~= nil
		variantToggle.ImageColor3 = v4 == "Shiny" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 243, 153)
		variantToggle.Image = v4 == "Shiny" and "rbxassetid://132902308072948" or "rbxassetid://99606859289147"

		if v4 == "Shiny" and not variantToggle.Visible then
			v4 = "Normal"
		end

		local shiny = v4 == "Shiny" and v9.Shiny or v9 and v9.Discovered
		local discovered2 = discovered
		local v16 = v4 == "Shiny" and " Shiny" or ""
		local v17 = formatDate(shiny) -- equivalent call inferred; original call site unknown
		discovered2.Text = `Discovered{v16}: {v17}`
		discovered.TextColor3 = v4 == "Shiny" and Color3.fromRGB(255, 243, 153) or Color3.fromRGB(200, 200, 200)
		local sparkling2 = v9 and v9.Sparkling
		local sparkling3 = sparkling
		local text

		if sparkling2 then
			local v21 = formatDate(sparkling2) -- equivalent call inferred; original call site unknown
			text = `Sparkling: {v21}` or "?"
		else
			text = "?"
		end

		sparkling3.Text = text
		sparkling.Visible = sparkling2
		local givenBy2 = v9 and v9.GivenBy
		givenBy.Visible = givenBy2

		if givenBy2 then
			local v20 = v5[givenBy2]

			if not v20 then
				local success, result = pcall(function()
					return Players:GetNameFromUserIdAsync(givenBy2)
				end)

				if success and result then
					v5[givenBy2] = result
					v20 = result
				end
			end

			givenBy.Text = `Given By: {v20}`
		end
	else
		title.Text = "???"
		desc.Text = v8.Hint or ""
		info.Visible = false
		caught.Text = "Caught: 0"
		largest.Text = "Largest: ???"
		givenBy.Visible = false
		sparkling.Visible = false
		variantToggle.Visible = false
		discovered.Text = "Discovered: —"
	end

	if thread then
		pcall(task.cancel, thread)
	end

	thread = task.spawn(renderViewModel, p, v10)
end

local function updateProgress()
	local counted = v7:GetCounted(v2)
	local location2 = locations[v2]
	local name = location2 and location2.Name or v2
	local discoveryPercentages, v8, v9 = getDiscoveryPercentages(counted)
	local v10 = math.floor(discoveryPercentages * 10) / 10
	local v11 = math.floor(v8 * 10) / 10
	local v12 = math.floor(v9 * 10) / 10
	percent.Text = `{v10}% Completed [{name}]`
	shinyPercent.Text = `{v11}% Shiny`
	sparklingPercent.Text = `{v12}% Sparkling`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildPage(currentLocation: string)
	v2 = currentLocation
	local location2 = locations[currentLocation]
	local v8 = category
	local v10

	if location2 then
		v10 = location2.Name or currentLocation
	else
		v10 = currentLocation
	end

	v8.Text = `[{v10}]`
	v6:SetKeys(v7:GetEntries(currentLocation))
	updateProgress()
end

local function searchPredicate(value: string)
	local text = textBox.Text:lower()

	if text ~= "" then
		return value:lower():find(text, 1, true) ~= nil
	end

	local v8 = fish[value]
	return v8 == nil or v8.HideInBestiary ~= true
end

local function resolveCurrentLocation()
	local zoneMeta = FischUtils.GetZoneMeta(localPlayer)
	local zone = BestiaryLocations.ResolveZone(zoneMeta.Bestiary)

	if zone then
		return zone
	end

	local zonesAt = FischUtils.GetZonesAt(localPlayer)

	for _, v8 in zonesAt do
		local zone2 = BestiaryLocations.ResolveZone(v8)

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
			renderCard = renderFishCard,
			onSelect = selectFish,
			onUnmount = clearCardGradient,
			comparator = function(p, p2)
				local v8 = rarityOrder(p) -- equivalent call inferred; original call site unknown
				local v9 = rarityOrder(p2) -- equivalent call inferred; original call site unknown

				if v8 == v9 then
					return p < p2
				end

				return v8 < v9
			end
		})
		v7 = BestiaryLocations.new({
			listFrame = list3,
			currentButton = current,
			searchBox = textBox2,
			buttonTemplate = locationButton,
			dropdownTemplate = locationDropdown,
			dropdownButtonTemplate = dropdownButton,
			getRawEntries = getRawFish,
			getRawCounted = getRawCounted,
			isEntryDiscovered = function(p: string)
				if bestiaryReplicator:TryIndex({ "Bestiary", p }) then
					return true
				end

				return false
			end,
			onSelect = buildPage,
			worldIndex = currentWorldIndex,
			supportsLimited = true,
			includeAll = true,
			includeRegionless = true,
			hideEmpty = false,
			highlightColor = color5
		})
		v7:SetMode("Base")
		bestiaryReplicator:Observe({ "Bestiary" }, function()
			v6:ApplySearch(searchPredicate)
			v6:RefreshVisuals()
			v7:RefreshDiscovery()
			updateProgress()

			if v3 then
				selectFish(v3)
			end
		end)
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			v6:ApplySearch(searchPredicate)
		end)
		local button = base

		local function onActivated()
			if v7:GetMode() ~= "Base" then
				v7:SetMode("Base")
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

		local button2 = limited

		local function onActivated2()
			if v7:GetMode() ~= "Limited" then
				v7:SetMode("Limited")
			end
		end

		if button2:IsA("GuiButton") then
			button2.Activated:Connect(onActivated2)
		else
			button2.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					onActivated2()
				end
			end)
		end

		local button3 = variantToggle

		local function onActivated3()
			if not v3 then
				return
			end

			v4 = v4 == "Shiny" and "Normal" or "Shiny"
			selectFish(v3)
		end

		if button3:IsA("GuiButton") then
			button3.Activated:Connect(onActivated3)
		else
			button3.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					onActivated3()
				end
			end)
		end

		local button4 = current

		local function onActivated4()
			local currentLocation = resolveCurrentLocation()

			if currentLocation then
				if v2 ~= currentLocation then
					buildPage(currentLocation) -- equivalent call inferred; original call site unknown
				end
			else
				anno_localthought:Fire("Oops! Couldn't find location data for your current location!")
			end
		end

		if button4:IsA("GuiButton") then
			button4.Activated:Connect(onActivated4)
		else
			button4.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					onActivated4()
				end
			end)
		end

		fish2:GetPropertyChangedSignal("Visible"):Connect(function()
			if fish2.Visible then
				local location2 = locations[v2]
				category.Text = `[{location2 and location2.Name or v2}]`

				if v3 then
					selectFish(v3)
				end

				v6:Refresh(true)
			end
		end)
		task.defer(function()
			v6:Refresh(true)
		end)
	end
}