local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local Sakura = {}
Sakura.EventName = "GreatBloom"
Sakura.CurrencyId = "SakuraCrystals"
Sakura.MutationName = "Sakura"
Sakura.SpecialMutationName = "GreatBloom"
Sakura.TreeTag = "SakuraBloomTree"
Sakura.CrystalTag = "SakuraCrystal"
Sakura.BatToolAttribute = "IsBat"
Sakura.Bloom = {
	IntervalSeconds = 1800,
	OffsetSeconds = 900,
	DurationSeconds = 285,
	NightPollSeconds = 0.5,
	EndsAtAttribute = "GreatBloomEndsAt",
	MaxActiveTrees = 50,
	SpawnDelayMin = 0.25,
	SpawnDelayMax = 0.75,
	SpawnClearance = 6,
	SpawnAttempts = 40,
	HitCooldownSeconds = 0.6,
	HitHoldSeconds = 0.2,
	EndingWarningSeconds = 30,
	HitRange = 10,
	SpawnShakeRadius = 10,
	CrystalScale = 0.22,
	CrystalPickupRange = 10,
	CrystalLifetimeSeconds = 60,
	CrystalSpreadRadius = 14,
	Sizes = {
		{
			Id = "Small",
			Weight = 50,
			Hits = 1,
			CrystalsPerHit = 0,
			ScatterCrystals = 1,
			ScatterCrystalValue = 5
		},
		{
			Id = "Medium",
			Weight = 30,
			Hits = 2,
			CrystalsPerHit = 0,
			ScatterCrystals = 2,
			ScatterCrystalValue = 5
		},
		{
			Id = "Large",
			Weight = 15,
			Hits = 3,
			CrystalsPerHit = 0,
			ScatterCrystals = 4,
			ScatterCrystalValue = 5
		},
		{
			Id = "Gigantic",
			Weight = 5,
			Hits = 3,
			CrystalsPerHit = 0,
			ScatterCrystals = 6,
			ScatterCrystalValue = 5
		}
	}
}
Sakura.Incubator = {
	Cost = 1000,
	MaxChargePercent = 150,
	SpecialChanceAt100 = 2.5,
	SpecialChanceAtMax = 5,
	LuckBoostMultiplier = 2,
	LuckBoostProductNames = { "SakuraLuckBoost1", "SakuraLuckBoost2", "SakuraLuckBoost3" },
	MaxLuckBoosts = 3
}
Sakura.Sounds = {
	TreeSpawn = 116457372922007,
	TreeHit = 84529703733081,
	TreeBreak = 83426144942407,
	CrystalPickup = 98181315786739,
	CrystalsGained = 72831064837421,
	Deposit = 133204478644023,
	Mutate = 139860804876890,
	CraneFlap = 9120779671,
	Bloom = 9116418035,
	Unlocked = 102177008084626,
	TutorialOpen = 89550685069550
}
Sakura.AreaDisplay = {
	AreaId = "CherryBlossom",
	DisplayName = "Cherry Blossom",
	Emoji = "🌸",
	Rarity = Rarity.Rarities.Divine,
	Lighting = "CherryBlossom"
}
Sakura.Quest = {
	CraneAssetId = "Crane"
}

function Sakura.GetRequiredCrystals()
	return Sakura.Incubator.Cost
end

function Sakura.GetChargePercent(p: number, p2: number)
	if p2 <= 0 then
		return 0
	end

	return (math.clamp(p / p2 * 100, 0, Sakura.Incubator.MaxChargePercent))
end

function Sakura.GetLuckMultiplier(p: number)
	return Sakura.Incubator.LuckBoostMultiplier ^ p
end

function Sakura.CanBuyLuckBoost(data, p: number)
	if not data.Unlocked then
		return false, "The Sakura Incubator is still sealed"
	end

	if data.Egg == false then
		return false, "Place an egg inside first"
	end

	if data.LuckBoost >= Sakura.Incubator.MaxLuckBoosts then
		return false, "This egg already has max luck"
	end

	if p == data.LuckBoost + 1 then
		return true, nil
	end

	return false, "Wrong luck boost tier for this egg"
