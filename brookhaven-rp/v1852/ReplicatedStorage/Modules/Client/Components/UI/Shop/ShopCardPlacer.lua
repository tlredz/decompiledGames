local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ItemProvider = require(ReplicatedStorage.Modules.Client.Components.UI.Shop.ItemProvider)
local PurchasableInfoController = require(ReplicatedStorage.Modules.Client.Data.PurchasableInfoController)
local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ShopTelemetrySource = require(ReplicatedStorage.Modules.Client.UI.ShopTelemetrySource)
require(ReplicatedStorage.Modules.Shared.DB.Shop.ShopItems)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local Summer2026Util = require(ReplicatedStorage.Modules.Shared.LiveOps.Summer2026Util)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local OfflineItem = require(ReplicatedStorage.Modules.Shared.Item.OfflineItem)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local ShopCardPlacer = {}

local function getFeatured(list, featured, p: number)
	local v = math.max(#list, #featured)
	local v2 = p - (p < v and 1 or 0)
	local result = {}

	for i = 1, v2 do
		if #featured < i then
			break
		else
			table.insert(result, featured[i])
		end
	end

	local v3 = 1

	while #result < v2 and v3 <= #list do
		if not table.find(result, list[v3]) then
			table.insert(result, list[v3])
		end

		v3 += 1
	end

	return result, (math.max(v - v2, 0))
end

local function addItems(object, parent, featured, p)
	for i = 1, #featured do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = featured[i]
		imageLabel.BackgroundTransparency = 0.35
		imageLabel.BorderSizePixel = 0
		imageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
		imageLabel.ScaleType = Enum.ScaleType.Fit
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.AspectRatio = 1
		uIAspectRatioConstraint.Parent = imageLabel
		imageLabel.Parent = parent
		object:Add(imageLabel)
	end

	if p > 0 then
		local textLabel = Instance.new("TextLabel")
		textLabel.Text = "<font weight=\"SemiBold\">+" .. p .. "</font> more!"
		textLabel.TextScaled = true
		textLabel.RichText = true
		textLabel.Font = Enum.Font.Nunito
		textLabel.BackgroundTransparency = 0.35
		textLabel.BorderSizePixel = 0
		textLabel.BackgroundColor3 = Color3.new(1, 1, 1)
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.AspectRatio = 1
		uIAspectRatioConstraint.Parent = textLabel
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingTop = UDim.new(0, 2)
		uIPadding.PaddingLeft = UDim.new(0, 2)
		uIPadding.PaddingRight = UDim.new(0, 2)
		uIPadding.PaddingBottom = UDim.new(0, 2)
		uIPadding.Parent = textLabel
		textLabel.Parent = parent
		object:Add(textLabel)
	end
end

function ShopCardPlacer.PlaceFeature(object, instance, p, data)
	task.spawn(function()
		local inset = instance:WaitForChild("Inset")
		local top = inset:WaitForChild("Left"):WaitForChild("Top")
		local infoClient = object:GetInfoClient()
		local gamepassIcon = top:WaitForChild("GamepassIcon")
		gamepassIcon.Image = "rbxassetid://" .. infoClient.IconImageAssetId
		local name = top:WaitForChild("Name")
		name.Text = data.ShortDescriptionHeader

		if data.PreviewImage ~= nil then
			local imageLabel_2 = inset:WaitForChild("ImageLabel")
			imageLabel_2.Image = data.PreviewImage
		end

		local uIGradient = inset:WaitForChild("ImageLabel"):WaitForChild("UIStroke"):WaitForChild("UIGradient")
		uIGradient.Color = ColorSequence.new(Color3.fromHex(data.BorderColor1), Color3.fromHex(data.BorderColor2))
		local v = {
			data.Feature1Icon,
			data.Feature2Icon,
			data.Feature3Icon,
			data.Feature4Icon
		}
		local v2 = {
			data.Feature1Description,
			data.Feature2Description,
			data.Feature3Description,
			data.Feature4Description
		}
		local frame = inset:WaitForChild("Left"):WaitForChild("Frame")

		for i = 1, 4 do
			local child = frame:WaitForChild((tostring(i)))
			local imageLabel = child:WaitForChild("ImageLabel")
			local textLabel = child:WaitForChild("TextLabel")
			imageLabel.Image = v[i]
			textLabel.Text = v2[i]
		end

		local buttons = inset:WaitForChild("Left"):WaitForChild("Buttons")
		local purchaseButton = buttons:WaitForChild("PurchaseButton")
		local ownedButton = buttons:WaitForChild("OwnedButton")

		if object:IsOwnedClient() then
			purchaseButton.Visible = false
			ownedButton.Visible = true
		else
			purchaseButton.Visible = true
			ownedButton.Visible = false
			local textLabel_2 = purchaseButton:WaitForChild("TextLabel")
			textLabel_2.Text = ""
			task.spawn(function()
				local priceAsync = object:GetPriceAsync()

				if priceAsync ~= nil then
					local textLabel = purchaseButton:WaitForChild("TextLabel")
					textLabel.Text = "" .. priceAsync
				end
			end)
		end

		local gamepass = object:ToGamepass()

		if gamepass == nil then
			local v3 = assert(object:ToDevProduct())
			ShopCardPlacer.ConnectProductPurchase(purchaseButton, p, v3)
		else
			ShopCardPlacer.ConnectGamepassPurchase(purchaseButton, p, gamepass)
		end

		if data.Type == "FeatureGamepass" then
			ShopCardPlacer.ConnectGamepassCard(instance, p, object, data)
		else
			ShopCardPlacer.ConnectProductCard(instance, p, assert(object:ToDevProduct()), data)
		end

		ShopCardPlacer.ConnectGift(buttons:WaitForChild("SendGift"), p, object)
		instance.Visible = true
	end)
end

function ShopCardPlacer.Place(object, p, p2, data)
	assert(data.Type == "Gamepass" or data.Type == "DevProduct")
	task.spawn(function()
		local instance = p.instance
		local inset = instance:WaitForChild("Inset")
		local top = inset:WaitForChild("Top")
		local infoClient = object:GetInfoClient()
		local gamepassIcon = top:WaitForChild("GamepassIcon")
		gamepassIcon.Image = "rbxassetid://" .. infoClient.IconImageAssetId
		local gamepassName = top:WaitForChild("GamepassName")
		gamepassName.Text = infoClient.Name
		local left = inset:WaitForChild("Split"):WaitForChild("Left")
		local description = left:WaitForChild("Description")
		description.Text = data.ShortDescription

		if data.ShortDescriptionHeader == "" then
			local header = left:WaitForChild("Header")
			header.Visible = false
		else
			local header_2 = left:WaitForChild("Header")
			header_2.Text = data.ShortDescriptionHeader
		end

		local buttons = inset:WaitForChild("Buttons")
		local purchaseButton = buttons:WaitForChild("PurchaseButton")
		local ownedButton = buttons:WaitForChild("OwnedButton")
		local v = false
		local eligibilityItem

		if data.Type == "Gamepass" then
			eligibilityItem = data.EligibilityItem
		end

		if eligibilityItem then
			local item = ItemRegistry.GetItem(eligibilityItem, OfflineItem)
			assert(item, "unknown item " .. eligibilityItem)
			v = item:IsUnlockedOrJustBoughtClient(nil)
		end

		if v or object:IsOwnedClient() then
			purchaseButton.Visible = false
			ownedButton.Visible = true
		else
			purchaseButton.Visible = true
			ownedButton.Visible = false
			local textLabel = purchaseButton:WaitForChild("TextLabel")
			textLabel.Text = ""
			task.spawn(function()
				local priceAsync = object:GetPriceAsync()

				if priceAsync ~= nil then
					local textLabel = purchaseButton:WaitForChild("TextLabel")
					textLabel.Text = "" .. priceAsync
				end
			end)
		end

		local items = inset:WaitForChild("Split"):WaitForChild("Items")
		local featured, v2 = getFeatured(ItemProvider.GetItemsPurchasable(object), data.Featured, p.items)
		addItems(p2, items, featured, v2)
		local gamepass = object:ToGamepass()

		if gamepass == nil then
			ShopCardPlacer.ConnectProductPurchase(purchaseButton, p2, assert(object:ToDevProduct()))
		else
			ShopCardPlacer.ConnectGamepassPurchase(purchaseButton, p2, gamepass)
		end

		if data.Type == "Gamepass" then
			ShopCardPlacer.ConnectGamepassCard(instance, p2, object, data)
		else
			local v3 = assert(object:ToDevProduct())
			ShopCardPlacer.ConnectProductCard(instance, p2, v3, data)
		end

		ShopCardPlacer.ConnectGift(buttons:WaitForChild("SendGift"), p2, object)
		instance.Visible = true
	end)
end

function ShopCardPlacer.ConnectGift(p, maid, object)
	maid:Add(p.Activated:Connect(function()
		ComponentUtil.FindAndWaitForComponentByTag(
			Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient"),
			"GiftSelectRecipient",
			false
		):SetGiftData(
			object:GetGiftId(),
			object:GetInfoClient().Name,
			ShopTelemetrySource.Prefix("shop")
		)
		PanelController.OpenPanelByContext("MainGUIHandler", "GiftSelectRecipient")
	end))
end

function ShopCardPlacer.ConnectGamepassCard(instance, maid, object, p)
	maid:Add(instance:WaitForChild("Inset").Activated:Connect(function()
		TelemetryController.SendClientInteraction("shopInteraction", {
			productType = object:ToDevProduct() == nil and "GamePass" or "DevProduct",
			id = object:GetId(),
			shop = ShopTelemetrySource.Prefix("new")
		})

		if ComponentUtil.FindAndWaitForComponentByTag(nil, "ItemCard", false):WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("ItemCard")):expect():SetGamepass(
			object,
			p
		) then
			PanelController.OpenPanelByContext("MainGUIHandler", "ItemCard")
		end
	end))
