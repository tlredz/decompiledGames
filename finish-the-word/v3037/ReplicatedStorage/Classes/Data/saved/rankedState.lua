local import = _G.import("class")
local import2 = _G.import("global")
_G.import("dictUtil")
local import3 = _G.import("rankUtil")
local import4 = _G.import("glicko2Util")
local import5 = _G.import("rankedConstants")
local import6 = _G.import("seasonCollection")
local PLACEMENT_MATCHES = import5.PLACEMENT_MATCHES
local RANK_BRACKETS = import5.RANK_BRACKETS
local GLICKO = import5.GLICKO
local _ = {
	Win = 1,
	Loss = 0
}
local _ = {
	Completed = 1,
	Disconnected = 0
}
local v = {
	Unranked = 0,
	Bronze = 1,
	Silver = 2,
	Gold = 3,
	Diamond = 4,
	Platinum = 5,
	Pro = 6
}

local function modeKey(p)
	local v2 = ""

	for i = 1, p do
		v2 ..= "1" .. (i == p and "" or "v")
	end

	return v2
end

local v2 = import.new()

function v2.isModePlaced(p, p2)
	local modes = p.RankedData.Modes
	local v3 = ""

	for i = 1, p2 do
		v3 ..= "1" .. (i == p2 and "" or "v")
	end

	local mode = modes[v3]

	if mode then
		return PLACEMENT_MATCHES <= mode.MatchesPlayed
	else
		return false
	end
end

function v2.getPlacementMatchesLeft(p, p2)
	local modes = p.RankedData.Modes
	local v3 = ""

	for i = 1, p2 do
		v3 ..= "1" .. (i == p2 and "" or "v")
	end

	local mode = modes[v3]
	local matchesPlayed = mode and mode.MatchesPlayed or 0
	return (math.max(0, PLACEMENT_MATCHES - matchesPlayed))
end

function v2.getPublicRating(p, p2)
	local v3 = ""

	for i = 1, p2 do
		v3 ..= "1" .. (i == p2 and "" or "v")
	end

	local mode = p.RankedData.Modes[v3]

	if not mode then
		return
	end

	if mode.MatchesPlayed < PLACEMENT_MATCHES then
		return
	else
		return (math.floor(import4.muToRating(mode.Mu) + 0.5))
	end
end

function v2.getModeConservativeRating(p, p2)
	local v3 = ""

	for i = 1, p2 do
		v3 ..= "1" .. (i == p2 and "" or "v")
	end

	local mode = p.RankedData.Modes[v3]

	if not mode or (type(mode.Mu) ~= "number" or type(mode.Phi) ~= "number") then
		return
	end

	local conservativeMu = import4.conservativeMu(mode.Mu, mode.Phi)
	return import4.muToRating(conservativeMu)
end

function v2.getModeRatingData(p, p2)
	local v3 = ""

	for i = 1, p2 do
		v3 ..= "1" .. (i == p2 and "" or "v")
	end

	local mode = p.RankedData.Modes[v3]
	return {
		Mu = mode and mode.Mu or GLICKO.MU0,
		Phi = mode and mode.Phi or GLICKO.PHI0
	}
end

function v2.getRankFromRating(value)
	if type(value) ~= "number" then
		return "Unranked"
	end

	local orderedBrackets = import3.getOrderedBrackets()

	for _, orderedBracket in ipairs(orderedBrackets) do
		local v3 = RANK_BRACKETS[orderedBracket][1]
		local v4 = RANK_BRACKETS[orderedBracket][2]

		if v3 <= value and value < v4 then
			return orderedBracket
		end
	end

	return "Pro"
end

function v2.getHighestModeRank(p)
	local v3 = nil

	for _, v4 in pairs(p.RankedData.Modes._State or p.RankedData.Modes) do
		if type(v4) ~= "table" or (v4.MatchesPlayed or 0) < PLACEMENT_MATCHES then
			continue
		end

		local v5 = math.floor(import4.muToRating(v4.Mu) + 0.5)

		if not v3 or v3 < v5 then
			v3 = v5
		end
	end

	return v2.getRankFromRating(v3)
end

