local v = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Universe = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Universe"))
v.USE_TEST_PRODUCTS_OVERRIDE = nil
local RunService = game:GetService("RunService")

if RunService:IsStudio() or not Universe:IsProductionPlace() then
	if v.USE_TEST_PRODUCTS_OVERRIDE == nil then
		v.USE_TEST_PRODUCTS = Universe:IsTestRealm()
	else
		v.USE_TEST_PRODUCTS = v.USE_TEST_PRODUCTS_OVERRIDE
	end
else
	v.USE_TEST_PRODUCTS = false
end

local v2 = {
	ICHOR_300 = 3321186848,
	ICHOR_1500 = 3321187975,
	ICHOR_3150 = 3321188478,
	ICHOR_5500 = 3321188735,
	GAMEPASS_STICKERS = 3459610337,
	GAMEPASS_STARTIME = 3321190812,
	GAMEPASS_SHOWTIME = 3321191528,
	GAMEPASS_SPOOKYTIME = 3715570074,
	STARTER_BUNDLE = 3312541887,
	GAMEPASS_FINN_TOTW = 3603505221,
	GAMEPASS_TISHA_TOTW = 3611305993,
	GAMEPASS_BRUSHA_TOTW = 3707452222,
	GAMEPASS_GIGI_TOTW = 3713072372,
	GAMEPASS_BACKGROUND_PRINTS = 3711167207,
	GAMEPASS_SWIMMY_BARNABY = 3711167227,
	PUMPKINS_300 = 3417389608,
	PUMPKINS_1450 = 3417390037,
	PUMPKINS_2950 = 3417390631,
	PUMPKINS_5000 = 3417390875,
	PUMPKINS_GIFT_300 = 3714752140,
	PUMPKINS_GIFT_1450 = 3714752159,
	PUMPKINS_GIFT_2950 = 3714752178,
	PUMPKINS_GIFT_5000 = 3714752200,
	CALENDAR_MISSED_DAY = 3469750771
}
local v3 = {
	ICHOR_300 = 3605188181,
	ICHOR_1500 = 3605191824,
	ICHOR_3150 = 3605191872,
	ICHOR_5500 = 3605192220,
	GAMEPASS_STICKERS = 3539419655,
	GAMEPASS_STARTIME = 3539419488,
	GAMEPASS_SHOWTIME = 3539419471,
	GAMEPASS_SPOOKYTIME = 3715569721,
	STARTER_BUNDLE = 3599767364,
	GAMEPASS_FINN_TOTW = 3602677809,
	GAMEPASS_TISHA_TOTW = 3608601109,
	GAMEPASS_BRUSHA_TOTW = 3704442699,
	GAMEPASS_GIGI_TOTW = 3713072293,
	GAMEPASS_BACKGROUND_PRINTS = 3709847990,
	GAMEPASS_SWIMMY_BARNABY = 3710897675,
	PUMPKINS_300 = 3714541810,
	PUMPKINS_1450 = 3714541852,
	PUMPKINS_2950 = 3714541896,
	PUMPKINS_5000 = 3714541916,
	PUMPKINS_GIFT_300 = 3714750136,
	PUMPKINS_GIFT_1450 = 3714750157,
	PUMPKINS_GIFT_2950 = 3714750172,
	PUMPKINS_GIFT_5000 = 3714750199,
	CALENDAR_MISSED_DAY = 3714541754
}
local v4 = {
	ExtraStickers = 1413417806,
	DreamSkins = 919044048,
	ShowtimeSkins = 1268911388,
	FinnTOTW = 1866124252,
	TishaTOTW = 1924518887,
	BrushaTOTW = 1940948185,
	GigiTOTW = 1981580501,
	SpookytimeSkins = 2001134601,
	BackgroundPrints = 1969748285,
	SwimmyBarnaby = 1962656424
}
local v5 = {
	ExtraStickers = 1848053255,
	DreamSkins = 1847951310,
	ShowtimeSkins = 1847033285,
	FinnTOTW = 1867800915,
	TishaTOTW = 1903062523,
	BrushaTOTW = 1941541931,
	GigiTOTW = 1982852464,
	BackgroundPrints = 1955653695,
	SwimmyBarnaby = 1967580472,
	SpookytimeSkins = 1998603787
}

function v.GetProducts()
	return v.USE_TEST_PRODUCTS and v3 or v2
end

function v.GetGamePasses()
	if v.USE_TEST_PRODUCTS then
		return v5
	end

	return v4
end

function v.GetGamePassId(p)
	return v.GetGamePasses()[p]
