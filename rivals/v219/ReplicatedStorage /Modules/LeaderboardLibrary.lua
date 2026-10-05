local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
require(ReplicatedStorage.Modules.Utility)
local LeaderboardLibrary = {
	REFRESH_TIME = 60,
	Info = {},
	Order = {},
	DisplayInfo = {}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function add_leaderboard(name, dataStoreKey, numPlayers, isAscending, updateCycle, hiddenFromClient, isReadOnly)
	if hiddenFromClient and CONSTANTS.IS_CLIENT then
		return
	end

	local v = {
		Name = name,
		DataStoreKey = dataStoreKey,
		NumPlayers = numPlayers,
		IsAscending = isAscending,
		UpdateCycle = updateCycle,
		HiddenFromClient = hiddenFromClient,
		IsReadOnly = isReadOnly
	}
	LeaderboardLibrary.Info[v.Name] = v
	table.insert(LeaderboardLibrary.Order, v.Name)
end

local v = {
	Name = "Highest ELO",
	DataStoreKey = "HighestELO3_" .. SeasonLibrary.CurrentSeason.Version,
	NumPlayers = 250,
	IsAscending = false,
	UpdateCycle = nil,
	HiddenFromClient = nil,
	IsReadOnly = nil
}
LeaderboardLibrary.Info[v.Name] = v
table.insert(LeaderboardLibrary.Order, v.Name)
add_leaderboard(
	"Highest ELO Last Season",
	"HighestELO3_" .. SeasonLibrary.CurrentSeason.Version - 1,
	250,
	false,
	nil,
	true,
	true
) -- equivalent call inferred; original call site unknown
add_leaderboard("Top Players Before Season 0 Reset", "HighestELO_0", 100, false, nil, true, true) -- equivalent call inferred; original call site unknown
local v3 = {
	Name = "Current Highest Win Streak",
	DataStoreKey = "WinStreakCurrent_1",
	NumPlayers = 100,
	IsAscending = false,
	UpdateCycle = 86400,
	HiddenFromClient = nil,
	IsReadOnly = nil
}
LeaderboardLibrary.Info[v3.Name] = v3
table.insert(LeaderboardLibrary.Order, v3.Name)
local v4 = {
	Name = "Most Eliminations",
	DataStoreKey = "Eliminations_1",
	NumPlayers = 100,
	IsAscending = false,
	UpdateCycle = nil,
	HiddenFromClient = nil,
	IsReadOnly = nil
}
LeaderboardLibrary.Info[v4.Name] = v4
table.insert(LeaderboardLibrary.Order, v4.Name)
local v5 = {
	Name = "Most Wins",
	DataStoreKey = "Wins_1",
	NumPlayers = 100,
	IsAscending = false,
	UpdateCycle = nil,
	HiddenFromClient = nil,
	IsReadOnly = nil
}
LeaderboardLibrary.Info[v5.Name] = v5
table.insert(LeaderboardLibrary.Order, v5.Name)
local v6 = {
	Name = "Highest Level",
	DataStoreKey = "Level_1",
	NumPlayers = 100,
	IsAscending = false,
	UpdateCycle = nil,
	HiddenFromClient = nil,
	IsReadOnly = nil
}
LeaderboardLibrary.Info[v6.Name] = v6
table.insert(LeaderboardLibrary.Order, v6.Name)
add_leaderboard("Highest Win Streak Ever", "WinStreakHighest_1", 100, false, nil, true, nil) -- equivalent call inferred; original call site unknown
add_leaderboard("Current Highest True Streak", "TrueStreakCurrent_1", 100, false, nil, true, nil) -- equivalent call inferred; original call site unknown
add_leaderboard("Most Robux Spent", "RobuxSpent_1", 100, false, nil, true, nil) -- equivalent call inferred; original call site unknown
add_leaderboard("Most Ranked Wins", "RankedWins_" .. SeasonLibrary.CurrentSeason.Version, 100, false, nil, true, nil) -- equivalent call inferred; original call site unknown
add_leaderboard(
	"Highest Ranked Win Percent",
	"RankedWinPercent_" .. SeasonLibrary.CurrentSeason.Version,
	100,
	false,
	nil,
	true,
	nil
) -- equivalent call inferred; original call site unknown
add_leaderboard("Largest Data Size", "DataSize_1", 100, false, nil, true, nil) -- equivalent call inferred; original call site unknown

local function add_leaderboard_display(name, displayID, displayName, icon, iconFilled, sanitizeUsernames, liveDisplayEnabled, p8, p9)
	local v9 = {
		Name = name,
		DisplayID = displayID,
		DisplayName = displayName,
		Icon = icon,
		IconFilled = iconFilled,
		SanitizeUsernames = sanitizeUsernames,
		LiveDisplayEnabled = liveDisplayEnabled,
		TextPosition = p8 or UDim2.new(0.5, 0, 0.5, 0),
		ColorSequence = p9 or ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		DarkColorSequence = nil
	}
	LeaderboardLibrary.DisplayInfo[name] = v9
	local colorSequenceKeypoints = {}

	for _, keypoint in pairs(v9.ColorSequence.Keypoints) do
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(
				keypoint.Time,
				Color3.new(keypoint.Value.R * 0.75, keypoint.Value.G * 0.75, keypoint.Value.B * 0.75)
			)
		)
	end

	v9.DarkColorSequence = ColorSequence.new(colorSequenceKeypoints)
end

add_leaderboard_display(
	"Current Highest Win Streak",
	nil,
	"Win Streaks                   ",
	"rbxassetid://17175092502",
	"rbxassetid://17175117593",
	nil,
	true,
	UDim2.new(0.5, 0, 0.65, 0),
	ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 157, 0))
)
add_leaderboard_display(
	"Most Eliminations",
	nil,
	"Most Eliminations",
	"rbxassetid://17736782213",
	"rbxassetid://17736752966",
	nil,
	nil,
	UDim2.new(0.5, 0, 0.5, 0),
	ColorSequence.new(Color3.fromRGB(106, 22, 22), Color3.fromRGB(255, 51, 51))
)
add_leaderboard_display(
	"Most Wins",
	nil,
	"Most Wins",
	"rbxassetid://17175095665",
	"rbxassetid://17175117401",
	nil,
	nil,
	UDim2.new(0.5, 0, 0.4, 0),
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 204, 0)),
		ColorSequenceKeypoint.new(0.542, Color3.fromRGB(255, 209, 27)),
		ColorSequenceKeypoint.new(0.856, Color3.fromRGB(255, 229, 131)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
)
add_leaderboard_display(
	"Highest Level",
	nil,
	"Highest Level",
	"rbxassetid://81461991645938",
	"rbxassetid://72402714013244",
	nil,
	nil,
	UDim2.new(0.5, 0, 0.5, 0),
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 89, 255)),
		ColorSequenceKeypoint.new(0.342, Color3.fromRGB(2, 173, 253)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(151, 250, 255))
	})
)
add_leaderboard_display(
	"Highest Win Streak Ever",
	nil,
	"Best Win Streaks",
	"rbxassetid://17175092502",
	"rbxassetid://17175117593",
	nil,
	nil,
	UDim2.new(0.5, 0, 0.65, 0),
	ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 157, 0))
)
add_leaderboard_display(
	"Highest ELO",
	"RankedLB",
	"Ranked                             ",
	"rbxassetid://117835427046796",
	"rbxassetid://89838302386905",
	true,
	true
)
return LeaderboardLibrary