require(game.ReplicatedStorage.Packages.Result)
local Option = require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Future)
local Type = require(game.ReplicatedStorage.Packages.Type)
local Display = require(game.ReplicatedStorage.Packages.Display)
require(game.ReplicatedStorage.Economy.EconomyItem.Product)
require(game.ReplicatedStorage.Economy.EconomyItem.LegacyInfo)
require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
require(game.ReplicatedStorage.Economy.EconomyItem.Qualification)
require(game.ReplicatedStorage.Economy.EconomyItem.Product.Settlement)
local TypeUtil = require(game.ReplicatedStorage.Economy.TypeUtil)
local Types = require(game.ReplicatedStorage.Economy.EconomyItem.Types)
local LegacyConversionUtil = require(game.ReplicatedStorage.Economy.EconomyItem.LegacyConversionUtil)
require(game.ReplicatedStorage.SaleService)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local class = {}
class.__index = class

function class:HasTag(p2)
	return self._Tags[p2] == true
end

function class:GetTags()
	local result = {}

	for k, _ in pairs(self._Tags) do
		table.insert(result, k)
	end

	return result
end

function class.ToLegacy(p)
	return LegacyConversionUtil.toLegacy(p)
end

function class.new(products, qualifications, legacyInfo, itemId: number, p5, p6)
	local clone = table.clone(p5)
	local unwrapped = ItemConfig.match(itemId):unwrap()

	if table.find(clone, "IsGiftable") then
		warn((`IsGiftable is handled by ItemConfig, currently being assigned in "{unwrapped.Index.DebugLabel}"`))
	end

	if unwrapped.Economy and unwrapped.Economy.IsGiftable then
		table.insert(clone, "IsGiftable")
	end

	if table.find(clone, "DoNotFeature") then
		warn((`DoNotFeature is handled by ItemConfig, currently being assigned in "{unwrapped.Index.DebugLabel}"`))
	end

	if not (unwrapped.Economy and unwrapped.Economy.CanBeFeatured) then
		table.insert(clone, "DoNotFeature")
	end

	local tags = {}

	for _, v2 in ipairs(clone) do
		tags[v2] = true
	end

	local unwrapped2 = ItemId.getDataFromId(itemId):unwrap()

	if unwrapped2.Type ~= "Redeemable" then
		error((`EconomyItem can only be created for Redeemable items, got {unwrapped2.Type} for itemId {itemId}`))
	end

	table.freeze(tags)
	local self = setmetatable({
		LegacyInfo = legacyInfo,
		Qualifications = qualifications,
		Products = products,
		ItemId = itemId,
		_Tags = tags,
		RestrictedToSales = Option.from(p6 and table.freeze(table.clone(p6)) or nil)
	}, class)
	table.freeze(self)
	return self
end

function class.__tostring(p)
	local clone = table.clone(p)
	setmetatable(clone, nil)
	return (`{script.Name}<{Display.JSON.new():display(clone)}>`)
end

return {
	Type = {
		check = Type.intersection(Types.Types.EconomyItemStruct, TypeUtil.Metatable.Type.check(class))
	},
	Class = class,
	Tags = {
		IsGiftable = "IsGiftable",
		StoreOnPurchase = "StoreOnPurchase",
		StoreOnGiftClaim = "StoreOnGiftClaim",
		DoNotFeature = "DoNotFeature",
		NoStore = "NoStore",
		NoTrade = "NoTrade",
		StoreAsEtcItem = "StoreAsEtcItem",
		BadPurchasesAreStored = "BadPurchasesAreStored",
		CanTradeDuplicates = "CanTradeDuplicates"
	},
	REVERSE_LOOK_UP_FIELD = LegacyConversionUtil.REVERSE_LOOK_UP_FIELD
}