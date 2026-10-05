local MarketplaceService = game:GetService("MarketplaceService")
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
local UI = require(modules.UI)
local Network = require(modules.Network)
local Data = require(modules.Data)
local Title = require(modules.Title)
local Janitor = require(modules.Janitor)
local ShopUtil = require(modules.ShopUtil)
local Money = require(modules.Money)
local WeeklyStore = require(data.WeeklyStore)
local Case = require(data.Case)
local Skins = require(store.Skins)
local Titles = require(store.Titles)
local Decoration = require(store.Decoration)
local Items = require(store.Items)
local Emotes = require(store.Emotes)
local v = {}
local heartbeatConnection = nil
local localPlayer = Players.LocalPlayer
local shop = script:FindFirstAncestor("Shop")
local banner = script.Banner
local pages = shop.Pages
local inspectItemPage = shop.InspectItemPage
local inspectItem = inspectItemPage.InspectItem
local weekly = shop.Tabs.TabList.Weekly
local v2 = {}

function secondsToDHMS(p: number)
	local v3 = math.floor(p / 86400)
	local v4 = math.floor(p % 86400 / 3600)
	local v5 = math.floor(p % 3600 / 60)
	local v6 = p % 60
	return string.format("%d:%02d:%02d:%02d", v3, v4, v5, v6)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doesOwnSkin(p: string)
	return Data.Skins:Get(p) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSkinEquipped(p: string)
	if doesOwnSkin(p) then
		return Data.Skins:Get(p).Equipped
	end

	return false
end

local function createSkinButton(container, name)
	local skin = Skins[name]
	local clone = script.Example:Clone()
	local maid = v[container]
	Case:GetCrateFromItem(name)
	local v3 = nil

	for _, allBanner in WeeklyStore.AllBanners do
		for k, list in allBanner.Items do
			if not table.find(list, name) then
				continue
			end

			v3 = k
			break
		end
	end

	local backgroundColor = Case:GetColors()[v3]
	clone.Icon.Image = skin.Icon or "rbxassetid://15989671213"
	clone.BackgroundColor3 = backgroundColor
	clone.ItemName.Title.Text = skin.Display
	clone.Rarity.BackgroundColor3 = backgroundColor
	clone.Parent = container.Items.ItemList
	clone.Name = name
	clone:SetAttribute("Rarity", v3)
	clone.LayoutOrder = Case:GetRarityIndex(v3)

	local function equipSkin()
		Network:fire("EquipSkin", name)
		maid:Cleanup()
		inspectItemPage.Visible = false
	end

	clone.MouseButton1Click:Connect(function()
		inspectItem.Item.Visible = true
		inspectItem.Profile.Visible = false
		inspectItem.Description.Visible = true
		inspectItem.ItemName.Text = skin.Display
		inspectItem.Description.Text = `This limited-time skin is part of the current "{container.Name}". Don’t miss your chance to add it to your collection before it’s gone!`
		inspectItem.Price.Text = ""
		inspectItem.Item.ItemImage.Visible = true
		inspectItem.Item.Title.Visible = false
		inspectItem.Item.ItemImage.Image = clone.Icon.Image
		local equip = inspectItem.Buttons.Equip
		local skinEquipped = isSkinEquipped(name) -- equivalent call inferred; original call site unknown
		local visible = not skinEquipped

		if visible then
			visible = doesOwnSkin(name)
		end

		equip.Visible = visible
		local unequip = inspectItem.Buttons.Unequip
		local skinEquipped2 = isSkinEquipped(name) -- equivalent call inferred; original call site unknown

		if skinEquipped2 then
			skinEquipped2 = doesOwnSkin(name)
		end

		unequip.Visible = skinEquipped2
		maid:Cleanup()
		maid:Add(inspectItem.Buttons.Equip.Activated:Connect(equipSkin))
		maid:Add(inspectItem.Buttons.Unequip.Activated:Connect(equipSkin))
		maid:Add(inspectItem.Buttons.Cancel.Activated:Connect(function()
			maid:Cleanup()
		end))
		maid:Add(inspectItem.Buttons.Cancel2.Activated:Connect(function()
			maid:Cleanup()
		end))
		inspectItemPage.Visible = true
	end)
	UI:Bind(clone)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doesOwnDecor(p: string)
	return Data.Decoration:Get(p) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isDecoEquipped(p: string)
	return Data.Decoration:Get(p) ~= nil and Data.Decoration:Get(p).Equipped
