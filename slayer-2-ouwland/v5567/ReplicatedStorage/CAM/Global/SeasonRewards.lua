local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resolve = require(ReplicatedStorage.CAM.Global.Powers.Resolve)
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local SeasonBoards = require(ReplicatedStorage.CAM.Global.SeasonBoards)
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local SeasonRewards = {
	Config = require(script.Config),
	PARTS = {
		"Wen",
		"Ore",
		"Item",
		"Title",
		"Zenith"
	},
	GroupOf = function(p: string)
		if Ranked.BucketOfKey(p) == nil then
			return p
		end

		return "Zenith"
	end
}

function SeasonRewards.Pays(p: string)
	return SeasonRewards.Config.Groups[SeasonRewards.GroupOf(p)] ~= nil
end

function SeasonRewards.Ready(p: number)
	local season = SeasonRewards.Config.Seasons[p]
	return season ~= nil and season.Ready == true
end

function SeasonRewards.Id(p: string, p2: number)
	return (`{p}@{p2}`)
end

function SeasonRewards.BoardOf(value: string)
	return string.match(value, "^(.+)@%d+$")
end

function SeasonRewards.Encode(p: number, data, p2)
	local formatted = `{p}:{data.Rank}:{data.Tier}:{data.Band}`
	local v = {}

	for _, v2 in SeasonRewards.PARTS do
		if p2 ~= nil and p2[v2] then
			table.insert(v, v2)
		end
	end

	if #v > 0 then
		return (`{formatted}|{table.concat(v, ",")}`)
	end

	return formatted
end

function SeasonRewards.Decode(value: string)
	local result = {}
	local v, v2, v3, v4, v5 = string.match(value, "^(%d+):(%d+):(%d+):(%d+)(.*)$")

	if v == nil or v5 ~= "" and string.sub(v5, 1, 1) ~= "|" then
		return nil, nil, result
	end

	for k in string.gmatch(string.sub(v5, 2), "[^,]+") do
		result[k] = true
	end

	return tonumber(v), {
		Rank = tonumber(v2),
		Tier = tonumber(v3),
		Band = tonumber(v4)
	}, result
end

function SeasonRewards.Owed(p, p2)
	local result = {
		Place = p.Place,
		Board = p.Board
	}
	local flag = false

	for _, v in SeasonRewards.PARTS do
		local v2 = p[v]

		if v2 == nil or p2[v] then
			continue
		end

		result[v] = v2
		flag = true
	end

	if flag then
		return result
	end

	return nil
end

local function reaches(item, p: number, p2: number, p3: number, p4, p5)
	if item.Rank ~= nil and p > 0 and p <= item.Rank then
		return true
	end

	if item.Percent == nil or math.ceil(p3 * item.Percent / 100) <= (item.Rank or 0) then
		return false
	end

	local cutoffFrom = Ranked.Rules.CutoffFrom(p5, p4.Dist, item.Percent)
	return cutoffFrom ~= nil and cutoffFrom <= p2
end

local function first(items, p: number, p2: number, p3: number, p4, knobs)
	if items == nil then
		return 0
	end

	for k, item in items do
		if reaches(item, p, p2, p3, p4, knobs) then
			return k
		end
	end

	return 0
end

function SeasonRewards.BandItem(p, p2, p3: string)
	local demon

	if Resolve.Resolve(p3) == "DemonArt" then
		demon = p2.Demon
	else
		demon = p2.Slayer
	end

	local selected

	if p.Items ~= nil then
		selected = p.Items[demon]
	end

	if type(selected) == "table" then
		return selected[p3]
	end

	return selected
end