end

function Sakura.GetFreeChargeCap(p: number)
	return (math.ceil(p * Sakura.Incubator.MaxChargePercent / 100))
end

function Sakura.GetMutationChance(value: number)
	return (math.clamp(value, 0, 100))
end

function Sakura.GetEffectiveMutationChance(p: number, p2: number)
	return 100 - Sakura.GetSpecialChance(p, p2)
end

function Sakura.GetSpecialChance(p: number, p2: number)
	local incubator = Sakura.Incubator
	local v = math.max(p - 100, 0) / math.max(incubator.MaxChargePercent - 100, 1)
	return (math.clamp(
		(incubator.SpecialChanceAt100 + (incubator.SpecialChanceAtMax - incubator.SpecialChanceAt100) * v) * Sakura.GetLuckMultiplier(p2),
		0,
		100
	))
end

function Sakura.PickTreeSize(object)
	local sizes = Sakura.Bloom.Sizes
	local total = 0

	for _, siz in sizes do
		total += siz.Weight
	end

	local v = object:NextNumber() * total
	local total2 = 0

	for _, siz in sizes do
		total2 += siz.Weight

		if v <= total2 then
			return siz
		end
	end

	return sizes[#sizes]
end

function Sakura.GetTreeSize(p: string)
	for _, siz in Sakura.Bloom.Sizes do
		if siz.Id == p then
			return siz
		end
	end

	error((`Unknown Sakura tree size {p}`))
end

function Sakura.HasSakuraMutation(list)
	if list == nil then
		return false
	end

	return table.find(list, Sakura.MutationName) ~= nil or table.find(list, Sakura.SpecialMutationName) ~= nil
end

function Sakura.IsBatTool(instance)
	return instance:GetAttribute(Sakura.BatToolAttribute) == true
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
Sakura = require(ReplicatedStorage2.Shared.Flags.BalanceConfig).Bind("Game.Balance.Sakura", Sakura, {
	Bloom = {
		IntervalSeconds = true,
		OffsetSeconds = true,
		DurationSeconds = true,
		MaxActiveTrees = true,
		SpawnDelayMin = true,
		SpawnDelayMax = true,
		HitCooldownSeconds = true,
		HitRange = true,
		CrystalPickupRange = true,
		CrystalLifetimeSeconds = true,
		Sizes = true
	},
	Incubator = {
		Cost = true,
		MaxChargePercent = true,
		SpecialChanceAt100 = true,
		SpecialChanceAtMax = true,
		LuckBoostMultiplier = true,
		MaxLuckBoosts = true
	}
}, false, function(p)
	local v

	if p.Bloom.IntervalSeconds > 0 then
		v = p.Bloom.DurationSeconds > 0
	else
		v = false
	end

	assert(v)
	local v2

	if p.Bloom.SpawnDelayMax >= p.Bloom.SpawnDelayMin then
		v2 = p.Bloom.SpawnDelayMin > 0
	else
		v2 = false
	end

	assert(v2)
	assert(p.Bloom.MaxActiveTrees % 1 == 0)
	local v3

	if p.Incubator.Cost > 0 then
		v3 = p.Incubator.MaxChargePercent > 100
	else
		v3 = false
	end

	assert(v3)
	local v4

	if p.Incubator.SpecialChanceAt100 <= 100 then
		v4 = p.Incubator.SpecialChanceAtMax <= 100
	else
		v4 = false
	end

	assert(v4)
	local v5

	if p.Incubator.MaxLuckBoosts % 1 == 0 then
		v5 = p.Incubator.MaxLuckBoosts <= 3
	else
		v5 = false
	end

	assert(v5)
end)
return Sakura