end

local function createDecorButton(container, name)
	local v3 = Decoration.Avatar[name]
	local clone = script.Example:Clone()
	local maid = v[container]
	Case:GetCrateFromItem(name)
	local v4 = nil

	for _, allBanner in WeeklyStore.AllBanners do
		for k, list in allBanner.Items do
			if not table.find(list, name) then
				continue
			end

			v4 = k
			break
		end
	end

	local backgroundColor = Case:GetColors()[v4]
	clone.Icon.Image = v3.Image or "rbxassetid://15989671213"
	clone.BackgroundColor3 = backgroundColor
	clone.ItemName.Title.Text = v3.Display
	clone.Rarity.BackgroundColor3 = backgroundColor
	clone.Parent = container.Items.ItemList
	clone.Name = name
	clone:SetAttribute("Rarity", v4)
	clone.LayoutOrder = Case:GetRarityIndex(v4)

	local function equipDecoration()
		Network:fire("SetDeco", name)
		maid:Cleanup()
		inspectItem.Profile.Visible = false
		inspectItemPage.Visible = false
	end

	clone.MouseButton1Click:Connect(function()
		inspectItem.Item.Visible = false
		inspectItem.Description.Visible = false
		inspectItem.Profile.Visible = true
		inspectItem.Price.Visible = false
		inspectItem.ItemName.Text = v3.Display
		inspectItem.Profile.CustomBG.Image = ""
		inspectItem.Profile.Banner.CustomBG.Image = ""
		inspectItem.Profile.Profile.AvatarDecoration.Image = ""
		inspectItem.Profile.DisplayName.Text = localPlayer.DisplayName
		inspectItem.Profile.Username.Text = "@" .. localPlayer.Name
		inspectItem.Profile.Profile.Avatar.Image = UI:GetAvatarDecal(localPlayer)
		inspectItem.Profile.Profile.AvatarDecoration.ZIndex = v3.AppearUnderProfile and 0 or 5
		inspectItem.Profile.Profile.AvatarDecoration.Image = v3.Image
		inspectItem.Profile.Profile.AvatarDecoration.ImageTransparency = v3.Transparency or 0
		inspectItem.Profile.Profile.AvatarDecoration.Position = v3.Position

		if doesOwnDecor(name) then
			local equip = inspectItem.Buttons.Equip
			equip.Visible = not isDecoEquipped(name)
			inspectItem.Buttons.Unequip.Visible = not inspectItem.Buttons.Equip.Visible
		else
			inspectItem.Buttons.Equip.Visible = false
			inspectItem.Buttons.Unequip.Visible = false
		end

		maid:Cleanup()
		maid:Add(inspectItem.Buttons.Equip.Activated:Connect(equipDecoration))
		maid:Add(inspectItem.Buttons.Unequip.Activated:Connect(equipDecoration))
		maid:Add(inspectItem.Buttons.Cancel.Activated:Connect(function()
			inspectItem.Profile.Visible = false
			inspectItem.Item.Visible = true
			inspectItem.Description.Visible = true
			maid:Cleanup()
		end))
		maid:Add(inspectItem.Buttons.Cancel2.Activated:Connect(function()
			inspectItem.Profile.Visible = false
			inspectItem.Item.Visible = true
			inspectItem.Description.Visible = true
			maid:Cleanup()
		end))
		inspectItemPage.Visible = true
	end)
	UI:Bind(clone)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doesOwnTitle(p)
	return Data.Titles:Get(p) ~= nil
end

local function getEquippedTitle()
	return localPlayer:GetAttribute("Title")
end