end

function v.GetProductId(p)
	return v.GetProducts()[p]
end

local v6 = {
	BackgroundPrints = "GAMEPASS_BACKGROUND_PRINTS",
	SwimmyBarnaby = "GAMEPASS_SWIMMY_BARNABY"
}

function v.GetGiftProductKey(p)
	return v6[p]
end

function v.IsPassPairConfigured(p)
	local v7 = v6[p]
	return not not v7 and v.GetGamePassId(p) ~= nil and v.GetProductId(v7) ~= nil
end

function v.IsKnownGamePassKey(p)
	return v4[p] ~= nil or v5[p] ~= nil
end

v.SEASONAL_GIFT_TIERS = {
	{
		key = "PUMPKINS_GIFT_300",
		amount = 300
	},
	{
		key = "PUMPKINS_GIFT_1450",
		amount = 1450
	},
	{
		key = "PUMPKINS_GIFT_2950",
		amount = 2950
	},
	{
		key = "PUMPKINS_GIFT_5000",
		amount = 5000
	}
}

function v.GetSeasonalGiftTiers()
	local result = {}

	for _, v7 in ipairs(v.SEASONAL_GIFT_TIERS) do
		local productId = v.GetProductId(v7.key)

		if type(productId) == "number" and productId > 0 then
			table.insert(result, {
				key = v7.key,
				amount = v7.amount,
				productId = productId
			})
		end
	end

	return result
end

local v7 = {
	TishaTOTW = "Swift Service",
	GAMEPASS_TISHA_TOTW = "Swift Service (Gift)",
	BrushaTOTW = "Messy Canvas",
	GAMEPASS_BRUSHA_TOTW = "Messy Canvas (Gift)",
	GigiTOTW = "Cute Collector",
	GAMEPASS_GIGI_TOTW = "Cute Collector (Gift)"
}

for k, v8 in pairs(v6) do
	if v4[k] == nil ~= (v2[v8] == nil) then
		warn(string.format(
			"[DevProductConfig] Pass %s: only one of its two production ids is filled in - fill the pair together",
			k
		))
	end
end

function v.GetTestDisplayName(p)
	if not v.USE_TEST_PRODUCTS then
		return nil
	end

	local v8 = tonumber(p)

	if not v8 then
		return nil
	end

	for k, v9 in pairs(v3) do
		if v9 == v8 then
			return v7[k]
		end
	end

	for k, v9 in pairs(v5) do
		if v9 == v8 then
			return v7[k]
		end
	end

	return nil
end

function v.GetProductConfig()
	local products = v.GetProducts()
	local gamePasses = v.GetGamePasses()
	local result = {
		[products.ICHOR_300] = {
			itemType = "Coin",
			itemAmount = 300,
			key = "ICHOR_300"
		},
		[products.ICHOR_1500] = {
			itemType = "Coin",
			itemAmount = 1500,
			key = "ICHOR_1500"
		},
		[products.ICHOR_3150] = {
			itemType = "Coin",
			itemAmount = 3150,
			key = "ICHOR_3150"
		},
		[products.ICHOR_5500] = {
			itemType = "Coin",
			itemAmount = 5500,
			key = "ICHOR_5500"
		},
		[products.GAMEPASS_STICKERS] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.ExtraStickers,
			passName = "3x Sticker Wheels",
			key = "GAMEPASS_STICKERS"
		},
		[products.GAMEPASS_STARTIME] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.DreamSkins,
			passName = "Startime Skins",
			key = "GAMEPASS_STARTIME"
		},
		[products.GAMEPASS_SHOWTIME] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.ShowtimeSkins,
			passName = "Showtime Skins",
			key = "GAMEPASS_SHOWTIME"
		},
		[products.GAMEPASS_SPOOKYTIME] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.SpookytimeSkins,
			passName = "Spooky-Time Skins",
			key = "GAMEPASS_SPOOKYTIME"
		},
		[products.STARTER_BUNDLE] = {
			itemType = "Bundle",
			key = "STARTER_BUNDLE"
		},
		[products.GAMEPASS_FINN_TOTW] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.FinnTOTW,
			passName = "Reef Explorer Finn",
			key = "GAMEPASS_FINN_TOTW"
		},
		[products.GAMEPASS_TISHA_TOTW] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.TishaTOTW,
			passName = "Swift Service",
			key = "GAMEPASS_TISHA_TOTW"
		},
		[products.GAMEPASS_BRUSHA_TOTW] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.BrushaTOTW,
			passName = "Messy Canvas",
			key = "GAMEPASS_BRUSHA_TOTW"
		},
		[products.GAMEPASS_GIGI_TOTW] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.GigiTOTW,
			passName = "Cute Collector Gigi",
			key = "GAMEPASS_GIGI_TOTW"
		}
	}

	if v.IsPassPairConfigured("BackgroundPrints") then
		result[products.GAMEPASS_BACKGROUND_PRINTS] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.BackgroundPrints,
			passName = "Rainbow Bundle",
			key = "GAMEPASS_BACKGROUND_PRINTS"
		}
	end

	if v.IsPassPairConfigured("SwimmyBarnaby") then
		result[products.GAMEPASS_SWIMMY_BARNABY] = {
			itemType = "GamePassVoucher",
			passId = gamePasses.SwimmyBarnaby,
			passName = "Swimmy Barnaby Bundle",
			key = "GAMEPASS_SWIMMY_BARNABY"
		}
	end

	for _, v8 in ipairs(v.GetSeasonalGiftTiers()) do
		result[v8.productId] = {
			itemType = "SeasonalCurrency",
			itemAmount = v8.amount,
			key = v8.key
		}
	end

	return result
