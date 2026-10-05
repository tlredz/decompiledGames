local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage3:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage5:WaitForChild("Remotes")
local ItemModule = require(script.Parent.ItemModule)
require(game.ReplicatedStorage.Modules.BoxModule)
require(game.ReplicatedStorage.Modules.XboxModule)
local featured = Sync.Featured
local hotItems = script.HotItems
local shop = Sync.Shop
local purchaseOption = script:WaitForChild("PurchaseOption")
local purchaseOptionFrame = script:WaitForChild("PurchaseOptionFrame")
local v = {
	Coins = {
		DisplayName = "Coins",
		Icon = "rbxassetid://3150319038"
	},
	Gems = {
		DisplayName = "Gems",
		Icon = "rbxassetid://377010926"
	}
}
local ShopModule = {
	GUI = {}
}
local v3 = "Featured"
local v4 = {
	Gems = true,
	Candies2024 = true
}
local boxType = "Featured"
local v5 = nil
local v6 = nil
local v7 = nil

for k, material in Sync.Materials do
	if material.Currency then
		v[k] = {
			DisplayName = material.ItemName or material.Name,
			Icon = material.Image
		}
	end
end

for _, v8 in { "Key" } do
	local v9 = Sync.Item[v8]
	v[v8] = {
		DisplayName = v9.ItemName or v9.Name,
		Icon = v9.Image or v9.Icon
	}
end

local function CheckForItem(p, p2)
	if ProfileData[p2].Owned[p] then
		return true
	end

	for _, v8 in ProfileData[p2].Owned do
		if v8 == p then
			return true
		end
	end

	return false
end

function ShopModule.CheckOwned(p, p2)
	if p2 == "Weapons" or p2 == "Pets" or p2 == "MysteryBox" or p2 == "Eggs" or p2 == "Item" then
		return false
	end

	if ProfileData[p2].Owned[p] then
		return true
	end

	for _, v8 in ProfileData[p2].Owned do
		if v8 == p then
			return true
		end
	end

	return false
end

function ShopModule.SelectObject() end

function ShopModule.BuyItem(p, p2, p3, p4)
	local v8 = shop[p2][p]
	local dataType = v8.DataType or p2
	local price = v8.Price
	local v9

	if p3 == "Coins" or p3 == "Gems" then
		v9 = ProfileData[p3] >= price[p3]
	else
		v9 = (ProfileData.Materials.Owned[p3] or 0) >= price[p3]
	end

	if v9 then
		local v10

		if dataType == "Weapons" or dataType == "Pets" or dataType == "MysteryBox" or dataType == "Eggs" or dataType == "Item" then
			v10 = false
		elseif ProfileData[dataType].Owned[p] then
			v10 = true
		else
			local flag = true

			for _, v11 in ProfileData[dataType].Owned do
				if v11 ~= p then
					continue
				end

				v10 = true
				flag = false
				break
			end

			if flag then
				v10 = false
			end
		end

		if not v10 then
			p4.PriceFrame[p3].Visible = false
			p4.PriceFrame.PurchaseLoading.LayoutOrder = p4.PriceFrame[p3].LayoutOrder
			p4.PriceFrame.PurchaseLoading.Visible = true
			spawn(function()
				while p4.PriceFrame.PurchaseLoading.Visible == true do
					p4.PriceFrame.PurchaseLoading.Container.Spinner.Rotation = p4.PriceFrame.PurchaseLoading.Container.Spinner.Rotation + 5
					local RunService = game:GetService("RunService")
					RunService.RenderStepped:wait()
				end
			end)
			local v11 = game.ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(p, p2, p3)
			p4.PriceFrame.PurchaseLoading.Visible = false

			if v11 then
				local _ = v8.ExchangeAmount
				ShopModule.UpdateShopFrames()
			end

			ShopModule.SelectObject(true)
			return
		end
	end

	local flag

	if dataType == "Weapons" or dataType == "Pets" or dataType == "MysteryBox" or dataType == "Eggs" or dataType == "Item" then
		flag = false
	elseif ProfileData[dataType].Owned[p] then
		flag = true
	else
		local flag2 = true

		for _, v10 in ProfileData[dataType].Owned do
			if v10 ~= p then
				continue
			end

			flag = true
			flag2 = false
			break
		end

		if flag2 then
			flag = false
		end
	end

	if flag then
		ShopModule.SelectObject()
	elseif p3 == "Gems" and price.Gems ~= nil then
		ShopModule.SelectObject()
		ShopModule.ViewGems(price.Gems - ProfileData.Gems)
	end