local function createTitleButton(container, p)
	local title = Titles[p]
	local clone = script.Example:Clone()
	local maid = v[container]
	local v3 = nil

	for _, allBanner in WeeklyStore.AllBanners do
		for k, list in allBanner.Items do
			if not table.find(list, p) then
				continue
			end

			v3 = k
			break
		end
	end

	local backgroundColor = Case:GetColors()[v3]
	clone.Rarity.BackgroundColor3 = backgroundColor
	clone.BackgroundColor3 = backgroundColor
	clone.Rarity.BackgroundColor3 = backgroundColor
	clone.Parent = container.Items.ItemList
	clone.ItemName.Title.Text = p
	clone.Icon.TitleDisplay.Visible = true
	clone.Name = p
	Title:Construct(localPlayer, clone.Icon, title.Display)
	clone:SetAttribute("Rarity", v3)
	clone.LayoutOrder = Case:GetRarityIndex(v3)

	local function equipTitle()
		Network:fire("SetActiveTitle", p)
		maid:Cleanup()
		inspectItemPage.Visible = false
	end

	clone.MouseButton1Click:Connect(function()
		local hex = (backgroundColor or Color3.new(1, 1, 1)):ToHex()
		inspectItem.ItemName.Text = `{title.Display}  (<font color="#{hex}"> <stroke color="#000000">{Case:GetRarityDisplay(v3 or "Common")}</stroke></font> )`

		if not title.Rarity then
			inspectItem.ItemName.Text = title.Display
		end

		inspectItem.Item.Visible = true
		inspectItem.Description.Visible = true
		inspectItem.Profile.Visible = false
		inspectItem.Description.Text = ""
		inspectItem.Item.ItemImage.Visible = false
		inspectItem.Item.Title.Visible = true
		Title:Construct(localPlayer, inspectItem.Item.Title, title.Display)

		if typeof(title.Description) == "function" then
			inspectItem.Description.Text = title.Description()
		elseif title.Description and title.Description ~= "" then
			inspectItem.Description.Text = title.Description
		else
			inspectItem.Description.Text = `"{title.Display}" Title`
		end

		if localPlayer:GetAttribute("Title") == title.Display then
			inspectItem.Buttons.Unequip.Visible = true
		elseif doesOwnTitle(p) then
			inspectItem.Buttons.Equip.Visible = true
		end

		maid:Cleanup()
		maid:Add(inspectItem.Buttons.Equip.Activated:Connect(equipTitle))
		maid:Add(inspectItem.Buttons.Unequip.Activated:Connect(equipTitle))
		maid:Add(inspectItem.Buttons.Cancel.Activated:Connect(function()
			inspectItem.Item.Title.Visible = false
			maid:Cleanup()
		end))
		maid:Add(inspectItem.Buttons.Cancel2.Activated:Connect(function()
			inspectItem.Item.Title.Visible = false
			maid:Cleanup()
		end))
		inspectItem.Price.Text = ""
		inspectItemPage.Visible = true
	end)
	UI:Bind(clone)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doesOwnItem(attributeName: string)
	return localPlayer:GetAttribute(attributeName) ~= nil or Data.Inventory:Get(attributeName)
end

local function getEquippedItems()
	local result = {}

	for k, item in Data.Inventory.Items do
		if item.Equipped then
			result[k] = item
		end
	end

	return result
end

