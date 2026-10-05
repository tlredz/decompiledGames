local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	RewardIds = table.freeze({
		EggGrowthBoost = "EggGrowthBoost",
		SpeedBoost = "SpeedBoost",
		TreadmillBoost = "TreadmillBoost",
		ExclusiveWeapon = "ExclusiveWeapon",
		MonsterEgg = "MonsterEgg"
	}),
	RetiredRewardIds = table.freeze({
		Cash = "Cash",
		SpeedSmall = "SpeedSmall",
		SpeedLarge = "SpeedLarge"
	})
}
local union = t.union(
	t.literal(v.RewardIds.EggGrowthBoost),
	t.literal(v.RewardIds.SpeedBoost),
	t.literal(v.RewardIds.TreadmillBoost),
	t.literal(v.RewardIds.ExclusiveWeapon),
	t.literal(v.RewardIds.MonsterEgg),
	t.literal(v.RetiredRewardIds.Cash),
	t.literal(v.RetiredRewardIds.SpeedSmall),
	t.literal(v.RetiredRewardIds.SpeedLarge)
)
local interface = t.interface({
	Id = union,
	DisplayName = t.string,
	Amount = t.optional(t.number),
	ItemId = t.optional(t.string),
	Egg = t.optional(t.interface({
		Uid = t.string,
		AssetCategory = t.string,
		Mutation = t.string
	}))
})
v.PendingRewardSchema = t.interface({
	OpeningId = t.string,
	Reward = interface,
	SerializedEgg = t.optional(Eggs.SchemaValidation.SerializedSavedEgg)
})
v.StateSchema = t.interface({
	Charge = t.number,
	PendingChests = t.number,
	TotalFeeds = t.number,
	PendingReward = t.optional(v.PendingRewardSchema),
	EggGrowthBoostExpiresAt = t.optional(t.number),
	SpeedBoostExpiresAt = t.optional(t.number)
})
v.EventStateSchema = t.interface({
	Active = t.boolean,
	EndsAt = t.number,
	ServerTime = t.number
})
v.SnapshotSchema = t.interface({
	Event = v.EventStateSchema,
	State = v.StateSchema
})
v.FeedResultSchema = t.interface({
	Success = t.boolean,
	Message = t.string,
	EggUid = t.optional(t.string),
	PreviousCharge = t.optional(t.number),
	Charge = t.optional(t.number),
	PendingChests = t.optional(t.number)
})
v.ChestResultSchema = t.interface({
	Success = t.boolean,
	Message = t.string,
	OpeningId = t.optional(t.string),
	Reward = t.optional(interface),
	PendingChests = t.optional(t.number)
})
v.RevealResultSchema = t.interface({
	Success = t.boolean,
	Message = t.string
})
v.TakeResultSchema = t.interface({
	Success = t.boolean,
	Message = t.string
})
v.ViewRewardsPromptName = "ViewRewardsPrompt"
v.ViewRewardsPromptText = "View Rewards"
v.ChargeDrainAttributeName = "MonsterChargeDrain"
v.ChargeDrainDuration = 0.5
v.ChargeGainAttributeName = "MonsterChargeGain"
v.ChargeGainCueTimeout = 4
v.BoostKinds = table.freeze({
	EggGrowth = "EggGrowth",
	Speed = "Speed"
})
v.BoostRewardIds = table.freeze({
	EggGrowth = v.RewardIds.EggGrowthBoost,
	Speed = v.RewardIds.SpeedBoost
})

function v.BoostExpiresAt(p, p2: string)
	if p == nil then
		return 0
	end

	local eggGrowthBoostExpiresAt

	if p2 == v.BoostKinds.EggGrowth then
		eggGrowthBoostExpiresAt = p.EggGrowthBoostExpiresAt
	else
		eggGrowthBoostExpiresAt = p.SpeedBoostExpiresAt
	end

	if type(eggGrowthBoostExpiresAt) == "number" then
		return eggGrowthBoostExpiresAt
	end

	return 0
end

function v.BoostRemainingSeconds(p, p2: string, serverTimeNow: number?)
	if serverTimeNow == nil then
		serverTimeNow = Workspace:GetServerTimeNow()
	end

	return (math.max(v.BoostExpiresAt(p, p2) - serverTimeNow, 0))
end

function v.IsBoostActive(p, p2: string, p3: number?)
	return v.BoostRemainingSeconds(p, p2, p3) > 0
end

function v.RefreshBoost(p, p2: string, p3: number, p4: number)
	local clone = table.clone(p)
	local v2 = math.max(p4 + p3, v.BoostExpiresAt(p, p2))

	if p2 == v.BoostKinds.EggGrowth then
		clone.EggGrowthBoostExpiresAt = v2
		return clone
	end

	clone.SpeedBoostExpiresAt = v2
	return clone
end

function v.DefaultState()
	return {
		Charge = 0,
		PendingChests = 0,
		TotalFeeds = 0
	}
end

return table.freeze(v)