end

function ShopModule.GenerateHotItems()
	function ShopModule.GenerateFeaturedBox()
		ItemModule.DisplayItem(ShopModule.GUI.FeaturedFrame.Box.ItemFrame.ItemContainer, Sync.MysteryBox[featured.Box])
		local box = Sync.Featured.Box
		local v8 = Sync.MysteryBox[box]
		local weapon = Sync.Shop.Weapons[box]
		ShopModule.GUI.Main.Featured.Box.ItemFrame.ItemContainer.Container.ActionButton.MouseButton1Click:connect(function()
			v3 = "Featured"
			ShopModule.ViewBoxContents(box, v8, weapon)
		end)
		ShopModule.GUI.Main.Featured.Box.Buy.MouseButton1Click:Connect(function()
			v3 = "Featured"
			ShopModule.ViewBoxContents(box, v8, weapon)
		end)

		for _, frame in pairs(ShopModule.GUI.Main.Featured.Box.ItemFrame.Price:GetChildren()) do
			if not frame:IsA("Frame") then
				continue
			end

			local name = frame.Name
			frame.Visible = weapon.Price[name] ~= nil
			frame.PriceFrame.PriceLabel.Text = ItemModule.Commafy(weapon.Price[name] or 0)
		end
	end

	ShopModule.GenerateFeaturedBox()
	ShopModule.GUI.HotItemsContainer:ClearAllChildren()
	local clone = (ShopModule.GUI.HotItemLayout or hotItems.HotItemLayout):Clone()
	clone.Parent = ShopModule.GUI.HotItemsContainer
	local itemSizer = ShopModule.GUI.HotItemsContainer.Parent.Parent:FindFirstChild("ItemSizer")

	if itemSizer then
		local cellSize = clone.CellSize
		clone.CellSize = UDim2.new(0, itemSizer.AbsoluteSize.X, cellSize.Y.Scale, cellSize.Y.Offset)
	end

	for k, hotItem in pairs(featured.HotItems) do
		if k > 4 then
			break
		end

		if hotItem.Type == "ItemPack" then
			local currentItemPack = EventInfoService:GetCurrentItemPack()

			if currentItemPack then
				local clone2 = (ShopModule.GUI.NewHotItem or hotItems.NewHotItem):Clone()
				clone2.Container.Icon.Image = currentItemPack.FeaturedIcon
				clone2.ItemName.Label.Text = "Item Pack"
				clone2.Container.New.Visible = false
				clone2.Container.Limited.Visible = true
				clone2.Parent = ShopModule.GUI.HotItemsContainer
				clone2.Container.ActionButton.Activated:Connect(function()
					WindowService:AddToStack("ItemPack")
				end)
			end
		elseif hotItem.Type == "EventFrame" then
			local currentEvent = EventInfoService:GetCurrentEvent()
			local clone2 = (ShopModule.GUI.NewHotItem or hotItems.NewHotItem):Clone()
			clone2.Container.Icon.Image = currentEvent.FeaturedIcon
			clone2.ItemName.Label.Text = "Evo Item"
			clone2.Container.New.Visible = false
			clone2.Container.Limited.Visible = true
			clone2.Parent = ShopModule.GUI.HotItemsContainer
			local v8 = hotItem
			clone2.Container.ActionButton.Activated:Connect(function()
				WindowService:AddToStack("CurrentEvent", v8.ItemID)
			end)
		else
			local clone2 = (ShopModule.GUI.NewHotItem or hotItems.NewHotItem):Clone()
			local v8 = Sync[hotItem.Type][hotItem.ItemID]
			ItemModule.DisplayItem(clone2, v8)
			local v9 = Sync.Shop[hotItem.Type]
			local v10 = v9 and v9[hotItem.ItemID]

			if v10 then
				if v10.Price then
					local gems = v10.Price.Gems or v10.Price.Coins

					if gems then
						clone2.Tags.Price.PriceFrame.Amount.Text = ItemModule.Commafy(gems)
						clone2.Tags.Price.Icon.Image = Sync.Currencies[v10.Price.Gems == nil and "Coins" or "Gems"]
						clone2.Tags.Price.Visible = true
					else
						clone2.Tags.Price.Visible = false
					end
				end

				local v11 = hotItem
				local v12 = v8
				local v13 = v10
				clone2.Container.ActionButton.MouseButton1Click:connect(function()
					local dataType = shop[v11.Type][v11.ItemID].DataType or v11.Type
					local type = v11.Type
					ShopModule.OpenBuyPopup(v11.ItemID, v12, dataType, type, v13)
				end)
			end

			clone2.Container.New.Visible = v8.New == true
			clone2.Parent = ShopModule.GUI.HotItemsContainer
		end
	end