local function createItemButton(container, name)
	local item = Items[name]
	local clone = script.Example:Clone()
	local maid = v[container]
	Case:GetCrateFromItem(name)
	local v3 = nil

	for _, allBanner in WeeklyStore.AllBanners do
		for k, list in allBanner.Items do
			if not table.find(list, name) then
				continue
			end

			v3 = k
			break
		end
	end

	local backgroundColor = Case:GetColors()[v3]
	clone.Icon.Image = item.Icon or "rbxassetid://15989671213"
	clone.BackgroundColor3 = backgroundColor
	clone.ItemName.Title.Text = item.Display
	clone.Rarity.BackgroundColor3 = backgroundColor
	clone.Parent = container.Items.ItemList
	clone.Name = name
	clone:SetAttribute("Rarity", v3)
	clone.LayoutOrder = Case:GetRarityIndex(v3)

	local function equipSkin()
		Network:fire("Equip", name)
		maid:Cleanup()
		inspectItemPage.Visible = false
	end

	clone.MouseButton1Click:Connect(function()
		inspectItem.Item.Visible = true
		inspectItem.Profile.Visible = false
		inspectItem.Description.Visible = true
		inspectItem.ItemName.Text = item.Display
		inspectItem.Description.Text = `This limited-time tool is part of the current "{container.Name}". Don’t miss your chance to add it to your collection before it’s gone!`
		inspectItem.Price.Text = ""
		inspectItem.Item.ItemImage.Visible = true
		inspectItem.Item.Title.Visible = false
		inspectItem.Item.ItemImage.Image = clone.Icon.Image
		local equip = inspectItem.Buttons.Equip
		local v5 = {}

		for k, item2 in Data.Inventory.Items do
			if item2.Equipped then
				v5[k] = item2
			end
		end

		local visible = not v5[name]

		if visible then
			visible = doesOwnItem(name)
		end

		equip.Visible = visible
		local unequip = inspectItem.Buttons.Unequip
		local v7 = {}

		for k, item2 in Data.Inventory.Items do
			if item2.Equipped then
				v7[k] = item2
			end
		end

		local visible2 = v7[name]

		if visible2 then
			visible2 = doesOwnItem(name)
		end

		unequip.Visible = visible2
		maid:Cleanup()
		maid:Add(inspectItem.Buttons.Equip.Activated:Connect(equipSkin))
		maid:Add(inspectItem.Buttons.Unequip.Activated:Connect(equipSkin))
		maid:Add(inspectItem.Buttons.Cancel.Activated:Connect(function()
			maid:Cleanup()
		end))
		maid:Add(inspectItem.Buttons.Cancel2.Activated:Connect(function()
			maid:Cleanup()
		end))
		inspectItemPage.Visible = true
	end)
	UI:Bind(clone)
	return clone
end

local function doesOwnEmote(p)
	return Data.Emotes:Get(p)
end

local function getEquippedEmotes()
	local result = {}

	for k, item in Data.Emotes.Items do
		if item.Slot then
			result[k] = item
		end
	end

	return result
end

local function isEmoteEquipped(p: string)
	local v3 = {}

	for k, item in Data.Emotes.Items do
		if item.Slot then
			v3[k] = item
		end
	end

	return v3[p] ~= nil
end

