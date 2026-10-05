game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local assets = ReplicatedStorage.Assets
local modules = ReplicatedStorage.Modules
local data = assets.Data
local store = data.Store
local localPlayer = Players.LocalPlayer
local parent = script.Parent.Parent.Parent
local _ = parent.Parent.Parent
local inspectItemPage = parent.InspectItemPage
local inspectItem = inspectItemPage.InspectItem
local parent2 = script.Parent
local shop = script:FindFirstAncestor("Shop")
local _ = parent2.Parent
local contents = parent2.Content.Featured.PrimaryShowcase.Contents
local contents2 = parent2.Content.Featured.SecondaryShowcase.Contents
local top = parent2.Content.BannerArea.Top
local example = contents.Example
local example2 = contents2.Example
local example3 = top.Content.Example
local featured = shop.Header.Featured
example.Parent = nil
example2.Parent = nil
example3.Parent = nil
local ownsEverything = parent2.Content.OwnsEverything
local _ = ownsEverything.Owner
local UI = require(modules.UI)
local Data = require(modules.Data)
require(modules.ShopUtil)
local Title = require(modules.Title)
local Janitor = require(modules.Janitor)
local FeaturedItemsUtility = require(modules.FeaturedItemsUtility)
local Network = require(modules.Network)
local Case = require(assets.Data.Case)
local Color = require(modules.Color)
local Items = require(store.Items)
local Skins = require(store.Skins)
require(store.Emotes)
local Titles = require(store.Titles)
local WeeklyStore = require(data.WeeklyStore)
local Decoration = require(store.Decoration)
local Holiday = require(modules.Holiday)
local color = Color3.fromRGB(255, 190, 50)
local color2 = Color3.fromRGB(255, 85, 255)
TweenInfo.new(15, Enum.EasingStyle.Linear)
local v = Janitor.new()
local maid = Janitor.new()
local v2 = nil