function SeasonRewards.Payout(p: string, p2: number, data)
	local group = SeasonRewards.GroupOf(p)
	local v = SeasonRewards.Config.Groups[group] or {}
	local season = SeasonRewards.Config.Seasons[p2]
	local v2 = season == nil and {} or season[group] or {}
	local kind = SeasonBoards.KindOf(p)
	local v3 = not (data.Rank > 0) and "" or ` #{data.Rank}`
	local v4 = data.Rank > 0 and data.Rank <= 10 and "Top10" or data.Rank > 0 and "Top100" or "Share"
	local v5 = {
		Place = not (data.Rank > 0) and "" or `#{data.Rank}`,
		Board = 0
	}
	local board

	if kind == nil then
		board = p
	else
		board = kind.Title(p)
	end

	v5.Board = board
	local v7

	if v.Tiers ~= nil then
		v7 = v.Tiers[data.Tier]
	end

	if v7 ~= nil then
		v5.Wen = v7.Wen
		v5.Ore = v7.Ore

		if data.Rank > 0 or v2.ItemShare == true then
			v5.Item = v2.Item
		end

		if v2.Title ~= nil then
			v5.Title = Titles.SeasonId(v4, group, (`Season {p2} {v2.Title}{v3}`))
		end
	end

	local v8

	if v.Titles ~= nil then
		v8 = v.Titles[data.Band]
	end

	local bucketOfKey = Ranked.BucketOfKey(p)

	if v8 ~= nil and bucketOfKey ~= nil then
		local v9

		if Resolve.Resolve(bucketOfKey) == "DemonArt" then
			v9 = v8.Demon
		else
			v9 = v8.Slayer
		end

		v5.Zenith = Titles.SeasonId(v4, bucketOfKey, (`Season {p2} {bucketOfKey} {v9}{v3}`))
		v5.Item = SeasonRewards.BandItem(v2, v8, bucketOfKey) or v5.Item
	end

	if data.Rank == 0 then
		v5.Place = `top {math.min(v7 == nil and 100 or v7.Percent or 100, v8 == nil and 100 or v8.Percent or 100)}%`
	end

	return v5
end

function SeasonRewards.Previews()
	local number = SeasonBoards.Kinds.PvP.Number(Ranked.Season())
	local season = SeasonRewards.Config.Seasons[number]
	local v = {}

	if season == nil then
		return v
	end

	local function add(p: string, p2: string, displayName: string, description: string)
		local seasonId = Titles.SeasonId(p, p2, displayName)
		local v2 = Titles.Get(seasonId)

		if v2 == nil then
			return
		end

		table.insert(v, {
			Id = seasonId,
			Def = {
				displayName = displayName,
				description = description,
				category = "Ranked",
				rarity = v2.rarity,
				requirements = {},
				buffs = v2.buffs,
				collection = v2.collection,
				disabled = false
			}
		})
	end

	for k, v2 in season do
		local kind = SeasonBoards.KindOf(k)

		if type(v2) == "table" and v2.Title ~= nil and kind ~= nil then
			add(
				"Top10",
				k,
				`Season {number} {v2.Title}`,
				`Finish Season {number} in the top 100 of {kind.Title(k)} to earn it with your place. The stats shown are the top 10's.`
			)
		end
	end

	local zenith = SeasonRewards.Config.Groups.Zenith
	local rank = 0

	for k, v2 in zenith == nil and {} or zenith.Titles or {} do
		local v3 = k == 1 and "Top10" or "Top100"
		local v4

		if rank == 0 then
			v4 = `the top {v2.Rank}`
		else
			v4 = `places {rank + 1}-{v2.Rank}`
		end

		for _, v5 in {
			{ v2.Slayer, "Breathing" },
			{ v2.Demon, "Demon Art" }
		} do
			add(
				v3,
				"Zenith",
				`Season {number} {v5[1]}`,
				`Finish Season {number} in {v4} of your {v5[2]}'s Zenith ladder (the top {v2.Percent}% on a big one) to earn it with your style and place.`
			)
		end

		rank = v2.Rank or rank
	end

	table.sort(v, function(a, b)
		return a.Id < b.Id
	end)
	return v
end

function SeasonRewards.Judge(p: string, p2: number, p3: number?, p4)
	local group = SeasonRewards.Config.Groups[SeasonRewards.GroupOf(p)]
	local kind = SeasonBoards.KindOf(p)

	if group == nil or kind == nil or p3 == nil then
		return nil
	end

	local v = math.max(Ranked.Rules.Population(p4.Dist), #p4.Top)

	if v < SeasonRewards.Config.MinPlayers then
		return nil
	end

	local rank = 0

	for k, v4 in p4.Top do
		if v4.UserId ~= p2 then
			continue
		end

		rank = k
		break
	end

	if rank == 0 then
		local count = 0

		for _, v4 in p4.Top do
			if p3 <= v4.Score then
				count += 1
			end
		end

		if count < 100 then
			rank = count + 1
		else
			rank = 0
		end
	end

	local knobs = kind.Knobs()
	local v4 = {
		Rank = rank,
		Tier = first(group.Tiers, rank, p3, v, p4, knobs),
		Band = first(group.Titles, rank, p3, v, p4, knobs)
	}

	if v4.Tier == 0 and v4.Band == 0 then
		return nil
	end

	return v4
end

return SeasonRewards