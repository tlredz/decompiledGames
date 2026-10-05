local Rules = {}
local v = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}
local v2 = {
	31,
	28,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31
}

local function daysIn(p: number, p2: number)
	if p2 == 2 and p % 4 == 0 and (p % 100 ~= 0 or p % 400 == 0) then
		return 29
	end

	return v2[p2]
end

function Rules.Season(p: number?)
	local v3 = os.date("!*t", p or os.time())
	return string.format("%04d-%02d", v3.year, v3.month)
end

function Rules.Previous(value: string)
	local v3, v4 = string.match(value, "^(%d+)%-(%d+)$")
	local v5 = tonumber(v3)
	local v6 = tonumber(v4)

	if v6 == 1 then
		return string.format("%04d-%02d", v5 - 1, 12)
	end

	return string.format("%04d-%02d", v5, v6 - 1)
end

function Rules.SeasonLabel(value: string)
	local v3, v4 = string.match(value, "^(%d+)%-(%d+)$")
	local v5 = v[tonumber(v4) or 0]

	if v5 == nil then
		return value
	end

	return (`{v5} {v3}`)
end

function Rules.SeasonEnds(p: number?)
	local v3 = p or os.time()
	local v4 = os.date("!*t", v3)
	local v5 = v3 - ((v4.day - 1) * 86400 + v4.hour * 3600 + v4.min * 60 + v4.sec)
	local year = v4.year
	local month = v4.month
	return v5 + (month == 2 and year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) and 29 or v2[month]) * 86400
end

function Rules.Display(p, p2: number)
	return p.DisplayBase + (p2 - 25) * p.DisplayScale
end

function Rules.TierOf(p, p2: number)
	local tiers = p.Tiers
	local v3 = 1

	for k, tier in tiers do
		if tier.Threshold <= p2 then
			v3 = k
		else
			break
		end
	end

	return v3, tiers[v3]
end

function Rules.PointsFor(p, p2: number)
	local tiers = p.Tiers
	local v3 = 1

	for k, tier in tiers do
		if p.PlacementCapTier < k then
			break
		end

		if tier.Anchor <= p2 then
			v3 = k
		end
	end

	return tiers[v3].Threshold
end

function Rules.Floor(p, p2: number)
	local v3 = math.min(p2, p.FloorTierMax)

	if v3 < 1 then
		return 0
	end

	return p.Tiers[v3].Threshold
end

function Rules.Placed(p, p2)
	return p2.Placements >= p.PlacementCount
end

function Rules.Delta(data, p, p2: string, p3: number)
	if p2 == "Draw" then
		return 0
	elseif p2 == "Dodge" then
		return -data.DodgePoints
	end

	local _, v3 = Rules.TierOf(data, p.Points)
	local v4 = math.clamp((Rules.Display(data, p.Mu) - v3.Anchor) / data.GapScale, -1, 1)
	local v5 = 1 - p3 * 2

	if p2 == "Win" then
		return (math.round(data.WinPoints * (data.GapBonus * v4 + 1) * (data.OddsBonus * v5 + 1)))
	end

	return -math.round(data.LossPoints * (1 - data.GapBonus * v4) * (1 - data.OddsBonus * v5))
end

function Rules.Apply(p, data, p2: string, mu: number, sigma: number, p5: number)
	local v3 = {
		Mu = mu,
		Sigma = sigma,
		Points = data.Points,
		Placements = data.Placements + 1,
		Peak = data.Peak
	}
	local points = 0
	local v4 = false

	if Rules.Placed(p, data) then
		local v5 = p2 == "Dodge" and 0 or Rules.Floor(p, data.Peak)
		v3.Points = math.max(data.Points + Rules.Delta(p, data, p2, p5), v5)
		points = v3.Points - data.Points
	elseif Rules.Placed(p, v3) then
		v3.Points = Rules.PointsFor(p, Rules.Display(p, mu - p.PlacementConfidence * sigma))
		points = v3.Points
		v4 = true
	end

	local tier = Rules.TierOf(p, v3.Points)
	v3.Peak = math.max(data.Peak, tier)
	return v3, points, v4
end

function Rules.Bucket(p, p2: number)
	return (math.clamp(math.floor(p2 / p.HistogramBucket) + 1, 1, p.HistogramBuckets))
end

function Rules.Population(items)
	local total = 0

	for _, item in items do
		total += item
	end

	return total
end

function Rules.CutoffFrom(p, list, p2: number)
	local population = Rules.Population(list)

	if population <= 0 or p2 <= 0 then
		return nil
	end

	local v3 = math.max(1, (math.ceil(population * p2 / 100)))
	local total = 0

	for i = #list, 1, -1 do
		local v4 = list[i]

		if v4 > 0 and v3 <= total + v4 then
			local v5 = (i - 1) * p.HistogramBucket

			if i ~= #list then
				return (math.floor(v5 + (1 - (v3 - total) / v4) * p.HistogramBucket))
			end

			if v4 == v3 then
				return v5
			end

			return nil
		else
			total += v4
		end
	end

	return 0
end

function Rules.ShareAbove(p, list, p2: number)
	local population = Rules.Population(list)

	if population <= 0 then
		return nil
	end

	local bucket = Rules.Bucket(p, p2)
	local v3 = list[bucket] / 2

	for i = #list, bucket + 1, -1 do
		v3 += list[i]
	end

	return (math.clamp(math.ceil(v3 / population * 100), 1, 100))
end

function Rules.ParseRecent(value: string)
	local result = {}

	for k, v3 in string.gmatch(value or "", "(%d+)@(%d+)") do
		table.insert(result, {
			UserId = tonumber(k),
			Time = tonumber(v3)
		})
	end

	return result
end

function Rules.SerializeRecent(items)
	local v3 = {}

	for _, item in items do
		table.insert(v3, (`{item.UserId}@{item.Time}`))
	end

	return table.concat(v3, ";")
end

function Rules.PruneRecent(p, items, p2: number)
	local result = {}

	for _, item in items do
		if p2 - item.Time < p.RepeatWindow then
			table.insert(result, item)
		end
	end

	return result
end

function Rules.Dampened(p, items, list, p2: number)
	if #list == 0 then
		return false
	end

	local v3 = {}

	for _, item in items do
		if p2 - item.Time < p.RepeatWindow then
			v3[item.UserId] = (v3[item.UserId] or 0) + 1
		end
	end

	for _, v4 in list do
		if (v3[v4] or 0) < p.RepeatLimit then
			return false
		end
	end

	return true
end

function Rules.Margin(data, p: number, p2: number)
	return (math.min(
		data.MarginBase + data.MarginStep * math.floor(p / data.MarginStepTime) + data.MarginStep * p2,
		data.MarginCap
	))
end

return Rules