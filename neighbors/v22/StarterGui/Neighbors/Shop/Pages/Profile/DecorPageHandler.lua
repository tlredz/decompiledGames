local MarketplaceService = game:GetService("MarketplaceService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
game:GetService("UserInputService")
local shop = script:FindFirstAncestor("Shop")
local _ = shop.Parent.Parent
local inspectItemPage = shop.InspectItemPage
local inspectItem = inspectItemPage.InspectItem
local parent = script.Parent
local example = script.Example
local UI = require(ReplicatedStorage.Modules.UI)
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
local Data = require(game.ReplicatedStorage.Modules.Data)
require(ReplicatedStorage.Modules.Server)
local Decoration = require(ReplicatedStorage.Assets.Data.Store.Decoration)
local SpriteSheet = require(ReplicatedStorage.Modules.SpriteSheet)
require(ReplicatedStorage.Modules.ShopUtil)
local Utility = require(ReplicatedStorage.Modules.Utility)
local titles = {}
local Network = require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
local bindableEvent = Instance.new("BindableEvent")
local v = Utility:FailSafeFunction(function()
	return localPlayer:GetRankInGroup(15109848)
end, 10, 0.25) or 255

local function GetInternalDecorationName(p)
	for _, v2 in pairs(Decoration) do
		for k, v3 in v2 do
			if v3 == p then
				return k
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsDecoEquipped(p)
	return Data.Decoration:Get(GetInternalDecorationName(p)) ~= nil and Data.Decoration:Get(GetInternalDecorationName(p)).Equipped
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnDeco(p)
	return Data.Decoration:Get(GetInternalDecorationName(p)) ~= nil
end

local function GetShopItems()
	return Decoration
end

local function CommaValue(p: number)
	return string.format("%0.0f", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function GetInfo(p: number)
	return MarketplaceService:GetProductInfo(p, Enum.InfoType.Product)
end

local function CreateItem(data)
	local clone = example:Clone()
	local footer = clone.Footer
	clone.Visible = true
	clone.ItemName.Title.Text = data.Display

	if data.RequiredRank then
		footer.Credits.Amount.Text = "FREE"
	else
		local amount = footer.Credits.Amount
		local price = data.Price
		amount.Text = `${string.format("%0.0f", price):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
	end

	clone.Icon.Image = data.Image
	return clone
end

local function CreateItemCategory(text: string)
	local category = UI:CreateCategory(parent)
	category.Collapsible.InfoContainer.Title.Text = text

	local function GetItemCount()
		local count = 0

		for _, button in category.List:GetChildren() do
			if button:IsA("ImageButton") and button.Visible then
				count += 1
			end
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateVisibility()
		category.Visible = GetItemCount() > 0
	end

	category.List.ChildAdded:Connect(function(button)
		UpdateVisibility() -- equivalent call inferred; original call site unknown

		if button:IsA("ImageButton") then
			button:GetPropertyChangedSignal("Visible"):Connect(function()
				UpdateVisibility() -- equivalent call inferred; original call site unknown
			end)
		end
	end)
	category.List.ChildRemoved:Connect(function()
		UpdateVisibility() -- equivalent call inferred; original call site unknown
	end)
	UpdateVisibility() -- equivalent call inferred; original call site unknown
	return category
end

local function GetFramePositionInScrollingFrame(p, p2)
	local absolutePosition = p.AbsolutePosition
	local canvasPosition = p2.CanvasPosition
	return absolutePosition - p2.AbsolutePosition + Vector2.new(canvasPosition.X, canvasPosition.Y)
end

local function UpdateItemPreview(data, p: string)
	inspectItemPage.Visible = true
	inspectItem.ItemName.Text = `{data.Display}`
	inspectItem.Description.Text = data.Description
	inspectItem.Item.ItemImage.Image = data.Image
	inspectItem.Item.ItemImage.Visible = true
	inspectItem.Item.Title.Visible = false
	local price = inspectItem.Price
	local price2 = data.Price
	price.Text = string.format("%0.0f", price2):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")

	if DoesOwnDeco(data) then
		local equip = inspectItem.Buttons.Equip
		equip.Visible = not IsDecoEquipped(data)
		inspectItem.Buttons.Unequip.Visible = not inspectItem.Buttons.Equip.Visible
		inspectItem.Price.Visible = false
	else
		inspectItem.Buttons.Purchase.Visible = true
	end

	inspectItem.Item.Visible = false
	inspectItem.Description.Visible = false
	inspectItem.Profile.Visible = true
	inspectItem.Profile.CustomBG.Image = ""
	inspectItem.Profile.Banner.CustomBG.Image = ""
	inspectItem.Profile.Profile.AvatarDecoration.Image = ""
	inspectItem.Profile.DisplayName.Text = localPlayer.DisplayName
	inspectItem.Profile.Username.Text = "@" .. localPlayer.Name
	inspectItem.Profile.Profile.Avatar.Image = UI:GetAvatarDecal(localPlayer)
	local avatarDecoration

	if p == "Avatar" then
		inspectItem.Profile.Profile.AvatarDecoration.ZIndex = data.AppearUnderProfile and 0 or 5
		inspectItem.Profile.Profile.AvatarDecoration.Image = data.Image
		inspectItem.Profile.Profile.AvatarDecoration.ImageTransparency = data.Transparency or 0
		inspectItem.Profile.Profile.AvatarDecoration.Position = data.Position
		inspectItem.Profile.Profile.AvatarDecoration.Size = data.Size
		avatarDecoration = inspectItem.Profile.Profile.AvatarDecoration
	elseif p == "Banner" then
		inspectItem.Profile.Banner.CustomBG.Image = data.Image
		inspectItem.Profile.Banner.CustomBG.ImageTransparency = data.Transparency or 0
		avatarDecoration = inspectItem.Profile.Banner.CustomBG
	else
		inspectItem.Profile.CustomBG.Image = data.Image
		inspectItem.Profile.CustomBG.ImageTransparency = data.Transparency or 0
		avatarDecoration = inspectItem.Profile.CustomBG
	end

	local v2

	if data.IsAnimated then
		v2 = SpriteSheet:Play(avatarDecoration, data.IsAnimated)
	else
		v2 = nil
	end

	if data.HidePurchaseButton then
		inspectItem.Buttons.Purchase.Visible = false
		inspectItem.Price.Visible = false
	end

	local connections = {}
	table.insert(connections, inspectItem.Buttons.Purchase.MouseButton1Click:Connect(function()
		Network:fire("BuyDeco", GetInternalDecorationName(data))

		if localPlayer:GetAttribute("Credits") >= data.Price then
			inspectItemPage.Visible = false
		end
	end))
	table.insert(connections, inspectItem.Buttons.Equip.MouseButton1Click:Connect(function()
		Network:fire("SetDeco", GetInternalDecorationName(data))
		inspectItemPage.Visible = false
	end))
	table.insert(connections, inspectItem.Buttons.Unequip.MouseButton1Click:Connect(function()
		Network:fire("SetDeco", GetInternalDecorationName(data))
		inspectItemPage.Visible = false
	end))
	inspectItemPage:GetPropertyChangedSignal("Visible"):Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end

		if v2 then
			v2()
		end

		inspectItem.Item.Visible = true
		inspectItem.Description.Visible = true
		inspectItem.Profile.Visible = false
	end)
end

local function CreateItemList()
	local v2 = Decoration
	local itemCategory = CreateItemCategory("LIMITED TIME!")
	itemCategory.Name = "1"
	itemCategory.LayoutOrder = -999
	table.insert(titles, itemCategory.Collapsible.InfoContainer.Title)
	local itemCategory2 = CreateItemCategory("Equipped")
	itemCategory2.Parent = parent
	local v5 = {}

	for k, _ in next, v2, nil do
		table.insert(v5, k)
	end

	table.sort(v5, function(a: string, b: string)
		return a:lower() < b:lower()
	end)

	for k, v6 in pairs(v2) do
		local itemCategory3 = CreateItemCategory(k)
		itemCategory3.LayoutOrder = table.find(v5, k) + 5
		itemCategory3.Parent = parent

		for _, v8 in v6 do
			if v8.RequiredRank and v < v8.RequiredRank then
				continue
			end

			local item = CreateItem(v8)
			local list = itemCategory3.List

			if v8.LimitedDecor then
				list = itemCategory.List
			end

			item.LayoutOrder = v8.Price
			item.Name = v8.Display:lower():gsub(" ", "_")
			item.Parent = list

			if k == "Avatar" or v8.ScaleType then
				item.Icon.ImageRectOffset = Vector2.zero
				item.Icon.ImageRectSize = Vector2.zero

				if v8.ScaleType then
					item.Icon.ScaleType = v8.ScaleType
				end
			end

			if v8.IsAnimated then
				SpriteSheet:ApplyFrame(item.Icon, v8.IsAnimated, 1)
				local v10 = nil
				local item2 = item
				local v12 = v8
				item.MouseEnter:Connect(function()
					if not v10 then
						v10 = SpriteSheet:Play(item2.Icon, v12.IsAnimated)
					end
				end)
				local item3 = item
				local v14 = v8
				item.MouseLeave:Connect(function()
					if v10 then
						v10()
						v10 = nil
						SpriteSheet:ApplyFrame(item3.Icon, v14.IsAnimated, 1)
					end
				end)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local v10 = v8

			local function updateVisibility()
				if Data.Decoration:Get(GetInternalDecorationName(v10)) == nil and v10.HidePurchaseButton then
					item.Visible = not v10.HidePurchaseButton
				end
			end

			local item4 = item
			local v13 = v8

			local function UpdateItem()
				local credits = item4.Footer.Credits
				credits.Visible = Data.Decoration:Get(GetInternalDecorationName(v13)) == nil
				item4.Icon.Hidden.Visible = item4.Footer.Credits.Visible
				local icon = item4.Icon
				icon.Size = DoesOwnDeco(v13) and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 1, -19)
				local itemName = item4.ItemName
				itemName.Position = Data.Decoration:Get(GetInternalDecorationName(v13)) == nil and UDim2.new(
					0.5,
					0,
					1,
					-19
				) or UDim2.new(0.5, 0, 1, 0)
				item4.Parent = IsDecoEquipped(v13) and itemCategory2.List or list

				if v13.HidePurchaseButton then
					item4.Footer.Credits.Amount.Text = "Weekly"
				end

				updateVisibility() -- equivalent call inferred; original call site unknown
			end

			local item5 = item
			local UpdateItem2 = UpdateItem
			bindableEvent.Event:Connect(function()
				item5.Visible = true
				UpdateItem2()
			end)
			local item6 = item
			local v16 = v8
			shop.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				local text = shop.Hotbar.SearchBar.Search.TextBox.Text
				item6.Visible = v16.Display:lower():find(text:lower())
				updateVisibility() -- equivalent call inferred; original call site unknown
			end)
			UpdateItem()
			local v17 = v8
			local v18 = k
			local item7 = item
			item.MouseButton1Click:Connect(function()
				if inspectItemPage.Visible then
					return
				end

				UpdateItemPreview(v17, v18)
				updateVisibility() -- equivalent call inferred; original call site unknown
			end)
			UI:Bind(item)
			UI:AddShadowOnHover(item)
		end
	end
end

CreateItemList()
Data.Decoration:GetPropertyChangedSignal("Items"):Connect(function()
	bindableEvent:Fire()
end)
RunService:BindToRenderStep("DecorShopRGBText", Enum.RenderPriority.Camera.Value, function()
	if not shop.Visible then
		return
	end

	local color = Color3.fromHSV(tick() % 10 / 10, 1, 1)

	for _, v2 in titles do
		v2.TextColor3 = color
	end
end)