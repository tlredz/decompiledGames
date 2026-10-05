local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
require(script.Parent.Types)

local function scaledWeight(p)
	return (math.floor(p.weight * 1000 + 0.5))
end

local function rollWeighted(object, rarities)
	local total = 0

	for _, v in ipairs(rarities) do
		total += math.floor(v.weight * 1000 + 0.5)
	end

	local integer = object:NextInteger(0, total - 1)
	local total2 = 0

	for _, v in ipairs(rarities) do
		total2 += math.floor(v.weight * 1000 + 0.5)

		if integer < total2 then
			return v.rarity
		end
	end

	return rarities[#rarities].rarity
end

local function resolveRarity(p, p2: number, random)
	if p.guaranteed then
		for _, v in ipairs(p.guaranteed) do
			if p2 % v.every == 0 then
				return v.rarity
			end
		end
	end

	return (rollWeighted(random, p.rarities))
end

local Rotation = {}

function Rotation.buildPools(p: string)
	local result = {}

	for k, v in Items.ITEMS do
		if v.EventKey ~= p then
			continue
		end

		if result[v.rarity] == nil then
			result[v.rarity] = {}
		end

		table.insert(result[v.rarity], k)
	end

	for _, list in result do
		table.sort(list)
	end

	return result
end

function Rotation.pickItem(p, p2, p3: number, p4: number)
	local random = Random.new(p4 * 1000 + p3)
	local v = p[resolveRarity(p2, p4, random)]

	if v then
		return v[random:NextInteger(1, #v)]
	end

	return nil
end

function Rotation.slotAllowsRarity(p, p2: string)
	for _, rarity in ipairs(p.rarities) do
		if rarity.rarity == p2 then
			return true
		end
	end

	if p.guaranteed then
		for _, v in ipairs(p.guaranteed) do
			if v.rarity == p2 then
				return true
			end
		end
	end

	return false
end

return Rotation