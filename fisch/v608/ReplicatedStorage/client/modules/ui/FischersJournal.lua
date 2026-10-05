local Players = game:GetService("Players")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("GuiService")
local LocalizationService = game:GetService("LocalizationService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
require(ReplicatedStorage.shared.playerSettings)
require(ReplicatedStorage.shared.playerSettings.Types)
require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local locations = require(ReplicatedStorage.shared.modules.library.locations)
local companions = require(ReplicatedStorage.shared.modules.library.companions)
local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local crewEmblems = require(ReplicatedStorage.shared.modules.library.crewEmblems)
local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
local titles = require(ReplicatedStorage.shared.modules.character.titles)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local ViewportModel = require(ReplicatedStorage.packages.ViewportModel)
local playerStats = require(ReplicatedStorage.shared.playerStats)
local legacyControllers = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
require(legacyControllers.SettingsController)
require(legacyControllers.DataController)
require(ReplicatedStorage.shared.modules.SharedJournal)
local FriendsList = require(ReplicatedStorage.client.modules.FriendsList)
local SharedWish = require(ReplicatedStorage.shared.modules.SharedWish)
local SharedPlayerStats = require(ReplicatedStorage.shared.modules.SharedPlayerStats)
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local NumberUtils = require(ReplicatedStorage.shared.modules.NumberUtils)
local localPlayer = Players.LocalPlayer
local fischersJournal = localPlayer.PlayerGui:WaitForChild("FischersJournal")
local main = fischersJournal:WaitForChild("FischerJournal"):WaitForChild("sections"):WaitForChild("main")
local left = main:WaitForChild("left")
local mainScroll = main:WaitForChild("right"):WaitForChild("mainScroll")
local bestCatches = mainScroll:WaitForChild("bestCatches")
local mostUsed = mainScroll:WaitForChild("mostUsed")
local crewInfo = mainScroll:WaitForChild("crewInfo")
local playerInfo = left:WaitForChild("playerInfo")
local searchBox = left:WaitForChild("tabber"):WaitForChild("searchBox")
local playerlist = fischersJournal:WaitForChild("FischerJournal"):WaitForChild("sections"):WaitForChild("playerlist")
local listSwitch = playerlist:WaitForChild("ScrollingFrame"):WaitForChild("!!listSwitch")
local anno_localthought = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")
local remoteFunction = Net:RemoteFunction("FischersJournal/RequestOnline", -1)
local remoteFunction2 = Net:RemoteFunction("FischersJournal/RequestOffline", -1)
local UI = script:WaitForChild("UI")
local v = nil
local v2 = nil
local FischersJournal = {}
local v3 = Trove.new()
local maid = v3:Extend()
local count = 0

local function addFishModel(parent, itemData)
	local v4 = count
	local v5 = FishModel.Create({
		Name = itemData.Name,
		ItemData = itemData,
		RemoveScripts = true,
		CastShadow = false
	})

	if not v5 then
		return
	end

	if v4 ~= count then
		v5:Destroy()
		return
	end

	maid:Add(v5)
	v5:PivotTo(CFrame.identity)
	local boundingBox, _ = v5:GetBoundingBox()

	if parent:FindFirstChild("Camera") then
		if not parent.CurrentCamera then
			parent.CurrentCamera = parent:FindFirstChild("Camera")
		end
	else
		parent.CurrentCamera = Instance.new("Camera", parent)
	end

	local currentCamera = parent.CurrentCamera
	currentCamera.FieldOfView = 15
	local v6 = ViewportModel.new(parent, currentCamera)
	v6:SetModel(v5)

	if fish[itemData.Name].ViewportSizeOffset then
		local _ = fish[itemData.Name].ViewportSizeOffset
	end

	currentCamera.CFrame = v6:GetMinimumFitCFrame((CFrame.fromOrientation(0, 3.9269908169872414, 0)))
	currentCamera.Focus = boundingBox
	v5.Parent = parent
end

local function loadFishViewportThing(p, p2)
	if not p2 then
		p.Visible = false
		return
	end

	p.icon.fihName.Text = FischUtils.ItemDisplay({
		name = p2.Fish.Name,
		sub = p2.Fish
	}, {
		rich = true,
		rarity_color = true,
		disable_newlines = true
	})

	if p2.Timestamp then
		p.icon.details.date.Text = DateTime.fromUnixTimestamp(p2.Timestamp):FormatLocalTime(
			"ll",
			LocalizationService.RobloxLocaleId
		)
		p.icon.details.date.Visible = true
	else
		p.icon.details.date.Visible = false
	end

	task.spawn(addFishModel, p.icon, p2.Fish)
end

function FischersJournal.loadHighestValueFish()
	local value = bestCatches.value
	local highestValueCatch = v.HighestValueCatch

	if not highestValueCatch then
		value.Visible = false
		return false
	end

	loadFishViewportThing(value, highestValueCatch)
	value.icon.details.value.Text = `C$ {NumberUtils:Comma((math.round(highestValueCatch.Value)))}`
	value.Visible = true
	return true
end

function FischersJournal.loadRarestFish()
	local rarest = bestCatches.smallerEntries.rarest
	local rarestCatch = v.RarestCatch

	if not rarestCatch then
		rarest.Visible = false
		return false
	end

	loadFishViewportThing(rarest, rarestCatch)
	rarest.icon.details.value.Text = `1 in {NumberUtils:Comma((math.round(rarestCatch.Value)))}`
	rarest.Visible = true
	return true
end

function FischersJournal.loadLargestFish()
	local largest = bestCatches.smallerEntries.largest
	local heaviestFish = v.HeaviestFish

	if not heaviestFish then
		largest.Visible = false
		return false
	end

	loadFishViewportThing(largest, heaviestFish)
	largest.icon.details.value.Text = `{NumberUtils:CommaRounded(heaviestFish.Value, 1)} kg`
	largest.Visible = true
	return true
end

function FischersJournal.loadRelativeLargestFish()
	local largestRelative = bestCatches.smallerEntries.largestRelative
	local highestRelativeWeight = v.HighestRelativeWeight

	if not highestRelativeWeight then
		largestRelative.Visible = false
		return false
	end

	loadFishViewportThing(largestRelative, highestRelativeWeight)
	largestRelative.icon.details.value.Text = `{NumberUtils:CommaRounded(highestRelativeWeight.Fish.Weight, 1)} kg ({tonumber(string.format("%.3f", highestRelativeWeight.Value))}×)`
	largestRelative.Visible = true
	return true
end

function FischersJournal.loadMostCaughtFish()
	local mostCaught = bestCatches.smallerEntries.mostCaught
	local mostCaughtFish = v.MostCaughtFish

	if not mostCaughtFish then
		mostCaught.Visible = false
		return false
	end

	local v4 = fish[mostCaughtFish.Name]

	if v4 then
		mostCaught.icon.Image = v4.Icon or ""
		mostCaught.icon.fihName.Text = FischUtils.QuickFishName(mostCaughtFish.Name)
		mostCaught.icon.details.value.Text = `{NumberUtils:Comma(mostCaughtFish.Value)} Caught`
		mostCaught.Visible = true
		return true
	else
		mostCaught.Visible = false
		warn((`[FischersJournal] Unknown most-caught fish "{mostCaughtFish.Name}" in {v2.Username}'s journal`))
		return false
	end
end

function FischersJournal.loadFindings()
	local highestValueFish = FischersJournal.loadHighestValueFish()
	local v4 = FischersJournal.loadRarestFish() or highestValueFish
	local v5 = FischersJournal.loadLargestFish() or v4
	local v6 = FischersJournal.loadRelativeLargestFish() or v5
	bestCatches.Visible = FischersJournal.loadMostCaughtFish() or v6
end

function FischersJournal.loadTopRods()
	local fishingRods = mostUsed:WaitForChild("fishingRods")

	if v.MostUsedRods and #v.MostUsedRods ~= 0 then
		for i = 1, 3 do
			local child = fishingRods:FindFirstChild((`slot{i}`))

			if child then
				local icon = child.icon
				local mostUsedRod = v.MostUsedRods[i]

				if mostUsedRod then
					local rod = rods[mostUsedRod.Name]

					if rod then
						if mostUsedRod.Skin and mostUsedRod.Skin ~= "Default" and RodSkins.RodsSkins[mostUsedRod.Name] and RodSkins.RodsSkins[mostUsedRod.Name][mostUsedRod.Skin] then
							icon.Image = RodSkins.RodsSkins[mostUsedRod.Name][mostUsedRod.Skin].Icon or ""
						else
							icon.Image = rod.Icon or ""
						end

						icon.fihName.Text = mostUsedRod.Name
						icon.BackgroundColor3 = rod.Color:Lerp(Color3.new(), 0.75)
						icon.borderv2.ImageColor3 = rod.Color
						icon.details.value.Text = `{NumberUtils:Comma(mostUsedRod.Catches)} Catches`

						if mostUsedRod.Wished then
							local wishTypeInfo = SharedWish.GetWishTypeInfo(mostUsedRod.Wished)

							if wishTypeInfo then
								icon.wished.Image = wishTypeInfo.Icon
								icon.wished.ImageColor3 = wishTypeInfo.Color
								icon.wished:SetAttribute("TooltipColor", wishTypeInfo.Color)
								icon.wished:SetAttribute(
									"TooltipText",
									(`<b>Wished</b> via <b><font color="#{wishTypeInfo.Color:ToHex()}">{wishTypeInfo.DisplayName}</font></b>`)
								)
								icon.wished.Visible = true
							else
								icon.wished.Visible = false
							end
						else
							icon.wished.Visible = false
						end

						child.Visible = true
					else
						child.Visible = false
						warn((`[FischersJournal] Unknown most-used rod "{mostUsedRod.Name}" in {v2.Username}'s journal`))
					end
				else
					child.Visible = false
				end
			else
				warn((`where slot{i}???`))
			end
		end

		mostUsed.fishingRodsHeader.Visible = true
		fishingRods.Visible = true
		mostUsed.rodpad1.Visible = true
		return true
	else
		fishingRods.Visible = false
		mostUsed.fishingRodsHeader.Visible = false
		mostUsed.rodpad1.Visible = false
		return false
	end
end

function FischersJournal.loadTimeLocation()
	local topTimeLocation = v.TopTimeLocation
	local timeSpent = mostUsed.locations.timeSpent

	if not topTimeLocation then
		timeSpent.Visible = false
		return false
	end

	local location = locations[topTimeLocation.Name]
	timeSpent.icon.Image = not location and "rbxassetid://18310847126" or location.Banner or "rbxassetid://18310847126"
	timeSpent.icon.fihName.Text = location and location.Name or topTimeLocation.Name

	if topTimeLocation.Value >= 120 then
		timeSpent.icon.details.value.Text = `{topTimeLocation.Value // 60} hours spent`
	else
		timeSpent.icon.details.value.Text = `{topTimeLocation.Value} minutes spent`
	end

	timeSpent.Visible = true
	return true
end

function FischersJournal.loadCatchesLocation()
	local topCatchLocation = v.TopCatchLocation
	local catches = mostUsed.locations.catches

	if not topCatchLocation then
		catches.Visible = false
		return false
	end

	local location = locations[topCatchLocation.Name]
	catches.icon.Image = not location and "rbxassetid://18310847126" or location.Banner or "rbxassetid://18310847126"
	catches.icon.fihName.Text = location and location.Name or topCatchLocation.Name
	catches.icon.details.value.Text = `{topCatchLocation.Value} Catches`
	catches.Visible = true
	return true
end

function FischersJournal.loadCompanion()
	local companionInfo = v.CompanionInfo
	local companion = mostUsed.companion
	local right = companion.right

	if companionInfo then
		local companion2 = companions.Companions[companionInfo.CompanionType]

		if companion2 then
			if companionInfo.Skin and companionInfo.Skin ~= "Default" and skins.CompanionSkins[companionInfo.CompanionType] and skins.CompanionSkins[companionInfo.CompanionType][companionInfo.Skin] then
				companion.left.icon.Image = skins.CompanionSkins[companionInfo.CompanionType][companionInfo.Skin].Icon or companion2.Icon or ""
			else
				companion.left.icon.Image = companion2.Icon or ""
			end

			right.row1.displayName.Text = `"{companionInfo.DisplayName or companionInfo.Skin ~= "Default" and companionInfo.Skin or `{v2.DisplayName}'s {companionInfo.CompanionType}`} "`
			right.row1.level.Text = `Lv. {companionInfo.Level}`
			right.row2.companionName.Text = companionInfo.CompanionType

			if companionInfo.TimeSpent >= 120 then
				right.row3.timeSpent.Text = `{companionInfo.TimeSpent // 60} hours spent`
			else
				right.row3.timeSpent.Text = `{companionInfo.TimeSpent} minutes spent`
			end

			companion.Visible = true
			mostUsed.companionpad.Visible = true
			mostUsed.companionHeader.Visible = true
			return true
		else
			companion.Visible = false
			mostUsed.companionpad.Visible = false
			mostUsed.companionHeader.Visible = false
			warn((`[FischersJournal] Unknown most-used companion "{companionInfo.CompanionType}" in {v2.Username}'s journal`))
			return false
		end
	else
		companion.Visible = false
		mostUsed.companionpad.Visible = false
		mostUsed.companionHeader.Visible = false
		return false
	end
end

function FischersJournal.loadMostUsed()
	local topRods = FischersJournal.loadTopRods()
	local timeLocation = FischersJournal.loadTimeLocation()
	local visible = FischersJournal.loadCatchesLocation() or timeLocation
	local visible2 = FischersJournal.loadCompanion() or visible or topRods
	mostUsed.locations.Visible = visible
	mostUsed.locationsHeader.Visible = visible
	mostUsed.locationpad1.Visible = visible
	mostUsed.locationpad2.Visible = visible
	mostUsed.Visible = visible2
	mainScroll.pad1.Visible = visible2
end

function FischersJournal.loadCrew()
	local crew = v.Crew

	if crew then
		local details = crewInfo.details
		local v4 = crewEmblems.Get(crew.EmblemId)
		details.left.emblem.Image = v4 and v4.Icon or "rbxassetid://73496497242690"
		details.left.emblem.ImageColor3 = crew.Color
		details.right.crewName.Text = crew.Name
		details.right.memberSince.Text = `Member since {DateTime.fromUnixTimestamp(crew.JoinedAt):FormatLocalTime("LL", LocalizationService.RobloxLocaleId)}`
		crewInfo.Visible = true
		mainScroll.pad2.Visible = true
	else
		crewInfo.Visible = false
		mainScroll.pad2.Visible = false
	end
end

function FischersJournal.loadTitle()
	local title = titles[v.Title]
	local title2 = playerInfo.details.row3.title

	if not title or v.Title == "None" then
		title2.Visible = false
		return
	end

	local text = (title.Text or v.Title):gsub("{name}", v2.DisplayName)
	local font = Font.new(
		not title.CustomFont and "rbxasset://fonts/families/SourceSansPro.json" or title.CustomFont.Family or "rbxasset://fonts/families/SourceSansPro.json",
		title.CustomFont and title.CustomFont.Weight or Enum.FontWeight.Regular,
		title.CustomFont and title.CustomFont.Style or Enum.FontStyle.Normal
	)

	if title.Bold and not font.Bold then
		font.Bold = true
	end

	if title.Italic then
		font.Style = Enum.FontStyle.Italic
	end

	title2.FontFace = font

	if title.IsCustom then
		text = `<{text}>` or text
	end

	title2.Text = text

	if title.StrokeColor == Color3.fromRGB(255, 255, 255) then
		title2.UIStroke.Color = Color3.fromRGB(0, 0, 0)
	else
		title2.UIStroke.Color = title.StrokeColor
	end

	local uIGradient = title2.UIGradient

	if typeof(title.TextColor) == "ColorSequence" then
		title2.TextColor3 = Color3.fromRGB(255, 255, 255)
		uIGradient.Color = title.TextColor
		uIGradient.Rotation = title.GradientRotation or 45

		if title.Animated then
			uIGradient:AddTag("AnimatedGradient")
			uIGradient:SetAttribute("AnimationSpeed", title.AnimationSpeed or 1)
		else
			uIGradient:RemoveTag("AnimatedGradient")
		end

		uIGradient.Enabled = true
	else
		title2.TextColor3 = title.TextColor
		uIGradient.Enabled = false
		uIGradient:RemoveTag("AnimatedGradient")
	end

	local uIShadow = title2.UIShadow

	if title.Shadow then
		for k, v5 in title.Shadow do
			uIShadow[k] = v5
		end

		uIShadow.Enabled = true
	else
		uIShadow.Enabled = false
	end

	playerInfo.details.row3.title.Visible = true
end

local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getSearch()
	return searchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")
end

function FischersJournal.updateSearch()
	local search = getSearch() -- equivalent call inferred; original call site unknown

	for k, v5 in v4 do
		k.Visible = search == "" or v5:find(search, 1, true) ~= nil
	end
end

function FischersJournal.addStat(p: string, layoutOrder: number)
	local playerStat = playerStats[p]
	local stat = v.Stats[p]

	if typeof(stat) ~= "number" then
		return
	end

	local formatStat = SharedPlayerStats.FormatStat(p, stat)

	if not formatStat then
		return
	end

	local v5 = false
	local clone

	if playerStat.Aliases then
		clone = table.clone(playerStat.Aliases)
	else
		clone = table.create(1)
	end

	table.insert(clone, playerStat.Name)

	if playerStat.SubstatKey then
		if v.Stats[playerStat.SubstatKey] == nil then
			v5 = false
		else
			v5 = next(v.Stats[playerStat.SubstatKey]) ~= nil
		end

		for k in v.Stats[playerStat.SubstatKey] do
			table.insert(clone, k)
		end
	elseif playerStat.Children then
		for _, v6 in playerStat.Children do
			if not v.Stats[v6] then
				continue
			end

			table.insert(clone, playerStats[v6].Name)
			v5 = true
		end
	end

	local mainstat, v6

	if v5 then
		local v7 = maid:Add(UI.collapsedstatitem:Clone())
		mainstat = v7.mainstat
		local v8 = false

		local function toggle()
			if v7:HasTag("JournalCollapsibleStatExpanded") then
				v7:RemoveTag("JournalCollapsibleStatExpanded")
				return
			end

			v7:AddTag("JournalCollapsibleStatExpanded")

			if playerStat.SubstatKey and not v8 then
				v8 = true

				if playerStat.SubstatKey and v.Stats[playerStat.SubstatKey] then
					local stat2 = v.Stats[playerStat.SubstatKey]
					local search = getSearch() -- equivalent call inferred; original call site unknown
					local v9 = {}

					for k in stat2 do
						table.insert(v9, k)
					end

					if playerStat.SubstatSort == "rarity" then
						table.sort(v9, function(a, b)
							return rarities.Rarities[a].Order < rarities.Rarities[b].Order
						end)
					else
						table.sort(v9)
					end

					for k, v10 in v9 do
						local text

						if typeof(playerStat.SubstatNameFormat) == "string" then
							text = playerStat.SubstatNameFormat:format(v10)
						elseif typeof(playerStat.SubstatNameFormat) == "function" then
							text = playerStat.SubstatNameFormat(v10) or v10
						else
							text = v10
						end

						local clone2 = UI.substatitem:Clone()
						clone2.itemcontent.Text = text
						clone2.statvalue.Text = `  {SharedPlayerStats.FormatStat(p, stat2[v10], true)}`
						clone2.LayoutOrder = k
						local v12 = text:lower():gsub("<.->", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")
						clone2.Visible = search == "" or v12:find(search, 1, true) ~= nil
						clone2.Parent = v7.substats
						v4[clone2] = v12
					end
				end
			end
		end

		if playerStat.Children then
			v7:AddTag("JournalCollapsibleStatExpanded")
			v8 = true
			v6 = v7

			for i, v9 in ipairs(playerStat.Children) do
				local playerStat2 = playerStats[v9]

				if not (playerStat2 and v.Stats[v9]) then
					continue
				end

				local clone2 = UI.substatitem:Clone()
				clone2.itemcontent.Text = playerStat2.Name
				clone2.statvalue.Text = `  {SharedPlayerStats.FormatStat(v9, v.Stats[v9])}`
				clone2.LayoutOrder = i
				clone2.Parent = v7.substats
				v4[clone2] = playerStat2.Name:lower():gsub("<.->", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")
			end
		else
			v6 = v7
		end

		maid:Add(v7.mainstat.Activated:Connect(toggle))
	else
		mainstat = maid:Add(UI.statitem:Clone())
		v6 = mainstat
	end

	mainstat.itemcontent.Text = playerStat.Name
	mainstat.statvalue.Text = "  " .. formatStat

	if layoutOrder % 2 == 0 then
		v6:AddTag("JournalStatEven")
	end

	v6.LayoutOrder = layoutOrder
	v6.Parent = left.statcontents.ScrollingFrame
	v4[v6] = table.concat(clone, " "):lower():gsub("<.->", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")
end

function FischersJournal.loadStats()
	maid:Add(function()
		table.clear(v4)
	end)
	local v5 = {}

	for k, stat in v.Stats do
		if not playerStats[k] or playerStats[k].Parent or typeof(stat) ~= "number" then
			continue
		end

		table.insert(v5, k)
	end

	table.sort(v5)

	for i, v6 in ipairs(v5) do
		FischersJournal.addStat(v6, i)
	end

	FischersJournal.updateSearch()
end

function FischersJournal.loadUserInfo()
	playerInfo.avatarFrame.avatar.Image = `rbxthumb://type=AvatarBust&id={v2.UserId}&w=180&h=180`
	local displayName = v2.DisplayName

	if v2.IsVerified then
		displayName ..= " " .. utf8.char(57344)
	end

	playerInfo.details.row1.displayName.Text = displayName
	playerInfo.details.row1.level.Text = `Lv. {v.Level}`
	playerInfo.details.row2.username.Text = `@{v2.Username}`
	FischersJournal.loadTitle()
end

function FischersJournal.updateContent(p, p2)
	maid:Clean()
	v = p
	v2 = p2
	FischersJournal.loadUserInfo()
	FischersJournal.loadFindings()
	FischersJournal.loadMostUsed()
	FischersJournal.loadCrew()
	FischersJournal.loadStats()
	FischersJournal.updateSelectedTab()
end

local flag = false

function FischersJournal.load(p)
	if flag then
		return
	end

	flag = true
	count += 1
	local playerByUserId = Players:GetPlayerByUserId(p.UserId)
	local v5 = nil
	local v6 = nil
	local success, result = pcall(function()
		if playerByUserId then
			v5, v6 = remoteFunction:InvokeServer(playerByUserId)
		else
			v5, v6 = remoteFunction2:InvokeServer(p.UserId)
		end
	end)

	if not success then
		warn((`[FischersJournal] Failed to load journal data for {p.Username}: {result}`))
		v6 = result
	end

	if v6 then
		anno_localthought:Fire(v6)
	end

	if v5 then
		task.spawn(FischersJournal.updateContent, v5, p)
	end

	flag = false
end

local v5 = "server"
local v6 = {}
local clonesByUsername = {}
local v7 = false
local v8 = {
	Color3.fromRGB(253, 41, 67),
	Color3.fromRGB(1, 162, 255),
	Color3.fromRGB(2, 184, 87),
	BrickColor.new("Alder").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.Yellow().Color,
	BrickColor.new("Light reddish violet").Color,
	BrickColor.new("Brick yellow").Color
}

local function ComputeNameValue(value)
	local total = 0

	for i = 1, #value do
		local v9 = string.byte((string.sub(value, i, i)))
		local v10 = #value - i + 1

		if #value % 2 == 1 then
			v10 -= 1
		end

		if v10 % 4 >= 2 then
			v9 = -v9
		end

		total += v9
	end

	return total
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetNameColor(username)
	return v8[ComputeNameValue(username) % #v8 + 1]
end

function FischersJournal.updateSelectedTab()
	if not v2 then
		return
	end

	for k, v9 in v6 do
		if k == v2.Username then
			v9:AddTag("SelectedItem")
		else
			v9:RemoveTag("SelectedItem")
		end
	end

	for k, v9 in clonesByUsername do
		if k == v2.Username then
			v9:AddTag("SelectedItem")
		else
			v9:RemoveTag("SelectedItem")
		end
	end

	playerlist.ScrollingFrame.CanvasSize = UDim2.fromOffset(
		0,
		playerlist.ScrollingFrame.PlayerListLayout.AbsoluteContentSize.Y
	)
end

function FischersJournal.addPlayerTab(player, flag2: boolean)
	local clone = UI.playerTab:Clone()
	clone.inner.displayName.Text = player.DisplayName
	clone.inner.username.Text = `@{player.Username}`
	local bg = clone.inner.bg
	bg.ImageColor3 = GetNameColor(player.Username)

	if player.UserId == localPlayer.UserId then
		clone.Name = "!" .. player.Username
	else
		clone.Name = player.Username
	end

	local visible

	if flag2 then
		visible = v5 == "friends"
	else
		visible = v5 == "server"
	end

	clone.Visible = visible
	clone.Parent = playerlist.ScrollingFrame

	if flag2 then
		clonesByUsername[player.Username] = clone
	else
		v6[player.Username] = clone
	end

	clone.Activated:Connect(function()
		FischersJournal.load(player)
	end)
	playerlist.ScrollingFrame.CanvasSize = UDim2.fromOffset(
		0,
		playerlist.ScrollingFrame.PlayerListLayout.AbsoluteContentSize.Y
	)
	return clone
end

function FischersJournal.loadPlayer(player)
	return FischersJournal.load({
		UserId = player.UserId,
		DisplayName = player.DisplayName,
		Username = player.Name,
		IsVerified = player.HasVerifiedBadge
	})
end

function FischersJournal.open()
	v3:Clean()
	v3:Add(maid)
	FischersJournal.loadPlayer(localPlayer)
end

function FischersJournal.close()
	v3:Clean()
end

function FischersJournal.init()
	fischersJournal:GetPropertyChangedSignal("Enabled"):Connect(function()
		if fischersJournal.Enabled then
			FischersJournal.open()
		else
			FischersJournal.close()
		end
	end)
	searchBox:GetPropertyChangedSignal("Text"):Connect(FischersJournal.updateSearch)
	left.top.closeButton.Activated:Connect(function()
		fischersJournal.Enabled = false
	end)
	listSwitch.Activated:Connect(function()
		if v5 == "server" then
			v5 = "friends"
			listSwitch.inner.switchText.Text = "Show Server"

			if not v7 then
				v7 = true
				local friendsAsync = FriendsList.GetFriendsAsync()

				if #friendsAsync > 0 then
					for _, v9 in friendsAsync do
						FischersJournal.addPlayerTab(v9, true)
					end
				else
					v7 = false
				end
			end
		else
			v5 = "server"
			listSwitch.inner.switchText.Text = "Show Friends"
		end

		for _, v9 in v6 do
			v9.Visible = v5 == "server"
		end

		for _, v9 in clonesByUsername do
			v9.Visible = v5 == "friends"
		end

		FischersJournal.updateSelectedTab()
	end)

	for _, v9 in Players:GetPlayers() do
		FischersJournal.addPlayerTab({
			DisplayName = v9.DisplayName,
			UserId = v9.UserId,
			Username = v9.Name,
			IsVerified = v9.HasVerifiedBadge
		}, false)
	end

	Players.PlayerAdded:Connect(function(player)
		FischersJournal.addPlayerTab({
			DisplayName = player.DisplayName,
			UserId = player.UserId,
			Username = player.Name,
			IsVerified = player.HasVerifiedBadge
		}, false)
	end)
	Players.PlayerRemoving:Connect(function(player)
		local v9 = v6[player.Name]

		if v9 then
			v9:Destroy()
			v6[player.Name] = nil
			playerlist.ScrollingFrame.CanvasSize = UDim2.fromOffset(
				0,
				playerlist.ScrollingFrame.PlayerListLayout.AbsoluteContentSize.Y
			)
		end
	end)
	FischersJournal.updateSelectedTab()
end

return FischersJournal