local import = _G.import("rankedConstants")
local import2 = _G.import("glicko2Util")
local RANK_BRACKETS = import.RANK_BRACKETS
local GLICKO = import.GLICKO

local function getLastBracketUpper()
	local v = 0

	for _, v2 in pairs(RANK_BRACKETS) do
		local v3 = v2[2]

		if not (v3 <= v) then
			v = v3
		end
	end

	return v
end

local RankUtil = {
	getOrderedBrackets = function()
		local result = {}

		for k, _ in pairs(RANK_BRACKETS) do
			table.insert(result, k)
		end

		table.sort(result, function(a, b)
			return RANK_BRACKETS[a][1] < RANK_BRACKETS[b][1]
		end)
		return result
	end
}

function RankUtil.getOrderedRankIds()
	local result = { "Unranked" }

	for _, v in ipairs(RankUtil.getOrderedBrackets()) do
		result[#result + 1] = v
	end

	result[#result + 1] = "Pro"
	return result
end

function RankUtil.getRatingFromRank(p)
	if p == "Unranked" then
		return import2.muToRating(GLICKO.MU0)
	end

	if p == "Pro" then
		local v = 0

		for _, v2 in pairs(RANK_BRACKETS) do
			local v3 = v2[2]

			if not (v3 <= v) then
				v = v3
			end
		end

		return v + 100
	else
		local v = RANK_BRACKETS[p]

		if v then
			return v[1]
		end

		return import2.muToRating(GLICKO.MU0)
	end
end

function RankUtil.getRankFromRating(value)
	if type(value) ~= "number" then
		return "Unranked"
	end

	local orderedBrackets = RankUtil.getOrderedBrackets()

	for _, orderedBracket in ipairs(orderedBrackets) do
		local v = RANK_BRACKETS[orderedBracket][1]
		local v2 = RANK_BRACKETS[orderedBracket][2]

		if v <= value and value < v2 then
			return orderedBracket
		end
	end

	return "Pro"
end

function RankUtil.getHighestRankFromModes(items, p)
	if type(items) ~= "table" then
		return "Unranked"
	end

	local v = nil

	for _, item in pairs(items) do
		if type(item) ~= "table" or (item.MatchesPlayed or 0) < p or type(item.Mu) ~= "number" then
			continue
		end

		local v2 = math.floor(import2.muToRating(item.Mu) + 0.5)

		if not v or v < v2 then
			v = v2
		end
	end

	return RankUtil.getRankFromRating(v)
end

return RankUtil