function v2.getRankProgress(_, value)
	if type(value) ~= "number" then
		return 0
	end

	local rankFromRating = v2.getRankFromRating(value)

	if rankFromRating == "Unranked" then
		return 0
	elseif rankFromRating == "Pro" then
		return 1
	end

	local v3 = RANK_BRACKETS[rankFromRating][1]
	local v4 = RANK_BRACKETS[rankFromRating][2]
	return (value - v3) / (v4 - v3)
end

function v2.getWinLoseRatio(p, p2)
	if p2 == nil then
		local total = 0
		local total2 = 0

		for _, v3 in p.RankedData.Modes:pairs() do
			total += v3.Wins or 0
			total2 += v3.Losses or 0
		end

		return total, total2
	else
		local v3 = ""

		for i = 1, p2 do
			v3 ..= "1" .. (i == p2 and "" or "v")
		end

		local mode = p.RankedData.Modes[v3]
		return not mode and 0 or mode.Wins or 0, mode and mode.Losses or 0
	end
end

function v2.getMatchesPlayed(p, p2)
	local modes = p.RankedData.Modes
	local v3 = ""

	for i = 1, p2 do
		v3 ..= "1" .. (i == p2 and "" or "v")
	end

	local mode = modes[v3]

	if mode then
		return mode.MatchesPlayed
	end

	return 0
end

function v2:ensureMode(p2)
	if not self.RankedData.Modes[p2] then
		self.RankedData.Modes[p2] = {
			Mu = GLICKO.MU0,
			Phi = GLICKO.PHI0,
			Sigma = GLICKO.SIGMA0,
			MatchesPlayed = 0,
			Wins = 0,
			Losses = 0
		}
	end

	return self.RankedData.Modes[p2]
end

function v2:applyGlicko2Result(p, p2, p3, p4)
	local v3 = ""

	for i = 1, p do
		v3 ..= "1" .. (i == p and "" or "v")
	end

	local mode = self:ensureMode(v3)
	local mu, phi, sigma = import4.update(mode.Mu, mode.Phi, mode.Sigma, p3, p4, p2 and 1 or 0)
	mode.Mu = mu
	mode.Phi = phi
	mode.Sigma = sigma
	mode.MatchesPlayed = (mode.MatchesPlayed or 0) + 1

	if p2 then
		mode.Wins = (mode.Wins or 0) + 1
	else
		mode.Losses = (mode.Losses or 0) + 1
	end

	if mode.MatchesPlayed == PLACEMENT_MATCHES then
		local ratingToMu = import4.ratingToMu(RANK_BRACKETS.Gold[2] - 1)
		mode.Mu = math.min(mode.Mu, ratingToMu)
	end
end

function v2.rankedReset(object, p)
	local seasonId = object.RankedData.SeasonId

	if not (seasonId ~= import6:getCurrentSeason() and seasonId) then
		return
	end

	local rankedRewards = import6:getRankedRewards(seasonId)

	if rankedRewards then
		local v3 = v[import3.getHighestRankFromModes(object.RankedData.Modes:getTable(), import5.PLACEMENT_MATCHES)] or 0
		local rankedRewards2 = {}

		for k, rankedReward in pairs(rankedRewards) do
			if type(rankedReward) ~= "string" then
				continue
			end

			local v4 = v[k]

			if not v4 or v3 < v4 then
				continue
			end

			table.insert(rankedRewards2, rankedReward)
		end

		local playerByUserId = game.Players:GetPlayerByUserId(object.UserId)

		if not playerByUserId then
			return
		end

		local playerSession = import2.get("playerSession", playerByUserId)
		object:auto_repl(true)

		for _, v4 in ipairs(rankedRewards2) do
			playerSession:award(v4)
		end

		object:auto_repl(false)
	end

	object:auto_repl(p or false)
	object.RankedData.SeasonId = import6:getCurrentSeason()
	object:auto_repl(false)
end

function v2:scheduleRankedReset()
	if self:hasTimedProcess("RankedReset") then
		return
	end

	self:timeProcess("RankedReset", import6:getSeasonTimeRemaining(), true)
end

function v2:new()
	self.RankedData = {
		Modes = {
			_Insertable = true
		},
		SeasonId = import6:getCurrentSeason()
	}
end

function v2:postShell()
	self:scheduleRankedReset()
end

return v2