local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function erf(p: number)
	local v = p < 0 and -1 or 1
	local v2 = math.abs(p)
	local v3 = 1 / (v2 * 0.3275911 + 1)
	return v * (1 - ((((v3 * 1.061405429 - 1.453152027) * v3 + 1.421413741) * v3 - 0.284496736) * v3 + 0.254829592) * v3 * math.exp(-v2 * v2))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function orderedKey(p: number, p2: string)
	return string.format("%03d %s", math.clamp(math.floor(p), 0, 999), p2)
end

local function hueColor(p: number, p2: number)
	return Color3.fromHSV((p - 1) / math.max(1, p2) % 1, 0.55, 0.95)
end

local function fillItemKeys(data, items, p)
	local v = {}
	local itemIds = {}
	local v2 = {}
	local count = 0

	for _, item in items do
		if not (p == nil or item.Rarity == p) then
			continue
		end

		if #v >= 24 then
			table.insert(itemIds, item.ItemId)
		else
			table.insert(v, item)

			if not v2[item.Rarity] then
				v2[item.Rarity] = true
				count += 1
			end
		end
	end

	local v3 = count > 1

	for k, v4 in v do
		local v5 = orderedKey(k, v4.Label) -- equivalent call inferred; original call site unknown
		data.Labels[v5] = v4.Label
		local colors = data.Colors
		local color

		if v3 then
			color = v4.Color:Lerp(Color3.new(1, 1, 1), (k - 1) % 5 * 0.12)
		else
			local v6 = #v
			color = Color3.fromHSV((k - 1) / math.max(1, v6) % 1, 0.55, 0.95)
		end

		colors[v5] = color
		data.ItemIds[v5] = { v4.ItemId }

		if v4.Sprite ~= nil then
			data.Icons[v5] = v4.Sprite
		end

		table.insert(data.Keys, v5)
	end

	if #itemIds > 0 then
		data.Labels["zzz Other"] = `Other ({#itemIds})`
		data.Colors["zzz Other"] = Color3.fromRGB(120, 120, 120)
		data.ItemIds["zzz Other"] = itemIds
		table.insert(data.Keys, "zzz Other")
	end
end

local Analysis = {
	Z_95 = 1.959964,
	OTHER_KEY = "zzz Other",
	normalTail = function(p: number)
		return (1 - erf(p / 1.4142135623730951)) * 0.5
	end,
	formatChance = function(p: number)
		local v = p * 100

		if v >= 10 then
			return string.format("%.1f%%", v)
		end

		if v >= 1 then
			return string.format("%.2f%%", v)
		end

		if v >= 0.01 then
			return string.format("%.3f%%", v)
		end

		if v > 0 then
			return string.format("%.4f%%", v)
		end

		return "0%"
	end,
	formatOdds = function(p: number)
		if p <= 1e-12 then
			return "never"
		end

		local v = 1 / p

		if v >= 1000 then
			return string.format("1 in %.0f", v)
		end

		return string.format("1 in %.1f", v)
	end,
	buildPool = function(boxName, items, callback, callback2)
		local entries = {}
		local byId = {}
		local v3 = {}

		for k, item in items do
			local label, rarity = callback(k)
			local v6 = RarityUtil.tryGetRarity(rarity)
			local v7 = {
				ItemId = k,
				Label = label,
				Rarity = rarity,
				RarityValue = not v6 and 0 or v6.Value,
				BaseChance = item,
				Sprite = callback2(k),
				Color = 0
			}
			local color

			if v6 then
				color = v6.Color
			else
				color = Color3.new(1, 1, 1)
			end

			v7.Color = color
			table.insert(entries, v7)
			byId[k] = v7
			v3[rarity] = true
		end

		table.sort(entries, function(a, b)
			if a.BaseChance == b.BaseChance then
				return a.ItemId < b.ItemId
			end

			return a.BaseChance > b.BaseChance
		end)
		local rarities = {}

		for k in v3 do
			table.insert(rarities, k)
		end

		table.sort(rarities, function(a, b)
			local v5 = RarityUtil.tryGetRarity(a)
			local v6 = RarityUtil.tryGetRarity(b)
			return (not v5 and 0 or v5.Value) < (not v6 and 0 or v6.Value)
		end)
		return {
			BoxName = boxName,
			Entries = entries,
			ById = byId,
			Rarities = rarities,
			SolvedAt = os.clock()
		}
	end,
	buildSeries = function(p, p2, flag: boolean?)
		local v = flag ~= false
		local v2 = {
			Keys = {},
			Labels = {},
			Colors = {},
			Icons = {},
			ItemIds = {},
			Rarity = {},
			IsDrilled = not v or p2 ~= nil
		}

		if v and p2 == nil then
			for _, rarity in p.Rarities do
				local v3 = RarityUtil.tryGetRarity(rarity)
				local v5 = orderedKey(not v3 and 0 or v3.Value, rarity) -- equivalent call inferred; original call site unknown
				v2.Labels[v5] = rarity
				local colors = v2.Colors
				local v6

				if v3 then
					v6 = v3.Color
				else
					v6 = Color3.new(1, 1, 1)
				end

				colors[v5] = v6
				v2.ItemIds[v5] = {}
				v2.Rarity[v5] = rarity
				table.insert(v2.Keys, v5)
			end

			for _, entry in p.Entries do
				local v3 = RarityUtil.tryGetRarity(entry.Rarity)
				local v5 = orderedKey(not v3 and 0 or v3.Value, entry.Rarity) -- equivalent call inferred; original call site unknown
				local itemIds = v2.ItemIds[v5]

				if itemIds == nil then
					continue
				end

				table.insert(itemIds, entry.ItemId)

				if v2.Icons[v5] == nil and entry.Sprite ~= nil then
					v2.Icons[v5] = entry.Sprite
				end
			end

			return v2
		else
			local entries = p.Entries

			if not v then
				p2 = nil
			end

			fillItemKeys(v2, entries, p2)
			return v2
		end
	end,
	aggregate = function(p, p2)
		local result = {}

		for _, key in p.Keys do
			local total = 0

			for _, v in p.ItemIds[key] do
				total += p2[v] or 0
			end

			result[key] = total
		end

		return result
	end
}

