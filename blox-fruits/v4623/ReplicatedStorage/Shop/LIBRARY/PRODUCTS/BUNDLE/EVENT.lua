require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Economy.EconomyItem)
require(game.ReplicatedStorage.Economy.EconomyItem.Qualification)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local IdMap = require(game.ReplicatedStorage.IdMap)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.Qualification.Templates
local EVENT = {}
local holidayEssentials24 = IdMap.Redeemable.HolidayEssentials24
local new = templates.Simple.new
local simple = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Buddha-Buddha"], true))
local simple2 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Portal-Portal"], true))
local simple3 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["10K Fragments"], true))
local complex = templates2.Tiered.complex
local v = {
	[NumberRange.new(0, 699)] = templates3.economyItem(IdMap.Redeemable["300K Money"], true),
	[NumberRange.new(700, 1499)] = templates3.economyItem(IdMap.Redeemable["900K Money"], true),
	[NumberRange.new(1500, 15000000000)] = templates3.economyItem(IdMap.Redeemable["1.8M Money"], true)
}
table.insert(EVENT, new(holidayEssentials24, {
	simple,
	simple2,
	simple3,
	complex(v)
}, {
	templates4.saleIsActive("HolidayEssentials24", Economy.excludeFilters({ "Redeem" })),
	templates4.Item.maxPurchases(holidayEssentials24, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(holidayEssentials24, 1, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(holidayEssentials24, "Bundle", nil), {}, { "HolidayEssentials24" }))
local winterCombo24 = IdMap.Redeemable.WinterCombo24
local new2 = templates.Simple.new
local simple4 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Yeti-Yeti"], true))
local simple5 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Gas-Gas"], true))
local simple6 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["10K Fragments"], true))
local complex2 = templates2.Tiered.complex
local v2 = {
	[NumberRange.new(0, 699)] = templates3.economyItem(IdMap.Redeemable["300K Money"], true),
	[NumberRange.new(700, 1499)] = templates3.economyItem(IdMap.Redeemable["900K Money"], true),
	[NumberRange.new(1500, 15000000000)] = templates3.economyItem(IdMap.Redeemable["1.8M Money"], true)
}
table.insert(EVENT, new2(winterCombo24, {
	simple4,
	simple5,
	simple6,
	complex2(v2)
}, {
	templates4.saleIsActive("WinterCombo24", Economy.excludeFilters({ "Redeem" })),
	templates4.Item.maxPurchases(winterCombo24, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(winterCombo24, 1, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(winterCombo24, "Bundle", nil), {}, { "WinterCombo24" }))
local ULTIMATEBUNDLE24 = IdMap.Redeemable.ULTIMATEBUNDLE24
local new3 = templates.Simple.new
local simple7 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Dragon-Dragon"], true))
local simple8 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Buddha-Buddha"], true))
local simple9 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Yeti-Yeti"], true))
local simple10 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Gas-Gas"], true))
local simple11 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["10K Fragments"], true))
local complex3 = templates2.Tiered.complex
local v3 = {
	[NumberRange.new(0, 699)] = templates3.economyItem(IdMap.Redeemable["300K Money"], true),
	[NumberRange.new(700, 1499)] = templates3.economyItem(IdMap.Redeemable["900K Money"], true),
	[NumberRange.new(1500, 15000000000)] = templates3.economyItem(IdMap.Redeemable["1.8M Money"], true)
}
table.insert(EVENT, new3(ULTIMATEBUNDLE24, {
	simple7,
	simple8,
	simple9,
	simple10,
	simple11,
	complex3(v3)
}, {
	templates4.saleIsActive("ULTIMATEBUNDLE24", Economy.excludeFilters({ "Redeem" })),
	templates4.Item.maxPurchases(ULTIMATEBUNDLE24, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(ULTIMATEBUNDLE24, 1, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(ULTIMATEBUNDLE24, "Bundle", nil), {}, { "ULTIMATEBUNDLE24" }))
local halloween2025Bundle = IdMap.Redeemable["Halloween 2025 Bundle"]
table.insert(EVENT, templates.Simple.new(halloween2025Bundle, {
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Tiger-Tiger"], true)),
	templates2.Simple.new(templates3.Item.mutatedFruit(IdMap.PhysicalMoveset["Werewolf (Tiger)-Werewolf (Tiger)"], 1)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["4.5K Fragments"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["810K Money"], true))
}, {
	templates4.saleIsActive("HalloweenBundle2025", Economy.excludeFilters({ "Redeem" })),
	templates4.Item.maxPurchases(halloween2025Bundle, 4, { "Purchase" }),
	templates4.Item.maxGiftsSent(halloween2025Bundle, 5, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(halloween2025Bundle, "Bundle", nil), {}, { "HalloweenBundle2025" }))
local foxSpiritBundle = IdMap.Redeemable["Fox Spirit Bundle"]
table.insert(EVENT, templates.Simple.new(foxSpiritBundle, {
	templates2.Simple.new(templates3.Item.mutatedFruit(
		IdMap.PhysicalMoveset["Empyrean (Kitsune)-Empyrean (Kitsune)"],
		1
	)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Kitsune-Kitsune"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["2.1K Fragments"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["1.5M Money"], true))
}, {
	templates4.saleIsActive("FoxSpiritBundle2025", Economy.excludeFilters({ "Redeem" })),
	templates4.Item.maxPurchases(foxSpiritBundle, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(foxSpiritBundle, 5, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(foxSpiritBundle, "Bundle", nil), {}, { "FoxSpiritBundle2025" }))
local ultimateBundle2025 = IdMap.Redeemable["Ultimate Bundle 2025"]
local new4 = templates.Simple.new
local simple12 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Control-Control"], true))
local simple13 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Dragon-Dragon"], true))
local simple14 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Tiger-Tiger"], true))
local complex4 = templates2.Tiered.complex
local v4 = {
	[NumberRange.new(0, 699)] = templates3.economyItem(IdMap.Redeemable["10K Money"], true),
	[NumberRange.new(700, 15000000000)] = templates3.economyItem(IdMap.Redeemable["10K Fragments"], true)
}
table.insert(EVENT, new4(ultimateBundle2025, {
	simple12,
	simple13,
	simple14,
	complex4(v4),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["900K Money"], true))
}, {
	templates4.saleIsActive("UltimateBundle2025", Economy.excludeFilters({ "Redeem" })),
	templates4.Item.maxPurchases(ultimateBundle2025, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(ultimateBundle2025, 5, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(ultimateBundle2025, "Bundle", nil), {}, { "UltimateBundle2025" }))
local holidayBundle2025 = IdMap.Redeemable["Holiday Bundle 2025"]
local new5 = templates.Simple.new
local simple15 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Portal-Portal"], true))
local simple16 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Buddha-Buddha"], true))
local complex5 = templates2.Tiered.complex
local v5 = {
	[NumberRange.new(0, 699)] = templates3.economyItem(IdMap.Redeemable["10K Money"], true),
	[NumberRange.new(700, 15000000000)] = templates3.economyItem(IdMap.Redeemable["10K Fragments"], true)
}
table.insert(EVENT, new5(holidayBundle2025, {
	simple15,
	simple16,
	complex5(v5),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["900K Money"], true))
}, {
	templates4.saleIsActive("HolidayBundle2025", Economy.excludeFilters({ "Redeem" })),
	templates4.Item.maxPurchases(holidayBundle2025, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(holidayBundle2025, 5, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(holidayBundle2025, "Bundle", nil), {}, { "HolidayBundle2025" }))
local bloodfrostBundle = IdMap.Redeemable["Bloodfrost Bundle"]
local new6 = templates.Simple.new
local simple17 = templates2.Simple.new(templates3.Item.mutatedFruit(
	IdMap.PhysicalMoveset["Fiend (Yeti)-Fiend (Yeti)"],
	1
))
local simple18 = templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Yeti-Yeti"], true))
local complex6 = templates2.Tiered.complex
local v6 = {
	[NumberRange.new(0, 699)] = templates3.economyItem(IdMap.Redeemable["10K Money"], true),
	[NumberRange.new(700, 15000000000)] = templates3.economyItem(IdMap.Redeemable["4.5K Fragments"], true)
}
table.insert(EVENT, new6(bloodfrostBundle, {
	simple17,
	simple18,
	complex6(v6),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["810K Money"], true))
}, {
	templates4.saleIsActive("Valentines2026Bundle"),
	templates4.Item.maxPurchases(bloodfrostBundle, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(bloodfrostBundle, 5, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(bloodfrostBundle, "Bundle", nil), {}, { "Valentines2026Bundle" }))
local easter2026Bundle = IdMap.Redeemable.Easter2026Bundle
table.insert(EVENT, Economy.Templates.Simple.new(easter2026Bundle, {
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Gas-Gas"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Permanent Lightning-Lightning"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["4.5K Fragments"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["810K Money"], true))
}, {
	templates4.saleIsActive("Easter2026"),
	templates4.Item.maxPurchases(easter2026Bundle, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(easter2026Bundle, 5, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(easter2026Bundle, "Bundle", nil), {}, { "Easter2026" }))
local gamepassBundle = IdMap.Redeemable.GamepassBundle
table.insert(EVENT, Economy.Templates.Simple.new(gamepassBundle, {
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["2x Boss Drops"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Fast Boats"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["2x Money"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["2x Mastery"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["Fruit Notifier"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["10K Fragments"], true)),
	templates2.Simple.new(templates3.economyItem(IdMap.Redeemable["1.8M Money"], true))
}, {
	templates4.saleIsActive("Easter2026"),
	templates4.Item.maxPurchases(gamepassBundle, 5, { "Purchase" }),
	templates4.Item.maxGiftsSent(gamepassBundle, 5, { "Gift" })
}, Economy.Modules.LegacyInfo.Templates.Simple.newRobuxItem(gamepassBundle, "Bundle", nil), {}, { "Easter2026" }))
table.freeze(EVENT)
return EVENT