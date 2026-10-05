local DragonEgg = {}
DragonEgg.EggDisplayName = "Dragon Egg"
DragonEgg.RewardEggDisplayName = "Dragon's Egg"
DragonEgg.MaxCountedReturns = 10
DragonEgg.BaseAssetScale = 0.3
DragonEgg.AssetScalePerReturn = 0.42
DragonEgg.NestBaseScale = 0.3
DragonEgg.NestScalePerReturn = 0.42
DragonEgg.DropTable = {
	{ "Baby Aurora Dragon", 85, -8.5 },
	{ "Shadow Dragon", 13.5, 1.25 },
	{ "Ember Dragon", 1, 6.5 },
	{ "Void Dragon", 0.5, 0.75 }
}
DragonEgg.RestoreDropTable = {
	{ "Baby Aurora Dragon", 45 },
	{ "Shadow Dragon", 35 },
	{ "Ember Dragon", 15 },
	{ "Void Dragon", 5 }
}
DragonEgg.RewardCategory = "ScorchedDragon"
DragonEgg.CarryCategory = "Baby Aurora Dragon"

function DragonEgg.GetCountedReturns(p: number)
	return (math.clamp(math.floor(p), 0, DragonEgg.MaxCountedReturns))
end

function DragonEgg.GetEntryWeight(list, p: number)
	return (math.max(list[2] + list[3] * DragonEgg.GetCountedReturns(p), 0))
end

function DragonEgg.GetTotalWeight(p: number)
	local total = 0

	for _, v in DragonEgg.DropTable do
		total += DragonEgg.GetEntryWeight(v, p)
	end

	return total
end

function DragonEgg.RollRestore()
	local random = Random.new()
	local total = 0

	for _, v in DragonEgg.RestoreDropTable do
		total += v[2]
	end

	local v = random:NextNumber() * total
	local total2 = 0

	for _, v2 in DragonEgg.DropTable do
		total2 += v2[2]

		if v <= total2 then
			return v2[1]
		end
	end

	error((`[{script.Name}] Roll out of bounds exception`))
end

function DragonEgg.Roll(p: number, p2)
	assert(#DragonEgg.DropTable > 0, "DragonEgg.DropTable is empty")
	local v = p2 or Random.new()
	local totalWeight = DragonEgg.GetTotalWeight(p)

	if totalWeight <= 0 then
		return DragonEgg.DropTable[1][1]
	end

	local v2 = v:NextNumber() * totalWeight
	local total = 0

	for _, v3 in DragonEgg.DropTable do
		total += DragonEgg.GetEntryWeight(v3, p)

		if v2 <= total then
			return v3[1]
		end
	end

	return DragonEgg.DropTable[#DragonEgg.DropTable][1]
end

function DragonEgg.GetAssetScale(p: number)
	return DragonEgg.BaseAssetScale + DragonEgg.AssetScalePerReturn * DragonEgg.GetCountedReturns(p)
end

function DragonEgg.GetNestVisualScale(p: number)
	return DragonEgg.NestBaseScale + DragonEgg.NestScalePerReturn * DragonEgg.GetCountedReturns(p)
end

function DragonEgg.IsEventCategory(p: string?)
	if p == nil then
		return false
	end

	if p == DragonEgg.RewardCategory then
		return true
	end

	for _, v in DragonEgg.DropTable do
		if v[1] == p then
			return true
		end
	end

	return false
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
DragonEgg = require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.DragonEgg", DragonEgg, {
	MaxCountedReturns = true,
	BaseAssetScale = true,
	AssetScalePerReturn = true,
	DropTable = true,
	RestoreDropTable = true
}, false, function(p)
	local v

	if p.MaxCountedReturns % 1 == 0 then
		v = p.BaseAssetScale > 0
	else
		v = false
	end

	assert(v)
end)
return DragonEgg