end

function ShopCardPlacer.ConnectProductCard(instance, maid, p, p2)
	PanelController.LoadLazy("MainGUIHandler", "ItemCardProduct", false)
	maid:Add(instance:WaitForChild("Inset").Activated:Connect(function()
		TelemetryController.SendClientInteraction("shopInteraction", {
			productType = "DevProduct",
			id = DevProducts.GetId(p),
			shop = ShopTelemetrySource.Prefix("new")
		})

		if ComponentUtil.FindAndWaitForComponentByTag(nil, "ItemCardProduct", false):WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("ItemCardProduct")):expect():SetProduct(
			p,
			p2
		) then
			PanelController.OpenPanelByContext("MainGUIHandler", "ItemCardProduct")
		end
	end))
end

function ShopCardPlacer.ConnectGamepassPurchase(p, maid, p2)
	maid:Add(p.Activated:Connect(function()
		local id = Gamepasses.GetId(p2)
		TelemetryController.SendClientInteraction("shopPurchase", {
			productType = "GamePass",
			id = id,
			shop = ShopTelemetrySource.Prefix("new")
		})
		Remotes.fireServer("PromptGamepassPurchase", id, ShopTelemetrySource.Prefix("FeaturedStore:false"))
	end))
end

function ShopCardPlacer.ConnectProductPurchase(p, maid, p2)
	maid:Add(p.Activated:Connect(function()
		local id = DevProducts.GetId(p2)
		TelemetryController.SendClientInteraction("shopPurchase", {
			productType = "DevProduct",
			id = id,
			shop = ShopTelemetrySource.Prefix("new")
		})
		DevProductController.PromptPurchaseWithId(DevProducts.GetId(p2), ShopTelemetrySource.Prefix("shop"))
	end))
