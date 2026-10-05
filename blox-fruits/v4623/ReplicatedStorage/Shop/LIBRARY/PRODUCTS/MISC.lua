require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local IdMap = require(game.ReplicatedStorage.IdMap)
require(game.ReplicatedStorage.SaleService)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string, p2: string, p3, options, _: boolean?, flag: boolean?, p4, flag2: boolean?, flag3: boolean?)
	local unwrapped = ItemId.getId(p, "Redeemable"):unwrap()
	local v = {}

	if flag == true then
		table.insert(v, "NoStore")
	end

	if flag3 then
		table.insert(v, "StoreOnGiftClaim")
	end

	if p == "Dragon Token (Tradable)" then
		table.insert(v, "StoreAsEtcItem")
	end

	if flag2 then
		table.insert(v, "CanTradeDuplicates")
	end

	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(p3) },
		options or {},
		templates4.Simple.newRobuxItem(unwrapped, p2, false),
		v,
		p4
	)
end

local MISC = {}

for k, v in pairs({
	["Physical Rocket Fruit"] = {
		subtype = "PhysicalRocketFruit",
		settlement = templates3.Item.physicalMoveset("Rocket-Rocket")
	},
	["Discounted Permanent Dragon"] = {
		subtype = "Fruit",
		settlement = templates3.Special.discountedPermanentDragon(),
		nostore = true,
		qualifications = { templates5.Special.noPermanentDragonDiscount("Recipient", { "Redeem", "Purchase" }) },
		doNotFeature = true
	},
	["Dragon Token (Tradable)"] = {
		subtype = "NamedProduct",
		settlement = templates3.Special.tradableDragonToken(),
		qualifications = { templates5.Item.notAlreadyRedeemed(IdMap.Moveset["Dragon-Dragon"], { "Redeem", "Trade" }) },
		doNotFeature = true
	},
	["Respawn Bosses"] = {
		subtype = "NamedProduct",
		settlement = templates3.Special.respawnBosses()
	},
	["Refund Points"] = {
		subtype = "NamedProduct",
		settlement = templates3.Special.refundPoints()
	},
	["Change Race"] = {
		subtype = "NamedProduct",
		settlement = templates3.Special.changeRace()
	},
	["+1 Fruit Storage"] = {
		subtype = "NamedProduct",
		settlement = templates3.Special.plus1FruitStorage(),
		storeOnGiftClaim = true,
		allowTradeDupes = true
	},
	["x1 Premium Holiday 2025 Box"] = {
		subtype = "NamedProduct",
		nostore = true,
		settlement = templates3.Item.box("x1 Premium Holiday 2025 Box"),
		qualifications = { templates5.saleIsActive("HolidayBundle2025", { "Purchase" }) },
		saleKey = "HolidayBundle2025"
	},
	["x3 Premium Holiday 2025 Box"] = {
		subtype = "NamedProduct",
		nostore = true,
		settlement = templates3.Item.box("x3 Premium Holiday 2025 Box"),
		qualifications = { templates5.saleIsActive("HolidayBundle2025", { "Purchase" }) },
		saleKey = "HolidayBundle2025"
	},
	["x10 Premium Holiday 2025 Box"] = {
		subtype = "NamedProduct",
		nostore = true,
		settlement = templates3.Item.box("x10 Premium Holiday 2025 Box"),
		qualifications = { templates5.saleIsActive("HolidayBundle2025", { "Purchase" }) },
		saleKey = "HolidayBundle2025"
	},
	["x1 Chromatic Magnet 2026 Box"] = {
		subtype = "NamedProduct",
		nostore = true,
		settlement = templates3.Item.box("x1 Chromatic Magnet 2026 Box"),
		qualifications = { templates5.saleIsActive("MagnetChromaticGacha2026", { "Purchase" }) }
	},
	["x3 Chromatic Magnet 2026 Box"] = {
		subtype = "NamedProduct",
		nostore = true,
		settlement = templates3.Item.box("x3 Chromatic Magnet 2026 Box"),
		qualifications = { templates5.saleIsActive("MagnetChromaticGacha2026", { "Purchase" }) }
	},
	["x10 Chromatic Magnet 2026 Box"] = {
		subtype = "NamedProduct",
		nostore = true,
		settlement = templates3.Item.box("x10 Chromatic Magnet 2026 Box"),
		qualifications = { templates5.saleIsActive("MagnetChromaticGacha2026", { "Purchase" }) }
	},
	["x50 Chromatic Magnet 2026 Box"] = {
		subtype = "NamedProduct",
		nostore = true,
		settlement = templates3.Item.box("x50 Chromatic Magnet 2026 Box"),
		qualifications = {
			templates5.saleIsActive("MagnetChromaticGacha2026", { "Purchase" }),
			templates5.minRobuxSpent(3000, { "Purchase" })
		}
	}
}) do
	table.insert(
		MISC,
		newEconomyItem(
			k,
			v.subtype,
			v.settlement,
			v.qualifications,
			v.doNotFeature,
			v.nostore,
			v.saleKey and { v.saleKey } or nil,
			v.allowTradeDupes,
			v.storeOnGiftClaim
		)
	)
end

table.freeze(MISC)
return MISC