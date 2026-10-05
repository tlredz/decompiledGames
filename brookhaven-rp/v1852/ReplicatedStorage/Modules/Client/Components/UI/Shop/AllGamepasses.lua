local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ShopAndFeatured = require(ReplicatedStorage.Modules.Client.Components.UI.Shop.ShopAndFeatured)
local ShopCardPlacer = require(ReplicatedStorage.Modules.Client.Components.UI.Shop.ShopCardPlacer)
local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local ManualSizeY = require(ReplicatedStorage.Modules.Client.UI.ManualSizeY)
local ShopItems = require(ReplicatedStorage.Modules.Shared.DB.Shop.ShopItems)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local OfflineItem = require(ReplicatedStorage.Modules.Shared.Item.OfflineItem)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "AllGamepasses"
})
local v2 = {
	Gamepass = ShopCardPlacer.Place,
	DevProduct = ShopCardPlacer.Place
}
local v3 = {
	DevProductBig = true,
	DevProduct = true,
	FeatureDevProduct = true,
	SummerBundle = true
}
local v4 = {
	DevProductBig = ShopCardPlacer.PlaceProduct,
	FeatureDevProduct = ShopCardPlacer.PlaceFeature,
	FeatureGamepass = ShopCardPlacer.PlaceFeature,
	SummerBundle = ShopCardPlacer.PlaceSummerBundle,
	TicketBundle = ShopCardPlacer.PlaceTicketBundle
}

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:ReorderOwned(items)
	local v5 = {}
	local result = {}

	for _, item in items do
		local purchasable = item.purchasable
		local eligibilityItem = item.item.EligibilityItem
		local v6

		if eligibilityItem then
			local item2 = ItemRegistry.GetItem(eligibilityItem, OfflineItem)
			assert(item2, "unknown item " .. eligibilityItem)
			v6 = item2:IsUnlockedOrJustBoughtClient(nil)
		else
			v6 = false
		end

		if purchasable == "SUMMER_CARNIVAL" then
			local SummerCarnival2026Controller = require(ReplicatedStorage.Modules.Client.LiveOps.SummerCarnival2026Controller)
			local Summer2026Util = require(ReplicatedStorage.Modules.Shared.LiveOps.Summer2026Util)

			if Summer2026Util.GetStoreTicketBundleUpsell(
				SummerCarnival2026Controller.GetTickets(),
				SummerCarnival2026Controller.Week
			) ~= nil then
				table.insert(result, item)
			end
		elseif v6 or purchasable:IsOwnedClient() then
			table.insert(v5, item)
		else
			table.insert(result, item)
		end
	end

	for _, v6 in v5 do
		table.insert(result, v6)
	end

	return result
end

local function deserializeShopItems(items)
	local result = {}

	for _, item in items do
		local flag = item.Flag

		if not (flag == nil or PlayerFlag.IsEnabled(flag)) then
			continue
		end

		local excludeFlag = item.ExcludeFlag

		if not (excludeFlag == nil or not PlayerFlag.IsEnabled(excludeFlag)) then
			continue
		end

		if item.Type == "TicketBundle" then
			table.insert(result, {
				purchasable = "SUMMER_CARNIVAL",
				item = item
			})
		elseif v3[item.Type] then
			table.insert(result, {
				purchasable = Purchasable.ofDevProduct(assert(DevProducts.All[item.Name])),
				item = item
			})
		else
			local v5 = assert(Gamepasses.All[item.Name], "Unknown gamepass: " .. item.Name)
			local overrideProductId = GamepassController.GetOverrideProductId(v5)
			local purchasable

			if overrideProductId == nil then
				purchasable = Purchasable.ofGamepass(v5)
			else
				purchasable = Purchasable.ofDevProduct(DevProducts.GetById(overrideProductId))
			end

			table.insert(result, {
				purchasable = purchasable,
				item = item
			})
		end
	end

	return result
end

