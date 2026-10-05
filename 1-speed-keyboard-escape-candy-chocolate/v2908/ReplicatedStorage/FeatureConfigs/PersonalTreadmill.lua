local PersonalTreadmill = {
	TIER_MULT = {
		Normal = 1,
		Gold = 3,
		Diamond = 9,
		Candy = 25,
		Admin = 100
	},
	TIER_ORDER = {
		"Admin",
		"Candy",
		"Diamond",
		"Gold"
	},
	TIER_ENTITLEMENTS = {
		Gold = {
			skinKey = "GoldTreadmill",
			manualAccessKey = "ManualGoldAccess"
		},
		Diamond = {
			skinKey = "DiamondTreadmill",
			manualAccessKey = "ManualDiamondAccess"
		},
		Candy = {
			skinKey = "CandyTreadmill",
			manualAccessKey = "ManualCandyAccess"
		},
		Admin = {
			skinKey = "AdminTreadmill",
			manualAccessKey = "ManualAdminAccess"
		}
	},
	TIER_ENTITLEMENT_BY_SKIN = {}
}

for k, v in pairs(PersonalTreadmill.TIER_ENTITLEMENTS) do
	PersonalTreadmill.TIER_ENTITLEMENT_BY_SKIN[v.skinKey] = {
		tier = k,
		skinKey = v.skinKey,
		manualAccessKey = v.manualAccessKey
	}
end

PersonalTreadmill.WORKSPACE_FOLDER = "PersonalTreadmills"
PersonalTreadmill.DESPAWN_RADIUS = 6
PersonalTreadmill.STEP_DISTANCE = 5
PersonalTreadmill.OVERLAP_PROBE_SIZE = vector.create(4, 12, 4)
PersonalTreadmill.MONITOR_INTERVAL = 0.2
PersonalTreadmill.DEFAULT_SKIN = "DefaultTreadmill"
return PersonalTreadmill