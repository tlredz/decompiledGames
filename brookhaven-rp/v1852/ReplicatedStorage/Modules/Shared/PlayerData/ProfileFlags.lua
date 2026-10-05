local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local ProfileFlags = {
	All = TableUtil.Lock({
		FACES_UNLOCKED_COMPENSATION_03102026 = {
			__PROFILE_FLAG = true
		},
		ROBLOX_PLUS_POPUP_SHOWN = {
			__PROFILE_FLAG = true
		},
		NEW_HOUSE_SAVES = {
			__PROFILE_FLAG = true
		},
		VEHICLE_BOOST_UNLOCKED = {
			__PROFILE_FLAG = true
		},
		VEHICLE_BOOST_CUSTOMIZATION = {
			__PROFILE_FLAG = true
		},
		VEHICLE_BOOST_CUSTOMIZATION_COLOR = {
			__PROFILE_FLAG = true
		},
		NEW_2026_CARNIVAL_MENU = {
			__PROFILE_FLAG = true
		},
		POPUP_2026_CARNIVAL = {
			__PROFILE_FLAG = true
		},
		POPUP_2026_CARNIVAL_W2 = {
			__PROFILE_FLAG = true
		},
		PETS_KIDS_HUD_BUTTON = {
			__PROFILE_FLAG = true
		},
		PETS_TURTLE_BUNNY = {
			__PROFILE_FLAG = true
		}
	})
}
ProfileFlags.FACES_UNLOCKED_COMPENSATION_03102026 = ProfileFlags.All.FACES_UNLOCKED_COMPENSATION_03102026
ProfileFlags.ROBLOX_PLUS_POPUP_SHOWN = ProfileFlags.All.ROBLOX_PLUS_POPUP_SHOWN
ProfileFlags.NEW_HOUSE_SAVES = ProfileFlags.All.NEW_HOUSE_SAVES
ProfileFlags.VEHICLE_BOOST_UNLOCKED = ProfileFlags.All.VEHICLE_BOOST_UNLOCKED
ProfileFlags.VEHICLE_BOOST_CUSTOMIZATION = ProfileFlags.All.VEHICLE_BOOST_CUSTOMIZATION
ProfileFlags.VEHICLE_BOOST_CUSTOMIZATION_COLOR = ProfileFlags.All.VEHICLE_BOOST_CUSTOMIZATION_COLOR
ProfileFlags.NEW_2026_CARNIVAL_MENU = ProfileFlags.All.NEW_2026_CARNIVAL_MENU
ProfileFlags.POPUP_2026_CARNIVAL = ProfileFlags.All.POPUP_2026_CARNIVAL
ProfileFlags.POPUP_2026_CARNIVAL_W2 = ProfileFlags.All.POPUP_2026_CARNIVAL_W2
ProfileFlags.PETS_KIDS_HUD_BUTTON = ProfileFlags.All.PETS_KIDS_HUD_BUTTON
ProfileFlags.PETS_TURTLE_BUNNY = ProfileFlags.All.PETS_TURTLE_BUNNY
local v = {
	[ProfileFlags.All.FACES_UNLOCKED_COMPENSATION_03102026] = {
		key = "facesUnlockedCompensation03102026",
		clientClaimable = true
	},
	[ProfileFlags.All.ROBLOX_PLUS_POPUP_SHOWN] = {
		key = "robloxPlusPopupShown",
		clientClaimable = true
	},
	[ProfileFlags.All.NEW_HOUSE_SAVES] = {
		key = "newHouseSaves",
		clientClaimable = true
	},
	[ProfileFlags.All.VEHICLE_BOOST_UNLOCKED] = {
		key = "newVehicleBoost",
		clientClaimable = true
	},
	[ProfileFlags.All.VEHICLE_BOOST_CUSTOMIZATION] = {
		key = "vehicleBoostCustomization",
		clientClaimable = true
	},
	[ProfileFlags.All.VEHICLE_BOOST_CUSTOMIZATION_COLOR] = {
		key = "vehicleBoostCustomizationColor",
		clientClaimable = true
	},
	[ProfileFlags.All.NEW_2026_CARNIVAL_MENU] = {
		key = "new2026CarnivalMenu",
		clientClaimable = true
	},
	[ProfileFlags.All.POPUP_2026_CARNIVAL] = {
		key = "popup2026Carnival",
		clientClaimable = true
	},
	[ProfileFlags.All.POPUP_2026_CARNIVAL_W2] = {
		key = "popup2026CarnivalW2",
		clientClaimable = true
	},
	[ProfileFlags.All.PETS_KIDS_HUD_BUTTON] = {
		key = "petsKidsHudButton",
		clientClaimable = true
	},
	[ProfileFlags.All.PETS_TURTLE_BUNNY] = {
		key = "petsTurtleBunny",
		clientClaimable = true
	}
}
local v2 = {}

for _, v3 in ProfileFlags.All do
	v2[v[v3].key] = v3
end

function ProfileFlags.GetByKey(p: string)
	return v2[p]
end

function ProfileFlags.Exists(p: string)
	return ProfileFlags.GetByKey(p) ~= nil
end

function ProfileFlags.GetKey(p)
	if v[p] == nil then
		error("In ProfileFlags.GetKey: received unknown flag")
	end

	return v[p].key
end

function ProfileFlags.IsClientClaimable(p)
	if v[p] == nil then
		error("In ProfileFlags.IsClientClaimable: received unknown flag")
	end

	return v[p].clientClaimable or false
end

return ProfileFlags