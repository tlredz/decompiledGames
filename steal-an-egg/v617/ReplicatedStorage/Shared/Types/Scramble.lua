local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local ScrambleRules = require(ReplicatedStorage.Shared.Util.ScrambleRules)

local function fn(p)
	return ScrambleRules.Integer(p, 0, ScrambleRules.MAX_SAMPLES)
end

return table.freeze({
	Blank = ScrambleRules.Blank,
	State = t.interface({
		Wallets = t.map(t.string, fn),
		LostParts = t.interface({
			LostPart1 = t.optional(t.boolean),
			LostPart2 = t.optional(t.boolean)
		}),
		DroneParts = function(p)
			return ScrambleRules.Integer(p, 0, 3)
		end,
		Discovered = t.boolean,
		Completed = t.boolean,
		RewardUid = t.string,
		MutationConsumables = t.optional(fn),
		ShopSequence = fn,
		ShopPurchases = t.optional(t.map(t.string, t.map(t.string, t.interface({
			Period = t.string,
			Count = fn
		})))),
		LastOperation = t.string,
		Receipts = t.map(t.string, t.interface({
			ProductId = fn,
			EventId = t.string,
			Amount = fn
		})),
		Mastery = t.optional(fn),
		ClaimedMilestoneIds = t.optional(t.map(t.string, t.boolean)),
		InfiniteRewardsClaimed = t.optional(fn)
	})
})