function Analysis.outcomes(p, data)
	local v = math.max(1, data.RollsDone)
	local total = 0
	local count = 0
	local count2 = 0
	local result = {}
	local count3 = 0

	for _, entry in p.Entries do
		local expected = data.BaseChances[entry.ItemId] or 0
		local count4 = data.Counts[entry.ItemId] or 0
		local bonusCount = data.BonusCounts[entry.ItemId] or 0
		local observed = count4 / v
		local v6 = 0

		if expected > 0 then
			local v7 = expected * (1 - expected) / v
			v6 = (observed - expected) / math.sqrt((math.max(v7, 1e-12)))
		elseif count4 > 0 then
			count3 += 1
		end

		local v7 = (count4 + 1.920729440648) / (v + 3.841458881296)
		local v8 = 1.959964 / (v + 3.841458881296) * math.sqrt(count4 * (v - count4) / v + 0.960364720324)
		local low = math.max(0, v7 - v8)
		local high = math.min(1, v7 + v8)
		local inRange

		if low <= expected then
			inRange = expected <= high
		else
			inRange = false
		end

		if expected > 0 then
			local v12 = expected * v
			total += (count4 - v12) ^ 2 / v12
			count += 1

			if inRange then
				count2 += 1
			end
		end

		table.insert(result, {
			ItemId = entry.ItemId,
			Label = entry.Label,
			Rarity = entry.Rarity,
			Expected = expected,
			Observed = observed,
			Count = count4,
			BonusCount = bonusCount,
			Delta = observed - expected,
			Ratio = not (expected > 1e-12) and 0 or observed / expected,
			Z = v6,
			Low = low,
			High = high,
			InRange = inRange
		})
	end

	local degreesOfFreedom = math.max(1, count - 1)
	local v3 = ((total / degreesOfFreedom) ^ 0.3333333333333333 - (1 - 2 / (degreesOfFreedom * 9))) / math.sqrt(2 / (degreesOfFreedom * 9))
	return result, {
		ChiSquare = total,
		DegreesOfFreedom = degreesOfFreedom,
		PValue = math.clamp(Analysis.normalTail(v3), 0, 1),
		InRange = count2,
		Total = count,
		Unexpected = count3
	}
end