function v:Open()
	if self.isGenerated then
		return
	end

	self.isGenerated = true

	if Janitor.Is(self.OpenJanitor) then
		self.OpenJanitor:Destroy()
	end

	self.OpenJanitor = Janitor.new()
	local scrollingFrame = self.Instance:WaitForChild("ScrollingFrame")
	local rowTemplate = scrollingFrame:WaitForChild("RowTemplate")
	local template = scrollingFrame:WaitForChild("Template")
	local productTemplate = scrollingFrame:WaitForChild("ProductTemplate")
	local summerBundleTemplate = scrollingFrame:WaitForChild("SummerBundleTemplate")
	local featureTemplate = scrollingFrame:WaitForChild("FeatureTemplate")
	local reorderOwned = self:ReorderOwned((deserializeShopItems(ShopItems.GetConfig())))
	local v5 = {
		Gamepass = template,
		DevProduct = template,
		DevProductBig = productTemplate,
		FeatureDevProduct = featureTemplate,
		FeatureGamepass = featureTemplate,
		SummerBundle = summerBundleTemplate,
		TicketBundle = productTemplate
	}
	local v6 = {}
	local v7 = {}

	for k, shop in reorderOwned do
		if v4[shop.item.Type] then
			local clone = v5[shop.item.Type]:Clone()
			clone.Parent = scrollingFrame
			clone.Name = shop.item.Type
			clone.LayoutOrder = k * 10
			self.OpenJanitor:Add(clone, "Destroy")
			table.insert(v6, {
				shop = shop,
				instance = clone,
				place = v4[shop.item.Type]
			})
		else
			local clone = assert(v5[shop.item.Type]):Clone()
			table.insert(v7, {
				shop = shop,
				order = k * 10,
				place = assert(v2[shop.item.Type]),
				slot = {
					instance = clone,
					items = 3
				}
			})
			clone.Name = "Item"
			clone.LayoutOrder = k
			clone.SelectionOrder = k + -1000
			clone.Selectable = true
			self.OpenJanitor:Add(clone, "Destroy")
		end
	end

	local plus = scrollingFrame:FindFirstChild("Plus")

	if plus ~= nil then
		plus:Destroy()
	end

	ManualSizeY.AddResizeFunction(self.OpenJanitor, function()
		local X = scrollingFrame.AbsoluteCanvasSize.X
		local v8 = math.ceil(#v7 / 2)
		local v9 = X / 4 * v8 + X / 3 * #v6
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, v9)

		for _, v10 in v7 do
			for _, label in v10.slot.instance:WaitForChild("Inset"):WaitForChild("Split"):WaitForChild("Left"):GetChildren() do
				if not label:IsA("TextLabel") then
					continue
				end

				local uITextSizeConstraint = label:FindFirstChild("UITextSizeConstraint")

				if uITextSizeConstraint == nil then
					continue
				end

				uITextSizeConstraint.MaxTextSize = math.min(36, X / 26)
				uITextSizeConstraint.MinTextSize = 8
			end
		end

		for _, v10 in v6 do
			local description = v10.instance:WaitForChild("Inset"):WaitForChild("Left"):FindFirstChild("Description")
			local uITextSizeConstraint = description and description:FindFirstChild("UITextSizeConstraint")

			if uITextSizeConstraint == nil then
				continue
			end

			uITextSizeConstraint.MaxTextSize = math.min(36, X / 26)
			uITextSizeConstraint.MinTextSize = 8
		end
	end)

	for _, v8 in v7 do
		v8.place(v8.shop.purchasable, v8.slot, self.OpenJanitor, v8.shop.item)
	end

	for _, v8 in v6 do
		if v8.shop.item.Type == "FeatureGamepass" or v8.shop.item.Type == "FeatureDevProduct" then
			v8.place(v8.shop.purchasable, v8.instance, self.OpenJanitor, v8.shop.item)
		else
			local v9

			if v8.shop.item.Type ~= "TicketBundle" then
				v9 = v8.shop.purchasable:ToDevProduct()
			end

			v8.place(v9, v8.instance, self.OpenJanitor, v8.shop.item)
		end
	end

	local v8 = {}

	for _, v9 in v7 do
		if v9.slot.instance.Visible then
			table.insert(v8, {
				instance = v9.slot.instance,
				order = v9.order
			})
		end
	end

	local total = 1

	while total <= #v8 do
		local clone = rowTemplate:Clone()
		clone.Visible = true
		clone.Parent = scrollingFrame
		clone.Name = "Row"
		clone.LayoutOrder = v8[total].order
		self.OpenJanitor:Add(clone, "Destroy")
		v8[total].instance.Parent = clone

		if total + 1 <= #v7 and total ~= #v8 then
			v8[total + 1].instance.Parent = clone
		end

		total += 2
	end
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"ShopAndFeatured",
		ShopAndFeatured
	)
	self._Janitor:Add(waitForAncestorComponent.SelectLayout:Connect(function(p)
		if p == self.Instance then
			self:Open()
		end
	end))
	self._Janitor:Add(Players.LocalPlayer:GetPropertyChangedSignal("HasRobloxSubscription"):Connect(function()
		if not Players.LocalPlayer.HasRobloxSubscription then
			return
		end

		self.isGenerated = false
		self:Open()
	end))
	self._Janitor:Add(Remotes.connect("DevProductPurchased", function(p)
		if not DevProducts.Exists(p) then
			return
		end

		self.isGenerated = false
		self:Open()
	end))
	self._Janitor:Add(Remotes.connect("GamepassPurchased", function(_)
		self.isGenerated = false
		self:Open()
	end))
	Remotes.connect("GiftReceived", function(_, _, _, _, _)
		self.isGenerated = false
	end)
end

function v:Stop()
	if Janitor.Is(self.OpenJanitor) then
		self.OpenJanitor:Destroy()
	end

	self._Janitor:Destroy()
end

function v.ForceRerender()
	for _, v5 in v:GetAll() do
		v5.isGenerated = false
		v5:Open()
	end
end

return v