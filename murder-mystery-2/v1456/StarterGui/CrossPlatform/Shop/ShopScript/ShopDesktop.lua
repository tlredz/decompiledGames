local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage2:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local ItemService = require(ReplicatedStorage4:WaitForChild("ClientServices"):WaitForChild("ItemService"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local ItemPopupService = require(ReplicatedStorage5:WaitForChild("ClientServices"):WaitForChild("ItemPopupService"))
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage6:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent.Parent
local ShopService = require(script.Parent:WaitForChild("ShopService"))
local newShop = Sync.NewShop
local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
local shop = ReplicatedStorage7:WaitForChild("Remotes"):WaitForChild("Shop")
local ReplicatedStorage8 = game:GetService("ReplicatedStorage")
local inventory = ReplicatedStorage8:WaitForChild("Remotes"):WaitForChild("Inventory")
local medium = parent:WaitForChild("Medium")
local main = medium:WaitForChild("Container"):WaitForChild("Container"):WaitForChild("Main")
local title = medium:WaitForChild("Title")
local container = medium:WaitForChild("Container"):WaitForChild("Container"):WaitForChild("Nav"):WaitForChild("Container")
local processing = medium:WaitForChild("Container"):WaitForChild("Processing")
local radioCover = main:WaitForChild("Items"):WaitForChild("Container"):WaitForChild("RadioCover")
local viewContents = main:WaitForChild("ViewContents")
local itemFrame = viewContents:WaitForChild("Container"):WaitForChild("BoxFrame"):WaitForChild("ItemFrame")
local currencies = viewContents:WaitForChild("Container"):WaitForChild("BuyFrame"):WaitForChild("Currencies")
local container2 = viewContents:WaitForChild("Container"):WaitForChild("BoxContents"):WaitForChild("Container")
local purchaseOptions = viewContents:WaitForChild("Container"):WaitForChild("BuyFrame"):WaitForChild("PurchaseOptions")
local buyPopup = main:WaitForChild("BuyPopup")
local itemFrame2 = buyPopup:WaitForChild("Container"):WaitForChild("Left"):WaitForChild("ItemContainer"):WaitForChild("ItemFrame")
local textLabel = buyPopup:WaitForChild("Container"):WaitForChild("Right"):WaitForChild("Description"):WaitForChild("TextLabel")
local priceFrame = buyPopup:WaitForChild("Container"):WaitForChild("Right"):WaitForChild("PriceFrame")
local scrollFrame = main:WaitForChild("Items"):WaitForChild("Container"):WaitForChild("ScrollFrame")
local featured = main:WaitForChild("Featured")
local container3 = featured:WaitForChild("HotItems"):WaitForChild("Container")
local v = "Featured"
local v2 = "Featured"
local v3 = nil
local ownedCurrencyFrame = script:WaitForChild("OwnedCurrencyFrame")

local function updateNavButtons()
	for _, button in container:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local name = button.Name

		if v3 == name then
			if v == "Featured" then
				button.Back.Visible = false
				button.IsSelected.Visible = true
			else
				button.Back.Visible = true
				button.IsSelected.Visible = false
			end

			button.NotSelected.Visible = false
		else
			button.Back.Visible = false
			button.IsSelected.Visible = false
			button.NotSelected.Visible = true
		end
	end
end

local function goToPage(p: string)
	for _, frame in main:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = frame.Name == p
		end
	end

	v2 = p
	updateNavButtons()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function goToTab(p: string)
	goToPage("Items")

	if p == "Radios" then
		radioCover.Visible = not localPlayer:GetAttribute("Radio")
	else
		radioCover.Visible = false
	end

	ShopService:SetVisibleItems(scrollFrame, p)
	v3 = p
	updateNavButtons()
end

local function onItemPurchaseRequested(p: string, p2: string)
	local type = newShop[p].Type

	if processing.Visible == true then
		return
	end

	if type == "MysteryBox" or type == "Eggs" then
		processing.Visible = true

		if type == "MysteryBox" then
			if ShopService:RequestUnbox(p, p2, 1) then
				medium.Visible = false
			end
		else
			local v4 = type == "Eggs" and shop.OpenCrate:InvokeServer(p, type, p2)

			if v4 then
				medium.Visible = false
				shop.EggController:Fire(p, v4)
			end
		end

		ItemPopupService.ItemClaimsComplete.Event:Once(function()
			medium.Visible = true
		end)
	else
		processing.Visible = true

		if shop.BuyItemNew:InvokeServer(p, p2) then
			medium.Visible = false
			buyPopup.Visible = false
			ItemPopupService.ItemClaimsComplete.Event:Once(function()
				medium.Visible = true
			end)
		end
	end

	processing.Visible = false
end

local connections = {}

local function viewBoxContents(p: string, p2: string)
	ShopService:ViewBoxContents(itemFrame, container2, purchaseOptions, p, p2)

	for _, connection in connections do
		connection:Disconnect()
	end

	for _, frame in currencies:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for k, _ in newShop[p].Price do
		if not (k ~= "Coins" and k ~= "Gems") then
			continue
		end

		local v4 = ItemService:FindItemInfo(k, "Materials") or ItemService:FindItemInfo(k, "Weapons")

		if not v4 then
			continue
		end

		local clone = ownedCurrencyFrame:Clone()
		clone.Container.Icon.Image = v4.Image
		local layoutOrder = ProfileData.Materials.Owned[k] or ProfileData.Weapons.Owned[k] or 0
		clone.Container.PriceFrame.PriceLabel.Text = ShopService.CommaValue(layoutOrder)
		clone.LayoutOrder = layoutOrder
		local v6 = k
		table.insert(connections, inventory.InventoryDataChanged.Event:Connect(function(p3, p4, value)
			if p4 == v6 then
				clone.Container.PriceFrame.PriceLabel.Text = ShopService.CommaValue(value or 0)
			end
		end))
		clone.Parent = currencies
	end

	for _, rarityChance in Sync[p2][p].RarityChances do
		local child = viewContents.Container.BoxFrame.RarityFrame:FindFirstChild(rarityChance.Rarity)

		if child then
			child.Chance.Text = `{rarityChance.Chance}%`
		end
	end

	viewContents.Container.BoxFrame.RarityFrame.Godly.Chance.Text = ".2%"
end

local function onItemClicked(p: string, p2: string)
	if p2 == "Event" then
		WindowService:ViewFrame("CurrentEvent")
	elseif p2 == "MysteryBox" or p2 == "Eggs" then
		v = v2
		viewBoxContents(p, p2)

		if p2 == "MysteryBox" then
			v3 = "Weapons"
		elseif p2 == "Eggs" then
			v3 = "Pets"
		end

		goToPage("ViewContents")
	else
		ShopService:ViewBuyPopup(itemFrame2, textLabel, priceFrame, p)
		buyPopup.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCallbacks()
	ShopService.ItemClicked.Event:Connect(onItemClicked)
end

local function onLatestMysteryBoxActivated()
	v = "Featured"
	v3 = "Weapons"
	viewBoxContents("MysteryBox2", "MysteryBox")
	goToPage("ViewContents")
end

local function setupFeatured()
	local itemFrame3 = featured:WaitForChild("Box"):WaitForChild("ItemFrame")
	ShopService:DisplayItem(itemFrame3, "MysteryBox2", "MysteryBox")
	featured:WaitForChild("Box"):WaitForChild("Buy").Activated:Connect(onLatestMysteryBoxActivated)
	itemFrame3:WaitForChild("Container"):WaitForChild("ActionButton").Activated:Connect(onLatestMysteryBoxActivated)
	ShopService:GenerateFeaturedItems(container3, ShopService.FeaturedItems.Desktop)
end

local function setupNavigation()
	for _, button in container:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local name = button.Name
		button.Activated:Connect(function()
			if v3 == name then
				if v == "Featured" then
					v3 = nil
					goToPage("Featured")
					return
				elseif v == "Items" then
				end
			end

			v = "Featured"
			goToTab(name) -- equivalent call inferred; original call site unknown
		end)
	end

	buyPopup:WaitForChild("Container"):WaitForChild("Close"):WaitForChild("ImageButton").Activated:Connect(function()
		buyPopup.Visible = false
	end)
	buyPopup:WaitForChild("ClickBlock").Activated:Connect(function()
		buyPopup.Visible = false
	end)
end

local function updateCurrency()
	local coins = ProfileData.Materials.Owned.Coins or 0
	local gems = ProfileData.Materials.Owned.Gems or 0
	local amount = title:WaitForChild("Coins"):WaitForChild("Container"):WaitForChild("Amount")
	amount.Text = ShopService.CommaValue(coins)
	local amount_2 = title:WaitForChild("Gems"):WaitForChild("Container"):WaitForChild("Amount")
	amount_2.Text = ShopService.CommaValue(gems)
end

local function onInitialize()
	setupFeatured()
	setupNavigation()
	setupCallbacks() -- equivalent call inferred; original call site unknown
	ShopService:ConnectItemChances(
		viewContents:WaitForChild("Container"):WaitForChild("ItemChances"),
		viewContents.Container:WaitForChild("BoxFrame"):WaitForChild("ViewOddsFrame"):WaitForChild("Button")
	)
	ShopService:ConnectPurchaseCurrency(main:WaitForChild("PurchaseCurrency"))
	medium:WaitForChild("Title"):WaitForChild("Gems"):WaitForChild("GetMore"):WaitForChild("Button").Activated:Connect(function()
		goToPage("PurchaseCurrency")
	end)
	ShopService:GenerateShopItems(scrollFrame)
	WindowService:RegisterFrame(medium, "Shop", function(p)
		if not p then
			return
		end

		local targetFrame = p.TargetFrame

		if not targetFrame then
			return
		end

		if targetFrame == "ViewContents" then
			local targetItem = p.TargetItem

			if not targetItem then
				return
			end

			v = "Featured"
			v3 = "Weapons"
			viewBoxContents(targetItem, "MysteryBox")
			goToPage("ViewContents")
		else
			goToTab(targetFrame) -- equivalent call inferred; original call site unknown

			if p.TargetItem then
				ShopService:ViewBuyPopup(itemFrame2, textLabel, priceFrame, p.TargetItem)
				buyPopup.Visible = true
			end
		end
	end)
	ShopService.ItemPurchaseRequested.Event:Connect(onItemPurchaseRequested)
	ShopService.PurchaseGemsRequested.Event:Connect(function()
		v = v2
		goToPage("PurchaseCurrency")
	end)
	updateCurrency()
	inventory:WaitForChild("InventoryDataChanged").Event:Connect(function(_, p, _)
		if p == "Gems" or p == "Coins" then
			updateCurrency()
		end
	end)
	localPlayer:GetAttributeChangedSignal("Radio"):Connect(function()
		if localPlayer:GetAttribute("Radio") then
			radioCover.Visible = false
		end
	end)
	radioCover:WaitForChild("Container"):WaitForChild("BuyFrame"):WaitForChild("Buy").Activated:Connect(function()
		shop.GetRadio:FireServer()
	end)
	EventInfoService:OnEventStarted(function(p)
		if p.EventStartInfo.FeaturedItems then
			ShopService:GenerateFeaturedItems(container3, p.EventStartInfo.FeaturedItems.Desktop)
		end

		if p.EventStartInfo.ShopData then
			ShopService:GenerateShopItems(scrollFrame)
		end
	end)
	goToPage("Featured")
end

onInitialize()