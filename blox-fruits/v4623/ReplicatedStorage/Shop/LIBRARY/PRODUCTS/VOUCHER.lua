require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates
local VOUCHER = {}
local theSwordOfTheBrat = IdMap.Redeemable["The Sword Of The Brat"]
local theSwordOfTheBrat2 = IdMap.Moveset["The Sword Of The Brat"]
table.insert(
	VOUCHER,
	templates.Simple.new(
		theSwordOfTheBrat,
		{ templates2.Simple.new(templates3.Item.sword(theSwordOfTheBrat2)) },
		{ templates5.Item.notAlreadyRedeemed(theSwordOfTheBrat2, { "Redeem" }) },
		templates4.Simple.newRobuxItem(theSwordOfTheBrat, "Sword"),
		{ "BadPurchasesAreStored", "StoreOnTrade" }
	)
)
local bRATSKINslayer = IdMap.Redeemable.BRATSKINslayer
local bRATSKINslayer2 = IdMap.Skin.BRATSKINslayer
local simples = {}
local v = {}
table.insert(v, templates5.Item.doesNotOwnSwordSkin(bRATSKINslayer2, Economy.excludeFilters({ "Store", "Trade" })))
local unwrapped = ItemConfig.match(bRATSKINslayer2):unwrap()
assert(unwrapped.Skin and unwrapped.Skin.Adornee, (`bad skin config: "{unwrapped.Index.DebugLabel}"`))
table.insert(simples, templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["The Sword Of The Brat"], false)))
table.insert(simples, templates2.Simple.new(templates3.Item.swordSkin(bRATSKINslayer2)))
table.insert(
	VOUCHER,
	templates.Simple.new(
		bRATSKINslayer,
		simples,
		v,
		templates4.Simple.newRobuxItem(bRATSKINslayer, "Bundle", false),
		{ "StoreOnTrade" }
	)
)
local doge = IdMap.Redeemable.Doge
local doge2 = IdMap.ProfileFullArt.Doge
local simples2 = {}
local v2 = {}
table.insert(v2, templates5.Item.doesNotOwnProfileFullArt(doge2, Economy.excludeFilters({ "Store", "Trade" })))
table.insert(simples2, templates2.Simple.new(templates3.Item.profileFullArt(doge2)))
table.insert(
	VOUCHER,
	templates.Simple.new(
		doge,
		simples2,
		v2,
		templates4.Simple.newRobuxItem(doge, "ProfileItem", false),
		{ "StoreOnTrade" }
	)
)
local vaporwave = IdMap.Redeemable.Vaporwave
local vaporwave2 = IdMap.ProfileFullArt.Vaporwave
local simples3 = {}
local v3 = {}
table.insert(v3, templates5.Item.doesNotOwnProfileFullArt(vaporwave2, Economy.excludeFilters({ "Store", "Trade" })))
table.insert(simples3, templates2.Simple.new(templates3.Item.profileFullArt(vaporwave2)))
table.insert(
	VOUCHER,
	templates.Simple.new(
		vaporwave,
		simples3,
		v3,
		templates4.Simple.newRobuxItem(vaporwave, "ProfileItem", false),
		{ "StoreOnTrade" }
	)
)
table.freeze(VOUCHER)
return VOUCHER