local function createEmoteButton(container, name)
	local emote = Emotes[name]
	local clone = script.Example:Clone()
	local maid = v[container]
	Case:GetCrateFromItem(name)
	local v3 = nil

	for _, allBanner in WeeklyStore.AllBanners do
		for k, list in allBanner.Items do
			if not table.find(list, name) then
				continue
			end

			v3 = k
			break
		end
	end

	local backgroundColor = Case:GetColors()[v3]
	local v5 = nil
	local v6 = nil
	clone.BackgroundColor3 = backgroundColor
	clone.ItemName.Title.Text = emote.Display
	clone.Rarity.BackgroundColor3 = backgroundColor
	clone.Parent = container.Items.ItemList
	clone.Name = name
	clone:SetAttribute("Rarity", v3)
	clone.LayoutOrder = Case:GetRarityIndex(v3)
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(0, 0, -350) * CFrame.Angles(0, 3.141592653589793, 0)
	camera.FieldOfView = 1
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.CurrentCamera = camera
	viewportFrame.Name = "EmoteDisplay"
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.ZIndex = 2
	camera.Parent = viewportFrame
	viewportFrame.Parent = clone.Icon
	local worldModel = Instance.new("WorldModel", viewportFrame)
	local clone2 = ReplicatedStorage.Assets.Models.Dummy:Clone()
	clone2:PivotTo(CFrame.new(0, -2.5, 0))
	clone2.Parent = worldModel

	local function loadAnimation(instance)
		local animation = Instance.new("Animation", instance)
		animation.AnimationId = `rbxassetid://{emote.AnimationId}`
		local track = instance:WaitForChild("Controller", 1e999):LoadAnimation(animation)
		track.Looped = true
		track:Play()

		if UserInputService.TouchEnabled then
			track.TimePosition = track.Length * 0.5
			track:AdjustSpeed(0)
		end

		return animation, track
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanupInspectRig()
		v6:Stop()
		v6:Destroy()
		v5:Destroy()
		maid:Cleanup()
		inspectItem.Item.EmoteDisplay.Visible = false
	end

	local function equipSkin()
		_G.StartBinding(name)
		cleanupInspectRig() -- equivalent call inferred; original call site unknown
		maid:Cleanup()
		inspectItemPage.Visible = false
	end

	loadAnimation(clone2)
	clone.MouseButton1Click:Connect(function()
		inspectItem.Item.Visible = true
		inspectItem.Profile.Visible = false
		inspectItem.Description.Visible = true
		inspectItem.ItemName.Text = emote.Display
		inspectItem.Description.Text = `This limited-time emote is part of the current "{container.Display}". Don’t miss your chance to add it to your collection before it’s gone!`
		inspectItem.Price.Text = ""
		inspectItem.Item.ItemImage.Visible = true
		inspectItem.Item.EmoteDisplay.Visible = true
		inspectItem.Item.Title.Visible = false
		inspectItem.Item.ItemImage.Image = clone.Icon.Image
		local bind = inspectItem.Buttons.Bind
		local v8 = {}

		for k, item in Data.Emotes.Items do
			if item.Slot then
				v8[k] = item
			end
		end

		local visible = v8[name] == nil

		if visible then
			visible = Data.Emotes:Get(name)
		end

		bind.Visible = visible
		local rebind = inspectItem.Buttons.Rebind
		local v11 = {}

		for k, item in Data.Emotes.Items do
			if item.Slot then
				v11[k] = item
			end
		end

		local visible2 = v11[name] ~= nil

		if visible2 then
			visible2 = Data.Emotes:Get(name)
		end

		rebind.Visible = visible2
		maid:Cleanup()
		maid:Add(inspectItem.Buttons.Bind.Activated:Connect(equipSkin))
		maid:Add(inspectItem.Buttons.Rebind.Activated:Connect(equipSkin))
		maid:Add(inspectItem.Buttons.Cancel.Activated:Connect(function()
			cleanupInspectRig() -- equivalent call inferred; original call site unknown
			maid:Cleanup()
		end))
		maid:Add(inspectItem.Buttons.Cancel2.Activated:Connect(function()
			cleanupInspectRig() -- equivalent call inferred; original call site unknown
			maid:Cleanup()
		end))
		v5, v6 = loadAnimation(inspectItem.Item.EmoteDisplay.WorldModel.Dummy)
		inspectItemPage.Visible = true
	end)
	UI:Bind(clone)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notificationDot()
	local notificationDot2 = weekly.NotificationDot

	if localPlayer:GetAttribute("LatestBanner") == workspace:GetAttribute("CurrentBanner") then
		notificationDot2.Visible = false
	else
		notificationDot2.Visible = true
	end
end

local function onButtonPressed(allBanner, p)
	if allBanner then
		if _G.Policy.ArePaidRandomItemsRestricted then
			return _G.DisplayError("Due to country regulations, you are unable to use the weekly banner.", 5)
		end

		local v3 = tonumber(p.Name:match("Buy(%d+)"))
		local match = p.Name:match("Credit")

		for k, allBanner2 in WeeklyStore.AllBanners do
			if allBanner ~= allBanner2 then
				continue
			end

			if match then
				Network:fire("BuyBannerCredits", k, v3)
			else
				Network:fire("SelectBanner", k, v3)
			end

			return
		end
	end
end