end

function ShopCardPlacer.PlaceProduct(p, instance, maid, data)
	assert(data.Type == "DevProductBig")
	task.spawn(function()
		local devProductInfo = PurchasableInfoController.GetDevProductInfo(p)

		if devProductInfo == nil then
			instance.Visible = false
			return
		end

		local inset = instance:WaitForChild("Inset")
		local top = inset:WaitForChild("Left"):WaitForChild("Top")
		local gamepassIcon = top:WaitForChild("GamepassIcon")
		gamepassIcon.Image = "rbxassetid://" .. devProductInfo.IconImageAssetId
		local gamepassName = top:WaitForChild("GamepassName")
		gamepassName.Text = DevProducts.GetDisplayName(p) or devProductInfo.Name
		local left = inset:WaitForChild("Left")
		local description = left:WaitForChild("Description")
		description.Text = data.ShortDescription

		if data.ShortDescriptionHeader == "" then
			local header = left:WaitForChild("Header")
			header.Visible = false
		else
			local header_2 = left:WaitForChild("Header")
			header_2.Text = data.ShortDescriptionHeader
		end

		local buttons = inset:WaitForChild("Right"):WaitForChild("Buttons")
		local purchaseButton = buttons:WaitForChild("PurchaseButton")
		local ownedButton = buttons:WaitForChild("OwnedButton")
		local countdown = left:WaitForChild("Bottom"):WaitForChild("Countdown")

		if data.Countdown then
			local countdown2 = countdown:WaitForChild("Countdown")

			local function updateTimer()
				local v = math.max(0, data.Countdown - DateTime.now().UnixTimestamp)

				if v >= 86400 then
					local v2 = math.floor(v / 86400)
					countdown2.Text = v2 .. " day" .. (v2 == 1 and "" or "s")
				else
					if v == 0 then
						countdown2.Text = "Soon!"
						return
					end

					local v2 = math.floor(v / 3600)
					local v3 = math.floor(v % 3600 / 60)
					local v4 = v % 60
					countdown2.Text = string.format("%02d:%02d:%02d", v2, v3, v4)
				end
			end

			updateTimer()
			local v = 0
			maid:Add(RunService.Heartbeat:Connect(function(dt)
				v += dt

				if v < 1 then
					return
				end

				while v >= 1 do
					v -= 1
				end

				updateTimer()
			end))
		else
			countdown:Destroy()
		end

		local eligibilityItem = data.EligibilityItem
		local v

		if eligibilityItem then
			v = ItemRegistry.GetItem(eligibilityItem, OfflineItem):IsUnlockedOrJustBoughtClient(nil)
		else
			v = false
		end

		if v or DevProductController.IsOwned(p) then
			purchaseButton.Visible = false
			ownedButton.Visible = true
		else
			purchaseButton.Visible = true
			ownedButton.Visible = false
			local textLabel = purchaseButton:WaitForChild("TextLabel")
			textLabel.Text = ""
			task.spawn(function()
				local v2, v3 = GetProductInfo(DevProducts.GetId(p), Enum.InfoType.Product, 0)

				if v2 then
					local textLabel = purchaseButton:WaitForChild("TextLabel")
					textLabel.Text = "" .. v3.PriceInRobux
				end
			end)
		end

		ShopCardPlacer.ConnectProductCard(instance, maid, p, data)
		ShopCardPlacer.ConnectProductPurchase(purchaseButton, maid, p)
		ShopCardPlacer.ConnectGift(buttons:WaitForChild("SendGift"), maid, Purchasable.ofDevProduct(p))
		task.spawn(function()
			if data.PreviewImage == nil then
				local items = inset:WaitForChild("Right"):WaitForChild("Items")
				local featured, v2 = getFeatured(
					ItemProvider.GetItemsPurchasable(Purchasable.ofDevProduct(p)),
					data.Featured,
					8
				)
				addItems(maid, items, featured, v2)

				if #featured <= 2 then
					local uIGridLayout = items:FindFirstChild("UIGridLayout")
					local cellSize = uIGridLayout.CellSize
					local cellPadding = uIGridLayout.CellPadding
					uIGridLayout.CellSize = UDim2.new(cellSize.Y.Scale, cellSize.Y.Offset, 1 - cellPadding.Y.Scale, 0)
					uIGridLayout.CellPadding = UDim2.new(cellPadding.Y.Scale, cellPadding.Y.Offset, 0, 0)
				end

				items.Visible = true
				inset:WaitForChild("Right"):WaitForChild("Video"):Destroy()
				inset:WaitForChild("Right"):WaitForChild("Image"):Destroy()
			else
				local image = inset:WaitForChild("Right"):WaitForChild("Image")
				local imageLabel = image:WaitForChild("ImageLabel")
				imageLabel.Image = data.PreviewImage
				image.Visible = true
				inset:WaitForChild("Right"):WaitForChild("Items"):Destroy()
				inset:WaitForChild("Right"):WaitForChild("Video"):Destroy()
			end
		end)
		instance.Visible = true
	end)