end

function ShopModule.SelectItemToPurchase(data, p, p2, p3, p4)
	ItemModule.DisplayItem(data.ItemFrame.ItemContainer, p2)
	data.Description.Visible = p4.Description ~= nil or p2.Description ~= nil
	data.Description.TextLabel.Text = p4.Description or p2.Description or ""
	data.BuyTitle.Visible = true
	local v8

	if p3 == "Weapons" or p3 == "Pets" or p3 == "MysteryBox" or p3 == "Eggs" or p3 == "Item" then
		v8 = false
	elseif ProfileData[p3].Owned[p] then
		v8 = true
	else
		local flag = true

		for _, v9 in ProfileData[p3].Owned do
			if v9 ~= p then
				continue
			end

			v8 = true
			flag = false
			break
		end

		if flag then
			v8 = false
		end
	end

	for _, child in pairs(data.PriceFrame:GetChildren()) do
		if Sync.Currencies[child.Name] == nil then
			continue
		end

		local name = child.Name
		child.Visible = p4.Price[name] ~= nil
		child.Container.PriceFrame.PriceLabel.Text = not p4.Price[name] and "" or ItemModule.Commafy(p4.Price[name]) or ""
		child.Buy.Style = (v8 or name == "Coins" and p4.Price.Coins ~= nil and ProfileData.Coins < p4.Price.Coins) and Enum.ButtonStyle.RobloxRoundButton or Enum.ButtonStyle.RobloxRoundDefaultButton
	end

	data.PriceFrame.BuyTitle.Title.Text = v8 and "OWNED" or "Buy It Now!"
	local getMoreGems = data.PriceFrame.GetMoreGems
	getMoreGems.Visible = p4.Price.Gems ~= nil and p4.Price.Coins == nil and ProfileData.Gems < (p4.Price and p4.Price.Gems or 0)
end

local v8 = {}

function ShopModule.OpenBuyPopup(itemID, itemData, itemType, shopType, itemShopData)
	ShopModule.SelectItemToPurchase(ShopModule.GUI.Main.BuyPopup.Container, itemID, itemData, itemType, itemShopData)
	v8 = {
		ItemID = itemID,
		ItemData = itemData,
		ItemType = itemType,
		ShopType = shopType,
		ItemShopData = itemShopData
	}
	ShopModule.GUI.Main.BuyPopup.Visible = true
end

local v9 = {}

