local MarketplaceService = game:GetService("MarketplaceService")
local Cache = require(game.ReplicatedStorage.UserGenerated.Concurrency.Cache)
local Asserts = require(game.ReplicatedStorage.UserGenerated.Lang.Asserts)
local tablePermissive = Asserts.TablePermissive({
	PurchaseId = Asserts.String,
	PlayerId = Asserts.Integer,
	ProductId = Asserts.Integer,
	PlaceIdWherePurchased = Asserts.Integer,
	CurrencySpent = Asserts.IntegerNonNegative,
	CurrencyType = Asserts.AnyOf(Asserts.Enum(Enum.CurrencyType), Asserts.String),
	ProductPurchaseChannel = Asserts.Enum(Enum.ProductPurchaseChannel)
})
local table2 = Asserts.Table({
	AssetId = Asserts.Integer,
	InfoType = Asserts.Enum(Enum.InfoType)
})
local v = Cache.new({
	Callback = function(p)
		return MarketplaceService:GetProductInfo(p.AssetId, p.InfoType)
	end,
	AssertKey = function(p)
		table2(p)
		return (`{p.AssetId},{p.InfoType.Value}`)
	end
})
return table.freeze({
	AssertReceiptInfo = tablePermissive,
	GetInfoAsync = function(assetId: number, infoType, flag: boolean?)
		Asserts.Integer(assetId)
		Asserts.Enum(Enum.InfoType)(infoType)
		Asserts.Optional(Asserts.Boolean)(flag)
		local v2 = {
			AssetId = assetId,
			InfoType = infoType
		}

		if flag then
			return v:Get(v2)
		end

		return v:GetAsync(v2)
	end
})