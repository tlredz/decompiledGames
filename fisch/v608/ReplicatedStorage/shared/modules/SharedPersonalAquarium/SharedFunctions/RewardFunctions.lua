local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
local modules = ReplicatedStorage.shared.modules
local library = modules.library
local fish = require(library.fish)
local mutations = require(modules.fishing.mutations)
local module = require("../SharedData/FishFoodData")
require("../SharedTypes")
local v = {
	Trash = {
		Items = 1,
		CurrencyMultiplier = 1
	},
	Common = {
		Items = 2,
		CurrencyMultiplier = 1
	},
	Uncommon = {
		Items = 2,
		CurrencyMultiplier = 1
	},
	Unusual = {
		Items = 3,
		CurrencyMultiplier = 1
	},
	Rare = {
		Items = 4,
		CurrencyMultiplier = 1
	},
	Limited = {
		Items = 5,
		CurrencyMultiplier = 1
	},
	Legendary = {
		Items = 5,
		CurrencyMultiplier = 1
	},
	Mythical = {
		Items = 6,
		CurrencyMultiplier = 1
	},
	Exotic = {
		Items = 7,
		CurrencyMultiplier = 1
	},
	Secret = {
		Items = 5,
		CurrencyMultiplier = 1
	},
	Relic = {
		Items = 9,
		CurrencyMultiplier = 1
	},
	Fragment = {
		Items = 10,
		CurrencyMultiplier = 1
	},
	Gemstone = {
		Items = 8,
		CurrencyMultiplier = 1
	},
	Apex = {
		Items = 3,
		CurrencyMultiplier = 1
	},
	Extinct = {
		Items = 3,
		CurrencyMultiplier = 1
	},
	Cataclysmic = {
		Items = 3,
		CurrencyMultiplier = 1
	},
	Divine = {
		Items = 6,
		CurrencyMultiplier = 1
	},
	Special = {
		Items = 4,
		CurrencyMultiplier = 1
	},
	["Divine Secret"] = {
		Items = 12,
		CurrencyMultiplier = 1
	}
}
local mutations2 = mutations.Mutations

local function dampenMultiplier(p: number)
	if p <= 1 then
		return p
	end

	return p - math.pow(p - 1, 1.3634165139304208) * 0.1
end

local function dampenWeightMultiplier(p: number)
	if p <= 1 then
		return p
	end

	return (math.max(1, p - math.pow(p - 1, 0.9342395088803243) * 1))
end

local function compoundedLoss(p: number, p2: number)
	if p2 <= 0 then
		return 0
	end

	local v2 = 1

	for _ = 1, p2 do
		v2 *= p
	end

	return math.floor((1 - v2) * 100 * 100 + 0.5) / 100
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureIntegerRewards(p)
	p.HourlyXP = math.round(p.HourlyXP)
	p.HourlyCoins = math.round(p.HourlyCoins)
	p.HourlyItems = math.round(p.HourlyItems)

	for k, v2 in p do
		if v2 < 0 then
			p[k] = 0
		end
	end
end

local function getTotalFishFoodMultipliers(items)
	local result = {
		SoftCurrencyMultiplier = 1,
		ExperienceMultiplier = 1,
		RewardItemsMultiplier = 1
	}

	for k, _ in items do
		for k2, multiplier in module[k].Multipliers do
			result[k2] *= multiplier
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyFishFoodMultipliersToHourlyRewards(result, totalFishFoodMultipliers)
	result.HourlyXP *= totalFishFoodMultipliers.ExperienceMultiplier
	result.HourlyCoins *= totalFishFoodMultipliers.SoftCurrencyMultiplier
	result.HourlyItems *= totalFishFoodMultipliers.RewardItemsMultiplier
end

local function getFishHourlyData(fishSellValue: number, name: string, fishRaritySafe)
	return {
		HourlyXP = math.round((fish[name] and fish[name].XP or 0) / 5),
		HourlyCoins = math.round(fishSellValue * 0.25 * (v[fishRaritySafe].CurrencyMultiplier or 1)),
		HourlyItems = v[fishRaritySafe].Items or 4
	}
end

