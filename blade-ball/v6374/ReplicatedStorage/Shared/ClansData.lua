local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent.ClansWarData)
local v = require3(script.Parent.ClansLeagueData)
local _ = {
	"'",
	"(",
	")",
	"-",
	"_"
}
local v2 = {
	MinTitleLength = 4,
	MaxTitleLength = 30,
	MaxTagLength = 6,
	MinTagLength = 1,
	MaxDescriptionLength = 300,
	RenameInterval = 2592000,
	TagChangeInterval = 2592000,
	BlockedTags = {
		"dev",
		"mod",
		"staff",
		"admin"
	},
	TagPattern = "[%w]+",
	TitlePattern = utf8.charpattern,
	CreationRequirements = {
		Wins = 10,
		TotalRobuxSpent = 500
	},
	CreationPrice = 15000,
	DefaultEmblem = "Emblem1",
	Emblems = {
		Emblem1 = {
			Order = 1,
			DisplayName = "Emblem 1",
			ImageId = "rbxassetid://15594917068"
		},
		Emblem2 = {
			Order = 2,
			DisplayName = "Emblem 2",
			ImageId = "rbxassetid://15594916914"
		},
		Emblem3 = {
			Order = 3,
			DisplayName = "Emblem 3",
			ImageId = "rbxassetid://15594916753"
		},
		Emblem4 = {
			Order = 4,
			DisplayName = "Emblem 4",
			ImageId = "rbxassetid://15594916644",
			MinimumLevel = 2
		},
		Emblem5 = {
			Order = 5,
			DisplayName = "Emblem 5",
			ImageId = "rbxassetid://15594916529",
			MinimumLevel = 3
		},
		Emblem6 = {
			Order = 6,
			DisplayName = "Emblem 6",
			ImageId = "rbxassetid://15594916425",
			MinimumLevel = 3
		},
		Emblem7 = {
			Order = 7,
			DisplayName = "Emblem 7",
			ImageId = "rbxassetid://15594916266",
			MinimumLevel = 3
		},
		Emblem8 = {
			Order = 8,
			DisplayName = "Emblem 8",
			ImageId = "rbxassetid://15594916127",
			MinimumLevel = 4
		},
		Emblem9 = {
			Order = 9,
			DisplayName = "Emblem 9",
			ImageId = "rbxassetid://15594915891",
			MinimumLevel = 4
		},
		Emblem10 = {
			Order = 10,
			DisplayName = "Emblem 10",
			ImageId = "rbxassetid://15594915718",
			MinimumLevel = 5
		}
	},
	LeaderboardFields = { "leaderboardAPoints", "leaderboardBPoints" },
	LeaderboardLimit = 100,
	MaxAuditLogSize = 50,
	MaxClanJoinRequests = 50,
	MaxRecentContribution = 50,
	ClansPerPage = 50,
	parseUserId = function(value: string)
		return string.match(value, "(%d+)$") or value
	end
}

function v2.findUserIdInArray(items, p: string)
	local userId = v2.parseUserId(p)

	for k, item in items do
		if v2.parseUserId(item) == userId then
			return k
		end
	end
end

function v2.getFormattedUserId(userId)
	local gameId = game.GameId

	if typeof(userId) == "Instance" then
		userId = userId.UserId
	elseif type(userId) == "string" then
		userId = v2.parseUserId(userId)
	end

	return (`{gameId}-{userId}`)
end

function v2.getBattleRewardsFor(clanId: string, p2)
	local isWinner = p2.winner == clanId
	return {
		clanId = clanId,
		isWinner = isWinner,
		crowns = isWinner and 50 or 10,
		activityPoints = isWinner and 100 or 20
	}
end

function v2.getClanEmblem(p)
	local clanEmblem = tonumber(p.clanEmblem)

	if clanEmblem then
		return v.RANKS[clanEmblem].icon
	end

	return v.RANKS[1].icon
end

return table.freeze(v2)