function Analysis.expectedObserved(p, data)
	local v = math.max(1, data.RollsDone)
	local v2 = {}

	for k, count in data.Counts do
		v2[k] = count / v
	end

	local aggregated = Analysis.aggregate(p, data.BaseChances)
	local aggregated2 = Analysis.aggregate(p, v2)
	local result = {}
	local expected = {}
	local observed = {}

	for _, key in p.Keys do
		table.insert(result, p.Labels[key] or key)
		table.insert(expected, (aggregated[key] or 0) * 100)
		table.insert(observed, (aggregated2[key] or 0) * 100)
	end

	return {
		Expected = expected,
		Observed = observed
	}, result
end

function Analysis.calibrationPoints(p, data)
	local v = math.max(1, data.RollsDone)
	local result = {}

	for _, key in p.Keys do
		local vectors = {}

		for _, v2 in p.ItemIds[key] do
			local v3 = (data.BaseChances[v2] or 0) * 100
			local v4 = (data.Counts[v2] or 0) / v * 100

			if v3 > 0 then
				table.insert(vectors, Vector2.new(v3, v4))
			end
		end

		if #vectors > 0 then
			result[key] = vectors
		end
	end

	return result
end

function Analysis.batchSamples(p, p2)
	local v = 0
	local result = {}

	for _, batchRate in p2.BatchRates do
		v = math.max(v, #batchRate)
	end

	if v == 0 then
		return result
	end

	for _, key in p.Keys do
		local v2 = table.create(v)

		for i = 1, v do
			local total = 0

			for _, v3 in p.ItemIds[key] do
				local batchRate = p2.BatchRates[v3]
				total += not batchRate and 0 or batchRate[i] or 0
			end

			table.insert(v2, total * 100)
		end

		result[key] = v2
	end

	return result
end

function Analysis.journey(p, p2)
	local pulls = table.create(#p2.Snapshots)
	local result = {}

	for _, key in p.Keys do
		result[key] = table.create(#p2.Snapshots)
	end

	for _, snapshot in p2.Snapshots do
		table.insert(pulls, snapshot.Pull)

		for _, key in p.Keys do
			local total = 0

			for _, v in p.ItemIds[key] do
				total += snapshot.Chances[v] or 0
			end

			table.insert(result[key], total * 100)
		end
	end

	for k, v in result do
		if #v == 0 then
			result[k] = nil
		end
	end

	return result, pulls
end

function Analysis.gaps(p, p2: number)
	local hit = p.Hits[p2]

	if hit == nil or #hit == 0 then
		return {}
	end

	local result = table.create(#hit)
	local v = 0

	for _, v2 in hit do
		table.insert(result, v2 - v)
		v = v2
	end

	return result
end

function Analysis.chanceTree(p, p2)
	local children = {}

	for _, rarity in p.Rarities do
		local v2 = RarityUtil.tryGetRarity(rarity)
		local color

		if v2 then
			color = v2.Color
		else
			color = Color3.new(1, 1, 1)
		end

		children[rarity] = {
			Label = rarity,
			Color = color,
			Children = {}
		}
	end

	for _, entry in p.Entries do
		local v2 = p2[entry.ItemId]

		if v2 == nil or v2 <= 0 then
			continue
		end

		local v3 = children[entry.Rarity]

		if v3 ~= nil then
			v3.Children[entry.Label] = {
				Value = v2 * 100,
				Label = entry.Label,
				Icon = entry.Sprite,
				Color = entry.Color
			}
		end
	end

	for k, v2 in children do
		if next(v2.Children) == nil then
			children[k] = nil
		end
	end

	return {
		Children = children
	}
end

function Analysis.scenarioSeries(p, items)
	local result = {}

	for _, key in p.Keys do
		table.insert(result, p.Labels[key] or key)
	end

	local result2 = {}
	local colors = {}

	for k, item in items do
		local v = orderedKey(k, item.Name) -- equivalent call inferred; original call site unknown
		local aggregated = Analysis.aggregate(p, item.Chances)
		local v2 = table.create(#p.Keys)

		for _, key in p.Keys do
			table.insert(v2, (aggregated[key] or 0) * 100)
		end

		result2[v] = v2
		colors[v] = item.Color
	end

	return result2, result, colors
end

function Analysis.scenarioLabels(items)
	local names = {}

	for k, item in items do
		local name = item.Name
		names[string.format("%03d %s", math.clamp(math.floor(k), 0, 999), name)] = item.Name
	end

	return names
end

return Analysis