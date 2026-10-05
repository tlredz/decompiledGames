local import = _G.import("collection")
_G.import("validUtil")
local import2 = _G.import("configuration")
local RunService = game:GetService("RunService")
local _ = {
	Year = 2026,
	Month = 6
}
local v = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getTestSeasonsPassed()
	if not RunService:IsStudio() then
		return 0
	end

	local TEST_SEASON = import2.TEST_SEASON

	if not (TEST_SEASON and TEST_SEASON.Enabled) then
		return 0
	end

	local now = os.time()

	if not v2 then
		v2 = now
	end

	return (math.floor((now - v2) / TEST_SEASON.NextSeasonInSeconds))
end

local v3 = import("Stat", script)

function v3.getSeasonNumber(_)
	local v4 = os.date("*t")
	local v5 = (v4.year - 2026) * 12 + (v4.month - 6) + 1
	local testSeasonsPassed = getTestSeasonsPassed() -- equivalent call inferred; original call site unknown
	return v5 + testSeasonsPassed
end

function v3:getCurrentSeason()
	local v4 = os.date("*t")
	local year = v4.year
	local month = v4.month
	local testSeasonsPassed = getTestSeasonsPassed() -- equivalent call inferred; original call site unknown
	local v5 = month + testSeasonsPassed

	while v5 > 12 do
		v5 -= 12
		year += 1
	end

	return string.format("%04d%02d", year, v5)
end

function v3.getNextSeason(_)
	local v4 = os.date("*t")
	local year = v4.year
	local v5 = v4.month + 1
	local testSeasonsPassed = getTestSeasonsPassed() -- equivalent call inferred; original call site unknown
	local v6 = v5 + testSeasonsPassed

	while v6 > 12 do
		v6 -= 12
		year += 1
	end

	return string.format("%04d%02d", year, v6)
end

function v3:getSeasonEndDate()
	local TEST_SEASON = import2.TEST_SEASON

	if RunService:IsStudio() and TEST_SEASON and TEST_SEASON.Enabled then
		local now = os.time()
		local nextSeasonInSeconds = TEST_SEASON.NextSeasonInSeconds

		if not v or v <= now then
			v = now + nextSeasonInSeconds
		end

		return DateTime.fromUnixTimestamp(v)
	else
		local function computeEndTimestamp(year, p)
			if p > 12 then
				year += 1
				p = 1
			end

			local v4 = DateTime.fromUniversalTime(year, p, 1, 0, 0, 0, 0).UnixTimestamp - 86400

			while os.date("!*t", v4).wday ~= 7 do
				v4 -= 86400
			end

			return v4
		end

		local universalTime = DateTime.now():ToUniversalTime()
		local v4 = computeEndTimestamp(universalTime.Year, universalTime.Month + 1)

		if v4 <= os.time() then
			v4 = computeEndTimestamp(universalTime.Year, universalTime.Month + 2)
		end

		return DateTime.fromUnixTimestamp(v4)
	end
end

function v3:getSeasonTimeRemaining()
	return (math.max(0, self:getSeasonEndDate().UnixTimestamp - os.time()))
end

function v3:getSeasonData(p)
	if p then
		return p and self:get("Season" .. p)
	end

	return self:get("Season" .. self:getCurrentSeason())
end

function v3:getBattlePassRewardsByTrack(p, p2)
	local seasonData = self:getSeasonData(p2)

	if not seasonData then
		return {}
	end

	local result = {}

	for k, v4 in pairs(seasonData.BattlePass) do
		if type(k) == "number" then
			result[k] = v4[p]
		end
	end

	return result
end

function v3:getRankedRewards(p)
	local seasonData = self:getSeasonData(p)

	if seasonData then
		return seasonData.RankRewards
	end

	return {}
end

v3:require(function(_, _) end)
return v3