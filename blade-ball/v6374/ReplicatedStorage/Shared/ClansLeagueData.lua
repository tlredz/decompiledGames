local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = game.GameId ~= 4777817887
local ClansLeagueData = {
	INITIAL_MMR = 1500,
	INITIAL_ELO = 1500,
	MAX_MONTHLY_ADJUSTMENT = 1500,
	MAX_MATCHES_PER_WEEK = 5,
	MAX_PLAYERS = 5,
	QUEUE_CYCLE_DURATION = 480,
	QUEUE_OPEN_DURATION = 120,
	MIN_TIME_IN_CLAN_TO_PLAY = 604800,
	K_FACTOR = 90,
	PLAYERS_PER_PARTY = v2 and 2 or 5,
	IS_TEST_SERVER = v2,
	RANKS = {
		{
			name = "Bronze 1",
			minElo = 0,
			maxElo = 1999,
			icon = "rbxassetid://90730802610275",
			partition = "BRONZE",
			reward = v.createClanPointsReward(2140, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(2140, "rbxassetid://15584529840"),
				v.createClanPointsReward(2050, "rbxassetid://15584529840"),
				v.createClanPointsReward(1970, "rbxassetid://15584529840"),
				(v.createClanPointsReward(1880, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Bronze 2",
			minElo = 2000,
			maxElo = 2999,
			icon = "rbxassetid://137082378013668",
			partition = "BRONZE",
			reward = v.createClanPointsReward(2780, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(2780, "rbxassetid://15584529840"),
				v.createClanPointsReward(2700, "rbxassetid://15584529840"),
				v.createClanPointsReward(2520, "rbxassetid://15584529840"),
				(v.createClanPointsReward(2520, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Bronze 3",
			minElo = 3000,
			maxElo = 3999,
			icon = "rbxassetid://72525008262164",
			partition = "BRONZE",
			reward = v.createClanPointsReward(3420, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(3420, "rbxassetid://15584529840"),
				v.createClanPointsReward(3340, "rbxassetid://15584529840"),
				v.createClanPointsReward(3170, "rbxassetid://15584529840"),
				(v.createClanPointsReward(3170, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Silver 1",
			minElo = 4000,
			maxElo = 5999,
			icon = "rbxassetid://72525008262164",
			partition = "SILVER",
			reward = v.createClanPointsReward(4280, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(4280, "rbxassetid://15584529840"),
				v.createClanPointsReward(4200, "rbxassetid://15584529840"),
				v.createClanPointsReward(4020, "rbxassetid://15584529840"),
				(v.createClanPointsReward(4020, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Silver 2",
			minElo = 6000,
			maxElo = 6999,
			icon = "rbxassetid://112237026222776",
			partition = "SILVER",
			reward = v.createClanPointsReward(5350, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(5350, "rbxassetid://15584529840"),
				v.createClanPointsReward(5270, "rbxassetid://15584529840"),
				v.createClanPointsReward(5100, "rbxassetid://15584529840"),
				(v.createClanPointsReward(5100, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Silver 3",
			minElo = 7000,
			maxElo = 7999,
			icon = "rbxassetid://112237026222776",
			partition = "SILVER",
			reward = v.createClanPointsReward(6420, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(6420, "rbxassetid://15584529840"),
				v.createClanPointsReward(6340, "rbxassetid://15584529840"),
				v.createClanPointsReward(6170, "rbxassetid://15584529840"),
				(v.createClanPointsReward(6170, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Gold 1",
			minElo = 8000,
			maxElo = 8999,
			icon = "rbxassetid://89822176096499",
			partition = "GOLD",
			reward = v.createClanPointsReward(7710, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(7710, "rbxassetid://15584529840"),
				v.createClanPointsReward(7620, "rbxassetid://15584529840"),
				v.createClanPointsReward(7450, "rbxassetid://15584529840"),
				(v.createClanPointsReward(7450, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Gold 2",
			minElo = 9000,
			maxElo = 9999,
			icon = "rbxassetid://89822176096499",
			partition = "GOLD",
			reward = v.createClanPointsReward(9000, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(9000, "rbxassetid://15584529840"),
				v.createClanPointsReward(8910, "rbxassetid://15584529840"),
				v.createClanPointsReward(8740, "rbxassetid://15584529840"),
				(v.createClanPointsReward(8740, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Gold 3",
			minElo = 10000,
			maxElo = 11999,
			icon = "rbxassetid://89822176096499",
			partition = "GOLD",
			reward = v.createClanPointsReward(10280, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(10280, "rbxassetid://15584529840"),
				v.createClanPointsReward(10200, "rbxassetid://15584529840"),
				v.createClanPointsReward(10020, "rbxassetid://15584529840"),
				(v.createClanPointsReward(10020, "rbxassetid://15584529840"))
			}
		},
		{
			name = "Blademaster",
			minElo = 12000,
			maxElo = 1e999,
			icon = "rbxassetid://116354921667199",
			partition = "BM",
			reward = v.createClanPointsReward(12000, "rbxassetid://15584529840"),
			rewards = {
				v.createClanPointsReward(12000, "rbxassetid://15584529840"),
				v.createClanPointsReward(11820, "rbxassetid://15584529840"),
				v.createClanPointsReward(11740, "rbxassetid://15584529840"),
				(v.createClanPointsReward(11740, "rbxassetid://15584529840"))
			}
		}
	}
}

function ClansLeagueData.calculateMMR(p: number, p2: number, flag: boolean)
	local v3 = 1 / (10 ^ ((p2 - p) / 400) + 1)
	return (math.round(p + ClansLeagueData.K_FACTOR * ((flag and 1 or 0) - v3)))
end

function ClansLeagueData.getClanMMRAdjustment(p: number, p2: number)
	return (math.clamp(p - p2, -ClansLeagueData.MAX_MONTHLY_ADJUSTMENT, ClansLeagueData.MAX_MONTHLY_ADJUSTMENT))
end

function ClansLeagueData.getLastSaturdayOfMonthTimestamp(p: number?, p2: number?)
	local universalTime = DateTime.now():ToUniversalTime()
	local v3 = p2 or universalTime.Year
	local v4 = (p or universalTime.Month) + 1

	if v4 > 12 then
		v3 += 1
		v4 = 1
	end

	local v5 = DateTime.fromUniversalTime(v3, v4, 1, 16).UnixTimestamp - 86400
	local v6 = v5 - (assert((tonumber(os.date("%w", v5)))) - 6 + 7) % 7 * 86400
	return DateTime.fromUnixTimestamp(v6).UnixTimestamp
end

function ClansLeagueData.getNextMondayAfterLastSaturday(p: number?, p2: number?)
	return ClansLeagueData.getLastSaturdayOfMonthTimestamp(p, p2) + 172800
end

ClansLeagueData.FIRST_SEASON_TIMESTAMP = ClansLeagueData.getLastSaturdayOfMonthTimestamp(3, 2025)

function ClansLeagueData.getCurrentSeason()
	local unixTimestamp = DateTime.now().UnixTimestamp

	if unixTimestamp < ClansLeagueData.FIRST_SEASON_TIMESTAMP then
		return 0
	end

	local universalTime = DateTime.fromUnixTimestamp(ClansLeagueData.FIRST_SEASON_TIMESTAMP):ToUniversalTime()
	local year = universalTime.Year
	local month = universalTime.Month
	local universalTime2 = DateTime.fromUnixTimestamp(unixTimestamp):ToUniversalTime()
	local year2 = universalTime2.Year
	local month2 = universalTime2.Month
	local v3 = (year2 - year) * 12 + (month2 - month) + 1
	local lastSaturdayOfMonthTimestamp = ClansLeagueData.getLastSaturdayOfMonthTimestamp(month2, year2)

	if lastSaturdayOfMonthTimestamp < unixTimestamp and lastSaturdayOfMonthTimestamp + 172800 <= unixTimestamp then
		return v3 + 1
	end

	return v3
end

function ClansLeagueData.getCurrentSeasonBoundaries()
	local currentSeason = ClansLeagueData.getCurrentSeason()
	local universalTime = DateTime.fromUnixTimestamp(ClansLeagueData.FIRST_SEASON_TIMESTAMP):ToUniversalTime()
	local year = universalTime.Year
	local month = universalTime.Month

	for _ = 1, currentSeason - 1 do
		month += 1

		if not (month > 12) then
			continue
		end

		year += 1
		month = 1
	end

	local lastSaturdayOfMonthTimestamp = ClansLeagueData.getLastSaturdayOfMonthTimestamp(month, year)
	local v3 = month - 1

	if v3 < 1 then
		year -= 1
		v3 = 12
	end

	return ClansLeagueData.getLastSaturdayOfMonthTimestamp(v3, year) + 172800, lastSaturdayOfMonthTimestamp
end

function ClansLeagueData.isInSeasonTransitionPeriod()
	local unixTimestamp = DateTime.now().UnixTimestamp
	local _, v3 = ClansLeagueData.getCurrentSeasonBoundaries()
	return v3 < unixTimestamp and unixTimestamp < v3 + 172800
end

function ClansLeagueData.getCurrentSeasonStartTimestamp()
	local currentSeasonBoundaries, _ = ClansLeagueData.getCurrentSeasonBoundaries()
	return currentSeasonBoundaries
end

function ClansLeagueData.getCurrentSeasonEndTimestamp()
	local _, v3 = ClansLeagueData.getCurrentSeasonBoundaries()
	return v3
end

function ClansLeagueData.isQueueOpen()
	if v2 then
		return true
	end

	if ClansLeagueData.isInSeasonTransitionPeriod() then
		return false
	end

	local universalTime = DateTime.now():ToUniversalTime()
	return (universalTime.Hour * 60 + universalTime.Minute) % 480 >= 360
end

function ClansLeagueData.getTimeRemainingUntilQueueOpens()
	local now = DateTime.now()

	if ClansLeagueData.isInSeasonTransitionPeriod() then
		local _, v3 = ClansLeagueData.getCurrentSeasonBoundaries()
		return v3 + 172800 - now.UnixTimestamp
	end

	local universalTime = now:ToUniversalTime()
	local v3 = (universalTime.Hour * 60 * 60 + universalTime.Minute * 60 + universalTime.Second) % 28800

	if v3 >= 21600 then
		return 28800 - v3 + 0
	end

	return 21600 - v3
end

function ClansLeagueData.getClanMatchmakingPartition(p: number)
	for _, v3 in ClansLeagueData.RANKS do
		if v3.minElo <= p and p <= v3.maxElo then
			return v3.partition
		end
	end

	return "BRONZE"
end

function ClansLeagueData.getEmblemFromElo(p: number)
	for _, v3 in ClansLeagueData.RANKS do
		if v3.minElo <= p and p <= v3.maxElo then
			return v3.icon
		end
	end

	return ClansLeagueData.RANKS[1].icon
end

function ClansLeagueData.getClanRank(p: number)
	local v3 = math.max(p, ClansLeagueData.RANKS[1].minElo)

	for k, v4 in ClansLeagueData.RANKS do
		if v4.minElo <= v3 and v3 <= v4.maxElo then
			return v4, k
		end
	end

	return ClansLeagueData.RANKS[1], 1
end

function ClansLeagueData.getClanRankRewardFor(p, p2)
	local currentSeason = ClansLeagueData.getCurrentSeason()
	local clanLeagueKills = p.clanLeagueKills
	local v3

	if p.leagues then
		v3 = p.leagues.elo
	else
		v3 = ClansLeagueData.INITIAL_ELO
	end

	local clanRank = ClansLeagueData.getClanRank(v3)

	if not (clanLeagueKills and (clanLeagueKills[p2] and clanLeagueKills[p2][`S{currentSeason}`])) then
		return nil
	end

	local v4 = {}

	for k, clanLeagueKill in clanLeagueKills do
		local kills = clanLeagueKill[`S{currentSeason}`]

		if kills then
			table.insert(v4, {
				memberId = k,
				kills = kills
			})
		end
	end

	table.sort(v4, function(a, b)
		return a.kills > b.kills
	end)
	local v5 = 1000

	for k, v7 in v4 do
		if v7.memberId ~= p2 then
			continue
		end

		v5 = k
		break
	end

	return clanRank.rewards[math.min(v5, 4)]
end

return ClansLeagueData