function ShopModule.GenerateShopItems()
	local cratesRestricted = game.ReplicatedFirst:GetAttribute("CratesRestricted")

	for k, v10 in pairs(shop) do
		local scrollFrame = ShopModule.GUI.Main[k].ScrollFrame
		scrollFrame.Container:ClearAllChildren()
		local clone = (ShopModule.GUI.ShopItemLayout or script.ShopTabs.ItemGridLayout):Clone()
		clone.Parent = scrollFrame.Container
		clone:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, clone.AbsoluteContentSize.Y + 5)
		end)
		local itemSizer = scrollFrame:FindFirstChild("ItemSizer")

		if itemSizer then
			local cellSize = clone.CellSize
			clone.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, itemSizer.AbsoluteSize.Y)
		end

		for k2, v13 in pairs(v10) do
			local dataType = v13.DataType or k
			local v14 = Sync[dataType][k2]

			if not (k2 ~= "Key" or not cratesRestricted) then
				continue
			end

			local v15 = dataType == "MysteryBox" or dataType == "Eggs"

			if v14 == nil then
				continue
			end

			local clone2 = script.ShopTabs.NewItem:Clone()
			ItemModule.DisplayItem(clone2, v14)
			clone2.Container.Icon.SizeConstraint = v14.ImageRelative and Enum.SizeConstraint[v14.ImageRelative] or clone2.Container.Icon.SizeConstraint
			local flag

			if dataType == "Weapons" or dataType == "Pets" or dataType == "MysteryBox" or dataType == "Eggs" or dataType == "Item" then
				flag = false
			elseif ProfileData[dataType].Owned[k2] then
				flag = true
			else
				local flag2 = true

				for _, v16 in ProfileData[dataType].Owned do
					if v16 ~= k2 then
						continue
					end

					flag = true
					flag2 = false
					break
				end

				if flag2 then
					flag = false
				end
			end

			if flag then
				clone2.Tags.Owned.Visible = true
			else
				for childName, v16 in v13.Price do
					local child = clone2.Tags:FindFirstChild(childName)

					if not child then
						continue
					end

					child.Container.PriceFrame.PriceLabel.Text = ItemModule.Commafy(v16)
					child.Visible = true

					if v15 and v4[childName] and cratesRestricted then
						child.Visible = false
					end
				end
			end

			local v16 = v13
			local v17 = k2
			local v18 = v14
			local v19 = dataType
			local v20 = k
			clone2.Container.ActionButton.MouseButton1Click:connect(function()
				if v16.DataType == "MysteryBox" then
					v3 = "Weapons"
				else
					if v16.DataType ~= "Eggs" then
						ShopModule.OpenBuyPopup(v17, v18, v19, v20, v16)
						return
					end

					v3 = "Pets"
				end

				ShopModule.ViewBoxContents(v17, v18, v16)
			end)

			if v13.LiveEvent == true and not EventInfoService:IsEventActive() then
				clone2.Visible = false
				clone2:AddTag("EventShopItem")
			end

			clone2.Parent = scrollFrame.Container
			local v21

			if dataType == "Weapons" or dataType == "Pets" or dataType == "MysteryBox" or dataType == "Eggs" or dataType == "Item" then
				v21 = false
			elseif ProfileData[dataType].Owned[k2] then
				v21 = true
			else
				local flag2 = true

				for _, v22 in ProfileData[dataType].Owned do
					if v22 ~= k2 then
						continue
					end

					v21 = true
					flag2 = false
					break
				end

				if flag2 then
					v21 = false
				end
			end

			clone2.LayoutOrder = (v13.LayoutOrder or v13.Price.Gems or v13.Price.Coins and v13.Price.Coins + 10000) + (v21 and 20000 or 0)
			v9[k] = v9[k] or {}
			v9[k][k2] = {
				DataType = k,
				Frame = clone2
			}
		end
	end
end

function ShopModule.UpdateShopFrames()
	for k, v10 in pairs(v9) do
		if not (k ~= "Weapons" and k ~= "Pets") then
			continue
		end

		for k2, v11 in pairs(v10) do
			local flag

			if k == "Weapons" or k == "Pets" or k == "MysteryBox" or k == "Eggs" or k == "Item" then
				flag = false
			elseif ProfileData[k].Owned[k2] then
				flag = true
			else
				local flag2 = true

				for _, v12 in ProfileData[k].Owned do
					if v12 ~= k2 then
						continue
					end

					flag = true
					flag2 = false
					break
				end

				if flag2 then
					flag = false
				end
			end

			if not flag then
				continue
			end

			for _, frame in pairs(v11.Frame.Tags:GetChildren()) do
				if frame:IsA("Frame") then
					frame.Visible = frame.Name == "Owned"
				end
			end
		end
	end
end

