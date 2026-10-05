local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local Summer2026Util = require(ReplicatedStorage.Modules.Shared.LiveOps.Summer2026Util)
local StickyBombUtil = {
	BOMBS_PER_REWARD = 3,
	BOMBS_PER_PERPETUAL_REWARD = 5,
	BOMBS_PER_PURCHASE = 5
}

function StickyBombUtil.GetGrantedFromRewards(data)
	local total = 0

	for _, v in Summer2026Util.GetSortedUnlockables() do
		if data.isFeatureUnlocked(v.unlockable) then
			total += StickyBombUtil.BOMBS_PER_REWARD
		end
	end

	local tickets = Summer2026Util.GetTickets(data.earnedTickets, data.getCountableDevProductCount)
	local perpetualInfo = Summer2026Util.GetPerpetualInfo()
	local v = perpetualInfo.lastStepTickets - perpetualInfo.cost

	if v <= tickets then
		total += (math.floor((tickets - v) / perpetualInfo.cost) + 1) * StickyBombUtil.BOMBS_PER_PERPETUAL_REWARD
	end

	return total
end

function StickyBombUtil.GetTotalGranted(p)
	local v = p.getCountableDevProductCount(CountableDevProducts.STICKY_SITUATION) * StickyBombUtil.BOMBS_PER_PURCHASE
	return StickyBombUtil.GetGrantedFromRewards(p) + v
end

function StickyBombUtil.GetStickyBombCount(p)
	return (math.max(StickyBombUtil.GetTotalGranted(p) - p.consumed, 0))
end

return StickyBombUtil