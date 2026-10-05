local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemProvider = require(ReplicatedStorage.Modules.Client.Components.UI.Shop.ItemProvider)
local PurchasableInfoController = require(ReplicatedStorage.Modules.Client.Data.PurchasableInfoController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local ShopTelemetrySource = require(ReplicatedStorage.Modules.Client.UI.ShopTelemetrySource)
local RobloxUnicode = require(ReplicatedStorage.Modules.Shared.Utils.RobloxUnicode)
local v = Component.new({
	Tag = "ItemCardCountableProduct"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:SetProduct(product, data)
	local countableDevProductInfo = PurchasableInfoController.GetCountableDevProductInfo(product)

	if countableDevProductInfo == nil then
		return false
	end

	local outerBox = self.Instance:WaitForChild("OuterBox")
	local imageLabel = outerBox:WaitForChild("Left"):WaitForChild("ImageLabel")
	imageLabel.Image = data.DetailsImage
	local right = outerBox:WaitForChild("Right")
	local gamepassBanner = right:WaitForChild("GamepassBanner")
	local gamepassIcon = gamepassBanner:WaitForChild("GamepassIcon")
	gamepassIcon.Image = "rbxassetid://" .. countableDevProductInfo.IconImageAssetId
	local gamepassName = gamepassBanner:WaitForChild("GamepassName")
	gamepassName.Text = "Summer Rewards Pass"
	local description = right:WaitForChild("Description")
	description.Text = data.LongDescription
	local purchaseButton = right:WaitForChild("Buttons"):WaitForChild("PurchaseButton")
	purchaseButton.Visible = true
	local textLabel = purchaseButton:WaitForChild("TextLabel")
	textLabel.Text = ""
	task.spawn(function()
		local v2, v3 = GetProductInfo(CountableDevProducts.GetId(product), Enum.InfoType.Product, 0)

		if v2 then
			local textLabel = purchaseButton:WaitForChild("TextLabel")
			textLabel.Text = "" .. v3.PriceInRobux
		end
	end)
	local items_2 = right:WaitForChild("Items")
	items_2.Visible = true
	local items = right:WaitForChild("Items")

	for _, frame in items:GetChildren() do
		if frame.Name == "Item" and frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local template = items:WaitForChild("Template")
	local itemsCountable = ItemProvider.GetItemsCountable(product)
	local clone = table.clone(data.Featured)

	for _, v2 in itemsCountable do
		if table.find(data.Featured, v2) == nil then
			table.insert(clone, v2)
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

	if #clone <= 2 then
		local uIGridLayout = items:WaitForChild("UIGridLayout")
		uIGridLayout.CellSize = UDim2.new(0.5, 0, 0, 1)
	end

	local X = items.AbsoluteCanvasSize.X
	items.CanvasSize = UDim2.new(0, 0, 0, math.ceil(X / 4) * math.ceil(#clone / 4))
	self.Product = product
	return true
end

function v:Start()
	local purchaseButton = self.Instance:WaitForChild("OuterBox"):WaitForChild("Right"):WaitForChild("Buttons"):WaitForChild("PurchaseButton")
	self._Janitor:Add(purchaseButton.Activated:Connect(function()
		if self.Product == nil then
			return
		end

		local id = CountableDevProducts.GetId(self.Product)
		TelemetryController.SendClientInteraction("shopPurchase", {
			productType = "CountableDevProduct",
			id = id,
			featured = false,
			shop = ShopTelemetrySource.Prefix("card")
		})
		CountableDevProductController.PromptPurchase(self.Product, ShopTelemetrySource.Prefix("card"))
	end))
	self._Janitor:Add(MarketplaceService.PromptProductPurchaseFinished:Connect(function(_: number, p: number, flag: boolean)
		if self.Product == nil or not flag or p ~= CountableDevProducts.GetId(self.Product) then
			return
		end

		local textLabel = purchaseButton:WaitForChild("TextLabel")
		textLabel.Text = RobloxUnicode.ROBUX
		task.spawn(function()
			local v2, v3 = GetProductInfo(p, Enum.InfoType.Product, 0)

			if v2 then
				local textLabel = purchaseButton:WaitForChild("TextLabel")
				textLabel.Text = RobloxUnicode.ROBUX .. v3.PriceInRobux
			end
		end)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v