local function updateBanner(name: string)
	local allBanner = WeeklyStore.AllBanners[name]

	if not allBanner or script.Parent:FindFirstChild(name) then
		return
	end

	Network:fire("UpdateLatestBanner")
	local clone = banner:Clone()
	local container = clone.Container
	local header = clone.Header
	local lastTime = tick()
	clone.LayoutOrder = WeeklyStore.EventBanners[name] and -1 or 1
	clone.Name = name
	local title = header.Title
	local timeLeft = header.TimeLeft
	local description = header.Description
	local maid = Janitor.new()
	v[container] = maid
	local v3 = {
		skins = 0,
		titles = 0,
		items = 0,
		emotes = 0,
		decors = 0
	}
	v3.skins = {}
	v3.titles = {}
	v3.items = {}
	v3.emotes = {}
	v3.decors = {}
	local itemChances = Case:GetItemChances(allBanner)
	header.UIGradient.Color = allBanner.Theme.HeaderColor
	container.Image = allBanner.Theme.BackgroundImage
	container.ScaleType = allBanner.Theme.ImageScaleType
	container.Items.Visible = true
	container.Name = allBanner.Display
	title.Text = allBanner.Display
	title.TextColor3 = allBanner.Theme.HeaderTextColor
	title.FontFace = Font.new(allBanner.Theme.HeaderFont, allBanner.Theme.HeaderWeight)
	title.TextSize = 12 * (allBanner.Theme.HeaderTextSizeMultiplier or 1)
	description.Text = allBanner.Description
	clone.Parent = script.Parent
	maid:Add(clone.Destroying:Connect(function()
		for i = #v2, 1, -1 do
			if v2[i]:IsDescendantOf(clone) then
				table.remove(v2, i)
			end
		end

		v[container] = nil
		table.clear(v3)
		v3 = nil
		maid:Destroy()
	end))

	if not (v3.skins and clone.Parent) then
		return
	end

	for _, button in container.ButtonContainer:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v4 = button
		button.Activated:Connect(function()
			onButtonPressed(allBanner, v4)
		end)
		UI:Bind(button)
		local v5 = tonumber(button.Name:match("Buy(%d+)"))
		local match = button.Name:match("Credit")
		local title2 = button:WaitForChild("Title", 1e999)

		if match then
			title2.Text = `Buy {v5} (${Money(allBanner.CreditCost * v5, true)})`
			button.Visible = workspace:GetAttribute("EnableCreditBanners") and true or false
		else
			local v6 = allBanner.ProductIds[v5]
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfo(v6, Enum.InfoType.Product)
			end)

			if success then
				title2.Text = `Buy {v5}x ({result.PriceInRobux})`
			else
				title2.Text = `Buy {v5}x (???)`
			end
		end
	end

	for _, item in allBanner.Items do
		for _, v4 in item do
			if Skins[v4] then
				table.insert(v3.skins, (createSkinButton(container, v4)))
			elseif Titles[v4] then
				table.insert(v3.titles, (createTitleButton(container, v4)))
			elseif Items[v4] then
				table.insert(v3.items, (createItemButton(container, v4)))
			elseif Emotes[v4] then
				table.insert(v3.emotes, (createEmoteButton(container, v4)))
			elseif Decoration.Avatar[v4] then
				table.insert(v3.decors, (createDecorButton(container, v4)))
			end
		end
	end

	for _, v4 in v3 do
		for _, v5 in v4 do
			if v5:FindFirstChild("Icon") and v5.Icon:FindFirstChild("Pattern") then
				table.insert(v2, v5)
			end

			v5.Header.Badge.Text = `{itemChances[v5.Name] or 0}%`
		end
	end

	notificationDot() -- equivalent call inferred; original call site unknown
	local jSONDecode = HttpService:JSONDecode(workspace:GetAttribute("Banners"))
	local v4 = jSONDecode[name]

	if not v4 then
		return
	end

	local function getSecondsLeft()
		local duration = tonumber(v4.Duration)
		local bannerTimeOffset = workspace:GetAttribute("BannerTimeOffset") or 0
		local globalTime = workspace:GetAttribute("GlobalTime")
		local v5 = math.max(duration - (v4.Special and globalTime or globalTime - bannerTimeOffset), 0)
		return secondsToDHMS(v5)
	end

	timeLeft.Text = getSecondsLeft()
	task.spawn(function()
		while task.wait(0.5) do
			jSONDecode = HttpService:JSONDecode(workspace:GetAttribute("Banners"))
			v4 = jSONDecode[name]

			if not (v4 and clone.Parent) then
				break
			end

			if not pages.Weekly.Visible then
				continue
			end

			timeLeft.Text = getSecondsLeft()

			if not (tick() - lastTime > 0.3) then
				continue
			end

			local v5 = {}

			for k, v6 in v3 do
				for _, v7 in v6 do
					local visible = false
					local name2 = v7.Name

					if k == "skins" then
						visible = doesOwnSkin(name2)
						local itemNameFromSkin = ShopUtil:GetItemNameFromSkin(name2) or "Unknown"
						local skin = ShopUtil:GetSkin(name2)

						if not ShopUtil:HasItem(itemNameFromSkin) then
							if not v5[itemNameFromSkin] then
								v5[itemNameFromSkin] = {}
							end

							if skin then
								table.insert(v5[itemNameFromSkin], skin.Display)
							else
								table.insert(v5[itemNameFromSkin], name2)
							end
						end
					elseif k == "titles" then
						visible = doesOwnTitle(name2)
					elseif k == "items" then
						visible = doesOwnItem(name2)
					elseif k == "emotes" then
						visible = Data.Emotes:Get(name2)
					elseif k == "decors" then
						visible = doesOwnDecor(name2)
					end

					local hidden = v7:FindFirstChild("Hidden", true)
					hidden.Visible = visible
				end
			end

			if next(v5) then
				local v6 = {}

				for k, list in next, v5, nil do
					local item = ShopUtil:GetItem(k)

					if item then
						table.insert(v6, (`* You need {item.Display} to use: {table.concat(list, ",")}.`))
					end
				end

				clone.Disclaimer.Text = table.concat(v6, "\n")
				clone.Disclaimer.Visible = true
			else
				clone.Disclaimer.Visible = false
			end

			lastTime = tick()
		end
	end)