end

local v8 = {
	{
		key = "ICHOR_300",
		amount = 300,
		live = 1840245611,
		qa = 3709144165
	},
	{
		key = "ICHOR_1500",
		amount = 1500,
		live = 1840247062,
		qa = 3709144187
	},
	{
		key = "ICHOR_3150",
		amount = 3150,
		live = 1840247574,
		qa = 3709144204
	},
	{
		key = "ICHOR_5500",
		amount = 5500,
		live = 1840247865,
		qa = 3709144219
	}
}
local amountsByLive = {}

for _, v9 in ipairs(v8) do
	amountsByLive[v9.live] = v9.amount
end

v.ICHOR_KEYS = {
	"ICHOR_300",
	"ICHOR_1500",
	"ICHOR_3150",
	"ICHOR_5500"
}

function v.GetLegacyIchorAmounts()
	local result = {}

	for k, v9 in pairs(amountsByLive) do
		result[k] = v9
	end

	return result
end

function v.GetIchorAmounts()
	local productConfig = v.GetProductConfig()
	local v9 = {}
	local result = {}

	for _, v10 in ipairs(v.ICHOR_KEYS) do
		local productId = v.GetProductId(v10)

		if type(productId) ~= "number" or productId <= 0 or productId % 1 ~= 0 then
			return nil, v10 .. " did not resolve to a positive integer ProductId (got " .. tostring(productId) .. ")"
		end

		local v11 = productConfig[productId]

		if not v11 then
			return nil, "no GetProductConfig entry for " .. v10 .. " (ProductId " .. tostring(productId) .. ")"
		end

		if v11.itemType ~= "Coin" then
			return
				nil,
				v10 .. " (ProductId " .. tostring(productId) .. ") itemType is " .. tostring(v11.itemType) .. ", expected \"Coin\""
		end

		if type(v11.itemAmount) ~= "number" or v11.itemAmount <= 0 or v11.itemAmount % 1 ~= 0 then
			return nil, v10 .. " (ProductId " .. tostring(productId) .. ") itemAmount is not a positive integer"
		end

		local v12 = v9[productId]

		if v12 then
			return nil, v12 .. " and " .. v10 .. " both resolve to ProductId " .. tostring(productId)
		end

		v9[productId] = v10
		result[productId] = v11.itemAmount
	end

	for k, v10 in pairs(amountsByLive) do
		local v11 = result[k]

		if v11 ~= nil and v11 ~= v10 then
			return
				nil,
				v9[k] .. " and legacy ProductId " .. tostring(k) .. " share a ProductId but disagree on amount (" .. tostring(v11) .. " vs " .. tostring(v10) .. ")"
		end

		result[k] = v10
	end

	return result
end

function v.GetSelfPurchaseIchorTiers()
	local isTestRealm = Universe:IsTestRealm()
	local result = {}

	for i, v9 in ipairs(v8) do
		result[i] = {
			key = v9.key,
			amount = v9.amount,
			productId = isTestRealm and v9.qa or v9.live
		}
	end

	return result
end

function v.GetSelfPurchaseProductId(p)
	for _, v9 in ipairs(v.GetSelfPurchaseIchorTiers()) do
		if v9.key == p then
			return v9.productId
		end
	end

	return nil
end

