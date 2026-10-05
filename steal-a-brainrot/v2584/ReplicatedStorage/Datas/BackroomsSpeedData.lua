local maxUpgradesByRebirth = {
	[0] = 2,
	[1] = 4,
	[2] = 7,
	[3] = 9,
	[4] = 11,
	[5] = 14,
	[6] = 16,
	[7] = 19,
	[8] = 21,
	[9] = 24,
	[10] = 26,
	[11] = 29,
	[12] = 31,
	[13] = 34,
	[14] = 36,
	[15] = 39,
	[16] = 41,
	[17] = 44
}
local maxTier = maxUpgradesByRebirth[17]
local BackroomsSpeedData = {}
BackroomsSpeedData.maxTier = maxTier
BackroomsSpeedData.highestKnownRebirth = 17
BackroomsSpeedData.exponentialUpgradeFactor = 1.75
BackroomsSpeedData.initialUpgradeCost = 5000
BackroomsSpeedData.upgrades = { 1, 5, 10 }
BackroomsSpeedData.maxUpgradesByRebirth = maxUpgradesByRebirth

function BackroomsSpeedData.getExtraSpeed(p: number)
	return p
end

function BackroomsSpeedData.getTotalSpeed(p: number)
	return p
end

function BackroomsSpeedData.getUpgradeCost(p: number, p2: number)
	return (math.max(math.floor(1.75 ^ (p + p2) * 5000), 1))
end

function BackroomsSpeedData.getMaxUpgradesForRebirth(p: number)
	if p >= 17 then
		return maxTier
	end

	return maxUpgradesByRebirth[p < 0 and 0 or p] or maxTier
end

function BackroomsSpeedData.getRequiredRebirthForAmount(p: number)
	for i = 0, 17 do
		if p <= maxUpgradesByRebirth[i] then
			return i
		end
	end

	return 17
end

function BackroomsSpeedData.canBuy(p: number, p2: number, p3: number)
	local v3 = p + p2
	local v4

	if p3 >= 17 then
		v4 = maxTier
	else
		v4 = maxUpgradesByRebirth[p3 < 0 and 0 or p3] or maxTier
	end

	return v3 <= v4
end

return BackroomsSpeedData