function ShopModule.ViewBoxContents(p, data, p2)
	local cratesRestricted = game.ReplicatedFirst:GetAttribute("CratesRestricted")

	if p == "Christmas2019Box" then
		_G.ViewHalloweenBox()
		local UserInputService = game:GetService("UserInputService")

		if UserInputService.GamepadEnabled then
			_G.ReturnToHWBox()
		end
	else
		if _G.MobileDevice == "Phone" then
			for _, child in pairs(ShopModule.GUI.Main:GetChildren()) do
				child.Visible = child.Name == "Weapons"
			end

			boxType = "Weapons"

			if ShopModule.GUI.ShopFrame.Title:FindFirstChild("Back") then
				ShopModule.GUI.ShopFrame.Title.Back.Visible = true
				ShopModule.GUI.ShopFrame.Title.Title.Visible = false
			end
		end

		v5 = p
		v6 = data
		v7 = p2
		boxType = data.BoxType
		ItemModule.DisplayItem(ShopModule.GUI.ViewBoxFrame.BoxFrame.ItemContainer, data)

		for k, rarityChance in pairs(data.RarityChances) do
			ShopModule.GUI.ViewBoxFrame.BoxFrame.RarityFrame[k].Chance.Text = rarityChance .. "%"
		end

		local getKeys = ShopModule.GUI.ViewBoxFrame.BuyFrame.GetKeys
		getKeys.Visible = p2.Price.Key ~= nil and not cratesRestricted

		for _, button in ShopModule.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container:GetChildren() do
			if not button:IsA("TextButton") then
				continue
			end

			button.Visible = p2.Price[button.Name] ~= nil
			local commafy = ItemModule.Commafy(p2.Price[button.Name] or 0)

			if tonumber(commafy) == 1 then
				commafy = "x" .. commafy
			end

			button.Cost.Text = commafy

			if button.Name == "Coins" then
				button.Style = ProfileData.Coins >= (p2.Price[button.Name] or 0) and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
			end

			if v4[button.Name] and cratesRestricted then
				button.Visible = false
			end
		end

		for _, child in pairs(ShopModule.GUI.Main:GetChildren()) do
			child.Visible = child.Name == "ViewCrate"
		end

		ShopModule.GUI.Nav.Container[boxType].NotSelected.Visible = false
		ShopModule.GUI.Nav.Container[boxType].IsSelected.Visible = false
		ShopModule.GUI.Nav.Container[boxType].Back.Visible = true
		local container = ShopModule.GUI.ViewBoxFrame.BoxContents:FindFirstChild("Container") or ShopModule.GUI.ViewBoxFrame.BoxContents.ScrollingFrame.Container
		container:ClearAllChildren()
		local clone = (ShopModule.GUI.BoxContentsLayout or script.ViewBoxContents.BoxContentsLayout):Clone()
		clone.Parent = container

		if container.Parent:IsA("ScrollingFrame") then
			clone:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				container.Parent.CanvasSize = UDim2.new(0, 0, 0, clone.AbsoluteContentSize.Y + 5)
			end)
		end

		local itemSizer = container.Parent:FindFirstChild("ItemSizer")

		if itemSizer then
			local cellSize = clone.CellSize
			clone.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, itemSizer.AbsoluteSize.Y)
		end

		for k, content in pairs(data.Contents) do
			local clone2 = (ShopModule.GUI.NewBoxContent or script.ViewBoxContents.NewBoxContents):Clone()
			local v11 = Sync[data.BoxType][content]
			ItemModule.DisplayItem(clone2, v11)
			clone2.LayoutOrder = k
			clone2.Parent = container
			local owned = clone2.Tags.Owned
			local boxType2 = data.BoxType
			local visible

			if ProfileData[boxType2].Owned[content] then
				visible = true
			else
				local flag = true

				for _, v13 in ProfileData[boxType2].Owned do
					if v13 ~= content then
						continue
					end

					visible = true
					flag = false
					break
				end

				if flag then
					visible = false
				end
			end

			owned.Visible = visible
		end
	end
end

function ShopModule.ViewBoxContentsXbox(p, p2, p3)
	v5 = p
	v6 = p2
	v7 = p3
end

function ShopModule.ConnectNavButtons()
	local buttons = {}

	for _, button in pairs(ShopModule.GUI.Nav.Container:GetChildren()) do
		if button:IsA("TextButton") then
			table.insert(buttons, button)
		end
	end

	function ShopModule.ResetNavButtons()
		for _, v10 in pairs(buttons) do
			v10.IsSelected.Visible = false
			v10.NotSelected.Visible = true
			v10.Back.Visible = false
		end
	end

	function ShopModule.ViewFeatured()
		ShopModule.ResetNavButtons()

		for _, child in pairs(ShopModule.GUI.Main:GetChildren()) do
			child.Visible = child.Name == "Featured"
		end

		boxType = "Featured"
	end

	for _, v10 in pairs(buttons) do
		local v11 = v10
		v10.MouseButton1Click:connect(function()
			if boxType == v11.Name then
				if ShopModule.GUI.ViewBoxFrame.Parent.Visible ~= true then
					ShopModule.ViewFeatured()
					return
				end

				if v3 ~= "Weapons" and v3 ~= "Pets" then
					ShopModule.ViewFeatured()
					return
				end

				v11.Back.Visible = false
				v11.IsSelected.Visible = true

				for i, child in pairs(ShopModule.GUI.Main:GetChildren()) do
					child.Visible = child.Name == v3
				end
			else
				for k, v12 in pairs(buttons) do
					v12.IsSelected.Visible = v12 == v11
					v12.NotSelected.Visible = v12 ~= v11
					v12.Back.Visible = false
				end

				for i, child in pairs(ShopModule.GUI.Main:GetChildren()) do
					child.Visible = child.Name == v11.Name
				end

				boxType = v11.Name
			end
		end)
	end

	if ShopModule.GUI.ShopFrame.Title:FindFirstChild("Back") then
		ShopModule.GUI.ShopFrame.Title.Back.Visible = true
		ShopModule.GUI.ShopFrame.Title.Title.Visible = false
	end