local function getFishSellValue(p, items)
	local names = {}

	for _, item in items do
		table.insert(names, item.name)
	end

	local count = 0

	for _, v2 in names do
		if v2 == p.name then
			count += 1
		end
	end

	local v2 = fish[p.name]

	local function dampenCombinationMultiplier(p2: number)
		if p2 <= 1 then
			return p2
		end

		return p2 - math.pow(p2 - 1, 1.3634165139304208) * 0.2
	end

	local price = v2.Price
	local v3

	if p.sub.Weight then
		local v4 = p.sub.Weight / (v2.WeightPool[2] / 10)

		if not (v4 <= 1) then
			v4 = math.max(1, v4 - math.pow(v4 - 1, 0.9342395088803243) * 1)
		end

		v3 = math.ceil(price * v4)
	else
		local v4 = v2.WeightPool[1] / (v2.WeightPool[2] / 10)

		if not (v4 <= 1) then
			v4 = math.max(1, v4 - math.pow(v4 - 1, 0.9342395088803243) * 1)
		end

		v3 = math.ceil(price * v4)
	end

	local v4 = 1
	local count2 = 0

	if p.sub.Shiny then
		v4 *= 1.5
		count2 += 1
	end

	if p.sub.Sparkling then
		v4 *= 1.5
		count2 += 1
	end

	local v5 = p.sub.Glitched and 0 or v3

	if p.sub.Mutation then
		local mutations3 = mutations2

		if mutations3[p.sub.Mutation] then
			local mutation = p.sub.Mutation

			if mutation == "Seasonal" then
				local season = p.sub.Season

				if season then
					local value = season.Value

					if value == "Spring" then
						v4 *= count2 == 0 and (3.948187725904613 or 4.5) or 4.5
					elseif value == "Winter" then
						v4 *= count2 == 0 and (2.326185609220638 or 2.5) or 2.5
					elseif value == "Autumn" then
						v4 *= count2 == 0 and (3.552786404500042 or 4) or 4
					end
				end
			else
				local priceMultiply

				if count2 == 0 then
					priceMultiply = mutations3[mutation].PriceMultiply

					if not (priceMultiply <= 1) then
						priceMultiply -= math.pow(priceMultiply - 1, 1.3634165139304208) * 0.1
					end

					if not priceMultiply then
						priceMultiply = mutations3[mutation].PriceMultiply
					end
				else
					priceMultiply = mutations3[mutation].PriceMultiply
				end

				v4 *= priceMultiply
			end

			count2 += 1
		end
	end

	if v4 > 1 and count2 > 1 and not (v4 <= 1) then
		v4 -= math.pow(v4 - 1, 1.3634165139304208) * 0.2
	end

	local v6 = v5 * v4
	local v7 = count - 1

	for _ = 1, v7 do
		v6 *= 0.75
	end

	if v7 <= 0 then
		return v6, 0
	end

	local v8 = 1

	for _ = 1, v7 do
		v8 *= 0.75
	end

	return v6, math.floor((1 - v8) * 100 * 100 + 0.5) / 100
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getFishRaritySafe(p)
	local name = p.name
	local rarity = fish[name] and fish[name].Rarity or "Common"
	return v[rarity] and rarity or "Common"
end

local RewardFunctions = {
	getHourlyRewardsForFish = function(p, p2)
		local name = p.name
		local fishRaritySafe = getFishRaritySafe(p) -- equivalent call inferred; original call site unknown
		local fishSellValue, v2 = getFishSellValue(p, p2)
		local fishHourlyData = getFishHourlyData(fishSellValue, name, fishRaritySafe)

		if v2 > 0 then
			local v3 = 1 - v2 / 100
			fishHourlyData.HourlyItems *= v3
		end

		ensureIntegerRewards(fishHourlyData) -- equivalent call inferred; original call site unknown
		return fishHourlyData, v2
	end
}

function RewardFunctions.getFullOnlineHourlyProfit(items, items2)
	local totalFishFoodMultipliers = getTotalFishFoodMultipliers(items2)
	local v2 = {}
	local result = {
		HourlyXP = 0,
		HourlyCoins = 0,
		HourlyItems = 0
	}

	for _, item in items do
		table.insert(v2, item)
		local hourlyRewardsForFish = RewardFunctions.getHourlyRewardsForFish(item, v2)

		for k, v3 in hourlyRewardsForFish do
			result[k] += v3
		end
	end

	if next(items2) then
		applyFishFoodMultipliersToHourlyRewards(result, totalFishFoodMultipliers) -- equivalent call inferred; original call site unknown
	end

	ensureIntegerRewards(result) -- equivalent call inferred; original call site unknown
	return result
end

function RewardFunctions.getFullOfflineHourlyProfit(p, p2)
	local fullOnlineHourlyProfit = RewardFunctions.getFullOnlineHourlyProfit(p, p2)

	for k, _ in fullOnlineHourlyProfit do
		fullOnlineHourlyProfit[k] *= 0.25
		fullOnlineHourlyProfit[k] = math.round(fullOnlineHourlyProfit[k])
	end

	ensureIntegerRewards(fullOnlineHourlyProfit) -- equivalent call inferred; original call site unknown
	return fullOnlineHourlyProfit
end

return RewardFunctions