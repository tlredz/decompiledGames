require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Future)
local Type = require(game.ReplicatedStorage.Packages.Type)
local Product = require(game.ReplicatedStorage.Economy.EconomyItem.Product)
local LegacyInfo = require(game.ReplicatedStorage.Economy.EconomyItem.LegacyInfo)
require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
local Qualification = require(game.ReplicatedStorage.Economy.EconomyItem.Qualification)
require(game.ReplicatedStorage.Economy.EconomyItem.Product.Settlement)
local SaleService = require(game.ReplicatedStorage.SaleService)
local TypeUtil = require(game.ReplicatedStorage.Economy.TypeUtil)
local literal = Type.literal(
	"IsGiftable",
	"StoreOnGiftClaim",
	"StoreOnTrade",
	"DoNotFeature",
	"NoStore",
	"NoTrade",
	"StoreOnPurchase",
	"StoreAsEtcItem",
	"BadPurchasesAreStored",
	"CanTradeDuplicates"
)
return {
	Types = {
		EconomyItemStruct = Type.strictInterface({
			LegacyInfo = LegacyInfo.Type.check,
			Products = Type.array(Product.Type.check),
			Qualifications = Type.array(Qualification.Type.check),
			ItemId = Type.integer,
			_Tags = Type.intersection(Type.keys(literal), Type.values(Type.literal(true))),
			RestrictedToSales = TypeUtil.Option.Type.check(Type.array(SaleService.Type.SaleKey))
		})
	}
}