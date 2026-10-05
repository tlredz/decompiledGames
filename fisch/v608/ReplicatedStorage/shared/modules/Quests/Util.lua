local Util = {}
require("../QuestTypes")

-- equivalent calls inferred from this helper; original call sites unknown
local function arrayIfString(value)
	if typeof(value) == "string" then
		return { value }
	end

	return value
end

function Util.SaneCatchFishObjective(data)
	local v = data.RequiredAttributes ~= nil
	local v2 = not data.RequiredAttributes and {} or table.clone(data.RequiredAttributes) or {}

	if data.PerfectCatch ~= nil then
		v2.Perfect = data.PerfectCatch
		v = true
	end

	if data.AndReturn ~= nil then
		v2.Return = data.AndReturn
		v = true
	end

	if data.PlayerZones ~= nil then
		v2.Locations = arrayIfString(data.PlayerZones)
		v = true
	end

	if data.FishingZones ~= nil then
		v2.Zones = arrayIfString(data.FishingZones)
		v = true
	end

	if not v then
		v2 = nil
	end

	local requiredAmount = data.RequiredAmount or 1
	local v3 = arrayIfString(data.Fish) -- equivalent call inferred; original call site unknown
	local v4 = arrayIfString(data.Raritites) -- equivalent call inferred; original call site unknown
	local v5 = arrayIfString(data.Rods) -- equivalent call inferred; original call site unknown
	local v6 = arrayIfString(data.Bait) -- equivalent call inferred; original call site unknown
	return {
		"CatchFish",
		requiredAmount,
		v3,
		v4,
		v2,
		v5,
		v6,
		nil,
		arrayIfString(data.EnchantCombos)
	}
end

return Util