end

function ShopCardPlacer.PlaceSummerBundle(p, instance, p2, p3)
	task.spawn(function()
		local buttons = instance:WaitForChild("Inset"):WaitForChild("Right"):WaitForChild("Buttons")
		local purchaseButton = buttons:WaitForChild("PurchaseButton")
		local ownedButton = buttons:WaitForChild("OwnedButton")
		local eligibilityItem = p3.EligibilityItem
		local v

		if eligibilityItem then
			v = ItemRegistry.GetItem(eligibilityItem, OfflineItem):IsUnlockedOrJustBoughtClient(nil)
		else
			v = false
		end

		if v or DevProductController.IsOwned(p) then
			purchaseButton.Visible = false
			ownedButton.Visible = true
		else
			purchaseButton.Visible = true
			ownedButton.Visible = false
			local textLabel = purchaseButton:WaitForChild("TextLabel")
			textLabel.Text = ""
			task.spawn(function()
				local v2, v3 = GetProductInfo(DevProducts.GetId(p), Enum.InfoType.Product, 0)

				if v2 then
					local textLabel = purchaseButton:WaitForChild("TextLabel")
					textLabel.Text = "" .. v3.PriceInRobux
				end
			end)
		end

		ShopCardPlacer.ConnectProductCard(instance, p2, p, p3)
		ShopCardPlacer.ConnectProductPurchase(purchaseButton, p2, p)
		instance.Visible = true
	end)
