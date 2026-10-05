local CountableDevProducts = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
CountableDevProducts.All = TableUtil.Lock({
	JULY_FIREWORK_GALAXY_PACK = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	JULY_FIREWORK_HEART_PACK = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	PLUS_ONE_PS_PROPS_SLOT = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	VEHICLE_SAVE_SLOT = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	STICKY_SITUATION = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	SUMMER_2026_SMALL_TICKETS = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	SUMMER_2026_MEDIUM_TICKETS = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	SUMMER_2026_LARGE_TICKETS = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	SUMMER_2026_HUGE_TICKETS = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	PUBLIC_SERVER_PROP_LIMIT = {
		__COUNTABLE_DEV_PRODUCT = true
	},
	PRIVATE_SERVER_PROP_LIMIT = {
		__COUNTABLE_DEV_PRODUCT = true
	}
})
CountableDevProducts.JULY_FIREWORK_GALAXY_PACK = CountableDevProducts.All.JULY_FIREWORK_GALAXY_PACK
CountableDevProducts.JULY_FIREWORK_HEART_PACK = CountableDevProducts.All.JULY_FIREWORK_HEART_PACK
CountableDevProducts.PLUS_ONE_PS_PROPS_SLOT = CountableDevProducts.All.PLUS_ONE_PS_PROPS_SLOT
CountableDevProducts.VEHICLE_SAVE_SLOT = CountableDevProducts.All.VEHICLE_SAVE_SLOT
CountableDevProducts.STICKY_SITUATION = CountableDevProducts.All.STICKY_SITUATION
CountableDevProducts.SUMMER_2026_SMALL_TICKETS = CountableDevProducts.All.SUMMER_2026_SMALL_TICKETS
CountableDevProducts.SUMMER_2026_MEDIUM_TICKETS = CountableDevProducts.All.SUMMER_2026_MEDIUM_TICKETS
CountableDevProducts.SUMMER_2026_LARGE_TICKETS = CountableDevProducts.All.SUMMER_2026_LARGE_TICKETS
CountableDevProducts.SUMMER_2026_HUGE_TICKETS = CountableDevProducts.All.SUMMER_2026_HUGE_TICKETS
CountableDevProducts.PUBLIC_SERVER_PROP_LIMIT = CountableDevProducts.All.PUBLIC_SERVER_PROP_LIMIT
CountableDevProducts.PRIVATE_SERVER_PROP_LIMIT = CountableDevProducts.All.PRIVATE_SERVER_PROP_LIMIT
local v = {
	[CountableDevProducts.All.JULY_FIREWORK_GALAXY_PACK] = {
		id = 3606424933,
		max = 100000
	},
	[CountableDevProducts.All.JULY_FIREWORK_HEART_PACK] = {
		id = 3606424793,
		max = 100000
	},
	[CountableDevProducts.All.PLUS_ONE_PS_PROPS_SLOT] = {
		id = 3604200710,
		max = 7,
		adminOverrideMax = 100
	},
	[CountableDevProducts.All.VEHICLE_SAVE_SLOT] = {
		id = 3709057875,
		max = 7,
		adminOverrideMax = 100
	},
	[CountableDevProducts.All.STICKY_SITUATION] = {
		id = 3606700071
	},
	[CountableDevProducts.All.SUMMER_2026_SMALL_TICKETS] = {
		id = 3607469908
	},
	[CountableDevProducts.All.SUMMER_2026_MEDIUM_TICKETS] = {
		id = 3607469936
	},
	[CountableDevProducts.All.SUMMER_2026_LARGE_TICKETS] = {
		id = 3607469955
	},
	[CountableDevProducts.All.SUMMER_2026_HUGE_TICKETS] = {
		id = 3607469971
	},
	[CountableDevProducts.All.PUBLIC_SERVER_PROP_LIMIT] = {
		id = 3609089704,
		max = 3,
		adminOverrideMax = 100
	},
	[CountableDevProducts.All.PRIVATE_SERVER_PROP_LIMIT] = {
		id = 3609089478,
		max = 15,
		adminOverrideMax = 100
	}
}
local v2 = {}

for k, v3 in v do
	v2[v3.id] = k
end

local v3 = {}

for k, v4 in CountableDevProducts.All do
	v3[v4] = k
end

function CountableDevProducts.Exists(p: number)
	return v2[p] ~= nil
end

function CountableDevProducts.GetId(p)
	if p == nil then
		error("countable dev product is nil")
		return
	end

	if v[p] ~= nil then
		return v[p].id
	end

	error("In CountableDevProducts.GetId: received unknown product")
end

function CountableDevProducts.GetName(p)
	if p == nil then
		error("countable dev product is nil")
		return
	end

	if v3[p] ~= nil then
		return v3[p]
	end

	error("In CountableDevProducts.GetName: received unknown product")
end

function CountableDevProducts.GetMax(p)
	if p == nil then
		error("countable dev product is nil")
		return
	end

	if v[p] ~= nil then
		return v[p].max
	end

	error("In CountableDevProducts.GetMax: received unknown product")
end

function CountableDevProducts.GetAdminOverrideMax(p)
	if p == nil then
		error("countable dev product is nil")
		return
	end

	if v[p] ~= nil then
		return v[p].adminOverrideMax or 100
	end

	error("In CountableDevProducts.GetAdminOverrideMax: received unknown product")
end

function CountableDevProducts.CapCount(p: number, p2, flag: boolean)
	local v4 = math.max(0, (math.floor(p)))
	local max = CountableDevProducts.GetMax(p2)

	if v4 <= max then
		return v4
	end

	if flag then
		return (math.min(v4, CountableDevProducts.GetAdminOverrideMax(p2)))
	end

	return max
end

function CountableDevProducts.GetById(p: number)
	if v2[p] ~= nil then
		return v2[p]
	end

	error("In CountableDevProducts.GetById: received unknown product id")
end

return CountableDevProducts