function v.GetSelfPurchaseIchorAmounts()
	local amountsByProductId = {}

	for _, v9 in ipairs(v.GetSelfPurchaseIchorTiers()) do
		amountsByProductId[v9.productId] = v9.amount
	end

	return amountsByProductId
end

function v.GetGamePassMappings()
	local products = v.GetProducts()
	local gamePasses = v.GetGamePasses()
	local v9 = {
		[products.GAMEPASS_STICKERS] = {
			passId = gamePasses.ExtraStickers,
			name = "Extra Sticker Slots",
			description = "Unlock 12 additional sticker slots!"
		},
		[products.GAMEPASS_STARTIME] = {
			passId = gamePasses.DreamSkins,
			name = "Startime Skins Pack",
			description = "Get Startime skins for Astro, Pebble, Shelly, Sprout, and Vee!"
		},
		[products.GAMEPASS_SHOWTIME] = {
			passId = gamePasses.ShowtimeSkins,
			name = "Showtime Skins Pack",
			description = "Get Showtime skins for Blot, Looey, Vee, Yatta, and Razzle & Dazzle!"
		},
		[products.GAMEPASS_FINN_TOTW] = {
			passId = gamePasses.FinnTOTW,
			name = "Reef Explorer Finn",
			description = "Gift the Reef Explorer Finn Toon of the Week skin!"
		},
		[products.GAMEPASS_TISHA_TOTW] = {
			passId = gamePasses.TishaTOTW,
			name = "Swift Service",
			description = "Gift the Swift Service Toon of the Week skin!"
		},
		[products.GAMEPASS_BRUSHA_TOTW] = {
			passId = gamePasses.BrushaTOTW,
			name = "Messy Canvas",
			description = "Gift the Messy Canvas Toon of the Week skin!"
		},
		[products.GAMEPASS_GIGI_TOTW] = {
			passId = gamePasses.GigiTOTW,
			name = "Cute Collector Gigi",
			description = "Gift the Cute Collector Gigi Toon of the Week skin!"
		},
		[products.GAMEPASS_SPOOKYTIME] = {
			passId = gamePasses.SpookytimeSkins,
			name = "Spooky-Time Skins Pack",
			description = "Get Spooky-Time skins for Ribecca, Soulvester, Eclipse, Gourdy, and Connie!"
		}
	}

	if v.IsPassPairConfigured("SwimmyBarnaby") then
		v9[products.GAMEPASS_SWIMMY_BARNABY] = {
			passId = gamePasses.SwimmyBarnaby,
			name = "Swimmy Barnaby Bundle",
			description = "A Swimmy Barnaby print, frame and backdrop for your profile."
		}
	end

	if v.IsPassPairConfigured("BackgroundPrints") then
		v9[products.GAMEPASS_BACKGROUND_PRINTS] = {
			passId = gamePasses.BackgroundPrints,
			name = "Rainbow Bundle",
			description = "PLACEHOLDER NOTE 3"
		}
	end

	return v9
end

v.FORCE_NOT_OWNED_TESTERS = {}

function v.IsForcedNotOwned(p)
	if v.USE_TEST_PRODUCTS then
		return v.FORCE_NOT_OWNED_TESTERS[p] == true
	end

	return false
end

if v.USE_TEST_PRODUCTS then
	print("[DevProductConfig] 🧪 TEST MODE - Using cheaper test products")
	local products = v.GetProducts()
	local gamePasses = v.GetGamePasses()
	print(string.format(
		"[DevProductConfig] 🧪 TEST IDS — StarterBundle=%d, FinnGift=%d | GAMEPASSES Stickers=%d, Startime=%d, Showtime=%d, Finn=%d",
		products.STARTER_BUNDLE,
		products.GAMEPASS_FINN_TOTW,
		gamePasses.ExtraStickers,
		gamePasses.DreamSkins,
		gamePasses.ShowtimeSkins,
		gamePasses.FinnTOTW
	))
	return v
else
	print("[DevProductConfig] 🚀 PRODUCTION MODE - Using production products")
	local products = v.GetProducts()
	local gamePasses = v.GetGamePasses()
	print(string.format(
		"[DevProductConfig] 🚀 PROD IDS — StarterBundle=%d, FinnGift=%d | GAMEPASSES Stickers=%d, Startime=%d, Showtime=%d, Finn=%d",
		products.STARTER_BUNDLE,
		products.GAMEPASS_FINN_TOTW,
		gamePasses.ExtraStickers,
		gamePasses.DreamSkins,
		gamePasses.ShowtimeSkins,
		gamePasses.FinnTOTW
	))
	return v
end