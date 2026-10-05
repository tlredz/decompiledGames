_G.import("event")

local function handlePremiumPassPurchase(_, _, p)
	p.BattlePass:replicate("PremiumUnlocked", true)
	return true
end

local function handleTierSkipPurchase(_, _, p, p2)
	local skippedTiers = p.BattlePass.SkippedTiers
	p.BattlePass:replicate("SkippedTiers", skippedTiers + p2)
	return true
end

return {
	p3374805071 = {
		Server = handlePremiumPassPurchase,
		Client = function() end
	},
	p3371789310 = {
		Server = function(_, _, p)
			local skippedTiers = p.BattlePass.SkippedTiers
			p.BattlePass:replicate("SkippedTiers", skippedTiers + 10)
			return true
		end,
		Client = function() end
	}
}