end

function ShopModule.ConnectNavButtonsPhone()
	local buttons = {}

	for _, button in pairs(ShopModule.GUI.Nav.Container:GetChildren()) do
		if button:IsA("TextButton") then
			table.insert(buttons, button)
		end
	end

	function ShopModule.ResetNavButtons() end

	for _, v10 in pairs(buttons) do
		local v11 = v10
		v10.MouseButton1Click:connect(function()
			for i, child in pairs(ShopModule.GUI.Main:GetChildren()) do
				child.Visible = child.Name == v11.Name
			end

			boxType = v11.Name

			if ShopModule.GUI.ShopFrame.Title:FindFirstChild("Back") then
				ShopModule.GUI.ShopFrame.Title.Back.Visible = true
				ShopModule.GUI.ShopFrame.Title.Title.Visible = false
			end
		end)
	end

	ShopModule.GUI.ShopFrame.Title.Gems.More.MouseButton1Click:connect(function()
		ShopModule.GUI.ShopFrame.Title.Back.Visible = true
		ShopModule.GUI.ShopFrame.Title.Title.Visible = false
	end)
	ShopModule.GUI.ShopFrame.Title.Gems.GetMore.MouseButton1Click:connect(function()
		ShopModule.GUI.ShopFrame.Title.Back.Visible = true
		ShopModule.GUI.ShopFrame.Title.Title.Visible = false
	end)
end

function ShopModule.PurchaseBox(p, p2, p3)
	if p2.BoxType == "Pets" then
		ShopModule.PurchaseEgg(p, p2, p3)
		return
	end

	ShopModule.GUI.ShopFrame.Visible = false
	_G.Process("Unboxing")
	local v10 = time()
	local v11 = game.ReplicatedStorage.Remotes.Shop.OpenCrate:InvokeServer(p, "MysteryBox", p3)
	wait(0.75 - (time() - v10))
	ShopModule.GUI.Processing.Visible = false

	if v11 then
		game.ReplicatedStorage.Remotes.Shop.BoxController:Fire(p, v11)
	end
end

function ShopModule.PurchaseEgg(p, _, p2)
	ShopModule.GUI.ShopFrame.Visible = false
	_G.Process("Unboxing")
	local v10 = time()
	local v11 = game.ReplicatedStorage.Remotes.Shop.OpenCrate:InvokeServer(p, "Eggs", p2)
	wait(0.75 - (time() - v10))
	ShopModule.GUI.Processing.Visible = false

	if v11 then
		game.ReplicatedStorage.Remotes.Shop.EggController:Fire(p, v11)
	end
end

function ShopModule.ConnectViewBoxFrame()
	local cratesRestricted = game.ReplicatedFirst:GetAttribute("CratesRestricted")

	if game.Players.LocalPlayer.PlayerGui:GetAttribute("Device") == "Phone" then
		purchaseOption = script:WaitForChild("PurchaseOptionPhone")
	end

	if not cratesRestricted then
		ShopModule.GUI.ViewBoxFrame.BuyFrame.GetKeys.MouseButton1Click:connect(function()
			ShopModule.OpenBuyPopup("Key", Sync.Weapons.Key, "Item", "Weapons", Sync.Shop.Weapons.Key)
		end)
	end

	ShopModule.GUI.ViewBoxFrame.BuyFrame.GetKeys.Amount.Text = "You have " .. (ProfileData.Weapons.Owned.Key or 0) .. " Keys"
	remotes:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged").Event:Connect(function(_, p, _)
		if p ~= "Key" then
			return
		end

		ShopModule.GUI.ViewBoxFrame.BuyFrame.GetKeys.Amount.Text = "You have " .. (ProfileData.Weapons.Owned.Key or 0) .. " Keys"
	end)
	local container = ShopModule.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container

	for _, button in container:GetChildren() do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end

	for k, v10 in v do
		local clone = purchaseOption:Clone()
		clone.Icon.Image = v10.Icon
		clone.Title.Text = v10.DisplayName
		clone.Name = k
		clone.Parent = container
		local v11 = k
		clone.Activated:Connect(function()
			if (ProfileData[v11] or ProfileData.Materials.Owned[v11] or ProfileData.Weapons.Owned[v11] or 0) >= v7.Price[v11] then
				ShopModule.PurchaseBox(v5, v6, v11)
				_G.LastShopSelection = ShopModule.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container[v11]
			end
		end)
	end
