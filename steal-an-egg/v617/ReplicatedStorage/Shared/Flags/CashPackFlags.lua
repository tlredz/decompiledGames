local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local BalanceConfig = require(script.Parent.BalanceConfig)
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local v = {}

for k, offer in CashPacks.Offers do
	v[k] = BalanceConfig.Bind("Game.Balance.ProductRewards." .. offer.Name, {
		Amount = offer.Floor
	}, true, false, function(p)
		assert(p.Amount > 0)
	end)
end

local replicated = FastFlags.Replicated("Game.CashPacks.Minutes", function(list)
	Asserts.Array(Asserts.FinitePositive)(list)
	assert(#list == #CashPacks.Offers, "Cash packs require five durations")
	return list
end, {
	40,
	120,
	360,
	1080,
	2880
})
return {
	GrowthMultiplier = FastFlags.Replicated("Game.CashPacks.GrowthMultiplier", Asserts.Range(1, 10), 1.2),
	GetOffers = function()
		local clones = {}

		for k, offer in CashPacks.Offers do
			local clone = table.clone(offer)
			clone.Minutes = replicated:Get()[k]
			clone.Floor = math.max(offer.Floor, v[k].Amount)
			clones[k] = clone
		end

		return clones
	end
}