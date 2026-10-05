local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = require(ReplicatedStorage.Common.MarketplaceService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Thread = require(ReplicatedStorage.Common.Utils.Utilities.Thread)
local ValueConvertor = require(ReplicatedStorage.Common.Utils.Utilities.ValueConvertor)
local v = {
	GamePass = Enum.InfoType.GamePass,
	DevProduct = Enum.InfoType.Product
}

local function updatePriceLabel(instance)
	local productId = tonumber(instance:GetAttribute("ProductId") or "")

	if not productId then
		warn((`Invalid ProductId for {instance:GetFullName()}: {instance:GetAttribute("ProductId")}`))
		return
	end

	if not (productId ~= -1 and instance:HasTag("ProductPriceLabel")) then
		return
	end

	local priceFormat = instance:GetAttribute("PriceFormat") or "%s"
	local productType = instance:GetAttribute("ProductType") or "DevProduct"
	MarketplaceService:GetProductInfoAsync(productId, v[productType]):andThen(function(p)
		local priceInRobux = p.PriceInRobux

		if priceInRobux then
			instance.Text = string.format(priceFormat, ValueConvertor:AddCommas(priceInRobux))
		end
	end):catch(function() end)
end

Thread.Every(300, function()
	for _, v2 in CollectionService:GetTagged("ProductPriceLabel") do
		task.spawn(updatePriceLabel, v2)
	end
end)
return Observers.observeTagNoAncestry("ProductPriceLabel", function(object)
	task.spawn(updatePriceLabel, object)
	local productIdChangedConnection = object:GetAttributeChangedSignal("ProductId"):Connect(function()
		updatePriceLabel(object)
	end)
	return function()
		productIdChangedConnection:Disconnect()
	end
end)