end

function ShopCardPlacer.ConnectCountableProductCard(instance, maid, p, p2)
	PanelController.LoadLazy("MainGUIHandler", "ItemCardCountableProduct", false)
	maid:Add(instance:WaitForChild("Inset").Activated:Connect(function()
		TelemetryController.SendClientInteraction("shopInteraction", {
			productType = "CountableDevProduct",
			id = CountableDevProducts.GetId(p),
			shop = ShopTelemetrySource.Prefix("new")
		})

		if ComponentUtil.FindAndWaitForComponentByTag(nil, "ItemCardCountableProduct", false):WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("ItemCardCountableProduct")):expect():SetProduct(
			p,
			p2
		) then
			PanelController.OpenPanelByContext("MainGUIHandler", "ItemCardCountableProduct")
		end
	end))
end

function ShopCardPlacer.ConnectCountableProductPurchase(p, maid, p2)
	maid:Add(p.Activated:Connect(function()
		local id = CountableDevProducts.GetId(p2)
		TelemetryController.SendClientInteraction("shopPurchase", {
			productType = "CountableDevProduct",
			id = id,
			shop = ShopTelemetrySource.Prefix("new")
		})
		CountableDevProductController.PromptPurchase(p2, ShopTelemetrySource.Prefix("shop"))
	end))
end

function ShopCardPlacer.PlaceTicketBundle(_, instance, p, data)
	assert(data.Type == "TicketBundle")
	task.spawn(function()
		local SummerCarnival2026Controller = require(ReplicatedStorage.Modules.Client.LiveOps.SummerCarnival2026Controller)
		local storeTicketBundleUpsell = Summer2026Util.GetStoreTicketBundleUpsell(
			SummerCarnival2026Controller.GetTickets(),
			SummerCarnival2026Controller.Week
		)

		if storeTicketBundleUpsell == nil then
			instance.Visible = false
			return
		end

		local countableDevProductInfo = PurchasableInfoController.GetCountableDevProductInfo(storeTicketBundleUpsell)
		local inset = instance:WaitForChild("Inset")
		local top = inset:WaitForChild("Left"):WaitForChild("Top")
		local gamepassIcon = top:WaitForChild("GamepassIcon")
		gamepassIcon.Image = "rbxassetid://" .. countableDevProductInfo.IconImageAssetId
		local gamepassName = top:WaitForChild("GamepassName")
		gamepassName.Text = "Summer Rewards Pass"
		local left = inset:WaitForChild("Left")
		local description = left:WaitForChild("Description")
		description.Text = data.ShortDescription

		if data.ShortDescriptionHeader == "" then
			local header = left:WaitForChild("Header")
			header.Visible = false
		else
			local header_2 = left:WaitForChild("Header")
			header_2.Text = data.ShortDescriptionHeader
		end

		left:WaitForChild("Bottom"):WaitForChild("Countdown"):Destroy()
		local buttons = inset:WaitForChild("Right"):WaitForChild("Buttons")
		local purchaseButton = buttons:WaitForChild("PurchaseButton")
		local ownedButton = buttons:WaitForChild("OwnedButton")
		ownedButton.Visible = false
		purchaseButton.Visible = true
		local textLabel = purchaseButton:WaitForChild("TextLabel")
		textLabel.Text = ""
		task.spawn(function()
			local v, v2 = GetProductInfo(CountableDevProducts.GetId(storeTicketBundleUpsell), Enum.InfoType.Product, 0)

			if v then
				local textLabel = purchaseButton:WaitForChild("TextLabel")
				textLabel.Text = "" .. v2.PriceInRobux
			end
		end)
		ShopCardPlacer.ConnectCountableProductCard(instance, p, storeTicketBundleUpsell, data)
		ShopCardPlacer.ConnectCountableProductPurchase(purchaseButton, p, storeTicketBundleUpsell)
		local sendGift = buttons:FindFirstChild("SendGift")

		if sendGift ~= nil then
			sendGift.Visible = false
		end

		local image = inset:WaitForChild("Right"):WaitForChild("Image")
		local imageLabel = image:WaitForChild("ImageLabel")
		imageLabel.Image = data.PreviewImage
		inset:WaitForChild("Right"):WaitForChild("Video"):Destroy()
		inset:WaitForChild("Right"):WaitForChild("Items"):Destroy()
		image.Visible = true
		instance.Visible = true
	end)
end

return ShopCardPlacer