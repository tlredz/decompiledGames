local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
require(ReplicatedStorage.Modules.EventLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {
	Color3.fromRGB(255, 50, 50),
	Color3.fromRGB(255, 150, 0),
	Color3.fromRGB(255, 215, 0),
	Color3.fromRGB(100, 255, 50),
	Color3.fromRGB(0, 150, 255),
	Color3.fromRGB(161, 53, 255),
	Color3.fromRGB(255, 140, 244)
}
local DuelLibrary = {
	MAX_TEAMS = 0,
	EMPTY_TEAM_COLOR = Color3.fromRGB(127, 127, 127),
	APRIL_FOOLS_QUEUES = { "ltm_easyexploits_2v2", "ltm_easyexploits_3v3" },
	NEW_MAP_RELEASE_DURATION = 1209600,
	Teams = {},
	TeamsByID = {},
	MapDifficulties = {},
	Maps = {},
	MapTags = {},
	MapOrder = {},
	HiddenMapOrder = {},
	PlaySourceTypes = {},
	PlaySources = {},
	PlaySourceOrder = {},
	MatchmakingQueues = {},
	MatchmakingQueueOrder = {},
	MatchmakingQueueDuelLogicToQueueName = {},
	MatchmakingQueueDisplayNameToQueueName = {},
	ArcadeModes = {},
	ArcadeModeOrder = {},
	ArcadeModeByPlaceID = {},
	_assigned_color_count = 0,
	_arcade_mode_display_names = nil,
	_arcade_mode_display_name_to_arcade_name = nil,
	GetArcadeModeDisplayNames = function(state)
		if state._arcade_mode_display_names then
			return state._arcade_mode_display_names, state._arcade_mode_display_name_to_arcade_name
		end

		state._arcade_mode_display_names = {}
		state._arcade_mode_display_name_to_arcade_name = {}

		for _, v2 in pairs(state.ArcadeModeOrder) do
			local displayName = state.ArcadeModes[v2].DisplayName
			table.insert(state._arcade_mode_display_names, state.ArcadeModes[v2].DisplayName)
			state._arcade_mode_display_name_to_arcade_name[displayName] = v2
		end

		return state._arcade_mode_display_names, state._arcade_mode_display_name_to_arcade_name
	end,
	GetTeamColor = function(p, p2, p3, value)
		return p2 and p.TeamsByID[p2] and p.TeamsByID[p2][value or "Color"] or p3 or p.EMPTY_TEAM_COLOR
	end,
	GetMaps = function(self, p2, p3, p4, p5)
		local playSource = self.PlaySources[p4]
		local mapPool = playSource and playSource.MapPool
		local isRigidMapPool = playSource and playSource.IsRigidMapPool

		if isRigidMapPool then
			isRigidMapPool = not (p5 and playSource) or playSource.Type ~= "ArcadeMode"
		end

		local v2 = p5 and not isRigidMapPool

		if not v2 and mapPool then
			return Utility:CloneTable(mapPool)
		end

		local v3 = playSource and playSource.Type == "ArcadeMode"
		local result = {}

		for k, map in pairs(self.Maps) do
			if map.IsHidden then
				continue
			end

			local v4

			if v2 then
				v4 = v2
			elseif map.MinimumPlayersRequired <= p2 then
				v4 = not map.DontAutomaticallyAddToMapPools
			else
				v4 = false
			end

			local v5 = p3 <= map.MaximumTeamsSupported
			local v6 = not v3 or map.SupportsArcadeMode

			if v4 and v5 and v6 then
				table.insert(result, k)
			elseif v4 and v3 and v2 then
				table.insert(result, k)
			end
		end

		for _, v4 in pairs(mapPool or {}) do
			if not table.find(result, v4) then
				table.insert(result, v4)
			end
		end

		return result
	end,
	GetFirstQueueNameByDuelLogic = function(p, p2)
		for _, v2 in pairs(p.PlaySourceOrder) do
			if p.PlaySources[v2].DuelLogic == p2 then
				return v2
			end
		end
	end,
	SortMaps = function(data, p, p2)
		local v2 = ServerOsTime:Get() < data.Maps[p].ReleaseTime + data.NEW_MAP_RELEASE_DURATION
		local v3 = ServerOsTime:Get() < data.Maps[p2].ReleaseTime + data.NEW_MAP_RELEASE_DURATION
		local v4 = not v2 and -1 or data.Maps[p].ReleaseTime
		local v5 = not v3 and -1 or data.Maps[p2].ReleaseTime

		if v4 ~= v5 then
			return v5 < v4
		end

		local value = data.MapDifficulties[data.Maps[p].Difficulty].Value
		local value2 = data.MapDifficulties[data.Maps[p2].Difficulty].Value

		if value == value2 then
			return Utility:StringLessThan(p, p2)
		end

		return value < value2
	end
}

local function add_team(teamIndex, teamName, value, color, color2, color3)
	local v2 = {
		TeamIndex = teamIndex,
		TeamID = utf8.char(teamIndex),
		TeamName = teamName,
		Logo = value or "",
		Color = color,
		PadColor = color2,
		PadColor2 = color3
	}
	DuelLibrary.Teams[v2.TeamIndex] = v2
	DuelLibrary.TeamsByID[v2.TeamID] = v2
	DuelLibrary.MAX_TEAMS += 1
end

add_team(
	1,
	"Sensei Global",
	"rbxassetid://97418037278150",
	Color3.fromRGB(255, 215, 0),
	Color3.fromRGB(163, 135, 51),
	Color3.fromRGB(194, 161, 61)
)
add_team(
	2,
	"Nosniy Inc.",
	"rbxassetid://114213660098262",
	Color3.fromRGB(116, 61, 255),
	Color3.fromRGB(125, 74, 162),
	Color3.fromRGB(180, 115, 255)
)
add_team(
	3,
	"Neko Labs",
	"rbxassetid://126657764282293",
	Color3.fromRGB(0, 150, 255),
	Color3.fromRGB(74, 112, 161),
	Color3.fromRGB(0, 115, 191)
)

local function add_map_difficulty(p, p2, color2)
	DuelLibrary.MapDifficulties[p2] = {
		Value = p,
		Color = color2
	}
end

local none = {
	Value = 0,
	Color = Color3.fromRGB(60, 60, 60)
}
DuelLibrary.MapDifficulties.None = none
local easy = {
	Value = 1,
	Color = Color3.fromRGB(100, 255, 50)
}
DuelLibrary.MapDifficulties.Easy = easy
local medium = {
	Value = 2,
	Color = Color3.fromRGB(255, 215, 0)
}
DuelLibrary.MapDifficulties.Medium = medium
local hard = {
	Value = 3,
	Color = Color3.fromRGB(255, 50, 50)
}
DuelLibrary.MapDifficulties.Hard = hard
local secret = {
	Value = 4,
	Color = Color3.fromRGB(255, 255, 255)
}
DuelLibrary.MapDifficulties.Secret = secret

-- equivalent calls inferred from this helper; original call sites unknown
local function add_map_tag(name, displayName, color, p3)
	local v7 = {
		Name = name,
		DisplayName = displayName,
		Color = color,
		SecondaryColor = p3 or Color3.fromRGB(255, 255, 255)
	}
	DuelLibrary.MapTags[name] = v7
end

local color, v7 = Color3.fromRGB(255, 50, 50)
add_map_tag("tag_newrelease", "NEW RELEASE", color, v7) -- equivalent call inferred; original call site unknown
local tag_experimental = {
	Name = "tag_experimental",
	DisplayName = "Experimental",
	Color = Color3.fromRGB(44, 255, 248),
	SecondaryColor = Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
}
DuelLibrary.MapTags.tag_experimental = tag_experimental

local function add_map(isHidden, value, p2, image, difficulty, _, maximumTeamsSupported, shuffleSpawnsUniversally, dontAutomaticallyAddToMapPools, supportsArcadeMode, options, options2, mapTag, description)
	local v9 = {
		IsHidden = isHidden,
		ReleaseTime = value or 0,
		Image = image,
		Description = description,
		Difficulty = difficulty,
		MinimumPlayersRequired = 1,
		MaximumTeamsSupported = maximumTeamsSupported,
		ShuffleSpawnsUniversally = shuffleSpawnsUniversally,
		DontAutomaticallyAddToMapPools = dontAutomaticallyAddToMapPools,
		SupportsArcadeMode = supportsArcadeMode,
		Creators = options or {},
		Contributors = options2 or {},
		MapTag = mapTag,
		PlaySources = {}
	}
	DuelLibrary.Maps[p2] = v9
	table.insert(DuelLibrary.HiddenMapOrder, p2)

	if not v9.IsHidden or CONSTANTS.IS_TESTING_SERVER then
		table.insert(DuelLibrary.MapOrder, p2)
	end
end

add_map(nil, 1766548800, "Village", "rbxassetid://78458667507109", "Easy", 1, 2, nil, nil, nil, { "GreatGuyBoom" }, nil)
add_map(nil, 1766548800, "Iceberg", "rbxassetid://110713820813038", "Medium", 1, 2, nil, nil, nil, { "Nosniy" }, nil)
add_map(nil, nil, "Backrooms", "rbxassetid://78425568447137", "Easy", 1, 2, nil, nil, nil, { "Nosniy" }, nil)
add_map(nil, nil, "Arena", "rbxassetid://108088064658436", "Easy", 1, 2, nil, nil, nil, { "Nosniy" }, nil)
add_map(nil, nil, "Dimension", "rbxassetid://78851598956506", "Hard", 1, 2, nil, nil, nil, { "GreatGuyBoom" }, nil)
add_map(nil, nil, "Bridge", "rbxassetid://110835255645526", "Easy", 1, 2, nil, nil, nil, { "GreatGuyBoom" }, nil)
add_map(
	nil,
	1777003200,
	"Museum",
	"rbxassetid://80495049076353",
	"Medium",
	5,
	3,
	nil,
	nil,
	true,
	{ "GreatGuyBoom" },
	nil
)
add_map(nil, nil, "Graveyard", "rbxassetid://129215409539945", "Medium", 1, 2, nil, nil, nil, { "GreatGuyBoom" }, nil)
add_map(nil, 1777003200, "Studio", "rbxassetid://113589926222762", "Easy", 1, 2, nil, nil, nil, { "GreatGuyBoom" }, nil)
add_map(nil, nil, "Playground", "rbxassetid://133164748672681", "Easy", 1, 2, nil, nil, nil, { "Nosniy" }, nil)
add_map(nil, nil, "Splash", "rbxassetid://73768743857232", "Medium", 1, 2, nil, nil, nil, { "Nosniy" }, nil)
add_map(nil, 1770958800, "Chess", "rbxassetid://88015580366583", "Easy", 1, 2, nil, nil, nil, { "Nosniy" }, nil)
add_map(nil, nil, "Construction", "rbxassetid://92127692376940", "Hard", 1, 2, nil, nil, nil, { "Nosniy" }, nil)
add_map(
	nil,
	nil,
	"Station",
	"rbxassetid://118067445717885",
	"Medium",
	1,
	2,
	nil,
	nil,
	true,
	{ "Nosniy" },
	{ "GreatGuyBoom" }
)
add_map(nil, nil, "Onyx", "rbxassetid://103965007372841", "Hard", 1, 3, nil, nil, nil, { "ShadowTrojan" }, nil)
add_map(nil, nil, "Crossroads", "rbxassetid://137051465958454", "Medium", 1, 3, true, nil, nil, { "ShadowTrojan" }, nil)
add_map(nil, nil, "Docks", "rbxassetid://118450909242865", "Medium", 1, 2, nil, nil, true, { "Nosniy" }, nil)
add_map(nil, 1777003200, "Westown", "rbxassetid://77717157639300", "Medium", 1, 2, nil, nil, true, { "Nosniy" }, nil)
add_map(nil, nil, "Big Arena", "rbxassetid://86783307295205", "Easy", 5, 3, nil, nil, true, { "Nosniy" }, nil)
add_map(nil, nil, "Big Onyx", "rbxassetid://102960591046810", "Hard", 5, 3, nil, nil, nil, { "ShadowTrojan" }, nil)
add_map(nil, nil, "Big Splash", "rbxassetid://129106276364955", "Medium", 5, 3, nil, nil, true, { "Nosniy" }, nil)
add_map(nil, nil, "Big Backrooms", "rbxassetid://70941797176675", "Easy", 5, 3, nil, nil, true, { "Nosniy" }, nil)
add_map(
	nil,
	nil,
	"Big Crossroads",
	"rbxassetid://73141606762048",
	"Medium",
	5,
	3,
	true,
	nil,
	true,
	{ "ShadowTrojan" },
	nil
)
add_map(
	nil,
	nil,
	"Big Graveyard",
	"rbxassetid://93673011647821",
	"Medium",
	5,
	3,
	true,
	nil,
	true,
	{ "GreatGuyBoom" },
	nil
)
add_map(
	nil,
	1770958800,
	"Big Station",
	"rbxassetid://115320285934414",
	"Medium",
	5,
	3,
	true,
	nil,
	true,
	{ "GreatGuyBoom" },
	nil
)
add_map(nil, nil, "Shooting Range", "rbxassetid://80094199312443", "Easy", 9, 2, nil, nil, true, { "Nosniy" }, nil)
add_map(
	nil,
	nil,
	"Battleground",
	"rbxassetid://102473488579867",
	"Easy",
	1,
	2,
	nil,
	nil,
	nil,
	{ "GreatGuyBoom" },
	{ "ShadowTrojan" }
)
add_map(
	nil,
	1782446400,
	"Sandbox",
	"rbxassetid://129581948881572",
	"Easy",
	1,
	2,
	nil,
	nil,
	nil,
	{ "GreatGuyBoom" },
	{ "ShadowTrojan" }
)
add_map(nil, nil, "Legacy Backrooms", "rbxassetid://16780257607", "Secret", 1, 2, nil, true, nil, { "Nosniy" }, nil)
add_map(
	nil,
	nil,
	"Legacy Big Splash",
	"rbxassetid://112550674762781",
	"Secret",
	1,
	2,
	nil,
	true,
	true,
	{ "Nosniy" },
	nil
)
add_map(nil, nil, "Legacy Splash", "rbxassetid://77611360382000", "Secret", 1, 2, nil, true, nil, { "Nosniy" }, nil)
add_map(nil, nil, "Legacy Docks", "rbxassetid://17619338260", "Secret", 1, 2, nil, true, true, { "Nosniy" }, nil)
add_map(nil, nil, "Legacy Onyx", "rbxassetid://73585862572119", "Secret", 1, 2, nil, true, nil, { "ShadowTrojan" }, nil)
add_map(
	nil,
	nil,
	"Legacy Crossroads",
	"rbxassetid://75089226416040",
	"Secret",
	1,
	2,
	nil,
	true,
	nil,
	{ "ShadowTrojan" },
	nil
)
add_map(
	nil,
	nil,
	"Legacy Battleground",
	"rbxassetid://92092855485574",
	"Secret",
	1,
	2,
	nil,
	true,
	nil,
	{ "ShadowTrojan" },
	nil
)
add_map(
	nil,
	nil,
	"Legacy Sandbox",
	"rbxassetid://84468237347412",
	"Secret",
	1,
	2,
	nil,
	nil,
	nil,
	{ "ShadowTrojan" },
	nil
)
add_map(nil, nil, "Baseplate", "rbxassetid://70533987337950", "Secret", 1, 3, nil, true, nil, nil, nil)
add_map(true, nil, "Boss Arena", "rbxassetid://75072389675461", "Secret", 1, 3, nil, true, nil, { "Nosniy" }, nil)
add_map(true, nil, "Obby", "rbxassetid://84725536967912", "Secret", 1, 3, nil, true, nil, { "Nosniy" }, nil)
add_map(true, nil, "Zombie Tower", "rbxassetid://129926572026365", "Secret", 1, 1, nil, true, nil, { "Nosniy" }, nil)
add_map(true, nil, "Spleef", "rbxassetid://92639076087223", "Secret", 1, 1, nil, true, nil, { "Nosniy" }, nil)
add_map(
	nil,
	nil,
	"Factory",
	"rbxassetid://134218858341023",
	"Easy",
	1,
	2,
	nil,
	nil,
	nil,
	{ "GreatGuyBoom" },
	nil,
	"tag_experimental"
)
add_map(
	nil,
	nil,
	"Gate",
	"rbxassetid://93979105537133",
	"Easy",
	1,
	2,
	nil,
	nil,
	nil,
	{ "ShadowTrojan" },
	nil,
	"tag_experimental"
)

if CONSTANTS.IS_TESTING_SERVER then
	add_map(
		nil,
		nil,
		"Front",
		"rbxassetid://110072622389604",
		"None",
		1,
		3,
		nil,
		nil,
		nil,
		nil,
		nil,
		"tag_experimental"
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function add_play_source_type(p)
	DuelLibrary.PlaySourceTypes[p] = {}
end

add_play_source_type("MatchmakingQueue") -- equivalent call inferred; original call site unknown
add_play_source_type("ArcadeMode") -- equivalent call inferred; original call site unknown

local function verify_map_pool(list)
	if not list then
		return
	end

	for i = #list, 1, -1 do
		if not DuelLibrary.Maps[list[i]] then
			table.remove(list, i)
		end
	end

	return list
end

local function iaf()
	return Utility:IsAprilFoolsGamemodesEnabled()
end

local function add_play_source(p, p2, duelLogic, displayName, databaseInfo, isRigidMapPool, p7)
	assert(DuelLibrary.PlaySourceTypes[p])
	assert(not DuelLibrary.PlaySourceTypes[p2])
	DuelLibrary._assigned_color_count = DuelLibrary._assigned_color_count % #v + 1
	local v9 = {
		Type = p,
		DisplayName = displayName,
		DuelLogic = duelLogic,
		DatabaseInfo = databaseInfo,
		IsRigidMapPool = isRigidMapPool,
		MapPool = verify_map_pool(p7),
		AssignedColor = v[DuelLibrary._assigned_color_count]
	}
	DuelLibrary.PlaySources[p2] = v9
	table.insert(DuelLibrary.PlaySourceOrder, p2)

	if v9.Type ~= "MatchmakingQueue" or v9.DatabaseInfo.CanBeStartedFromClient then
		local maps

		if v9.Type == "MatchmakingQueue" then
			maps = DuelLibrary:GetMaps(
				v9.DatabaseInfo.NumTeams * v9.DatabaseInfo.PlayersPerTeam,
				v9.DatabaseInfo.NumTeams,
				p2
			)
		elseif v9.Type == "ArcadeMode" then
			maps = DuelLibrary:GetMaps(nil, nil, p2)
		else
			maps = assert(false, "???")
		end

		for _, v10 in pairs(maps or {}) do
			table.insert(DuelLibrary.Maps[v10].PlaySources, p2)
		end
	end
end

local function add_queue(p, name, duelLogic, numTeams, playersPerTeam, canBeStartedFromClient, p7, statisticsDisabled, isSafeFromAprilFools, displayName, titleName, value2, value3, value4, isRigidMapPool, p12)
	local v9 = p and p < 0 and 1e999 or p
	local databaseInfo = {
		TerminalsReleaseTime = CONSTANTS.IS_TESTING_SERVER and (not v9 or v9 < 1e999) and 0 or v9 or 0,
		Name = name,
		NumTeams = numTeams,
		PlayersPerTeam = playersPerTeam,
		CanBeStartedFromClient = canBeStartedFromClient,
		AreStreaksDisabled = function()
			return p7 or Utility:IsAprilFools() and not isSafeFromAprilFools
		end,
		StatisticsDisabled = statisticsDisabled,
		IsSafeFromAprilFools = isSafeFromAprilFools,
		DisplayName = displayName or "???",
		TitleName = titleName,
		Image = value2 or "rbxassetid://18523763487",
		Thumbnail = value3 or "rbxassetid://117875704523935",
		Description = value4 or ""
	}
	DuelLibrary.MatchmakingQueues[name] = databaseInfo
	DuelLibrary.MatchmakingQueueDisplayNameToQueueName[displayName] = name
	table.insert(DuelLibrary.MatchmakingQueueOrder, name)

	if duelLogic then
		DuelLibrary.MatchmakingQueueDuelLogicToQueueName[duelLogic] = DuelLibrary.MatchmakingQueueDuelLogicToQueueName[duelLogic] or databaseInfo
	end

	add_play_source("MatchmakingQueue", name, duelLogic, displayName, databaseInfo, isRigidMapPool, p12)
end

add_queue(
	-1,
	"2v2_beginner",
	nil,
	2,
	1,
	true,
	nil,
	nil,
	nil,
	"Beginner 2v2",
	"Beginner",
	nil,
	"rbxassetid://86693110079054",
	nil,
	nil,
	{ "Arena" }
)
add_queue(
	nil,
	"1v1",
	nil,
	2,
	1,
	true,
	nil,
	nil,
	nil,
	"1v1",
	nil,
	"rbxassetid://18525954682",
	"rbxassetid://110648887575668",
	nil,
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Chess",
		"Sandbox",
		"Westown",
		"Museum",
		"Studio",
		"Gate"
	}
)
add_queue(
	nil,
	"2v2",
	nil,
	2,
	2,
	true,
	nil,
	nil,
	nil,
	"2v2",
	nil,
	"rbxassetid://18525954682",
	"rbxassetid://75765063500610",
	nil,
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Chess",
		"Sandbox",
		"Westown",
		"Museum",
		"Studio",
		"Gate"
	}
)
add_queue(
	nil,
	"3v3",
	nil,
	2,
	3,
	true,
	nil,
	nil,
	nil,
	"3v3",
	nil,
	"rbxassetid://18525954682",
	"rbxassetid://115188828715635",
	nil,
	nil,
	{
		"Big Arena",
		"Backrooms",
		"Crossroads",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Factory",
		"Westown",
		"Museum"
	}
)
add_queue(
	nil,
	"4v4",
	nil,
	2,
	4,
	true,
	nil,
	nil,
	nil,
	"4v4",
	nil,
	"rbxassetid://18525954682",
	"rbxassetid://78144981625266",
	nil,
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Docks",
		"Station",
		"Big Onyx",
		"Big Splash",
		"Big Graveyard",
		"Battleground",
		"Iceberg",
		"Big Station",
		"Chess",
		"Factory",
		"Westown",
		"Museum"
	}
)
add_queue(
	nil,
	"5v5",
	nil,
	2,
	5,
	true,
	nil,
	nil,
	nil,
	"5v5",
	nil,
	"rbxassetid://18525954682",
	"rbxassetid://100769223566900",
	nil,
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Docks",
		"Big Onyx",
		"Big Splash",
		"Big Graveyard",
		"Shooting Range",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	nil,
	"ranked_1v1",
	"Ranked",
	2,
	1,
	true,
	true,
	nil,
	true,
	"Ranked 1v1",
	"Ranked",
	"rbxassetid://117835427046796",
	SeasonLibrary.CurrentSeason.ThumbnailRanked1v1,
	nil,
	nil,
	{
		"Arena",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Westown",
		"Studio",
		"Museum",
		"Battleground",
		"Village"
	}
)
add_queue(
	nil,
	"ranked_2v2",
	"Ranked",
	2,
	2,
	true,
	true,
	nil,
	true,
	"Ranked 2v2",
	"Ranked",
	"rbxassetid://117835427046796",
	SeasonLibrary.CurrentSeason.ThumbnailRanked2v2,
	nil,
	nil,
	{
		"Arena",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Battleground",
		"Westown",
		"Studio",
		"Museum",
		"Crossroads",
		"Village"
	}
)
add_queue(
	nil,
	"ranked_3v3",
	"Ranked",
	2,
	3,
	true,
	true,
	nil,
	true,
	"Ranked 3v3",
	"Ranked",
	"rbxassetid://117835427046796",
	SeasonLibrary.CurrentSeason.ThumbnailRanked3v3,
	nil,
	nil,
	{
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Battleground",
		"Big Arena",
		"Westown",
		"Museum"
	}
)
add_queue(
	nil,
	"ltm_doubletrouble_1v1",
	"Double Trouble",
	2,
	1,
	nil,
	true,
	nil,
	nil,
	"Double Trouble 1v1",
	"Double Trouble",
	"rbxassetid://132073690319347",
	"rbxassetid://137424181577897",
	"Dual wield your favorite weapons!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Iceberg",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	nil,
	"ltm_doubletrouble",
	"Double Trouble",
	2,
	2,
	nil,
	true,
	nil,
	nil,
	"Double Trouble 2v2",
	"Double Trouble",
	"rbxassetid://132073690319347",
	"rbxassetid://137424181577897",
	"Dual wield your favorite weapons!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	nil,
	"ltm_doubletrouble_3v3",
	"Double Trouble",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"Double Trouble 3v3",
	"Double Trouble",
	"rbxassetid://132073690319347",
	"rbxassetid://137424181577897",
	"Dual wield your favorite weapons!",
	nil,
	{
		"Big Arena",
		"Backrooms",
		"Crossroads",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	nil,
	"ltm_mirrormatchup_1v1",
	"Mirror Matchup",
	2,
	1,
	nil,
	true,
	nil,
	nil,
	"Mirror Matchup 1v1",
	"Mirror Matchup",
	"rbxassetid://132073690319347",
	"rbxassetid://105092869907244",
	"Everyone has to use the same random weapons!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	nil,
	"ltm_mirrormatchup_2v2",
	"Mirror Matchup",
	2,
	2,
	nil,
	true,
	nil,
	nil,
	"Mirror Matchup 2v2",
	"Mirror Matchup",
	"rbxassetid://132073690319347",
	"rbxassetid://105092869907244",
	"Everyone has to use the same random weapons!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	nil,
	"ltm_mirrormatchup_3v3",
	"Mirror Matchup",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"Mirror Matchup 3v3",
	"Mirror Matchup",
	"rbxassetid://132073690319347",
	"rbxassetid://105092869907244",
	"Everyone has to use the same random weapons!",
	nil,
	{
		"Big Arena",
		"Backrooms",
		"Crossroads",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	nil,
	"ltm_easyexploits_2v2",
	"Easy Exploits",
	2,
	2,
	iaf,
	true,
	nil,
	nil,
	"Easy Exploits 2v2",
	"Easy Exploits",
	"rbxassetid://132073690319347",
	"rbxassetid://131530572287607",
	"Fake cheating — actual cheaters get banned!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	nil,
	"ltm_easyexploits_3v3",
	"Easy Exploits",
	2,
	3,
	iaf,
	true,
	nil,
	nil,
	"Easy Exploits 3v3",
	"Easy Exploits",
	"rbxassetid://132073690319347",
	"rbxassetid://131530572287607",
	"Fake cheating — actual cheaters get banned!",
	nil,
	{
		"Big Arena",
		"Backrooms",
		"Crossroads",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	nil,
	"ltm_limitlessloadout_1v1",
	"Limitless Loadout",
	2,
	1,
	nil,
	true,
	nil,
	nil,
	"Limitless Loadout 1v1",
	"Limitless Loadout",
	"rbxassetid://132073690319347",
	"rbxassetid://132019868240159",
	"Equip any weapon in any slot!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	nil,
	"ltm_limitlessloadout_2v2",
	"Limitless Loadout",
	2,
	2,
	nil,
	true,
	nil,
	nil,
	"Limitless Loadout 2v2",
	"Limitless Loadout",
	"rbxassetid://132073690319347",
	"rbxassetid://132019868240159",
	"Equip any weapon in any slot!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	nil,
	"ltm_limitlessloadout_3v3",
	"Limitless Loadout",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"Limitless Loadout 3v3",
	"Limitless Loadout",
	"rbxassetid://132073690319347",
	"rbxassetid://132019868240159",
	"Equip any weapon in any slot!",
	nil,
	{
		"Big Arena",
		"Backrooms",
		"Crossroads",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	1749182400,
	"ltm_juggernaut_1v7",
	"Juggernaut",
	2,
	4,
	nil,
	true,
	nil,
	nil,
	"Juggernaut 1v7",
	"Juggernaut",
	"rbxassetid://132073690319347",
	"rbxassetid://111131964001261",
	"Will you be the raid boss?",
	nil,
	{
		"Big Arena",
		"Backrooms",
		"Bridge",
		"Graveyard",
		"Playground",
		"Construction",
		"Onyx",
		"Dimension",
		"Iceberg",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	1749787200,
	"ltm_swiftstandoff_1v1",
	"Swift Standoff",
	2,
	1,
	nil,
	true,
	nil,
	nil,
	"Swift Standoff 1v1",
	"Swift Standoff",
	"rbxassetid://132073690319347",
	"rbxassetid://97275583028575",
	"Slash & dash with just 1 bullet in the chamber!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	1749787200,
	"ltm_swiftstandoff_2v2",
	"Swift Standoff",
	2,
	2,
	nil,
	true,
	nil,
	nil,
	"Swift Standoff 2v2",
	"Swift Standoff",
	"rbxassetid://132073690319347",
	"rbxassetid://97275583028575",
	"Slash & dash with just 1 bullet in the chamber!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	1749787200,
	"ltm_swiftstandoff_3v3",
	"Swift Standoff",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"Swift Standoff 3v3",
	"Swift Standoff",
	"rbxassetid://132073690319347",
	"rbxassetid://97275583028575",
	"Slash & dash with just 1 bullet in the chamber!",
	nil,
	{
		"Big Arena",
		"Backrooms",
		"Crossroads",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	1750392000,
	"ltm_defaultduel_1v1",
	"Default Duel",
	2,
	1,
	nil,
	nil,
	nil,
	nil,
	"Default Duel 1v1",
	"Default Duel",
	"rbxassetid://132073690319347",
	"rbxassetid://97514791083427",
	"A true test of skill — default weapons only!",
	nil,
	{
		"Arena",
		"Station",
		"Legacy Backrooms",
		"Legacy Docks",
		"Legacy Onyx",
		"Legacy Crossroads"
	}
)
add_queue(
	1750392000,
	"ltm_defaultduel_2v2",
	"Default Duel",
	2,
	2,
	nil,
	nil,
	nil,
	nil,
	"Default Duel 2v2",
	"Default Duel",
	"rbxassetid://132073690319347",
	"rbxassetid://97514791083427",
	"A true test of skill — default weapons only!",
	nil,
	{
		"Arena",
		"Station",
		"Legacy Backrooms",
		"Legacy Docks",
		"Legacy Onyx",
		"Legacy Crossroads"
	}
)
add_queue(
	1750392000,
	"ltm_bunnysniping_2v2",
	"Bunny Sniping",
	2,
	2,
	nil,
	true,
	nil,
	nil,
	"Bunny Sniping 2v2",
	"Bunny Sniping",
	"rbxassetid://132073690319347",
	"rbxassetid://111836104944441",
	"Snipe enemies in low gravity!",
	nil,
	{
		"Arena",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Iceberg",
		"Chess",
		"Westown",
		"Studio"
	}
)
add_queue(
	1750392000,
	"ltm_bunnysniping_3v3",
	"Bunny Sniping",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"Bunny Sniping 3v3",
	"Bunny Sniping",
	"rbxassetid://132073690319347",
	"rbxassetid://81786315504458",
	"Snipe enemies in low gravity!",
	nil,
	{
		"Arena",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown"
	}
)
add_queue(
	1750996800,
	"ltm_tagteam_3v3",
	"Tag Team",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"Tag Team 3v3",
	"Tag Team",
	"rbxassetid://132073690319347",
	"rbxassetid://98049823970129",
	"Sweep the enemy team as your teammates watch you!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Iceberg",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	1750996800,
	"ltm_tagteam_5v5",
	"Tag Team",
	2,
	5,
	nil,
	true,
	nil,
	nil,
	"Tag Team 5v5",
	"Tag Team",
	"rbxassetid://132073690319347",
	"rbxassetid://98049823970129",
	"Sweep the enemy team as your teammates watch you!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Iceberg",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	1751601600,
	"ltm_chickengames_1v1",
	"Chicken Game",
	2,
	1,
	nil,
	true,
	nil,
	nil,
	"Chicken Game 1v1",
	"Chicken Game",
	"rbxassetid://132073690319347",
	"rbxassetid://130631351253585",
	"Red Light 🚦 Green Light",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	1751601600,
	"ltm_chickengames_2v2",
	"Chicken Game",
	2,
	2,
	nil,
	true,
	nil,
	nil,
	"Chicken Game 2v2",
	"Chicken Game",
	"rbxassetid://132073690319347",
	"rbxassetid://130631351253585",
	"Red Light 🚦 Green Light",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	1751601600,
	"ltm_chickengames_3v3",
	"Chicken Game",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"Chicken Game 3v3",
	"Chicken Game",
	"rbxassetid://132073690319347",
	"rbxassetid://130631351253585",
	"Red Light 🚦 Green Light",
	nil,
	{
		"Big Arena",
		"Backrooms",
		"Crossroads",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	1751601600,
	"ltm_chickengames_4v4",
	"Chicken Game",
	2,
	4,
	nil,
	true,
	nil,
	nil,
	"Chicken Game 4v4",
	"Chicken Game",
	"rbxassetid://132073690319347",
	"rbxassetid://130631351253585",
	"Red Light 🚦 Green Light",
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Docks",
		"Big Onyx",
		"Big Splash",
		"Station",
		"Big Graveyard",
		"Battleground",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	1752206400,
	"ltm_rivalsrng_1v1",
	"RIVALS RNG",
	2,
	1,
	nil,
	true,
	nil,
	nil,
	"RIVALS RNG 1v1",
	"RIVALS RNG",
	"rbxassetid://132073690319347",
	"rbxassetid://77265684173552",
	"Roll for a random weapon!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	1752206400,
	"ltm_rivalsrng_2v2",
	"RIVALS RNG",
	2,
	2,
	nil,
	true,
	nil,
	nil,
	"RIVALS RNG 2v2",
	"RIVALS RNG",
	"rbxassetid://132073690319347",
	"rbxassetid://77265684173552",
	"Roll for a random weapon!",
	nil,
	{
		"Arena",
		"Backrooms",
		"Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Dimension",
		"Village",
		"Chess",
		"Westown",
		"Museum",
		"Studio"
	}
)
add_queue(
	1752206400,
	"ltm_rivalsrng_3v3",
	"RIVALS RNG",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"RIVALS RNG 3v3",
	"RIVALS RNG",
	"rbxassetid://132073690319347",
	"rbxassetid://77265684173552",
	"Roll for a random weapon!",
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Crossroads",
		"Big Crossroads",
		"Docks",
		"Splash",
		"Station",
		"Construction",
		"Onyx",
		"Bridge",
		"Playground",
		"Graveyard",
		"Battleground",
		"Village",
		"Iceberg",
		"Big Station",
		"Chess",
		"Westown",
		"Museum"
	}
)
add_queue(
	1752811200,
	"ltm_headhoncho_3v3",
	"Head Honcho",
	2,
	3,
	nil,
	true,
	nil,
	nil,
	"Head Honcho 3v3",
	"Head Honcho",
	"rbxassetid://132073690319347",
	"rbxassetid://129701707427431",
	"Assassinate the rival company's leader!",
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Docks",
		"Big Onyx",
		"Big Splash",
		"Big Graveyard",
		"Shooting Range",
		"Iceberg",
		"Big Station",
		"Westown",
		"Museum"
	}
)
add_queue(
	1752811200,
	"ltm_headhoncho_4v4",
	"Head Honcho",
	2,
	4,
	nil,
	true,
	nil,
	nil,
	"Head Honcho 4v4",
	"Head Honcho",
	"rbxassetid://132073690319347",
	"rbxassetid://129701707427431",
	"Assassinate the rival company's leader!",
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Docks",
		"Big Onyx",
		"Big Splash",
		"Big Graveyard",
		"Shooting Range",
		"Iceberg",
		"Big Station",
		"Westown",
		"Museum"
	}
)
add_queue(
	1752811200,
	"ltm_headhoncho_5v5",
	"Head Honcho",
	2,
	5,
	nil,
	true,
	nil,
	nil,
	"Head Honcho 5v5",
	"Head Honcho",
	"rbxassetid://132073690319347",
	"rbxassetid://111031080770975",
	"Assassinate the rival company's leader!",
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Docks",
		"Big Onyx",
		"Big Splash",
		"Big Graveyard",
		"Shooting Range",
		"Iceberg",
		"Big Station",
		"Westown",
		"Museum"
	}
)
add_queue(
	1753416000,
	"ltm_hardcoreparkour_1v1",
	"Hardcore Parkour",
	2,
	1,
	nil,
	true,
	nil,
	nil,
	"Hardcore Parkour 1v1",
	"Hardcore Parkour",
	"rbxassetid://132073690319347",
	"rbxassetid://104911032041491",
	"Obby but you're in RIVALS!",
	true,
	{ "Obby" }
)
add_queue(
	1753416000,
	"ltm_hardcoreparkour_2v2",
	"Hardcore Parkour",
	2,
	2,
	nil,
	true,
	nil,
	nil,
	"Hardcore Parkour 2v2",
	"Hardcore Parkour",
	"rbxassetid://132073690319347",
	"rbxassetid://104911032041491",
	"Obby but you're in RIVALS!",
	true,
	{ "Obby" }
)
add_queue(
	1753416000,
	"ltm_hardcoreparkour_5v5",
	"Hardcore Parkour",
	2,
	5,
	nil,
	true,
	nil,
	nil,
	"Hardcore Parkour 5v5",
	"Hardcore Parkour",
	"rbxassetid://132073690319347",
	"rbxassetid://104911032041491",
	"Obby but you're in RIVALS!",
	true,
	{ "Obby" }
)
add_queue(
	nil,
	"1v1v1",
	nil,
	3,
	1,
	nil,
	true,
	nil,
	nil,
	"1v1v1",
	nil,
	"rbxassetid://132073690319347",
	"rbxassetid://105588944981527",
	"Classic duels but with 3 teams!",
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Shooting Range",
		"Onyx",
		"Big Graveyard",
		"Station",
		"Docks",
		"Crossroads",
		"Big Onyx",
		"Iceberg",
		"Big Station",
		"Museum",
		"Westown"
	}
)
add_queue(
	nil,
	"2v2v2",
	nil,
	3,
	2,
	nil,
	true,
	nil,
	nil,
	"2v2v2",
	nil,
	"rbxassetid://132073690319347",
	"rbxassetid://105588944981527",
	"Classic duels but with 3 teams!",
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Shooting Range",
		"Oynx",
		"Big Graveyard",
		"Station",
		"Docks",
		"Crossroads",
		"Big Onyx",
		"Iceberg",
		"Big Station",
		"Museum",
		"Westown"
	}
)
add_queue(
	nil,
	"3v3v3",
	nil,
	3,
	3,
	nil,
	true,
	nil,
	nil,
	"3v3v3",
	nil,
	"rbxassetid://132073690319347",
	"rbxassetid://105588944981527",
	"Classic duels but with 3 teams!",
	nil,
	{
		"Big Arena",
		"Big Backrooms",
		"Big Crossroads",
		"Shooting Range",
		"Oynx",
		"Big Graveyard",
		"Station",
		"Docks",
		"Crossroads",
		"Big Onyx",
		"Iceberg",
		"Big Station",
		"Museum",
		"Westown"
	}
)
add_queue(
	nil,
	"ltm_spleef_8v8",
	"Spleef",
	2,
	8,
	nil,
	true,
	nil,
	nil,
	"Spleef 8v8",
	"Spleef",
	"rbxassetid://132073690319347",
	"rbxassetid://136079282184880",
	"Don't fall into the chark-infested waters!",
	true,
	{ "Spleef" }
)
add_queue(
	-1,
	"ltm_zombietower",
	"Zombie Tower",
	1,
	5,
	nil,
	true,
	true,
	nil,
	"Zombie Tower",
	"Zombie Tower",
	"rbxassetid://132073690319347",
	"rbxassetid://79328971751595",
	"Can you reach the top?",
	true,
	{ "Zombie Tower" }
)
add_queue(
	-1,
	"ltm_zombietower_solo",
	"Zombie Tower",
	1,
	1,
	nil,
	true,
	true,
	nil,
	"Zombie Tower Solo",
	"Zombie Tower",
	"rbxassetid://132073690319347",
	"rbxassetid://72764838190885",
	"Can you reach the top.. by yourself?",
	true,
	{ "Zombie Tower" }
)
add_queue(
	-1,
	"evt_senseibot",
	"Boss Battle",
	1,
	1,
	nil,
	true,
	true,
	true,
	"Sensei Bot",
	"Sensei Bot",
	"rbxassetid://132073690319347",
	"rbxassetid://110648887575668",
	nil,
	true,
	{ "Boss Arena" }
)
add_queue(
	-1,
	"evt_nosniybot",
	"Boss Battle",
	1,
	1,
	nil,
	true,
	true,
	true,
	"Nosniy Bot",
	"Nosniy Bot",
	"rbxassetid://132073690319347",
	"rbxassetid://110648887575668",
	nil,
	true,
	{ "Boss Arena" }
)

local function add_arcade_mode(name, duelLogic, displayName, thumbnail, description, placeID, p7)
	local databaseInfo = {
		Name = name,
		DisplayName = displayName,
		Thumbnail = thumbnail,
		Description = description,
		PlaceID = placeID
	}
	DuelLibrary.ArcadeModes[name] = databaseInfo
	DuelLibrary.ArcadeModeByPlaceID[tostring(databaseInfo.PlaceID)] = databaseInfo
	table.insert(DuelLibrary.ArcadeModeOrder, name)
	add_play_source("ArcadeMode", name, duelLogic, displayName, databaseInfo, true, p7)
end

add_arcade_mode(
	"arc_gungame",
	"Gun Game",
	"Gun Game",
	"rbxassetid://126712308378143",
	"Race to the final weapon to win!",
	CONSTANTS.ARCADE_GUNGAME_PLACE_ID,
	{
		"Big Crossroads",
		"Shooting Range",
		"Station",
		"Big Arena",
		"Big Backrooms",
		"Big Graveyard",
		"Big Splash",
		"Docks",
		"Iceberg",
		"Big Station",
		"Westown",
		"Museum"
	}
)
add_arcade_mode(
	"arc_teamdeathmatch",
	"Deathmatch",
	"Team Deathmatch",
	"rbxassetid://117499628913182",
	"The team with the most points wins!",
	CONSTANTS.ARCADE_TEAMDEATHMATCH_PLACE_ID,
	{
		"Big Crossroads",
		"Shooting Range",
		"Station",
		"Big Arena",
		"Big Backrooms",
		"Big Graveyard",
		"Big Splash",
		"Docks",
		"Iceberg",
		"Chess",
		"Big Station",
		"Westown",
		"Museum"
	}
)
add_arcade_mode(
	"arc_freeforall",
	"Deathmatch",
	"Free For All",
	"rbxassetid://86903206151694",
	"The player with the most points wins!",
	CONSTANTS.ARCADE_FREEFORALL_PLACE_ID,
	{
		"Big Crossroads",
		"Shooting Range",
		"Station",
		"Big Arena",
		"Big Backrooms",
		"Big Graveyard",
		"Big Splash",
		"Docks",
		"Iceberg",
		"Big Station",
		"Westown"
	}
)
return DuelLibrary