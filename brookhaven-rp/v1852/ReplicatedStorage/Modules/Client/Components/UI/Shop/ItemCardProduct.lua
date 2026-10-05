local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local ItemProvider = require(ReplicatedStorage.Modules.Client.Components.UI.Shop.ItemProvider)
local PurchasableInfoController = require(ReplicatedStorage.Modules.Client.Data.PurchasableInfoController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ShopTelemetrySource = require(ReplicatedStorage.Modules.Client.UI.ShopTelemetrySource)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local OfflineItem = require(ReplicatedStorage.Modules.Shared.Item.OfflineItem)
local v = Component.new({
	Tag = "ItemCardProduct"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:SetProduct(product, data)
	self.Gamepass = nil
	self.PassName = nil
	local devProductInfo = PurchasableInfoController.GetDevProductInfo(product)

	if devProductInfo == nil then
		return false
	end

	local outerBox = self.Instance:WaitForChild("OuterBox")
	local imageLabel = outerBox:WaitForChild("Left"):WaitForChild("ImageLabel")
	imageLabel.Image = data.DetailsImage
	local right = outerBox:WaitForChild("Right")
	local gamepassBanner = right:WaitForChild("GamepassBanner")
	local gamepassIcon = gamepassBanner:WaitForChild("GamepassIcon")
	gamepassIcon.Image = "rbxassetid://" .. devProductInfo.IconImageAssetId
	local gamepassName = gamepassBanner:WaitForChild("GamepassName")
	gamepassName.Text = DevProducts.GetDisplayName(product) or devProductInfo.Name
	local description = right:WaitForChild("Description")
	description.Text = data.LongDescription
	local buttons = right:WaitForChild("Buttons")
	local purchaseButton = buttons:WaitForChild("PurchaseButton")
	local ownedButton = buttons:WaitForChild("OwnedButton")
	local eligibilityItem = data.EligibilityItem
	local v2

	if eligibilityItem then
		v2 = ItemRegistry.GetItem(eligibilityItem, OfflineItem):IsUnlockedClient()
	else
		v2 = false
	end

	if v2 or DevProductController.IsOwned(product) then
		purchaseButton.Visible = false
		ownedButton.Visible = true
	else
		purchaseButton.Visible = true
		ownedButton.Visible = false
		local textLabel = purchaseButton:WaitForChild("TextLabel")
		textLabel.Text = ""
		task.spawn(function()
			local v3, v4 = GetProductInfo(DevProducts.GetId(product), Enum.InfoType.Product, 0)

			if v3 then
				local textLabel = purchaseButton:WaitForChild("TextLabel")
				textLabel.Text = "" .. v4.PriceInRobux
			end
		end)
	end

	local items_2 = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Items")
	items_2.Visible = false
	local video = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Video")
	video.Visible = false
	local image = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Image")
	image.Visible = false

	if data.CardType == "Items" then
		local items_3 = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Items")
		items_3.Visible = true
		local items = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Items")

		for _, frame in items:GetChildren() do
			if frame.Name == "Item" and frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		local template = items:WaitForChild("Template")
		local itemsPurchasable = ItemProvider.GetItemsPurchasable(Purchasable.ofDevProduct(product))
		local clone = table.clone(data.Featured)

		for _, v3 in itemsPurchasable do
			if table.find(data.Featured, v3) == nil then
				table.insert(clone, v3)
			end
		end

		for _, image2 in clone do
			local clone2 = template:Clone()
			clone2.Visible = true
			clone2.Name = "Item"
			local imageLabel_2 = clone2:WaitForChild("ImageLabel")
			imageLabel_2.Image = image2
			clone2.Parent = items
		end

		if #clone <= 2 then
			local uIGridLayout = items:WaitForChild("UIGridLayout")
			uIGridLayout.CellSize = UDim2.new(0.5, 0, 0, 1)
		end

		local X = items.AbsoluteCanvasSize.X
		items.CanvasSize = UDim2.new(0, 0, 0, math.ceil(X / 4) * math.ceil(#clone / 4))
	elseif data.CardType == "Image" then
		local image_2 = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Image")
		image_2.Visible = true
		local imageLabel_3 = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Image"):WaitForChild("ImageLabel")
		imageLabel_3.Image = data.CardImage
	else
		assert(false, "card type not implemented")
	end

	local visible = DevProducts.GetGiftId(product) ~= DevProducts.GetId(product)
	local sendGift = buttons:WaitForChild("SendGift")
	sendGift.Visible = visible
	self.Product = product
	self.PassName = DevProducts.GetDisplayName(product) or devProductInfo.Name
	return true
end

function v:Start()
	local buttons = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Buttons")
	local purchaseButton = buttons:WaitForChild("PurchaseButton")
	local ownedButton = buttons:WaitForChild("OwnedButton")
	local panel = PanelController.GetPanel("MainGUIHandler", "ItemCardProduct")
	self._Janitor:Add(function()
		panel:UnregisterListener(self, Panel.Events.Closing)
	end)
	self._Janitor:Add(purchaseButton.Activated:Connect(function()
		if self.Product == nil then
			return
		end

		local id = DevProducts.GetId(self.Product)
		TelemetryController.SendClientInteraction("shopPurchase", {
			productType = "DevProduct",
			id = id,
			featured = false,
			shop = ShopTelemetrySource.Prefix("card")
		})
		DevProductController.PromptPurchaseWithId(DevProducts.GetId(self.Product), ShopTelemetrySource.Prefix("card"))
	end))
	self._Janitor:Add(buttons:WaitForChild("SendGift").Activated:Connect(function()
		if self.Product == nil then
			return
		end

		local waitForComponent = ComponentUtil.FindAndWaitForComponentByTag(
			Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient"),
			"GiftSelectRecipient",
			false
		)
		waitForComponent:SetGiftData(
			DevProducts.GetGiftId(self.Product),
			self.PassName,
			ShopTelemetrySource.Prefix("card")
		)
		waitForComponent:WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient")):expect():SetPreviousPanel("ItemCardProduct")
		PanelController.OpenPanelByContext("MainGUIHandler", "GiftSelectRecipient")
	end))
	self._Janitor:Add(DevProductController.OnPurchase:Connect(function(p: number)
		if self.Product == nil or p ~= DevProducts.GetId(self.Product) then
			return
		end

		purchaseButton.Visible = false
		ownedButton.Visible = true
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v