end

function ShopModule.ConnectBuyPopup()
	local priceFrame = ShopModule.GUI.Main.BuyPopup.Container.PriceFrame

	for _, frame in priceFrame:GetChildren() do
		if not (frame.Name ~= "BuyTitle" and frame.Name ~= "GetMoreGems" and frame.Name ~= "PurchaseLoading" and frame:IsA("Frame")) then
			continue
		end

		frame:Destroy()
	end

	for k, v10 in v do
		local clone = purchaseOptionFrame:Clone()
		clone.Container.Icon.Image = v10.Icon
		clone.Name = k
		clone.Parent = priceFrame
		local v11 = k
		clone.Buy.Activated:Connect(function()
			if v8 then
				ShopModule.BuyItem(v8.ItemID, v8.ShopType, v11, ShopModule.GUI.Main.BuyPopup.Container)
				ShopModule.GUI.Main.BuyPopup.Visible = false
			end
		end)
	end

	ShopModule.GUI.Main.BuyPopup.Container.Close.MouseButton1Click:connect(function()
		ShopModule.GUI.Main.BuyPopup.Visible = false
	end)
	ShopModule.GUI.Main.BuyPopup.Container.PriceFrame.GetMoreGems.Buy.MouseButton1Click:connect(function()
		local shopType = v8.ShopType
		local itemID = v8.ItemID
		local price = shop[shopType][itemID].Price
		ShopModule.ViewGems(price.Gems - ProfileData.Gems)
	end)
end

function ShopModule.HighlightGem(p)
	if p ~= nil then
		local children = ShopModule.GUI.Main.Gems:GetChildren()
		table.sort(children, function(a, b)
			return tonumber(a.Name) < tonumber(b.Name)
		end)

		for _, v10 in pairs(children) do
			local name = tonumber(v10.Name)

			if not (p <= name) then
				continue
			end

			print("RQ", name, p)
			local v11 = v10
			spawn(function()
				local position = v11.Position
				wait(0.1)
				v11:TweenPosition(
					UDim2.new(
						v11.Position.X.Scale,
						v11.Position.X.Offset,
						v11.Position.Y.Scale,
						v11.Position.Y.Offset - 30
					),
					"Out",
					"Sine",
					0.3
				)
				wait(0.31)
				v11:TweenPosition(
					UDim2.new(
						v11.Position.X.Scale,
						v11.Position.X.Offset,
						v11.Position.Y.Scale,
						v11.Position.Y.Offset + 30
					),
					"In",
					"Sine",
					0.3
				)
				wait(0.31)
				v11.Position = position
			end)
			return
		end
	end
end

function ShopModule.ViewGems(p)
	ShopModule.ResetNavButtons()

	for _, child in pairs(ShopModule.GUI.Main:GetChildren()) do
		child.Visible = child.Name == "Gems"
	end

	boxType = "Gems"
	ShopModule.HighlightGem(p)
end

function ShopModule.ConnectGems()
	for _, child in pairs(ShopModule.GUI.Main.Gems:GetChildren()) do
		local v10 = child
		child.MouseButton1Click:connect(function()
			script.Click:Play()
			game.ReplicatedStorage.Remotes.Shop.PurchaseProduct:FireServer(v10.Name, "Gems")
		end)
	end

	ShopModule.GUI.Title.Gems.GetMore.MouseButton1Click:connect(function()
		ShopModule.ViewGems()
	end)
end

local function onEventStarted()
	local CollectionService = game:GetService("CollectionService")

	for _, v10 in CollectionService:GetTagged("EventShopItem") do
		v10.Visible = true
	end
end

EventInfoService:OnEventStarted(onEventStarted)
return ShopModule