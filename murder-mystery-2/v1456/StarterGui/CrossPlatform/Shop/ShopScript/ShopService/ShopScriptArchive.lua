-- failed to load script (decompiled with syntax error):
-- cBhGpMTGWRaXPTawiMEwBTMoN:30: Ambiguous syntax: this looks like an argument list for a function call, but could also be a start of new statement; use ';' to separate statements

local v = {
	"Event",
	"MysteryBox2",
	"Dual",
	"Electric"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage2:WaitForChild("ClientServices"):WaitForChild("Button"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ItemService = require(ReplicatedStorage3:WaitForChild("ClientServices"):WaitForChild("ItemService"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage5:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local inventory = ReplicatedStorage6:WaitForChild("Remotes"):WaitForChild("Inventory")
local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
local shop = ReplicatedStorage7:WaitForChild("Remotes"):WaitForChild("Shop")
local newShop = Sync.NewShop
local parent = script.Parent
local small = parent:WaitForChild("Small")
local container = parent:WaitForChild("Small"):WaitForChild("Container")
local main = container:WaitForChild("Main")
local container2 = container:WaitForChild("Title"):WaitForChild("Container")
({
	Navigation = {
		ButtonsList = nil
	},
	Featured = {
		LatestBox = nil,
		ItemsList = nil
	}
}).Navigation.ButtonsList = small:WaitForChild("Container"):WaitForChild("Main"):WaitForChild("Featured"):WaitForChild("Nav"):WaitForChild("Container")
local featured = main:WaitForChild("Featured")
local nav = featured:WaitForChild("Nav")
local buyPopup = main:WaitForChild("BuyPopup")
local viewContents = main:WaitForChild("ViewContents")
local scrollingFrame = viewContents:WaitForChild("Container"):WaitForChild("Main"):WaitForChild("BoxContents"):WaitForChild("Container"):WaitForChild("ScrollingFrame")
local purchaseCurrency = main:WaitForChild("PurchaseCurrency")
local processing = small:WaitForChild("Processing")
local scrollFrame = main:WaitForChild("Items"):WaitForChild("Container"):WaitForChild("ScrollFrame")
local itemGridLayout = scrollFrame:WaitForChild("ItemGridLayout")
local newItem = scrollFrame:WaitForChild("NewItem")
local gems = newItem:WaitForChild("Container"):WaitForChild("Prices"):WaitForChild("Gems")
gems.Parent = script
local gems2 = buyPopup:WaitForChild("Container"):WaitForChild("Right"):WaitForChild("PriceFrame"):WaitForChild("Gems")
gems2.Parent = script
local newItem2 = scrollingFrame:WaitForChild("NewItem")
newItem2.Parent = script
local currencyFrame = viewContents:WaitForChild("Container"):WaitForChild("BuyFrame"):WaitForChild("CurrencyFrame")
currencyFrame.Parent = script
local itemFrame = featured:WaitForChild("Container"):WaitForChild("ItemFrame")
itemFrame.Parent = script
local v2 = {
	Weapons = {
		Weapons = true,
		MysteryBox = true,
		ItemBundle = true
	}
}
local v3 = {
	MysteryBox = "Mystery Box",
	Event = "Event",
	Effects = "Effect"
}
local v4 = {
	Godly = 10,
	Legendary = 20,
	Rare = 30,
	Uncommon = 40,
	Common = 50
}
local v5 = {}
v5[1] = "Featured"

local function comma_value(value)
	repeat
		local v6
		value, v6 = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v6 == 0

	return value
end

local function GoToPage(main2, p: string)
	local back = container2:WaitForChild("Back")
	back.Visible = p ~= "Featured"
	local title = container2:WaitForChild("Title")
	title.Visible = p == "Featured"

	for _, guiObject in main2:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = guiObject.Name == p
		end
	end
end

local function GoBack()
	table.remove(v5)
	GoToPage(main, v5[#v5])
end

local function GetCurrentPage(instance)
	for _, guiObject in instance:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Visible then
			return guiObject
		end
	end
end

local function GetSortedItemList()
	local v6 = {}

	for k, shop2 in newShop do
		if ItemService:FindItemInfo(k, shop2.Type) then
			table.insert(v6, {
				ID = k,
				Info = ItemService:GetItemInfo(k, shop2.Type),
				Shop = shop2
			})
		end
	end

	table.sort(v6, function(a, b)
		local _ = a.ID
		local info = a.Info
		local shop2 = a.Shop
		local _ = b.ID
		local info2 = b.Info
		local shop3 = b.Shop
		local rarity = info.Rarity or "Common"
		local rarity2 = info2.Rarity or "Common"

		if rarity ~= rarity2 then
			return v4[rarity] > v4[rarity2]
		end

		if shop2.Price.Coins and shop3.Price.Coins then
			return shop2.Price.Coins < shop3.Price.Coins
		end

		if shop2.Price.Coins and not shop3.Price.Coins then
			return true
		end

		if shop2.Price.Gems and shop3.Price.Gems then
			return shop2.Price.Gems < shop3.Price.Gems
		end

		return v4[rarity] > v4[rarity2]
	end)
	local IDs = {}

	for _, v7 in v6 do
		table.insert(IDs, v7.ID)
	end

	return IDs
end

local function onItemPurchaseRequested(p: string, p2: string)
	local type = newShop[p].Type

	if type == "MysteryBox" or type == "Eggs" then
		processing.Visible = true
		local v6 = shop.OpenCrate:InvokeServer(p, type, p2)
		small.Visible = false
		processing.Visible = false
		shop.BoxController:Fire(p, v6)
	else
		processing.Visible = true
		shop.BuyItemNew:InvokeServer(p, p2)
		small.Visible = false
		processing.Visible = false
	end
end

local function ViewBoxContents(p: string, p2: string)
	local itemContainer = viewContents:WaitForChild("Container"):WaitForChild("Main"):WaitForChild("BoxFrame"):WaitForChild("ItemContainer")
	local v6 = newShop[p]
	local displayInfo = ItemService:GetDisplayInfo(p, p2)
	itemContainer.Container.Icon.Image = displayInfo.Image
	itemContainer.ItemName.TextLabel.Text = displayInfo.Name
	itemContainer.ItemName.BackgroundColor3 = displayInfo.Color
	local itemInfo = ItemService:GetItemInfo(p, p2)
	local contents = itemInfo.Contents

	for _, frame in scrollingFrame:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for k, content in contents do
		local clone = newItem2:Clone()
		local displayInfo2 = ItemService:GetDisplayInfo(content, itemInfo.BoxType)
		clone.Container.Icon.Image = displayInfo2.Image
		clone.ItemName.TextLabel.Text = displayInfo2.Name
		clone.ItemName.BackgroundColor3 = displayInfo2.Color
		clone.Container.OwnedText.Visible = false
		clone.Container.OwnedBackground.Visible = false
		clone.LayoutOrder = k
		clone.Parent = scrollingFrame
	end

	for _, frame in viewContents.Container.BuyFrame:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for k, layoutOrder in v6.Price do
		local itemInfo2

		if ItemService:ItemExists(k, "Materials") then
			itemInfo2 = ItemService:GetItemInfo(k, "Materials")
		elseif ItemService:ItemExists(k, "Weapons") then
			itemInfo2 = ItemService:GetItemInfo(k, "Weapons")
		else
			warn("Currency does not exist")
			continue
		end

		local itemImage = ItemService:GetItemImage(itemInfo2)
		local clone = currencyFrame:Clone()
		clone.Container.Icon.Image = itemImage
		clone.Container.PriceFrame.PriceLabel.Text = comma_value(layoutOrder)
		local v8 = k
		clone.Buy.Activated:Connect(function()
			onItemPurchaseRequested(p, v8)
		end)
		clone.LayoutOrder = layoutOrder
		clone.Parent = viewContents.Container.BuyFrame
	end

	table.insert(v5, "ViewContents")
	GoToPage(main, "ViewContents")
end

local function ViewBuyPopup(p: string)
	local v6 = newShop[p]
	local displayInfo = v6.DisplayInfo or ItemService:GetDisplayInfo(p, v6.Type)
	local itemContainer = buyPopup:WaitForChild("Container"):WaitForChild("Left"):WaitForChild("ItemFrame"):WaitForChild("ItemContainer")
	local v7 = ItemService:FindItemInfo(p, v6.Type) or {}
	itemContainer.Container.Icon.Image = displayInfo.Image
	itemContainer.ItemName.TextLabel.Text = displayInfo.Name
	itemContainer.ItemName.BackgroundColor3 = displayInfo.Color
	buyPopup.Container.Right.Description.TextLabel.Text = v6.Description or v7.Description or ""

	for _, frame in buyPopup.Container.Right.PriceFrame:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for k, layoutOrder in v6.Price do
		local itemInfo

		if ItemService:ItemExists(k, "Materials") then
			itemInfo = ItemService:GetItemInfo(k, "Materials")
		elseif ItemService:ItemExists(k, "Weapons") then
			itemInfo = ItemService:GetItemInfo(k, "Weapons")
		else
			warn("Currency does not exist")
			continue
		end

		local itemImage = ItemService:GetItemImage(itemInfo)
		local clone = gems2:Clone()
		clone.Container.Icon.Image = itemImage
		clone.Container.PriceFrame.PriceLabel.Text = comma_value(layoutOrder)
		local v9 = k
		clone.Buy.Activated:Connect(function()
			onItemPurchaseRequested(p, v9)
		end)
		clone.LayoutOrder = layoutOrder
		clone.Parent = buyPopup.Container.Right.PriceFrame
	end

	table.insert(v5, "BuyPopup")
	GoToPage(main, "BuyPopup")
end

local function onCurrencyUpdated()
	local coins = ProfileData.Coins
	local gems3 = ProfileData.Gems
	local amount = container2:WaitForChild("Gems"):WaitForChild("Container"):WaitForChild("Amount")
	amount.Text = comma_value(gems3)
	local amount_2 = container2:WaitForChild("Coins"):WaitForChild("Container"):WaitForChild("Amount")
	amount_2.Text = comma_value(coins)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onItemClicked(p: string, p2: string)
	if p2 == "Event" then
		WindowService:ViewFrame("CurrentEvent")
	elseif p2 == "MysteryBox" or p2 == "Eggs" then
		ViewBoxContents(p, p2)
	else
		ViewBuyPopup(p)
	end
end

local function SetupNavigation()
	for _, button in nav:WaitForChild("Container"):GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v6 = button
		button.Activated:Connect(function()
			table.insert(v5, "Items")
			GoToPage(main, "Items")

			for i, frame in scrollFrame:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				local itemType = frame:GetAttribute("ItemType")

				if v6.Name == "Weapons" then
					frame.Visible = v2.Weapons[itemType]
				elseif v6.Name == "Emotes" then
					frame.Visible = itemType == "Emotes" or itemType == "Toys"
				elseif v6.Name == "Pets" then
					frame.Visible = itemType == "Pets" or itemType == "Eggs"
				else
					frame.Visible = frame:GetAttribute("ItemType") == v6.Name
				end
			end
		end)
	end
end

local function GenerateShopItems()
	local sortedItemList = GetSortedItemList()

	for k, v7 in newShop do
		local type = v7.Type
		local clone = newItem:Clone()
		local displayInfo = v7.DisplayInfo or ItemService:GetDisplayInfo(k, type)
		clone.Container.Icon.Image = displayInfo.Image
		clone.ItemName.TextLabel.Text = displayInfo.Name
		clone.ItemName.BackgroundColor3 = displayInfo.Color
		clone.LayoutOrder = v7.LayoutOrder or table.find(sortedItemList, k) or 0

		if v7.Type ~= "MysteryBox" then
			for k2, layoutOrder in v7.Price do
				local itemInfo

				if ItemService:ItemExists(k2, "Materials") then
					itemInfo = ItemService:GetItemInfo(k2, "Materials")
				elseif ItemService:ItemExists(k2, "Weapons") then
					itemInfo = ItemService:GetItemInfo(k2, "Weapons")
				else
					warn("Currency does not exist")
					continue
				end

				local itemImage = ItemService:GetItemImage(itemInfo)
				local clone2 = gems:Clone()
				clone2.Icon.Title.Image = itemImage
				clone2.Price.Text = comma_value(layoutOrder)
				clone2.LayoutOrder = layoutOrder
				clone2.Parent = clone.Container.Prices
			end
		end

		local v8 = k
		clone.Container.ActionButton.Activated:Connect(function()
			onItemClicked(v8, type) -- equivalent call inferred; original call site unknown
		end)
		clone:SetAttribute("ItemType", type)
		clone.Parent = scrollFrame
	end
end

local function GenerateFeaturedItems()
	for k, v6 in v do
		local v7 = newShop[v6]

		if v7 then
			local clone = itemFrame:Clone()
			local displayInfo = v7.DisplayInfo or ItemService:GetDisplayInfo(v6, v7.Type)
			clone.Container.Icon.Image = displayInfo.Image
			clone.ItemName.TextLabel.Text = displayInfo.Name
			clone.ItemName.BackgroundColor3 = displayInfo.Color
			clone.Container.Subtitle.Text = v3[v7.Type] or v7.Type
			local v8 = v6
			local v9 = v7
			clone.Container.ActionButton.Activated:Connect(function()
				onItemClicked(v8, v9.Type) -- equivalent call inferred; original call site unknown
			end)
			clone.LayoutOrder = k
			clone.Parent = featured:WaitForChild("Container")
		else
			warn("Featured item not found.")
		end
	end
end

local function SetupPurchaseCurrency()
	for _, frame in purchaseCurrency:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v6 = frame
		Button.createButton(frame, function()
			shop.PurchaseProduct:FireServer(v6.Name, "Gems")
		end)
	end

	container2:WaitForChild("Gems"):WaitForChild("GetMore"):WaitForChild("Button").Activated:Connect(function()
		table.insert(v5, "PurchaseCurrency")
		GoToPage(main, "PurchaseCurrency")
	end)
end

local function onInitialize()
	if newItem.AbsoluteSize.Y < 160 then
		itemGridLayout.CellSize = UDim2.new(0.333, -4, 1, 0)
	end

	newItem.Parent = script
	newItem:WaitForChild("Container"):WaitForChild("Prices"):WaitForChild("Coins"):Destroy()
	buyPopup:WaitForChild("Container"):WaitForChild("Right"):WaitForChild("PriceFrame"):WaitForChild("Coins"):Destroy()
	GoToPage(main, "Featured")
	GenerateShopItems()
	GenerateFeaturedItems()
	SetupNavigation()
	SetupPurchaseCurrency()
	onCurrencyUpdated()
	inventory.ProfileDataChanged.Event:Connect(onCurrencyUpdated)
	container2:WaitForChild("Back").Activated:Connect(GoBack)
	WindowService:RegisterFrame(parent:WaitForChild("Small"), "Shop", function()
		v5 = { "Featured" }
	end)
end

onInitialize()