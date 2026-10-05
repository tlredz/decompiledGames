local TREADMILLS = {
	{
		tag = "DiamondTreadmill",
		dataKey = "ManualDiamondAccess",
		label = "Diamond Treadmill",
		periodSeconds = 1209600,
		defaultQuota = 1
	}
}
local v2 = {}

for _, v3 in TREADMILLS do
	v2[v3.tag] = v3
end

return {
	TREADMILLS = TREADMILLS,
	BY_TAG = v2
}