local function CommaValue(p: number)
	return string.format("%0.0f", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function FormatPrice(p: number)
	if p == 0 then
		return "FREE"
	elseif p == 1e999 then
		return ""
	end

	return CommaValue(p)
end

local function applyPriceLabel(p, flag: boolean, p2: number, value: string?, p3: string?)
	p.RichText = false

	if flag then
		p.Text = value or "Owned"
	else
		p.Text = p3 or p2 == 0 and "FREE" or p2 == 1e999 and "" or string.format("%0.0f", p2):reverse():gsub(
			"(%d%d%d)",
			"%1,"
		):reverse():gsub(
			"^,",
			""
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function purchaseFeaturedEntry(p)
	local handler = FeaturedItemsUtility.Handlers[p.Source]

	if handler and handler.Purchase then
		handler:Purchase(p)
	end
end

local function toggleOwnedFeaturedEntry(p)
	local handler = FeaturedItemsUtility.Handlers[p.Source]

	if not handler then
		return
	end

	local toggle = handler.Toggle

	if toggle then
		toggle(handler, p)
	end
end

local function secondsToDHMS(p: number)
	local v3 = math.floor(p / 86400)
	local v4 = math.floor(p % 86400 / 3600)
	local v5 = math.floor(p % 3600 / 60)
	local v6 = p % 60
	return string.format("%d:%02d:%02d:%02d", v3, v4, v5, v6)
end

local function getSecondsLeft(currentBanner: string)
	local v3 = HttpService:JSONDecode(workspace:GetAttribute("Banners"))[currentBanner]
	local duration = tonumber(v3.Duration)
	local bannerTimeOffset = workspace:GetAttribute("BannerTimeOffset") or 0
	local globalTime = workspace:GetAttribute("GlobalTime")
	return secondsToDHMS(math.max(duration - (v3.Special and globalTime or globalTime - bannerTimeOffset), 0))
end

local function updateEntrySlots(currentBanner: string)
	local allBanner = WeeklyStore.AllBanners[currentBanner]
	local v3 = {}
	local count = 0

	for _, button in top.Content:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	local itemChances = Case:GetItemChances(allBanner)

	for k, item in allBanner.Items do
		for _, v4 in item do
			local chance = itemChances[v4] or 0
			local rarityColor = Case:GetColors()[k]
			local display = ""
			local icon = ""

			if Skins[v4] then
				display = Skins[v4].Display
				icon = Skins[v4].Icon
			elseif Decoration.Avatar[v4] then
				display = Decoration.Avatar[v4].Display
				icon = Decoration.Avatar[v4].Image
			elseif Items[v4] then
				display = Items[v4].Display
				icon = Items[v4].Icon
			elseif Titles[v4] then
				display = Titles[v4].Display
				icon = "Title"
			end

			table.insert(v3, {
				chance = chance,
				rarityColor = rarityColor,
				objectName = display,
				icon = icon
			})
		end
	end

	table.sort(v3, function(a, b)
		return a.chance < b.chance
	end)
	top.Title.FontFace = Font.new(allBanner.Theme.HeaderFont, allBanner.Theme.HeaderWeight)
	top.Title.TextColor3 = allBanner.Theme.HeaderTextColor
	top.Title.UIStroke.Color = Color:GetShadedColor(allBanner.Theme.HeaderTextColor, 0.4)
	top.Title.TextSize = 12 * (allBanner.Theme.HeaderTextSizeMultiplier or 1)
	top.Background.Image = allBanner.Theme.BackgroundImage or ""

	for _ = 1, 2 do
		for _, v4 in v3 do
			count += 1
			local clone = example3:Clone()

			if v4.icon == "Title" then
				clone.Icon.TitleDisplay.Visible = true
				clone.Icon.ImageTransparency = 1
				clone.Icon.Hidden.Visible = false
				Title:Construct(localPlayer, clone.Icon, v4.objectName)
			else
				clone.Icon.Image = v4.icon
			end

			clone.Rarity.BackgroundColor3 = v4.rarityColor
			clone.ItemName.Title.Text = v4.objectName
			clone.Icon.BackgroundColor3 = v4.rarityColor
			clone.Header.Badge.Text = `{v4.chance}%`
			clone.LayoutOrder = count
			clone.Parent = top.Content
			UI:AddShadowOnHover(clone)
			UI:Bind(clone)
			clone.Activated:Connect(function()
				parent.Pages.SetPage:Fire(parent.Pages.Weekly)
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveEntry(p)
	local handler = FeaturedItemsUtility.Handlers[p.Source]

	if handler then
		return handler:Resolve(p)
	end

	return nil
end

local function createEmoteViewport(clone, animationId: string)
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(0, 0, -350) * CFrame.Angles(0, 3.141592653589793, 0)
	camera.FieldOfView = 1
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.CurrentCamera = camera
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.ZIndex = 0
	viewportFrame.Name = "EmotePreview"
	camera.Parent = viewportFrame
	local worldModel = Instance.new("WorldModel")
	local clone2 = ReplicatedStorage.Assets.Models.Dummy:Clone()

	if clone:GetAttribute("Slot") == 0 then
		clone2:PivotTo(CFrame.new(0, -2.5, 20))
	else
		clone2:PivotTo(CFrame.new(0, -2, 80))
	end

	clone2.Parent = worldModel
	worldModel.Parent = viewportFrame
	local animation = Instance.new("Animation", clone2)
	animation.AnimationId = `rbxassetid://{animationId}`
	local controller = clone2:WaitForChild("Controller")
	local track

	if controller then
		track = controller:LoadAnimation(animation)
		track.Looped = true
		track:Play()

		if UserInputService.TouchEnabled then
			track.TimePosition = track.Length * 0.5
			track:AdjustSpeed(0)
		end
	end

	viewportFrame.Parent = clone
	return viewportFrame, track
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearObjects()
	v:Cleanup()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getContainerForSlot(slot: number)
	if slot == 0 then
		return contents
	end

	return contents2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTemplateForSlot(slot: number)
	if slot == 0 then
		return example
	end

	return example2
end

local function closeInspect()
	maid:Cleanup()

	if not parent2.Visible then
		return
	end

	inspectItemPage.Visible = false
	inspectItem.Item.Visible = true
	inspectItem.Profile.Visible = false
	inspectItem.Description.Visible = true
	inspectItem.Buttons.Equip.Visible = false
	inspectItem.Buttons.Unequip.Visible = false
	inspectItem.Buttons.Purchase.Visible = false
	inspectItem.Price.Visible = true
	inspectItem.Price.RichText = false

	if inspectItem.Buttons:FindFirstChild("Bind") then
		inspectItem.Buttons.Bind.Visible = false
	end

	if inspectItem.Buttons:FindFirstChild("Rebind") then
		inspectItem.Buttons.Rebind.Visible = false
	end

	if inspectItem.Item:FindFirstChild("EmoteDisplay") then
		inspectItem.Item.EmoteDisplay.Visible = false
	end

	if inspectItem.Item:FindFirstChild("Title") then
		inspectItem.Item.Title.Visible = false
	end
end

inspectItemPage:GetPropertyChangedSignal("Visible"):Connect(function()
	if inspectItemPage.Visible then
		return
	end

	maid:Cleanup()

	if inspectItem.Item:FindFirstChild("EmoteDisplay") then
		inspectItem.Item.EmoteDisplay.Visible = false
	end
end)

local function openInspect(data2, data3, _)
	maid:Cleanup()
	inspectItem.ItemName.Text = data3.Display
	inspectItem.Description.Visible = true
	inspectItem.Description.Text = data3.Description or ""
	inspectItem.Item.Visible = true
	inspectItem.Profile.Visible = false
	inspectItem.Item.ItemImage.Visible = false

	if inspectItem.Item:FindFirstChild("Title") then
		inspectItem.Item.Title.Visible = false
	end

	if inspectItem.Item:FindFirstChild("EmoteDisplay") then
		inspectItem.Item.EmoteDisplay.Visible = false
	end

	local price = inspectItem.Price
	local owned = data3.Owned
	local price2 = data3.Price
	local priceText = data3.PriceText
	price.RichText = false

	if owned then
		price.Text = "Owned"
	else
		price.Text = priceText or price2 == 0 and "FREE" or price2 == 1e999 and "" or string.format("%0.0f", price2):reverse():gsub(
			"(%d%d%d)",
			"%1,"
		):reverse():gsub(
			"^,",
			""
		)
	end

	inspectItem.Buttons.Equip.Visible = false
	inspectItem.Buttons.Unequip.Visible = false
	inspectItem.Buttons.Purchase.Visible = false

	if inspectItem.Buttons:FindFirstChild("Bind") then
		inspectItem.Buttons.Bind.Visible = false
	end

	if inspectItem.Buttons:FindFirstChild("Rebind") then
		inspectItem.Buttons.Rebind.Visible = false
	end

	local source = data2.Source

	if source == "Item" then
		inspectItem.Item.ItemImage.Visible = true
		inspectItem.Item.ItemImage.Image = data3.RoundIcon or ""
	elseif source == "Emote" then
		if inspectItem.Item:FindFirstChild("EmoteDisplay") and data3.AnimationId then
			inspectItem.Item.EmoteDisplay.Visible = true
			local dummy = inspectItem.Item.EmoteDisplay.WorldModel:FindFirstChild("Dummy")

			if dummy then
				local animation = Instance.new("Animation")
				animation.AnimationId = `rbxassetid://{data3.AnimationId}`
				animation.Parent = dummy
				local controller = dummy:FindFirstChild("Controller")

				if controller then
					local track = controller:LoadAnimation(animation)
					track.Looped = true
					track:Play()
					maid:Add(function()
						track:Stop()
						track:Destroy()
						animation:Destroy()
					end, true)
				end
			end
		end
	elseif source == "Decoration" then
		inspectItem.Item.Visible = false
		inspectItem.Profile.Visible = true
		local decoGroup = data2.DecoGroup
		local v3

		if decoGroup then
			v3 = Decoration[decoGroup]
		end

		local v4

		if v3 then
			v4 = v3[data2.Name]
		end

		if v4 then
			inspectItem.Profile.CustomBG.Image = ""
			inspectItem.Profile.Banner.CustomBG.Image = ""
			inspectItem.Profile.Profile.AvatarDecoration.Image = ""
			inspectItem.Profile.DisplayName.Text = localPlayer.DisplayName
			inspectItem.Profile.Username.Text = `@{localPlayer.Name}`
			inspectItem.Profile.Profile.Avatar.Image = UI:GetAvatarDecal(localPlayer)

			if decoGroup == "Avatar" then
				inspectItem.Profile.Profile.AvatarDecoration.ZIndex = v4.AppearUnderProfile and 0 or 5
				inspectItem.Profile.Profile.AvatarDecoration.Image = v4.Image or ""
				inspectItem.Profile.Profile.AvatarDecoration.ImageTransparency = v4.Transparency or 0
				inspectItem.Profile.Profile.AvatarDecoration.Position = v4.Position or UDim2.fromScale(0.5, 0.5)
				inspectItem.Profile.Profile.AvatarDecoration.Size = v4.Size or UDim2.fromScale(1, 1)
			elseif decoGroup == "Banner" then
				inspectItem.Profile.Banner.CustomBG.Image = v4.Image or ""
				inspectItem.Profile.Banner.CustomBG.ImageTransparency = v4.Transparency or 0
			else
				inspectItem.Profile.CustomBG.Image = v4.Image or ""
				inspectItem.Profile.CustomBG.ImageTransparency = v4.Transparency or 0
			end
		end
	elseif source == "Title" then
		inspectItem.Item.ItemImage.Visible = false

		if inspectItem.Item:FindFirstChild("Title") then
			inspectItem.Item.Title.Visible = true
			Title:Construct(localPlayer, inspectItem.Item.Title, data3.Display)
		end
	elseif source == "Skin" then
		inspectItem.Item.ItemImage.Visible = true
		inspectItem.Item.ItemImage.Image = data3.Icon or ""
	end

	if data3.Owned then
		if source == "Emote" then
			local bind = inspectItem.Buttons:FindFirstChild("Bind")
			local rebind = inspectItem.Buttons:FindFirstChild("Rebind")

			if bind and rebind then
				bind.Visible = not data3.Equipped
				rebind.Visible = data3.Equipped

				local function handleBind()
					if _G.StartBinding then
						_G.StartBinding(data2.Name)
					end

					closeInspect()
				end

				maid:Add(bind.Activated:Connect(handleBind), "Disconnect")
				maid:Add(rebind.Activated:Connect(handleBind), "Disconnect")
			end
		else
			inspectItem.Buttons.Equip.Visible = not data3.Equipped
			inspectItem.Buttons.Unequip.Visible = data3.Equipped

			local function handleToggle()
				local v3 = data2
				local handler = FeaturedItemsUtility.Handlers[v3.Source]
				local toggle = handler and handler.Toggle

				if toggle then
					toggle(handler, v3)
				end

				closeInspect()
			end

			maid:Add(inspectItem.Buttons.Equip.Activated:Connect(handleToggle), "Disconnect")
			maid:Add(inspectItem.Buttons.Unequip.Activated:Connect(handleToggle), "Disconnect")
		end
	else
		inspectItem.Buttons.Purchase.Visible = true
		maid:Add(inspectItem.Buttons.Purchase.Activated:Connect(function()
			purchaseFeaturedEntry(data2) -- equivalent call inferred; original call site unknown
			closeInspect()
		end), "Disconnect")
	end

	maid:Add(inspectItem.Buttons.Cancel.Activated:Connect(closeInspect), "Disconnect")
	maid:Add(inspectItem.Buttons.Cancel2.Activated:Connect(closeInspect), "Disconnect")
	inspectItemPage.Visible = true
end

local function createFeaturedCard(state, entry)
	local maid2 = Janitor.new()
	v:Add(maid2, "Cleanup")

	if Holiday:GetCurrentHoliday().Hub then
		if state.Slot == 0 then
			local shopHub = localPlayer.PlayerGui:FindFirstChild("ShopHub")
			local hub

			if shopHub then
				hub = shopHub:FindFirstChild("Hub")
			end

			if hub then
				local clone = example:Clone()
				maid2:Add(clone, "Destroy")
				clone:SetAttribute("Slot", state.Slot)
				clone.Icon.ImageTransparency = 0
				clone.Name = "Shop_Hub"
				clone.LayoutOrder = state.Slot
				local badge = clone.Header.Badge
				badge.Text = "Limited"
				badge.BackgroundColor3 = color2
				clone.ItemName.Title.Text = `{Holiday:GetCurrentHoliday().Name} Hub`
				clone.Footer.Visible = false
				clone.Icon.Size = UDim2.fromScale(1, 1)
				clone.ItemName.Position = UDim2.fromScale(0.5, 1)
				clone.Icon.Image = hub.Content.NavigationArea.Image
				clone.Icon.HubLabel.Image = hub.Top.TitleArea.Icon.Image
				clone.Icon.HubLabel.Visible = true
				maid2:Add(clone.MouseButton1Click:Connect(function()
					_G.ShowShopHub(true)
					parent.Visible = false
				end), "Disconnect")
				UI:AddShadowOnHover(clone)
				UI:Bind(clone)
				clone.Parent = contents
			end
		end

		state.Slot += 1

		if state.Slot >= 7 then
			return
		end
	end

	local containerForSlot = getContainerForSlot(state.Slot) -- equivalent call inferred; original call site unknown
	local templateForSlot = getTemplateForSlot(state.Slot) -- equivalent call inferred; original call site unknown
	local clone = templateForSlot:Clone()
	maid2:Add(clone, "Destroy")
	local v3 = nil
	clone:SetAttribute("Slot", state.Slot)
	clone.Icon.ImageTransparency = 0
	local backgroundColor

	if state.Tag == "LimitedTime" then
		backgroundColor = color2
	else
		backgroundColor = color
	end

	clone.Name = `{state.Source}_{state.Name}`
	clone.LayoutOrder = state.Slot

	if state.Source == "Emote" and entry.AnimationId then
		clone.Icon.Visible = false
		local _, v5 = createEmoteViewport(clone, entry.AnimationId)
		v3 = v5

		if v3 then
			maid2:Add(function()
				v3:Stop()
				v3:Destroy()
			end, true)
		end
	elseif state.Source == "Title" then
		if clone.Icon:FindFirstChild("TitleDisplay") then
			clone.Icon.TitleDisplay.Visible = true
			clone.Icon.ImageTransparency = 1
			clone.Icon.Hidden.Visible = false
			local group = clone.Icon.TitleDisplay.Group
			local head = clone.Icon.TitleDisplay.Head

			if state.Slot == 0 then
				group.Position = UDim2.new(group.Position.X.Scale, 0, group.Position.Y.Scale, -70)
				head.Position = UDim2.new(head.Position.X.Scale, 0, head.Position.Y.Scale, 70)
			else
				group.Position = UDim2.new(group.Position.X.Scale, 0, group.Position.Y.Scale, -30)
			end

			Title:Construct(localPlayer, clone.Icon, entry.Display)
		end
	else
		clone.Icon.Image = entry.Icon or "rbxassetid://15989671213"
	end

	clone.ItemName.Title.Text = entry.Display
	clone.Hidden.Visible = entry.Owned
	clone.Footer.Visible = not entry.Owned

	if entry.Owned then
		clone.Icon.Size = UDim2.fromScale(1, 1)
		clone.ItemName.Position = UDim2.fromScale(0.5, 1)
	end

	local badge = clone.Header.Badge

	if state.Tag == "LimitedTime" then
		badge.Text = "Limited"
		badge.BackgroundColor3 = color2
	elseif state.Tag == "New" then
		badge.Text = "New"
		badge.BackgroundColor3 = color
	elseif state.Tag == "Popular" then
		badge.Text = "Popular"
		badge.BackgroundColor3 = color

		if state.Slot >= 1 then
			badge.UIPadding.PaddingBottom = UDim.new(0, 1)
		end
	else
		clone.Header.Badge.Visible = false
	end

	local amount = clone.Footer.Credits.Amount

	if amount then
		local owned = entry.Owned
		local price = entry.Price
		local priceText = entry.PriceText
		amount.RichText = false

		if owned then
			amount.Text = "Owned"
		else
			amount.Text = priceText or price == 0 and "FREE" or price == 1e999 and "" or string.format("%0.0f", price):reverse():gsub(
				"(%d%d%d)",
				"%1,"
			):reverse():gsub(
				"^,",
				""
			)
		end
	end

	clone.Footer.Credits.Icon.Visible = entry.PriceText == nil

	if clone and clone:FindFirstChild("Rarity") then
		clone.Rarity.BackgroundColor3 = backgroundColor
	end

	maid2:Add(clone.MouseButton1Click:Connect(function()
		if state.Source == "Bundle" then
			purchaseFeaturedEntry(state) -- equivalent call inferred; original call site unknown
		else
			openInspect(state, entry, maid2)
		end
	end), "Disconnect")
	UI:AddShadowOnHover(clone)
	UI:Bind(clone)
	clone.Parent = containerForSlot
end

local function updateTimer()
	local currentBanner = workspace:GetAttribute("CurrentBanner")
	local v3 = currentBanner and WeeklyStore.AllBanners[currentBanner]

	if v3 then
		local display = v3.Display:upper()
		top.Timer.Text = getSecondsLeft(currentBanner)

		if top.Title.Text ~= display then
			top.Title.Text = display
			updateEntrySlots(currentBanner)
		end
	end

	local featuredRotationEnd = workspace:GetAttribute("FeaturedRotationEnd")

	if not featuredRotationEnd then
		featured.Timer.Text = ""
		return
	end

	local v4 = math.max(0, featuredRotationEnd - workspace:GetAttribute("GlobalTime"))
	local timer = featured.Timer
	local v5 = math.floor(v4 / 86400)
	local v6 = math.floor(v4 % 86400 / 3600)
	local v7 = math.floor(v4 % 3600 / 60)
	local v8 = v4 % 60
	timer.Text = `Refreshes in {string.format("%d:%02d:%02d:%02d", v5, v6, v7, v8)}`
end

local BuildCuratedPage

BuildCuratedPage = function()
	clearObjects() -- equivalent call inferred; original call site unknown
	closeInspect()

	if not v2 or v2 == "" then
		ownsEverything.Visible = false
		return
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, v2)

	if not success or typeof(result) ~= "table" then
		ownsEverything.Visible = false
		return
	end

	local count = 0
	local visible = true
	local flag = false

	for _, v4 in result do
		local entry = resolveEntry(v4) -- equivalent call inferred; original call site unknown

		if not entry then
			continue
		end

		count += 1
		createFeaturedCard(v4, entry)

		if not entry.Owned then
			visible = false
		end

		if entry.Pending then
			flag = true
		end
	end

	ownsEverything.Visible = visible

	if flag then
		task.delay(1, BuildCuratedPage)
	end

	updateTimer()
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function queueRebuild()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		BuildCuratedPage()
	end)
end

Network:listen("UpdateFeaturedPage", function(p: string)
	if not p or p == "" then
		return
	end

	v2 = p
	queueRebuild() -- equivalent call inferred; original call site unknown
end)
top.View.Activated:Connect(function()
	parent.Pages.SetPage:Fire(parent.Pages.Weekly)
end)
UI:Bind(top.View)
Data.Inventory:GetPropertyChangedSignal("Items"):Connect(queueRebuild)
Data.Decoration:GetPropertyChangedSignal("Items"):Connect(queueRebuild)
Data.Titles:GetPropertyChangedSignal("Items"):Connect(queueRebuild)
Data.Skins:GetPropertyChangedSignal("Items"):Connect(queueRebuild)
Data.Emotes:GetPropertyChangedSignal("Items"):Connect(queueRebuild)
RunService.Heartbeat:Connect(function()
	if shop.Visible and parent2.Visible then
		local imageButton = top.Content:FindFirstChildOfClass("ImageButton")

		if not imageButton then
			return
		end

		local X = imageButton.AbsoluteSize.X
		local v3 = 1
		local currentBanner = workspace:GetAttribute("CurrentBanner")
		local v4 = currentBanner and WeeklyStore.AllBanners[currentBanner]

		if not v4 then
			return
		end

		for _, item in v4.Items do
			for _, _ in item do
				v3 += 1
			end
		end

		local v5 = os.clock() * 30
		local vector = Vector2.new(v5 % (X * v3 + 4), 0)
		top.Content.CanvasPosition = vector
	end
end)
parent2:GetPropertyChangedSignal("Visible"):Connect(function()
	featured.Visible = parent2.Visible
end)
featured.Visible = parent2.Visible
task.spawn(function()
	while true do
		if shop and shop.Visible then
			updateTimer()
		end

		task.wait(1)
	end
end)
BuildCuratedPage()