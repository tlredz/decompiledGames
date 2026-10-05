local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Gamepasses = {
	All = TableUtil.Lock({
		VIP = {
			__GAMEPASS = true
		},
		BOAT_PACK = {
			__GAMEPASS = true
		},
		ESTATES_UNLOCKED = {
			__GAMEPASS = true
		},
		DISASTER_PASS = {
			__GAMEPASS = true
		},
		THEME_PASS = {
			__GAMEPASS = true
		},
		PENTHOUSE = {
			__GAMEPASS = true
		},
		VEHICLE_PACK = {
			__GAMEPASS = true
		},
		FACES_UNLOCKED = {
			__GAMEPASS = true
		},
		LAND_UNLOCKED = {
			__GAMEPASS = true
		},
		HORSE_UNLOCKED = {
			__GAMEPASS = true
		},
		ON_DEMAND_FIRE = {
			__GAMEPASS = true
		},
		MUSIC_UNLOCKED = {
			__GAMEPASS = true
		},
		PREMIUM = {
			__GAMEPASS = true
		},
		PRISON_LANDMARK = {
			__GAMEPASS = true
		},
		VEHICLE_SPEED_UNLOCKED = {
			__GAMEPASS = true
		},
		VEHICLE_UPGRADE = {
			__GAMEPASS = true
		},
		HOUSE_AND_MOTORCYCLE = {
			__GAMEPASS = true
		},
		VEHICLE_CUSTOMIZATION = {
			__GAMEPASS = true
		},
		VEHICLE_BOOST = {
			__GAMEPASS = true
		},
		HOUSE_PETS = {
			__GAMEPASS = true
		}
	})
}
Gamepasses.VIP = Gamepasses.All.VIP
Gamepasses.BOAT_PACK = Gamepasses.All.BOAT_PACK
Gamepasses.ESTATES_UNLOCKED = Gamepasses.All.ESTATES_UNLOCKED
Gamepasses.DISASTER_PASS = Gamepasses.All.DISASTER_PASS
Gamepasses.THEME_PASS = Gamepasses.All.THEME_PASS
Gamepasses.PENTHOUSE = Gamepasses.All.PENTHOUSE
Gamepasses.VEHICLE_PACK = Gamepasses.All.VEHICLE_PACK
Gamepasses.FACES_UNLOCKED = Gamepasses.All.FACES_UNLOCKED
Gamepasses.LAND_UNLOCKED = Gamepasses.All.LAND_UNLOCKED
Gamepasses.HORSE_UNLOCKED = Gamepasses.All.HORSE_UNLOCKED
Gamepasses.ON_DEMAND_FIRE = Gamepasses.All.ON_DEMAND_FIRE
Gamepasses.MUSIC_UNLOCKED = Gamepasses.All.MUSIC_UNLOCKED
Gamepasses.PREMIUM = Gamepasses.All.PREMIUM
Gamepasses.PRISON_LANDMARK = Gamepasses.All.PRISON_LANDMARK
Gamepasses.VEHICLE_SPEED_UNLOCKED = Gamepasses.All.VEHICLE_SPEED_UNLOCKED
Gamepasses.VEHICLE_UPGRADE = Gamepasses.All.VEHICLE_UPGRADE
Gamepasses.HOUSE_AND_MOTORCYCLE = Gamepasses.All.HOUSE_AND_MOTORCYCLE
Gamepasses.VEHICLE_CUSTOMIZATION = Gamepasses.All.VEHICLE_CUSTOMIZATION
Gamepasses.VEHICLE_BOOST = Gamepasses.All.VEHICLE_BOOST
Gamepasses.HOUSE_PETS = Gamepasses.All.HOUSE_PETS
local v = {
	[Gamepasses.All.VIP] = {
		id = 850049439,
		giftId = 3244029616
	},
	[Gamepasses.All.BOAT_PACK] = {
		id = 667983868,
		giftId = 3244602862
	},
	[Gamepasses.All.ESTATES_UNLOCKED] = {
		id = 82773869,
		giftId = 3244603776
	},
	[Gamepasses.All.DISASTER_PASS] = {
		id = 48857519,
		giftId = 3244603036
	},
	[Gamepasses.All.THEME_PASS] = {
		id = 25341106,
		giftId = 3244601463
	},
	[Gamepasses.All.PENTHOUSE] = {
		id = 19660651,
		giftId = 3244602131
	},
	[Gamepasses.All.VEHICLE_PACK] = {
		id = 15927395,
		giftId = 3244601310
	},
	[Gamepasses.All.FACES_UNLOCKED] = {
		id = 13489552,
		giftId = 3244602743
	},
	[Gamepasses.All.LAND_UNLOCKED] = {
		id = 13405328,
		giftId = 3244601798
	},
	[Gamepasses.All.HORSE_UNLOCKED] = {
		id = 10991687,
		giftId = 3244602260
	},
	[Gamepasses.All.ON_DEMAND_FIRE] = {
		id = 10991517,
		giftId = 3244602585
	},
	[Gamepasses.All.MUSIC_UNLOCKED] = {
		id = 9066988,
		giftId = 3244602432
	},
	[Gamepasses.All.PREMIUM] = {
		id = 9066980,
		giftId = 3244601961
	},
	[Gamepasses.All.PRISON_LANDMARK] = {
		id = 1904016251,
		giftId = 3608642792
	},
	[Gamepasses.All.VEHICLE_SPEED_UNLOCKED] = {
		id = 9066970,
		giftId = 3244601646
	},
	[Gamepasses.All.VEHICLE_UPGRADE] = {
		id = 9066924,
		giftId = 3244603353
	},
	[Gamepasses.All.HOUSE_AND_MOTORCYCLE] = {
		id = 1221383640,
		giftId = 1221383640
	},
	[Gamepasses.All.VEHICLE_CUSTOMIZATION] = {
		id = 1459820822,
		giftId = 3316976317
	},
	[Gamepasses.All.VEHICLE_BOOST] = {
		id = 1899013193,
		giftId = 3607865703
	},
	[Gamepasses.All.HOUSE_PETS] = {
		id = 1924902263,
		giftId = 3611051257
	}
}
local v2 = {}
local v3 = {}

for k, v4 in v do
	v2[v4.id] = k
	v3[v4.giftId] = k
end

local v4 = {}

for k, v5 in Gamepasses.All do
	v4[v5] = k
end

function Gamepasses.Exists(p: number)
	return v2[p] ~= nil
end

function Gamepasses.GiftExists(p: number)
	return v3[p] ~= nil
end

function Gamepasses.GetId(p)
	if v[p] ~= nil then
		return v[p].id
	end

	error("In Gamepasses.GetId: received unknown gamepass")
end

function Gamepasses.GetGiftId(p)
	if v[p] ~= nil then
		return v[p].giftId
	end

	error("In Gamepasses.GetGiftId: received unknown gamepass")
end

function Gamepasses.GetName(p)
	if v4[p] ~= nil then
		return v4[p]
	end

	error("In Gamepasses.GetName: received unknown gamepass")
end

function Gamepasses.GetById(p: number)
	if v2[p] ~= nil then
		return v2[p]
	end

	error("In Gamepasses.GetById: received unknown gamepass id")
end

function Gamepasses.GetByGiftId(p: number)
	if v3[p] ~= nil then
		return v3[p]
	end

	error("In Gamepasses.GetByGiftId: received unknown product id")
end

return Gamepasses