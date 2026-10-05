local ShopService = {}
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ItemService = require(ReplicatedStorage2:WaitForChild("ClientServices"):WaitForChild("ItemService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage4:WaitForChild("ClientServices"):WaitForChild("Button"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local shop = ReplicatedStorage5:WaitForChild("Remotes"):WaitForChild("Shop")
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local inventory = ReplicatedStorage6:WaitForChild("Remotes"):WaitForChild("Inventory")
local newShop = Sync.NewShop
local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
local PolicyManager = require(ReplicatedStorage7:WaitForChild("ClientServices"):WaitForChild("PolicyManager"))
ShopService.ItemClicked = Instance.new("BindableEvent")
ShopService.ItemSelectionGained = Instance.new("BindableEvent")
ShopService.ItemPurchaseRequested = Instance.new("BindableEvent")
ShopService.PurchaseGemsRequested = Instance.new("BindableEvent")
ShopService.FeaturedItems = {
	Desktop = {
		"Dual",
		"Electric",
		"BeachBundleEffect",
		"Trap",
		"Decoy"
	},
	Mobile = {
		"BeachBundleEffect",
		"MysteryBox2",
		"Electric",
		"Dual",
		"Decoy"
	},
	Console = {
		"BeachBundleEffect",
		"MysteryBox2",
		"MysteryBox1",
		"Decoy",
		"Dual",
		"Electric"
	}
}
local v = {
	MysteryBox = "Mystery Box",
	Event = "Event",
	Effects = "Effect",
	ItemBundle = "Bundle",
	Perks = "Perk"
}
local v2 = {
	Unique = 4,
	Ancient = 5,
	Godly = 10,
	Legendary = 20,
	Rare = 30,
	Uncommon = 40,
	Common = 50
}
local v3 = {
	Weapons = {
		Weapons = true,
		MysteryBox = true,
		ItemBundle = true,
		Materials = true
	}
}
local v4 = {
	Weapons = true,
	Pets = true,
	Materials = true
}
local v5 = {
	Key = true,
	CandyExchange = true
}
ShopService.CurrencyPriceFrame = script:WaitForChild("CurrencyPriceFrame")
ShopService.FeaturedItemFrame = script:WaitForChild("FeaturedItemFrame")
ShopService.ShopItemFrame = script:WaitForChild("ShopItemFrame")
ShopService.BoxContentItemFrame = script:WaitForChild("BoxContentItemFrame")
ShopService.ShopItemCurrencyFrame = ShopService.ShopItemFrame:WaitForChild("Container"):WaitForChild("Prices"):WaitForChild("Gems")
ShopService.ShopItemFrame:WaitForChild("Container"):WaitForChild("Prices"):WaitForChild("Coins"):Destroy()
ShopService.ShopItemCurrencyFrame.Parent = script

local function comma_value(value)
	repeat
		local v6
		value, v6 = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v6 == 0

	return value
end

ShopService.CommaValue = comma_value
local clones = {}
local clones2 = {}

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
		local ID = a.ID
		local info = a.Info
		local shop2 = a.Shop
		local ID2 = b.ID
		local info2 = b.Info
		local shop3 = b.Shop
		local rarity = info.Rarity or "Common"
		local rarity2 = info2.Rarity or "Common"
		local itemAlreadyPurchased = ShopService:ItemAlreadyPurchased(ID)

		if itemAlreadyPurchased ~= ShopService:ItemAlreadyPurchased(ID2) then
			return not itemAlreadyPurchased
		end

		if shop2.Limited and not shop3.Limited then
			return true
		end

		if shop3.Limited and not shop2.Limited then
			return false
		end

		if rarity == rarity2 then
			local v7 = shop2.Price.Coins ~= nil
			local v8 = shop3.Price.Coins ~= nil

			if v7 and v8 then
				if shop2.Price.Coins ~= shop3.Price.Coins then
					return shop2.Price.Coins < shop3.Price.Coins
				end
			elseif v7 ~= v8 then
				return v7
			end

			local v9 = shop2.Price.Gems ~= nil
			local v10 = shop3.Price.Gems ~= nil

			if v9 and v10 then
				if shop2.Price.Gems ~= shop3.Price.Gems then
					return shop2.Price.Gems < shop3.Price.Gems
				end
			elseif v9 ~= v10 then
				return v9
			end
		end

		local v7 = v2[rarity] or 0
		local v8 = v2[rarity2] or 0

		if v7 == v8 then
			return ID < ID2
		end

		return v8 < v7
	end)
	local IDs = {}

	for _, v7 in v6 do
		table.insert(IDs, v7.ID)
	end

	return IDs
end

function ShopService:PurchaseIsRepeatable(p: string)
	local v6 = newShop[p]
	local type = v6.Type

	if v6.OneTimePurchase then
		return false
	end

	if v6.DevProductId and not v6.OneTimePurchase or (v4[type] or type == "MysteryBox" or type == "Eggs") then
		return true
	end

	return false
end

function ShopService:HasRequiredPurchases(p: string)
	local v6 = newShop[p]

	if not v6.RequiredPurchases then
		return true
	end

	local count = 0
	local count2 = 0

	for _, requiredPurchas in v6.RequiredPurchases do
		if ProfileData.OneTimePurchases[requiredPurchas] then
			count += 1
		end

		count2 += 1
	end

	return count2 <= count
end

function ShopService:ItemAlreadyPurchased(p: string)
	local v6 = newShop[p]
	local type = v6.Type

	if v6.DevProductId then
		return v6.OneTimePurchase == true and ProfileData.OneTimePurchases[p] == true
	else
		if v6.GamepassId and ProfileData.OneTimePurchases[p] == true then
			return true
		end

		if v4[type] or type == "MysteryBox" or type == "Eggs" then
			return false
		end

		if ProfileData[type] then
			return table.find(ProfileData[type].Owned, p) ~= nil
		end

		return false
	end
end

function ShopService:CanAffordItem(p: string, p2: string)
	if p2 == "Robux" then
		return true
	end

	return newShop[p].Price[p2] <= (ProfileData.Materials.Owned[p2] or ProfileData.Weapons.Owned[p2] or 0)
end

function ShopService:CanPurchaseItem(p: string, p2: string)
	return ShopService:CanAffordItem(p, p2) and not ShopService:ItemAlreadyPurchased(p)
end

function ShopService.GenerateFeaturedItems(_, parent, items)
	for _, frame in parent:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for k, item in items do
		local v6 = newShop[item]

		if v6 then
			local clone = ShopService.FeaturedItemFrame:Clone()
			local displayInfo = v6.DisplayInfo or ItemService:GetDisplayInfo(item, v6.Type)
			clone.Name = item
			clone.Container.Icon.Image = displayInfo.Image
			clone.ItemName.TextLabel.Text = displayInfo.Name
			clone.ItemName.BackgroundColor3 = displayInfo.Color
			clone.Container.Subtitle.Text = v[v6.Type] or v6.Type
			clone.Container.Limited.Visible = v6.Limited == true
			local v7 = item
			local v8 = v6
			clone.Container.ActionButton.Activated:Connect(function()
				ShopService.ItemClicked:Fire(v7, v8.Type)
			end)

			if UserInputService.GamepadEnabled then
				local v9 = item
				local v10 = v6
				clone.Container.ActionButton.SelectionGained:Connect(function()
					ShopService.ItemSelectionGained:Fire(v9, v10.Type)
				end)
			end

			clone.LayoutOrder = k
			clone.Parent = parent
		else
			warn("Featured item not found.")
		end
	end
end

function ShopService.SetVisibleItems(_, instance, p: string)
	for _, frame in instance:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local name = frame.Name
		local itemType = frame:GetAttribute("ItemType")
		local _ = newShop[name]

		if newShop[name] then
			if ShopService:HasRequiredPurchases(name) then
				if p == "Weapons" then
					frame.Visible = v3.Weapons[itemType]
				elseif p == "Emotes" then
					frame.Visible = itemType == "Emotes" or itemType == "Toys"
				elseif p == "Pets" then
					frame.Visible = itemType == "Pets" or itemType == "Eggs"
				else
					frame.Visible = frame:GetAttribute("ItemType") == p
				end
			else
				frame.Visible = false
			end
		else
			frame.Visible = false
		end
	end
end

function ShopService.GenerateShopItems(_, parent)
	local sortedItemList = GetSortedItemList()

	for k, v7 in newShop do
		if clones2[k] or v5[k] and PolicyManager.ArePaidRandomItemsRestricted or v7.Hidden then
			continue
		end

		local type = v7.Type
		local clone = ShopService.ShopItemFrame:Clone()
		local displayInfo = v7.DisplayInfo or ItemService:GetDisplayInfo(k, type)
		clone.Name = k
		clone.Container.Icon.Image = displayInfo.Image
		clone.ItemName.TextLabel.Text = displayInfo.Name
		clone.ItemName.BackgroundColor3 = displayInfo.Color
		clone.Container.Limited.Visible = v7.Limited == true
		clone.LayoutOrder = v7.LayoutOrder or table.find(sortedItemList, k) or 0

		if v7.Type ~= "MysteryBox" then
			if ShopService:ItemAlreadyPurchased(k) then
				clone.Container.Prices.OwnedPrice.Visible = true
			else
				if not ShopService:PurchaseIsRepeatable(k) then
					clones[k] = clone
				end

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
					local clone2 = ShopService.ShopItemCurrencyFrame:Clone()
					clone2.Icon.Title.Image = itemImage
					clone2.Price.Text = comma_value(layoutOrder)
					clone2.LayoutOrder = layoutOrder
					clone2.Parent = clone.Container.Prices
				end
			end
		end

		local v8 = k
		clone.Container.ActionButton.Activated:Connect(function()
			ShopService.ItemClicked:Fire(v8, type)
		end)

		if UserInputService.GamepadEnabled then
			local v10 = k
			local v11 = v7
			clone.Container.ActionButton.SelectionGained:Connect(function()
				ShopService.ItemSelectionGained:Fire(v10, v11.Type)
			end)
		end

		clone:SetAttribute("ItemType", type)
		clone.Parent = parent
		clones2[k] = clone
	end
end

function ShopService.ViewBuyPopup(_, p, p2, parent, p3: string)
	local v6 = newShop[p3]
	local displayInfo = v6.DisplayInfo or ItemService:GetDisplayInfo(p3, v6.Type)
	local v7 = ItemService:FindItemInfo(p3, v6.Type) or {}
	p.Container.Icon.Image = displayInfo.Image
	p.ItemName.TextLabel.Text = displayInfo.Name
	p.ItemName.BackgroundColor3 = displayInfo.Color
	p2.Text = v6.Description or v7.Description or ""

	for _, frame in parent:GetChildren() do
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
		local clone = ShopService.CurrencyPriceFrame:Clone()
		clone.LayoutOrder = layoutOrder
		clone.Container.Icon.Image = itemImage
		clone.Container.PriceFrame.PriceLabel.Text = comma_value(layoutOrder)
		clone.Buy.Style = ShopService:CanPurchaseItem(p3, k) and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
		local v9 = k
		clone.Buy.Activated:Connect(function()
			if v9 == "Gems" and not (ShopService:ItemAlreadyPurchased(p3, v9) or ShopService:CanAffordItem(p3, v9)) then
				ShopService.PurchaseGemsRequested:Fire()
				return
			end

			if not ShopService:CanPurchaseItem(p3, v9) then
				return
			end

			ShopService.ItemPurchaseRequested:Fire(p3, v9)
		end)
		clone.LayoutOrder = layoutOrder
		clone.Parent = parent
	end
end

function ShopService.ViewBoxContents(_, p, parent, parent2, viewedBoxId: string, viewedBoxType: string)
	ShopService.ViewedBoxId = viewedBoxId
	ShopService.ViewedBoxType = viewedBoxType

	if ShopService.ItemChancesFrame then
		ShopService.ItemChancesFrame.Visible = false
	end

	local v6 = newShop[viewedBoxId]
	local displayInfo = ItemService:GetDisplayInfo(viewedBoxId, viewedBoxType)
	p.Container.Icon.Image = displayInfo.Image
	p.ItemName.TextLabel.Text = displayInfo.Name
	p.ItemName.BackgroundColor3 = displayInfo.Color
	local itemInfo = ItemService:GetItemInfo(viewedBoxId, viewedBoxType)
	local contents = itemInfo.Contents

	for _, frame in parent:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for k, content in contents do
		local clone = ShopService.BoxContentItemFrame:Clone()
		local displayInfo2 = ItemService:GetDisplayInfo(content, itemInfo.BoxType)
		clone.Name = content
		clone.Container.Icon.Image = displayInfo2.Image
		clone.ItemName.TextLabel.Text = displayInfo2.Name
		clone.ItemName.BackgroundColor3 = displayInfo2.Color
		clone.Container.OwnedText.Visible = false
		clone.Container.OwnedBackground.Visible = false
		clone.LayoutOrder = k
		clone.Parent = parent
	end

	for _, frame in parent2:GetChildren() do
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

		if not (k ~= "Gems" or not PolicyManager.ArePaidRandomItemsRestricted) then
			continue
		end

		local itemImage = ItemService:GetItemImage(itemInfo2)
		local clone = ShopService.CurrencyPriceFrame:Clone()
		clone.Container.Icon.Image = itemImage
		clone.Container.PriceFrame.PriceLabel.Text = comma_value(layoutOrder)
		clone.Buy.Style = ShopService:CanAffordItem(viewedBoxId, k) and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
		local v8 = k
		clone.Buy.Activated:Connect(function()
			if v8 == "Gems" and not (ShopService:ItemAlreadyPurchased(viewedBoxId, v8) or ShopService:CanAffordItem(
				viewedBoxId,
				v8
			)) then
				ShopService.PurchaseGemsRequested:Fire()
				return
			end

			if not ShopService:CanPurchaseItem(viewedBoxId, v8) then
				return
			end

			ShopService.ItemPurchaseRequested:Fire(viewedBoxId, v8)
		end)
		clone.LayoutOrder = layoutOrder
		clone.Parent = parent2
	end
end

local clone = nil
local clone2 = nil

function ShopService:PopulateItemChances(instance, p: string, p2: string)
	local scrollingFrame = instance:FindFirstChild("ScrollingFrame")
	local itemInfo = ItemService:GetItemInfo(p, p2)
	local rarity = Sync.Rarity

	if not clone then
		clone = scrollingFrame:FindFirstChild("Common"):Clone()
		clone2 = scrollingFrame:FindFirstChild("Common1"):Clone()
	end

	for _, label in scrollingFrame:GetChildren() do
		if label:IsA("TextLabel") and label.Name ~= "Title" then
			label:Destroy()
		end
	end

	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addLabel(instance2, text: string, color: Color3?)
		count += 1
		local clone3 = instance2:Clone()
		clone3.Name = `Chance{count}`
		clone3.Text = text
		clone3.TextColor3 = color or Color3.new(1, 1, 1)
		clone3.LayoutOrder = count
		clone3.Parent = scrollingFrame
	end

	local function getItemName(displayName: string)
		local itemInfo2 = ItemService:FindItemInfo(displayName, itemInfo.BoxType)

		if itemInfo2 then
			displayName = ItemService:GetDisplayName(itemInfo2) or displayName
		end

		return displayName
	end

	local v6 = {}

	for _, content in itemInfo.Contents do
		local itemInfo2 = ItemService:FindItemInfo(content, itemInfo.BoxType)
		local rarity2 = itemInfo2 and itemInfo2.Rarity or "Common"
		v6[rarity2] = v6[rarity2] or {}
		table.insert(v6[rarity2], content)
	end

	for _, rarityChance in itemInfo.RarityChances do
		local v7 = v6[rarityChance.Rarity]

		if not v7 then
			continue
		end

		addLabel(clone, `{rarityChance.Rarity}: {rarityChance.Chance}%`, rarity[rarityChance.Rarity]) -- equivalent call inferred; original call site unknown

		for _, displayName in v7 do
			local v10 = string.format("%.2f", rarityChance.Chance / #v7)
			local v11 = clone2
			local itemInfo2 = ItemService:FindItemInfo(displayName, itemInfo.BoxType)

			if itemInfo2 then
				displayName = ItemService:GetDisplayName(itemInfo2) or displayName
			end

			local formatted2 = `{displayName} - {rarityChance.Chance}%/{#v7} = {v10}%`
			count += 1
			local clone3 = v11:Clone()
			clone3.Name = `Chance{count}`
			clone3.Text = formatted2
			clone3.TextColor3 = Color3.new(1, 1, 1)
			clone3.LayoutOrder = count
			clone3.Parent = scrollingFrame
		end
	end

	local v7 = {}

	if itemInfo.Godly then
		table.insert(v7, itemInfo.Godly)
	elseif itemInfo.GodlyTable then
		for _, v8 in itemInfo.GodlyTable do
			table.insert(v7, v8)
		end
	elseif itemInfo.GodlyTag then
		for _, content in itemInfo.Contents do
			table.insert(v7, content .. itemInfo.GodlyTag)
		end
	end

	if #v7 > 0 then
		addLabel(clone, `Godly: {0.2}%`, rarity.Godly) -- equivalent call inferred; original call site unknown

		for _, displayName in v7 do
			if #v7 == 1 then
				local v9 = clone2
				local itemInfo2 = ItemService:FindItemInfo(displayName, itemInfo.BoxType)

				if itemInfo2 then
					displayName = ItemService:GetDisplayName(itemInfo2) or displayName
				end

				local formatted2 = `{displayName} - {0.2}%`
				count += 1
				local clone3 = v9:Clone()
				clone3.Name = `Chance{count}`
				clone3.Text = formatted2
				clone3.TextColor3 = Color3.new(1, 1, 1)
				clone3.LayoutOrder = count
				clone3.Parent = scrollingFrame
			else
				local v9 = string.format("%.3f", 0.2 / #v7)
				local v10 = clone2
				local itemInfo2 = ItemService:FindItemInfo(displayName, itemInfo.BoxType)

				if itemInfo2 then
					displayName = ItemService:GetDisplayName(itemInfo2) or displayName
				end

				local formatted2 = `{displayName} - {0.2}%/{#v7} = {v9}%`
				count += 1
				local clone3 = v10:Clone()
				clone3.Name = `Chance{count}`
				clone3.Text = formatted2
				clone3.TextColor3 = Color3.new(1, 1, 1)
				clone3.LayoutOrder = count
				clone3.Parent = scrollingFrame
			end
		end

		local v9 = itemInfo.ChromaTable ~= nil or itemInfo.GodlyTag ~= nil

		if not v9 then
			for _, v11 in v7 do
				if not ItemService:FindItemInfo(v11 .. "Chroma", itemInfo.BoxType) then
					continue
				end

				v9 = true
				break
			end
		end

		if v9 then
			local v10 = clone2
			local formatted2 = `Chroma - {string.format("%g", 0.004)}%`
			count += 1
			local clone3 = v10:Clone()
			clone3.Name = `Chance{count}`
			clone3.Text = formatted2
			clone3.TextColor3 = Color3.new(1, 1, 1)
			clone3.LayoutOrder = count
			clone3.Parent = scrollingFrame
		end
	end
end

function ShopService.ConnectItemChances(_, itemChancesFrame, p)
	ShopService.ItemChancesFrame = itemChancesFrame
	p.Activated:Connect(function()
		if not ShopService.ViewedBoxId then
			return
		end

		ShopService:PopulateItemChances(itemChancesFrame, ShopService.ViewedBoxId, ShopService.ViewedBoxType)
		itemChancesFrame.Visible = true
	end)
	itemChancesFrame:WaitForChild("Close"):WaitForChild("Button").Activated:Connect(function()
		itemChancesFrame.Visible = false
	end)
	local parent = itemChancesFrame.Parent

	while parent and parent:IsA("GuiObject") do
		local v6 = parent
		parent:GetPropertyChangedSignal("Visible"):Connect(function()
			if not v6.Visible then
				itemChancesFrame.Visible = false
			end
		end)
		parent = parent.Parent
	end
end

function ShopService.RequestUnbox(_, mysteryBoxId: string, p2: string, p3: number)
	if p3 <= 0 or p3 > 3 then
		return
	end

	local result = {}

	for i = 1, p3 do
		local rewardedItemId = shop.OpenCrate:InvokeServer(mysteryBoxId, "MysteryBox", p2)

		if rewardedItemId then
			result[i] = {
				MysteryBoxId = mysteryBoxId,
				RewardedItemId = rewardedItemId
			}
		end
	end

	shop.BoxController:Fire(result)
	return result
end

function ShopService.ConnectPurchaseCurrency(_, instance)
	for _, frame in instance:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v6 = frame
		Button.createButton(frame, function()
			shop.BuyItemNew:InvokeServer(v6.Name, "Robux")
		end)
	end
end

function ShopService.DisplayItem(_, p, p2: string, p3: string, value: string?)
	local displayInfo = newShop[p2].DisplayInfo or ItemService:GetDisplayInfo(p2, p3)
	p.Container.Icon.Image = displayInfo.Image
	p.ItemName.TextLabel.Text = displayInfo.Name
	p.ItemName.BackgroundColor3 = displayInfo.Color
	p.Container.Subtitle.Text = value or ""
end

shop:WaitForChild("ProductPurchaseComplete").OnClientEvent:Connect(function(p: string, _: number)
	for k, v6 in clones2 do
		local v7 = newShop[k]

		if not (v7.RequiredPurchases and table.find(v7.RequiredPurchases, p) and ShopService:HasRequiredPurchases(k) and clones2[p]) then
			continue
		end

		if not clones2[p].Visible then
			continue
		end

		v6.Visible = true
	end

	if clones[p] then
		for _, frame in clones[p].Container.Prices:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name == "OwnedPrice"
			end
		end
	end
end)
inventory:WaitForChild("InventoryDataChanged").Event:Connect(function(_, p, p2)
	if clones[p] and p2 > 0 then
		for _, frame in clones[p].Container.Prices:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name == "OwnedPrice"
			end
		end
	end
end)

function ShopService.Initialize(_) end

return ShopService