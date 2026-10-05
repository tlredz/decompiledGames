local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local DevProducts = {
	All = TableUtil.Lock({
		HALLOWEEN_2025_HAUNTED_HOUSE = {
			__DEV_PRODUCT = true
		},
		CHRISTMAS_2025_BUNDLE = {
			__DEV_PRODUCT = true
		},
		PREMIUM_1 = {
			__DEV_PRODUCT = true
		},
		PREMIUM_2 = {
			__DEV_PRODUCT = true
		},
		PREMIUM_3 = {
			__DEV_PRODUCT = true
		},
		PREMIUM_4 = {
			__DEV_PRODUCT = true
		},
		EASTER_2026_SPRING_HOUSE = {
			__DEV_PRODUCT = true
		},
		HOUSE_SAVE_SLOT_1 = {
			__DEV_PRODUCT = true
		},
		HOUSE_SAVE_SLOT_2 = {
			__DEV_PRODUCT = true
		},
		HOUSE_SAVE_SLOT_3 = {
			__DEV_PRODUCT = true
		},
		SUMMER_2026_HOUSE = {
			__DEV_PRODUCT = true
		},
		SUMMER_2026_PREMIUM_BUNDLE = {
			__DEV_PRODUCT = true
		},
		MILITARY_ROLEPLAY_BUNDLE = {
			__DEV_PRODUCT = true
		}
	})
}
DevProducts.HALLOWEEN_2025_HAUNTED_HOUSE = DevProducts.All.HALLOWEEN_2025_HAUNTED_HOUSE
DevProducts.CHRISTMAS_2025_BUNDLE = DevProducts.All.CHRISTMAS_2025_BUNDLE
DevProducts.PREMIUM_1 = DevProducts.All.PREMIUM_1
DevProducts.PREMIUM_2 = DevProducts.All.PREMIUM_2
DevProducts.PREMIUM_3 = DevProducts.All.PREMIUM_3
DevProducts.PREMIUM_4 = DevProducts.All.PREMIUM_4
DevProducts.EASTER_2026_SPRING_HOUSE = DevProducts.All.EASTER_2026_SPRING_HOUSE
DevProducts.HOUSE_SAVE_SLOT_1 = DevProducts.All.HOUSE_SAVE_SLOT_1
DevProducts.HOUSE_SAVE_SLOT_2 = DevProducts.All.HOUSE_SAVE_SLOT_2
DevProducts.HOUSE_SAVE_SLOT_3 = DevProducts.All.HOUSE_SAVE_SLOT_3
DevProducts.SUMMER_2026_PREMIUM_BUNDLE = DevProducts.All.SUMMER_2026_PREMIUM_BUNDLE
DevProducts.SUMMER_2026_HOUSE = DevProducts.All.SUMMER_2026_HOUSE
DevProducts.MILITARY_ROLEPLAY_BUNDLE = DevProducts.All.MILITARY_ROLEPLAY_BUNDLE
DevProducts.HOUSE_SAVE_SLOTS = {
	DevProducts.HOUSE_SAVE_SLOT_1,
	DevProducts.HOUSE_SAVE_SLOT_2,
	DevProducts.HOUSE_SAVE_SLOT_3
}
local v = {
	[DevProducts.All.HALLOWEEN_2025_HAUNTED_HOUSE] = {
		id = 3430920748,
		giftId = 3431489037,
		displayName = "Midnight Manor",
		isPurchasable = false
	},
	[DevProducts.All.CHRISTMAS_2025_BUNDLE] = {
		id = 3469809114,
		giftId = 3469819178,
		isPurchasable = false
	},
	[DevProducts.All.EASTER_2026_SPRING_HOUSE] = {
		id = 3557854012,
		giftId = 3557854176,
		isPurchasable = true
	},
	[DevProducts.All.PREMIUM_1] = {
		id = 3560028231,
		giftId = 3564630198,
		displayName = "Premium",
		isPurchasable = true
	},
	[DevProducts.All.PREMIUM_2] = {
		id = 3560014096,
		giftId = 3564630745,
		displayName = "Premium",
		isPurchasable = true
	},
	[DevProducts.All.PREMIUM_3] = {
		id = 3560014225,
		giftId = 3564630856,
		displayName = "Premium",
		isPurchasable = true
	},
	[DevProducts.All.PREMIUM_4] = {
		id = 3560013404,
		giftId = 3564627726,
		displayName = "Premium",
		isPurchasable = true
	},
	[DevProducts.All.HOUSE_SAVE_SLOT_1] = {
		id = 3588157056,
		giftId = 3588157056,
		isPurchasable = true
	},
	[DevProducts.All.HOUSE_SAVE_SLOT_2] = {
		id = 3591295571,
		giftId = 3591295571,
		isPurchasable = true
	},
	[DevProducts.All.HOUSE_SAVE_SLOT_3] = {
		id = 3591295656,
		giftId = 3591295656,
		isPurchasable = true
	},
	[DevProducts.All.SUMMER_2026_PREMIUM_BUNDLE] = {
		id = 3607830408,
		giftId = 3607830408,
		isPurchasable = true
	},
	[DevProducts.All.SUMMER_2026_HOUSE] = {
		id = 3607835878,
		giftId = 3607835916,
		isPurchasable = true
	},
	[DevProducts.All.MILITARY_ROLEPLAY_BUNDLE] = {
		id = 3713054065,
		giftId = 3713054093,
		isPurchasable = true
	}
}
local v2 = {}
local v3 = {}

for k, v4 in v do
	v2[v4.id] = k
	v3[v4.giftId] = k
end

local v4 = {}

for k, v5 in DevProducts.All do
	v4[v5] = k
end

function DevProducts.Exists(p: number)
	return v2[p] ~= nil
end

function DevProducts.GiftExists(p: number)
	return v3[p] ~= nil
end

function DevProducts.GetId(p)
	if p == nil then
		error("dev product is nil")
		return
	end

	if v[p] ~= nil then
		return v[p].id
	end

	error("In DevProducts.GetId: received unknown product")
end

function DevProducts.GetGiftId(p)
	if p == nil then
		error("dev product is nil")
		return
	end

	if v[p] ~= nil then
		return v[p].giftId
	end

	error("In DevProducts.GetGiftId: received unknown product")
end

function DevProducts.GetName(p)
	if p == nil then
		error("dev product is nil")
		return
	end

	if v4[p] ~= nil then
		return v4[p]
	end

	error("In DevProducts.GetName: received unknown product")
end

function DevProducts.GetDisplayName(p)
	if p == nil then
		error("dev product is nil")
		return
	end

	if v[p] ~= nil then
		return v[p].displayName
	end

	error("In DevProducts.GetDisplayName: received unknown product")
end

function DevProducts.IsPurchasable(p)
	if p == nil then
		error("dev product is nil")
		return
	end

	if v[p] ~= nil then
		return v[p].isPurchasable
	end

	error("In DevProducts.GetDisplayName: received unknown product")
end

function DevProducts.GetById(p: number)
	if v2[p] ~= nil then
		return v2[p]
	end

	error("In DevProducts.GetById: received unknown product id")
end

function DevProducts.GetByGiftId(p: number)
	if v3[p] ~= nil then
		return v3[p]
	end

	error("In DevProducts.GetByGiftId: received unknown product id")
end

return DevProducts