local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lottery = require(ReplicatedStorage.Shared.Flags.GameplayBalance).Lottery
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage2.Data.Assets)
local Constants = require(ReplicatedStorage2.Shared.Globals.Constants)
local Log = require(ReplicatedStorage2.Packages.Log)
local Numeric = require(ReplicatedStorage2.Shared.Utils.Numeric)
local drawWeighted = Numeric.DrawWeighted
local Numeric2 = require(ReplicatedStorage2.Shared.Utils.Numeric)
local rollWeighted = Numeric2.RollWeighted
local Mutations = require(ReplicatedStorage2.Shared.Modules.Mutations)
local Rarity = require(ReplicatedStorage2.Data.Rarity)
local AssetRollScaleWeights = require(script.Parent.AssetRollScaleWeights)
local TableUtil = require(ReplicatedStorage2.Packages.TableUtil)
local t = require(ReplicatedStorage2.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local intersection2 = t.intersection(t.numberMin(0), t.numberMaxExclusive(1e999))
local NO_MUTATION = Mutations.NO_MUTATION
local random = Random.new()
local random2 = Random.new()
local strict = t.strict(intersection)
local strict2 = t.strict(intersection2)
local strict3 = t.strict(t.number)
local strict4 = t.strict(t.table)
local AssetLottery = {}
local limitUnderLevel = Log.new():LimitUnderLevel("Warning")
local v = {}
local v2 = {}
local v3 = {}
local v4 = ""

local function refreshRollTables()
	table.clear(v)

	for _, assetRollScaleWeight in ipairs(AssetRollScaleWeights) do
		table.insert(v, {
			{ assetRollScaleWeight.low, assetRollScaleWeight.high },
			assetRollScaleWeight.weight
		})
	end

	table.clear(v2)
	v4 = ""

	for k, v5 in pairs(Assets.Directory) do
		if v4 == "" then
			v4 = k
		end

		local dropWeight = v5.DropWeight

		if not (dropWeight > 0) or v5.DontRoll or v5.Rarity == Rarity.Rarities.Eternal then
			continue
		end

		table.insert(v2, { k, dropWeight })
	end

	assert(#v2 > 0, "Asset catalog yielded nothing rollable")
	v3 = Mutations.RollTable()
end

refreshRollTables()
local BalanceConfig = require(ReplicatedStorage2.Shared.Flags.BalanceConfig)
BalanceConfig.Changed:Connect(function()
	task.defer(refreshRollTables)
end)
local all = Mutations.All()

local function shiftedTowardsFlat(list, p: number)
	if p <= 0 then
		return TableUtil.Copy(list, true)
	end

	local v5 = p / 100
	local v6 = v5 / (v5 + 1) * lottery.SHIFT_DAMPING
	local v7 = 1e999
	local total = 0

	for _, v8 in ipairs(list) do
		local v9 = v8[2]

		if v9 < v7 then
			v7 = v9
		end

		total += v9
	end

	local result = {}
	local total2 = 0

	for _, v8 in ipairs(list) do
		local v9 = v8[2]
		local v10 = v9 - (v9 - v7) * v6
		table.insert(result, { v8[1], v10 })
		total2 += v10
	end

	local v8 = total2 == 0 and 1 or total / total2

	for _, v9 in ipairs(result) do
		v9[2] *= v8
	end

	limitUnderLevel:AtTrace():Log((`weight shift luck={p} pull={v6} norm={v8}`))
	return result
end

local function amplifyMutations(list, p: number)
	local result = {}

	for _, v5 in ipairs(list) do
		local v6 = v5[1]
		local v7 = v5[2]

		if v6 ~= NO_MUTATION then
			v7 *= p
		end

		table.insert(result, { v6, v7 })
	end

	return result
end

local function entriesAtRarity(p: string, p2: string)
	local v5 = Assets.ByRarity[p2]
	assert(v5 ~= nil, (`{p}: no assets indexed under rarity {p2}`))
	local result = {}

	for k, v6 in pairs(v5) do
		local dropWeight = v6.DropWeight

		if typeof(dropWeight) == "number" and dropWeight > 0 then
			table.insert(result, { k, dropWeight })
		end
	end

	assert(#result > 0, (`{p}: rarity {p2} has no asset with a drop weight`))
	return result
end

local function usableWeight(value)
	return typeof(value) == "number" and value > 0 and value == value and value ~= 1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tokenOf(list)
	if typeof(list[1]) == "string" then
		return list[1]
	end

	return ""
end

local function rarestFirst(list)
	local result = {}

	for _, v5 in ipairs(list) do
		table.insert(result, v5)
	end

	table.sort(result, function(a, b)
		local v5 = a[2]
		local v6

		if typeof(v5) == "number" and v5 > 0 and v5 == v5 then
			v6 = v5 ~= 1e999
		else
			v6 = false
		end

		local v7 = b[2]
		local v8

		if typeof(v7) == "number" and v7 > 0 and v7 == v7 then
			v8 = v7 ~= 1e999
		else
			v8 = false
		end

		if v6 ~= v8 then
			return v6
		end

		if not v6 then
			return tokenOf(a) < tokenOf(b)
		end

		local v9 = a[2]
		local v10 = b[2]

		if v9 == v10 then
			return tokenOf(a) < tokenOf(b)
		end

		return v9 < v10
	end)
	return result
end

local function usableWeightSum(list)
	local total = 0

	for _, v5 in ipairs(list) do
		local v6 = v5[2]
		local v7

		if typeof(v6) == "number" and v6 > 0 and v6 == v6 then
			v7 = v6 ~= 1e999
		else
			v7 = false
		end

		if v7 then
			total += v5[2]
		end
	end

	return total
end

local function cumulativeChance(p: number, p2: number)
	strict(p)
	strict2(p2)

	if p2 <= 1 then
		return p
	end

	return 1 - (1 - p) ^ p2
end

local function drawLuckyToken(p, p2: number, p3)
	strict4(p)
	strict3(p2)
	assert(p3 == nil or typeof(p3) == "Random", "A token draw needs a Random or nil")
	local v5 = rarestFirst(p)
	local v6 = usableWeightSum(v5)

	if v6 <= 0 then
		return nil
	end

	local v7 = (1 - (1 - (p3 or Random.new()):NextNumber()) ^ (1 / math.max(p2, 1))) * v6
	local v8 = nil

	for _, v9 in ipairs(v5) do
		if typeof(v9[1]) ~= "string" then
			continue
		end

		local v10 = v9[2]
		local v11

		if typeof(v10) == "number" and v10 > 0 and v10 == v10 then
			v11 = v10 ~= 1e999
		else
			v11 = false
		end

		if not v11 then
			continue
		end

		v8 = v9[1]
		v7 -= v9[2]

		if v7 <= 0 then
			return v8
		end
	end

	return v8
end

local function bandCeiling(list)
	local selected = list[1]

	if typeof(selected) == "table" then
		selected = selected[#selected]
	end

	if typeof(selected) == "number" then
		return selected
	end

	return nil
end

function AssetLottery.RollCountFor(value: number?, value2: number?)
	return (math.max(
		math.max(1 + (typeof(value) ~= "number" and 0 or value) / 100, 0) + ((typeof(value2) ~= "number" and 1 or math.max(
			value2,
			1
		)) - 1),
		1
	))
end

function AssetLottery.TokenChances(p, p2: number)
	strict4(p)
	strict3(p2)
	local v5 = rarestFirst(p)
	local v6 = usableWeightSum(v5)

	if v6 <= 0 then
		return {}
	end

	local v7 = math.max(p2, 1)
	local total = 0
	local result = {}

	for _, v8 in ipairs(v5) do
		if typeof(v8[1]) ~= "string" then
			continue
		end

		local v9 = v8[2]
		local v10

		if typeof(v9) == "number" and v9 > 0 and v9 == v9 then
			v10 = v9 ~= 1e999
		else
			v10 = false
		end

		if not v10 then
			continue
		end

		local v11 = v8[1]
		local v12 = total / v6
		total += v8[2]
		local v13 = total / v6
		strict(v13)
		strict2(v7)

		if not (v7 <= 1) then
			v13 = 1 - (1 - v13) ^ v7
		end

		strict(v12)
		strict2(v7)

		if not (v7 <= 1) then
			v12 = 1 - (1 - v12) ^ v7
		end

		local v14 = v13 - v12

		if v14 > 0 then
			result[v11] = (result[v11] or 0) + v14
		end
	end

	return result
end

function AssetLottery.DrawCategory(_, value: number?, p)
	local v5 = drawLuckyToken(v2, AssetLottery.RollCountFor(value or 0), p or random2)

	if typeof(v5) == "string" and v5 ~= "" then
		return v5
	end

	limitUnderLevel:AtError():Log((`category draw came back empty, substituting {v4}`))
	return v4
end

function AssetLottery.DrawCategoryForRarity(p: string, p2: string, p3)
	local v5 = rollWeighted(entriesAtRarity(p, p2), p3)
	local v6

	if typeof(v5) == "string" then
		v6 = v5 ~= ""
	else
		v6 = false
	end

	assert(v6, (`{p}: rarity {p2} produced no asset name`))
	return v5
end

function AssetLottery.DrawCategoryFromRarityTable(p: string, p2, p3)
	local v5 = rollWeighted(p2, p3)
	local v6

	if typeof(v5) == "string" then
		v6 = v5 ~= ""
	else
		v6 = false
	end

	assert(v6, (`{p}: rarity table produced no rarity token`))
	return AssetLottery.DrawCategoryForRarity(p, v5, p3)
end

function AssetLottery.DrawCategoryFromTable(p: string, p2, p3: number, p4)
	strict(p3)
	assert(p3 >= 1, "A category draw needs at least one roll")
	local v5

	if p3 > 1 then
		v5 = drawLuckyToken(p2, p3, p4)
	else
		v5 = rollWeighted(p2, p4)
	end

	local v6

	if typeof(v5) == "string" then
		v6 = v5 ~= ""
	else
		v6 = false
	end

	assert(v6, (`{p}: drop table produced no name`))
	assert(Assets.AssetNameExists(v5), (`{p}: drop table named {v5}, which is not in the catalog`))
	return v5
end

function AssetLottery.DrawMutations(_, value: number?, p, p2: number?)
	local v5 = p or random
	local v6 = shiftedTowardsFlat(v3, value or 0)

	if p2 ~= nil and p2 > 1 then
		v6 = amplifyMutations(v6, p2)
	end

	limitUnderLevel:AtInfo():Log((`mutation draw, follow-up odds {lottery.SECOND_MUTATION_ODDS}`))
	local v7 = {}
	local v8 = rollWeighted(v6, v5)

	if typeof(v8) == "string" and v8 ~= NO_MUTATION then
		table.insert(v7, v8)
	end

	if #v7 > 0 and v5:NextNumber() < lottery.SECOND_MUTATION_ODDS then
		local v9 = rollWeighted(v6, v5)

		if typeof(v9) == "string" and v9 ~= NO_MUTATION and not table.find(v7, v9) then
			table.insert(v7, v9)
		end
	end

	table.sort(v7, function(a: string, b: string)
		return all[a].RollWeight < all[b].RollWeight
	end)
	return v7
end

function AssetLottery.DrawScale(_, value: number?, p: number?, p2: number?)
	local v5 = shiftedTowardsFlat(v, value or 0)
	local v6 = {}

	if p and p2 then
		local v7 = {}
		local v8 = {}

		for i, v9 in ipairs(v5) do
			local v10 = v9[1]

			if typeof(v10) == "table" then
				v10 = v10[#v10]
			end

			if typeof(v10) ~= "number" then
				v10 = nil
			end

			if v10 == nil then
				local formatted = `scale band {i} has no numeric ceiling`

				if Constants.IS_STUDIO then
					error(formatted)
				else
					limitUnderLevel:AtWarning():Log(formatted)
				end
			elseif p <= v10 * p2 then
				table.insert(v7, v9)
				table.insert(v8, i)
			end
		end

		if #v7 == 0 then
			return p / p2, #AssetRollScaleWeights
		end

		local v9 = random:NextInteger(1, lottery.UPGRADE_BAND_ODDS) == 1 and #v7 > 1 and 2 or 1
		v5 = {}

		for i = v9, v9 == 1 and 1 or #v7 do
			table.insert(v5, v7[i])
			table.insert(v6, v8[i])
		end
	end

	local v7 = drawWeighted(v5)
	local value2

	if v7 then
		value2 = v7.Value
	end

	local v8 = not v7 and 0 or v7.Index

	if not value2 then
		limitUnderLevel:AtError():Log("scale draw came back empty, substituting 1x")
		return 1, 1
	end

	local v9

	if typeof(value2) == "table" then
		if p and p2 then
			local v10 = value2[#value2]

			if v10 * p2 <= p then
				v9 = p / p2
			else
				v9 = random:NextNumber(p / p2, v10)
			end
		else
			v9 = value2[1]
			local v10 = value2[2]

			if v10 ~= nil then
				v9 = random:NextNumber(v9, v10)
			end
		end
	else
		v9 = value2
	end

	if v6 then
		v8 = v6[v8] or v8
	end

	return typeof(v9) ~= "number" and 1 or v9, v8
end

return AssetLottery