end

local function updatePatterns()
	if shop.Pages.Weekly.Visible then
		local count = 0

		if heartbeatConnection then
			return
		end

		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if pages.Weekly.Visible then
				count += 1

				if count < 5 then
					return
				end

				count = 0

				for i = #v2, 1, -1 do
					local v3 = v2[i]

					if v3:FindFirstAncestorOfClass("CanvasGroup") and v3:FindFirstChild("Icon") then
						v3.Icon.Pattern.Image.Size = UDim2.new(1, 50, 1, 50 + tick() * 50 % 20)
					else
						table.remove(v2, i)
					end
				end
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end)
	elseif heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function update()
	local banners = workspace:GetAttribute("Banners")

	if not banners then
		return
	end

	local jSONDecode = HttpService:JSONDecode(banners)

	for _, canvasGroup in script.Parent:GetChildren() do
		if not canvasGroup:IsA("CanvasGroup") or jSONDecode[canvasGroup.Name] then
			continue
		end

		canvasGroup:Destroy()
	end

	for k, _ in jSONDecode do
		updateBanner(k)
	end
end

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Visible then
		script.Sounds:GetChildren()[math.random(1, #script.Sounds:GetChildren())]:Play()
	end
end)
workspace:GetAttributeChangedSignal("EnableCreditBanners"):Connect(function()
	local visible = workspace:GetAttribute("EnableCreditBanners") and true or false

	for _, canvasGroup in script.Parent:GetChildren() do
		if not canvasGroup:IsA("CanvasGroup") then
			continue
		end

		local buttonContainer = canvasGroup:FindFirstChild("ButtonContainer", true)

		if not buttonContainer then
			continue
		end

		for _, guiObject in buttonContainer:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Name:match("Credit") then
				guiObject.Visible = visible
			end
		end
	end
end)
shop.Pages.Weekly:GetPropertyChangedSignal("Visible"):Connect(updatePatterns)
workspace:GetAttributeChangedSignal("Banners"):Connect(update)
update()