local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemProvider = require(ReplicatedStorage.Modules.Client.Components.UI.Shop.ItemProvider)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ShopTelemetrySource = require(ReplicatedStorage.Modules.Client.UI.ShopTelemetrySource)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "ItemCard"
})
local v2 = {
	[Gamepasses.VEHICLE_UPGRADE] = "VehicleUpgradeGamepassItem"
}

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:SetGamepass(gamepass, data)
	self.Gamepass = nil
	self.PassName = nil
	local infoClient = gamepass:GetInfoClient()

	if infoClient == nil then
		return false
	end

	local outerBox = self.Instance:WaitForChild("OuterBox")
	local imageLabel = outerBox:WaitForChild("Left"):WaitForChild("ImageLabel")
	imageLabel.Image = data.DetailsImage
	local right = outerBox:WaitForChild("Right")
	local gamepassBanner = right:WaitForChild("GamepassBanner")
	local gamepassIcon = gamepassBanner:WaitForChild("GamepassIcon")
	gamepassIcon.Image = "rbxassetid://" .. infoClient.IconImageAssetId
	local gamepassName = gamepassBanner:WaitForChild("GamepassName")
	gamepassName.Text = infoClient.Name
	local description = right:WaitForChild("Description")
	description.Text = data.LongDescription
	local buttons = right:WaitForChild("Buttons")
	local purchaseButton = buttons:WaitForChild("PurchaseButton")
	local ownedButton = buttons:WaitForChild("OwnedButton")
	local gamepass2 = gamepass:ToGamepass()
	local v3

	if gamepass2 and v2[gamepass2] then
		v3 = ItemRegistry.GetItem(v2[gamepass2], Item):IsUnlockedClient()
	else
		v3 = false
	end

	if v3 or gamepass:IsOwnedClient() then
		purchaseButton.Visible = false
		ownedButton.Visible = true
	else
		purchaseButton.Visible = true
		ownedButton.Visible = false
		local textLabel = purchaseButton:WaitForChild("TextLabel")
		textLabel.Text = ""
		task.spawn(function()
			local priceAsync = gamepass:GetPriceAsync()

			if priceAsync ~= nil then
				local textLabel = purchaseButton:WaitForChild("TextLabel")
				textLabel.Text = "" .. priceAsync
			end
		end)
	end

	local items = right:WaitForChild("Items")
	items.CanvasPosition = Vector2.new(0, 0)
	local template = items:WaitForChild("Template")

	for _, frame in items:GetChildren() do
		if frame.Name == "Item" and frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local itemsPurchasable = ItemProvider.GetItemsPurchasable(gamepass)
	local clone = table.clone(data.Featured)

	for _, v4 in itemsPurchasable do
		if table.find(data.Featured, v4) == nil then
			table.insert(clone, v4)
		end
	end

	for _, image in clone do
		local clone2 = template:Clone()
		clone2.Visible = true
		clone2.Name = "Item"
		local imageLabel_2 = clone2:WaitForChild("ImageLabel")
		imageLabel_2.Image = image
		clone2.Parent = items
	end

	local X = items.AbsoluteCanvasSize.X
	items.CanvasSize = UDim2.new(0, 0, 0, math.ceil(X / 4) * math.ceil(#clone / 4))
	self.Gamepass = gamepass
	self.PassName = infoClient.Name
	return true
end

function v:Start()
	local buttons = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Buttons")
	local purchaseButton = buttons:WaitForChild("PurchaseButton")
	local ownedButton = buttons:WaitForChild("OwnedButton")
	self._Janitor:Add(purchaseButton.Activated:Connect(function()
		if self.Gamepass == nil then
			return
		end

		local devProduct = self.Gamepass:ToDevProduct()

		if devProduct == nil then
			local id = self.Gamepass:GetId()
			TelemetryController.SendClientInteraction("shopPurchase", {
				productType = "GamePass",
				id = id,
				shop = ShopTelemetrySource.Prefix("card")
			})
			Remotes.fireServer("PromptGamepassPurchase", id, ShopTelemetrySource.Prefix("Preview Card"))
		else
			TelemetryController.SendClientInteraction("shopPurchase", {
				productType = "DevProduct",
				id = self.Gamepass:GetId(),
				shop = ShopTelemetrySource.Prefix("card")
			})
			DevProductController.PromptPurchaseWithId(
				DevProducts.GetId(devProduct),
				ShopTelemetrySource.Prefix("Preview Card")
			)
		end
	end))
	self._Janitor:Add(buttons:WaitForChild("SendGift").Activated:Connect(function()
		if self.Gamepass == nil or self.PassName == nil then
			return
		end

		local waitForComponent = ComponentUtil.FindAndWaitForComponentByTag(
			Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient"),
			"GiftSelectRecipient",
			false
		)
		waitForComponent:SetGiftData(self.Gamepass:GetGiftId(), self.PassName, ShopTelemetrySource.Prefix("card"))
		waitForComponent:WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient")):expect():SetPreviousPanel("ItemCard")
		PanelController.OpenPanelByContext("MainGUIHandler", "GiftSelectRecipient")
	end))
	self._Janitor:Add(Remotes.connect("GamepassPromptPurchaseFinished", function(p: number, flag: boolean)
		if self.Gamepass == nil or not flag or p ~= self.Gamepass:GetId() then
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