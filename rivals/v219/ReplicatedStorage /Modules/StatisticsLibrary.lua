local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local StatisticsLibrary = {
	Info = {},
	Order = {},
	Items = {},
	Maps = {},
	CareerStatistics = {}
}
StatisticsLibrary.STATISTICS_DIRECTORY_INFO = {
	{ "WeaponStatistics", StatisticsLibrary.Items },
	{ "MapStatistics", StatisticsLibrary.Maps }
}

function StatisticsLibrary.GetStatisticsDirectoryInfo(p, p2)
	for k, list in pairs(p.STATISTICS_DIRECTORY_INFO) do
		local v, _ = table.unpack(list)

		if v == p2 then
			return list, k
		end
	end
end

function StatisticsLibrary.GetPercent(_, p, p2)
	if p == 0 then
		return -1
	end

	return p2 / p
end

function StatisticsLibrary:GetCareerStatistics(p)
	local v = {}
	local v2 = {}
	local v3 = {}

	for k, item in pairs(StatisticsLibrary.Items) do
		for _, dataName in pairs(item.DataNames) do
			v[dataName] = true
			v2[dataName] = v2[dataName] or p[k] or nil
		end
	end

	for k, _ in pairs(StatisticsLibrary.Info) do
		if not v[k] then
			v3[k] = true
		end
	end

	local result = {}

	for k in pairs(v2) do
		table.insert(result, k)
	end

	for k in pairs(v3) do
		table.insert(result, k)
	end

	for i = #result, 1, -1 do
		if not StatisticsLibrary.Info[result[i]].IsCareerStatistic then
			table.remove(result, i)
		end
	end

	table.sort(result, function(a, b)
		return StatisticsLibrary.Info[a].Index < StatisticsLibrary.Info[b].Index
	end)
	return result
end

local function pretty_number_tostring(p)
	return Utility:PrettyNumber((math.floor(p + 0.5)))
end

local function percent_tostring(p)
	if p == -1 then
		return "N/A"
	end

	return math.floor(p * 1000) / 10 .. "%"
end

local function playtime_tostring(p)
	return Utility:TimeFormat2(p < 60 and p or math.floor(p / 60) * 60, nil, true)
end

local function raw_value(p)
	return p
end

local function date_tostring(p)
	return p and p > 0 and DateTime.fromUnixTimestamp(p):FormatLocalTime("ll", "en-us") or "???"
end

local function add_statistic(isCareerStatistic, onlyDisplayNonZero, p3, displayName, p5, p6, value, p7, p8)
	local dataName = "Statistic" .. p3
	local parentDataName

	if not (p5 == true or not p5) then
		parentDataName = "Statistic" .. p5 or nil
	end

	local v3 = parentDataName and StatisticsLibrary.Info[parentDataName]
	local isStatisticFolder = p5 == true
	local defaultValue = value or 0
	local v6 = {
		Index = #StatisticsLibrary.Order + 1,
		IsCareerStatistic = isCareerStatistic,
		OnlyDisplayNonZero = onlyDisplayNonZero,
		DataName = dataName,
		DisplayName = displayName,
		FullDisplayName = p7 or (not v3 and "" or v3.FullDisplayName .. " " or "") .. displayName,
		IsStatisticFolder = isStatisticFolder,
		ParentDataName = parentDataName,
		DefaultValue = defaultValue,
		ValueType = typeof(defaultValue),
		TostringFunction = p8 or pretty_number_tostring,
		Image = p6 or v3 and v3.Image or ""
	}
	StatisticsLibrary.Info[v6.DataName] = v6
	table.insert(StatisticsLibrary.Order, v6.DataName)
end

ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticJoinedTime",
	DisplayName = "Joined",
	FullDisplayName = "Joined",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = -1,
	ValueType = "number",
	TostringFunction = date_tostring or pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticPlaytime",
	DisplayName = "Playtime",
	FullDisplayName = "Playtime",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = playtime_tostring or pretty_number_tostring,
	Image = "rbxassetid://17156089790"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticPlaytime = StatisticsLibrary.Info.StatisticPlaytime
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = nil,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticPlaytimeUnequipped",
	DisplayName = "while unequipped",
	FullDisplayName = (not statisticPlaytime and "" or statisticPlaytime.FullDisplayName .. " " or "") .. "while unequipped",
	IsStatisticFolder = false,
	ParentDataName = "StatisticPlaytime",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = playtime_tostring or pretty_number_tostring,
	Image = statisticPlaytime and statisticPlaytime.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticTasksCompleted",
	DisplayName = "Tasks Completed",
	FullDisplayName = "Tasks Completed",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticContractsCompleted",
	DisplayName = "Contracts Completed",
	FullDisplayName = "Contracts Completed",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteWeapon",
	DisplayName = "Most Played Weapon",
	FullDisplayName = "Most Played Weapon",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFavoriteWeapon = StatisticsLibrary.Info.StatisticFavoriteWeapon
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteWeaponPrimary",
	DisplayName = "primary",
	FullDisplayName = (not statisticFavoriteWeapon and "" or statisticFavoriteWeapon.FullDisplayName .. " " or "") .. "primary",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFavoriteWeapon",
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = statisticFavoriteWeapon and statisticFavoriteWeapon.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFavoriteWeapon2 = StatisticsLibrary.Info.StatisticFavoriteWeapon
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteWeaponSecondary",
	DisplayName = "secondary",
	FullDisplayName = (not statisticFavoriteWeapon2 and "" or statisticFavoriteWeapon2.FullDisplayName .. " " or "") .. "secondary",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFavoriteWeapon",
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = statisticFavoriteWeapon2 and statisticFavoriteWeapon2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFavoriteWeapon3 = StatisticsLibrary.Info.StatisticFavoriteWeapon
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteWeaponMelee",
	DisplayName = "melee",
	FullDisplayName = (not statisticFavoriteWeapon3 and "" or statisticFavoriteWeapon3.FullDisplayName .. " " or "") .. "melee",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFavoriteWeapon",
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = statisticFavoriteWeapon3 and statisticFavoriteWeapon3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFavoriteWeapon4 = StatisticsLibrary.Info.StatisticFavoriteWeapon
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteWeaponUtility",
	DisplayName = "utility",
	FullDisplayName = (not statisticFavoriteWeapon4 and "" or statisticFavoriteWeapon4.FullDisplayName .. " " or "") .. "utility",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFavoriteWeapon",
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = statisticFavoriteWeapon4 and statisticFavoriteWeapon4.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteMap",
	DisplayName = "Most Played Map",
	FullDisplayName = "Most Played Map",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFavoriteMap = StatisticsLibrary.Info.StatisticFavoriteMap
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteMap2",
	DisplayName = "2nd",
	FullDisplayName = (not statisticFavoriteMap and "" or statisticFavoriteMap.FullDisplayName .. " " or "") .. "2nd",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFavoriteMap",
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = statisticFavoriteMap and statisticFavoriteMap.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFavoriteMap2 = StatisticsLibrary.Info.StatisticFavoriteMap
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteMap3",
	DisplayName = "3rd",
	FullDisplayName = (not statisticFavoriteMap2 and "" or statisticFavoriteMap2.FullDisplayName .. " " or "") .. "3rd",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFavoriteMap",
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = statisticFavoriteMap2 and statisticFavoriteMap2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFavoriteMap3 = StatisticsLibrary.Info.StatisticFavoriteMap
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFavoriteMap4",
	DisplayName = "4th",
	FullDisplayName = (not statisticFavoriteMap3 and "" or statisticFavoriteMap3.FullDisplayName .. " " or "") .. "4th",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFavoriteMap",
	DefaultValue = "N/A",
	ValueType = "string",
	TostringFunction = raw_value or pretty_number_tostring,
	Image = statisticFavoriteMap3 and statisticFavoriteMap3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsPlayed",
	DisplayName = "Duels Played",
	FullDisplayName = "Duels Played",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsWon",
	DisplayName = "wins",
	FullDisplayName = (not statisticDuelsPlayed and "" or statisticDuelsPlayed.FullDisplayName .. " " or "") .. "wins",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed and statisticDuelsPlayed.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed2 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsLost",
	DisplayName = "losses",
	FullDisplayName = (not statisticDuelsPlayed2 and "" or statisticDuelsPlayed2.FullDisplayName .. " " or "") .. "losses",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed2 and statisticDuelsPlayed2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed3 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsWinPercent",
	DisplayName = "win %",
	FullDisplayName = (not statisticDuelsPlayed3 and "" or statisticDuelsPlayed3.FullDisplayName .. " " or "") .. "win %",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = -1,
	ValueType = "number",
	TostringFunction = percent_tostring or pretty_number_tostring,
	Image = statisticDuelsPlayed3 and statisticDuelsPlayed3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed4 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsWonFlawless",
	DisplayName = "flawless wins",
	FullDisplayName = (not statisticDuelsPlayed4 and "" or statisticDuelsPlayed4.FullDisplayName .. " " or "") .. "flawless wins",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed4 and statisticDuelsPlayed4.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed5 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsLostFlawless",
	DisplayName = "flawless losses",
	FullDisplayName = (not statisticDuelsPlayed5 and "" or statisticDuelsPlayed5.FullDisplayName .. " " or "") .. "flawless losses",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed5 and statisticDuelsPlayed5.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed6 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsWonSuddenDeath",
	DisplayName = "sudden death wins",
	FullDisplayName = (not statisticDuelsPlayed6 and "" or statisticDuelsPlayed6.FullDisplayName .. " " or "") .. "sudden death wins",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed6 and statisticDuelsPlayed6.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed7 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsLostSuddenDeath",
	DisplayName = "sudden death losses",
	FullDisplayName = (not statisticDuelsPlayed7 and "" or statisticDuelsPlayed7.FullDisplayName .. " " or "") .. "sudden death losses",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed7 and statisticDuelsPlayed7.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed8 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsWinStreak",
	DisplayName = "current win streak",
	FullDisplayName = (not statisticDuelsPlayed8 and "" or statisticDuelsPlayed8.FullDisplayName .. " " or "") .. "current win streak",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed8 and statisticDuelsPlayed8.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed9 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsWinStreakHighest",
	DisplayName = "highest ever win streak",
	FullDisplayName = (not statisticDuelsPlayed9 and "" or statisticDuelsPlayed9.FullDisplayName .. " " or "") .. "highest ever win streak",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed9 and statisticDuelsPlayed9.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed10 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsWinStreaksTaken",
	DisplayName = "highest win streak ended",
	FullDisplayName = (not statisticDuelsPlayed10 and "" or statisticDuelsPlayed10.FullDisplayName .. " " or "") .. "highest win streak ended",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed10 and statisticDuelsPlayed10.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed11 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsWinStreaksTakenTotal",
	DisplayName = "total win streaks ended",
	FullDisplayName = (not statisticDuelsPlayed11 and "" or statisticDuelsPlayed11.FullDisplayName .. " " or "") .. "total win streaks ended",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed11 and statisticDuelsPlayed11.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDuelsPlayed12 = StatisticsLibrary.Info.StatisticDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDuelsMVPs",
	DisplayName = "MVPs",
	FullDisplayName = (not statisticDuelsPlayed12 and "" or statisticDuelsPlayed12.FullDisplayName .. " " or "") .. "MVPs",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDuelsPlayed12 and statisticDuelsPlayed12.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRoundsPlayed",
	DisplayName = "Rounds Played",
	FullDisplayName = "Rounds Played",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = StatisticsLibrary.Info.StatisticRoundsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRoundsWon",
	DisplayName = "wins",
	FullDisplayName = "Rounds Won",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRoundsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://100786023219923"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticRoundsPlayed = StatisticsLibrary.Info.StatisticRoundsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRoundsLost",
	DisplayName = "losses",
	FullDisplayName = (not statisticRoundsPlayed and "" or statisticRoundsPlayed.FullDisplayName .. " " or "") .. "losses",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRoundsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticRoundsPlayed and statisticRoundsPlayed.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticRoundsPlayed2 = StatisticsLibrary.Info.StatisticRoundsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRoundsWinPercent",
	DisplayName = "win %",
	FullDisplayName = (not statisticRoundsPlayed2 and "" or statisticRoundsPlayed2.FullDisplayName .. " " or "") .. "win %",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRoundsPlayed",
	DefaultValue = -1,
	ValueType = "number",
	TostringFunction = percent_tostring or pretty_number_tostring,
	Image = statisticRoundsPlayed2 and statisticRoundsPlayed2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRankedDuelsPlayed",
	DisplayName = "Ranked Duels Played",
	FullDisplayName = "Ranked Duels Played",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticRankedDuelsPlayed = StatisticsLibrary.Info.StatisticRankedDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRankedDuelsWon",
	DisplayName = "ranked wins",
	FullDisplayName = (not statisticRankedDuelsPlayed and "" or statisticRankedDuelsPlayed.FullDisplayName .. " " or "") .. "ranked wins",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRankedDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticRankedDuelsPlayed and statisticRankedDuelsPlayed.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticRankedDuelsPlayed2 = StatisticsLibrary.Info.StatisticRankedDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRankedDuelsLost",
	DisplayName = "ranked losses",
	FullDisplayName = (not statisticRankedDuelsPlayed2 and "" or statisticRankedDuelsPlayed2.FullDisplayName .. " " or "") .. "ranked losses",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRankedDuelsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticRankedDuelsPlayed2 and statisticRankedDuelsPlayed2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticRankedDuelsPlayed3 = StatisticsLibrary.Info.StatisticRankedDuelsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRankedDuelsWinPercent",
	DisplayName = "ranked win %",
	FullDisplayName = (not statisticRankedDuelsPlayed3 and "" or statisticRankedDuelsPlayed3.FullDisplayName .. " " or "") .. "ranked win %",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRankedDuelsPlayed",
	DefaultValue = -1,
	ValueType = "number",
	TostringFunction = percent_tostring or pretty_number_tostring,
	Image = statisticRankedDuelsPlayed3 and statisticRankedDuelsPlayed3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRankedRoundsPlayed",
	DisplayName = "Ranked Rounds Played",
	FullDisplayName = "Ranked Rounds Played",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticRankedRoundsPlayed = StatisticsLibrary.Info.StatisticRankedRoundsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRankedRoundsWon",
	DisplayName = "ranked wins",
	FullDisplayName = "Ranked Rounds Won",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRankedRoundsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticRankedRoundsPlayed and statisticRankedRoundsPlayed.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticRankedRoundsPlayed2 = StatisticsLibrary.Info.StatisticRankedRoundsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRankedRoundsLost",
	DisplayName = "ranked losses",
	FullDisplayName = (not statisticRankedRoundsPlayed2 and "" or statisticRankedRoundsPlayed2.FullDisplayName .. " " or "") .. "ranked losses",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRankedRoundsPlayed",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticRankedRoundsPlayed2 and statisticRankedRoundsPlayed2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticRankedRoundsPlayed3 = StatisticsLibrary.Info.StatisticRankedRoundsPlayed
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticRankedRoundsWinPercent",
	DisplayName = "ranked win %",
	FullDisplayName = (not statisticRankedRoundsPlayed3 and "" or statisticRankedRoundsPlayed3.FullDisplayName .. " " or "") .. "ranked win %",
	IsStatisticFolder = false,
	ParentDataName = "StatisticRankedRoundsPlayed",
	DefaultValue = -1,
	ValueType = "number",
	TostringFunction = percent_tostring or pretty_number_tostring,
	Image = statisticRankedRoundsPlayed3 and statisticRankedRoundsPlayed3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealt",
	DisplayName = "Damage Dealt",
	FullDisplayName = "Damage Dealt",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://18404346057"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtSliding",
	DisplayName = "while sliding",
	FullDisplayName = (not statisticDamageDealt and "" or statisticDamageDealt.FullDisplayName .. " " or "") .. "while sliding",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt and statisticDamageDealt.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt2 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtCrouching",
	DisplayName = "while crouching",
	FullDisplayName = (not statisticDamageDealt2 and "" or statisticDamageDealt2.FullDisplayName .. " " or "") .. "while crouching",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt2 and statisticDamageDealt2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt3 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtAirborne",
	DisplayName = "while airborne",
	FullDisplayName = (not statisticDamageDealt3 and "" or statisticDamageDealt3.FullDisplayName .. " " or "") .. "while airborne",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt3 and statisticDamageDealt3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt4 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtBlinded",
	DisplayName = "while blinded",
	FullDisplayName = (not statisticDamageDealt4 and "" or statisticDamageDealt4.FullDisplayName .. " " or "") .. "while blinded",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt4 and statisticDamageDealt4.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt5 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtDead",
	DisplayName = "while dead",
	FullDisplayName = (not statisticDamageDealt5 and "" or statisticDamageDealt5.FullDisplayName .. " " or "") .. "while dead",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt5 and statisticDamageDealt5.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt6 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtNoscope",
	DisplayName = "while noscoping",
	FullDisplayName = (not statisticDamageDealt6 and "" or statisticDamageDealt6.FullDisplayName .. " " or "") .. "while noscoping",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt6 and statisticDamageDealt6.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt7 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtDashing",
	DisplayName = "while dashing",
	FullDisplayName = (not statisticDamageDealt7 and "" or statisticDamageDealt7.FullDisplayName .. " " or "") .. "while dashing",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt7 and statisticDamageDealt7.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt8 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtDeflecting",
	DisplayName = "from deflecting",
	FullDisplayName = (not statisticDamageDealt8 and "" or statisticDamageDealt8.FullDisplayName .. " " or "") .. "from deflecting",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt8 and statisticDamageDealt8.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt9 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtBouncing",
	DisplayName = "after a bounce",
	FullDisplayName = (not statisticDamageDealt9 and "" or statisticDamageDealt9.FullDisplayName .. " " or "") .. "after a bounce",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt9 and statisticDamageDealt9.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt10 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtGunMode",
	DisplayName = "in gun mode",
	FullDisplayName = (not statisticDamageDealt10 and "" or statisticDamageDealt10.FullDisplayName .. " " or "") .. "in gun mode",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt10 and statisticDamageDealt10.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDamageDealt11 = StatisticsLibrary.Info.StatisticDamageDealt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageDealtBladeMode",
	DisplayName = "in blade mode",
	FullDisplayName = (not statisticDamageDealt11 and "" or statisticDamageDealt11.FullDisplayName .. " " or "") .. "in blade mode",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDamageDealt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDamageDealt11 and statisticDamageDealt11.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminations",
	DisplayName = "Eliminations",
	FullDisplayName = "Eliminations",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://17736790660"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsSliding",
	DisplayName = "while sliding",
	FullDisplayName = (not statisticEliminations and "" or statisticEliminations.FullDisplayName .. " " or "") .. "while sliding",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations and statisticEliminations.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations2 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsCrouching",
	DisplayName = "while crouching",
	FullDisplayName = (not statisticEliminations2 and "" or statisticEliminations2.FullDisplayName .. " " or "") .. "while crouching",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations2 and statisticEliminations2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations3 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsAirborne",
	DisplayName = "while airborne",
	FullDisplayName = (not statisticEliminations3 and "" or statisticEliminations3.FullDisplayName .. " " or "") .. "while airborne",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations3 and statisticEliminations3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations4 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsBlinded",
	DisplayName = "while blinded",
	FullDisplayName = (not statisticEliminations4 and "" or statisticEliminations4.FullDisplayName .. " " or "") .. "while blinded",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations4 and statisticEliminations4.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations5 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsDead",
	DisplayName = "while dead",
	FullDisplayName = (not statisticEliminations5 and "" or statisticEliminations5.FullDisplayName .. " " or "") .. "while dead",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations5 and statisticEliminations5.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations6 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsNoscope",
	DisplayName = "while noscoping",
	FullDisplayName = (not statisticEliminations6 and "" or statisticEliminations6.FullDisplayName .. " " or "") .. "while noscoping",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations6 and statisticEliminations6.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations7 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsDashing",
	DisplayName = "while dashing",
	FullDisplayName = (not statisticEliminations7 and "" or statisticEliminations7.FullDisplayName .. " " or "") .. "while dashing",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations7 and statisticEliminations7.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations8 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsDeflecting",
	DisplayName = "from deflecting",
	FullDisplayName = (not statisticEliminations8 and "" or statisticEliminations8.FullDisplayName .. " " or "") .. "from deflecting",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations8 and statisticEliminations8.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations9 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsBouncing",
	DisplayName = "after a bounce",
	FullDisplayName = (not statisticEliminations9 and "" or statisticEliminations9.FullDisplayName .. " " or "") .. "after a bounce",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations9 and statisticEliminations9.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations10 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsGunMode",
	DisplayName = "in gun mode",
	FullDisplayName = (not statisticEliminations10 and "" or statisticEliminations10.FullDisplayName .. " " or "") .. "in gun mode",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations10 and statisticEliminations10.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEliminations11 = StatisticsLibrary.Info.StatisticEliminations
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEliminationsBladeMode",
	DisplayName = "in blade mode",
	FullDisplayName = (not statisticEliminations11 and "" or statisticEliminations11.FullDisplayName .. " " or "") .. "in blade mode",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEliminations",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEliminations11 and statisticEliminations11.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDeaths",
	DisplayName = "Deaths",
	FullDisplayName = "Deaths",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDeaths = StatisticsLibrary.Info.StatisticDeaths
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDeathsRatio",
	DisplayName = "eliminations ratio",
	FullDisplayName = (not statisticDeaths and "" or statisticDeaths.FullDisplayName .. " " or "") .. "eliminations ratio",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDeaths",
	DefaultValue = -1,
	ValueType = "number",
	TostringFunction = function(p)
		if p == -1 then
			return "N/A"
		end

		return (string.format("%.2f", p))
	end or pretty_number_tostring,
	Image = statisticDeaths and statisticDeaths.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticAssists",
	DisplayName = "Assists",
	FullDisplayName = "Assists",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticAssists = StatisticsLibrary.Info.StatisticAssists
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticAssistsDead",
	DisplayName = "while dead",
	FullDisplayName = (not statisticAssists and "" or statisticAssists.FullDisplayName .. " " or "") .. "while dead",
	IsStatisticFolder = false,
	ParentDataName = "StatisticAssists",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticAssists and statisticAssists.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDamageReceived",
	DisplayName = "Damage Received",
	FullDisplayName = "Damage Received",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticHealsReceived",
	DisplayName = "Heals Received",
	FullDisplayName = "Heals Received",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticHealsGiven",
	DisplayName = "Heals Given",
	FullDisplayName = "Heals Given",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://102083156692899"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticHealsGiven = StatisticsLibrary.Info.StatisticHealsGiven
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticHealsGivenTeammates",
	DisplayName = "to teammates",
	FullDisplayName = (not statisticHealsGiven and "" or statisticHealsGiven.FullDisplayName .. " " or "") .. "to teammates",
	IsStatisticFolder = false,
	ParentDataName = "StatisticHealsGiven",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticHealsGiven and statisticHealsGiven.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticUses",
	DisplayName = "Uses",
	FullDisplayName = "Uses",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticUses = StatisticsLibrary.Info.StatisticUses
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticUsesQuick",
	DisplayName = "quick uses",
	FullDisplayName = (not statisticUses and "" or statisticUses.FullDisplayName .. " " or "") .. "quick uses",
	IsStatisticFolder = false,
	ParentDataName = "StatisticUses",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticUses and statisticUses.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticUses2 = StatisticsLibrary.Info.StatisticUses
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticUsesHits",
	DisplayName = "hits",
	FullDisplayName = (not statisticUses2 and "" or statisticUses2.FullDisplayName .. " " or "") .. "hits",
	IsStatisticFolder = false,
	ParentDataName = "StatisticUses",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticUses2 and statisticUses2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticUses3 = StatisticsLibrary.Info.StatisticUses
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticUsesHitPercent",
	DisplayName = "hit %",
	FullDisplayName = (not statisticUses3 and "" or statisticUses3.FullDisplayName .. " " or "") .. "hit %",
	IsStatisticFolder = false,
	ParentDataName = "StatisticUses",
	DefaultValue = -1,
	ValueType = "number",
	TostringFunction = percent_tostring or pretty_number_tostring,
	Image = statisticUses3 and statisticUses3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticUses4 = StatisticsLibrary.Info.StatisticUses
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticUsesCriticalHits",
	DisplayName = "critical hits",
	FullDisplayName = (not statisticUses4 and "" or statisticUses4.FullDisplayName .. " " or "") .. "critical hits",
	IsStatisticFolder = false,
	ParentDataName = "StatisticUses",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticUses4 and statisticUses4.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticUses5 = StatisticsLibrary.Info.StatisticUses
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticUsesCriticalHitPercent",
	DisplayName = "critical hit %",
	FullDisplayName = (not statisticUses5 and "" or statisticUses5.FullDisplayName .. " " or "") .. "critical hit %",
	IsStatisticFolder = false,
	ParentDataName = "StatisticUses",
	DefaultValue = -1,
	ValueType = "number",
	TostringFunction = percent_tostring or pretty_number_tostring,
	Image = statisticUses5 and statisticUses5.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticUses6 = StatisticsLibrary.Info.StatisticUses
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticUsesHitsSelf",
	DisplayName = "self hits",
	FullDisplayName = (not statisticUses6 and "" or statisticUses6.FullDisplayName .. " " or "") .. "self hits",
	IsStatisticFolder = false,
	ParentDataName = "StatisticUses",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticUses6 and statisticUses6.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticUses7 = StatisticsLibrary.Info.StatisticUses
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticUsesHitsDirect",
	DisplayName = "direct hits",
	FullDisplayName = (not statisticUses7 and "" or statisticUses7.FullDisplayName .. " " or "") .. "direct hits",
	IsStatisticFolder = false,
	ParentDataName = "StatisticUses",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticUses7 and statisticUses7.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticInspects",
	DisplayName = "Inspects",
	FullDisplayName = "Inspects",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticInspects = StatisticsLibrary.Info.StatisticInspects
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticInspectsAfterElimination",
	DisplayName = "after an elimination",
	FullDisplayName = (not statisticInspects and "" or statisticInspects.FullDisplayName .. " " or "") .. "after an elimination",
	IsStatisticFolder = false,
	ParentDataName = "StatisticInspects",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticInspects and statisticInspects.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticAmmoUsed",
	DisplayName = "Ammo Used",
	FullDisplayName = "Ammo Used",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticReloads",
	DisplayName = "Reloads",
	FullDisplayName = "Reloads",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticAirblasts",
	DisplayName = "Airblasts",
	FullDisplayName = "Airblasts",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticAirblasts = StatisticsLibrary.Info.StatisticAirblasts
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticAirblastsHits",
	DisplayName = "players blasted",
	FullDisplayName = (not statisticAirblasts and "" or statisticAirblasts.FullDisplayName .. " " or "") .. "players blasted",
	IsStatisticFolder = false,
	ParentDataName = "StatisticAirblasts",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticAirblasts and statisticAirblasts.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticAirblasts2 = StatisticsLibrary.Info.StatisticAirblasts
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticAirblastsSmokesCleared",
	DisplayName = "smokes blasted",
	FullDisplayName = (not statisticAirblasts2 and "" or statisticAirblasts2.FullDisplayName .. " " or "") .. "smokes blasted",
	IsStatisticFolder = false,
	ParentDataName = "StatisticAirblasts",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticAirblasts2 and statisticAirblasts2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDashes",
	DisplayName = "Dashes",
	FullDisplayName = "Dashes",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticWallsBuilt",
	DisplayName = "Walls Built",
	FullDisplayName = "Walls Built",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticWallsBuilt = StatisticsLibrary.Info.StatisticWallsBuilt
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticWallsBuiltBricksLayed",
	DisplayName = "bricks layed",
	FullDisplayName = (not statisticWallsBuilt and "" or statisticWallsBuilt.FullDisplayName .. " " or "") .. "bricks layed",
	IsStatisticFolder = false,
	ParentDataName = "StatisticWallsBuilt",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticWallsBuilt and statisticWallsBuilt.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDeflects",
	DisplayName = "Deflects",
	FullDisplayName = "Deflects",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDeflects = StatisticsLibrary.Info.StatisticDeflects
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDeflectsHits",
	DisplayName = "hits",
	FullDisplayName = (not statisticDeflects and "" or statisticDeflects.FullDisplayName .. " " or "") .. "hits",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDeflects",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDeflects and statisticDeflects.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticDeflects2 = StatisticsLibrary.Info.StatisticDeflects
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticDeflectsCriticalHits",
	DisplayName = "critical hits",
	FullDisplayName = (not statisticDeflects2 and "" or statisticDeflects2.FullDisplayName .. " " or "") .. "critical hits",
	IsStatisticFolder = false,
	ParentDataName = "StatisticDeflects",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticDeflects2 and statisticDeflects2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticExtinguishes",
	DisplayName = "Extinguishes",
	FullDisplayName = "Extinguishes",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticExtinguishes = StatisticsLibrary.Info.StatisticExtinguishes
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticExtinguishesPlayers",
	DisplayName = "players",
	FullDisplayName = (not statisticExtinguishes and "" or statisticExtinguishes.FullDisplayName .. " " or "") .. "players",
	IsStatisticFolder = false,
	ParentDataName = "StatisticExtinguishes",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticExtinguishes and statisticExtinguishes.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticExtinguishes2 = StatisticsLibrary.Info.StatisticExtinguishes
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticExtinguishesMolotovs",
	DisplayName = "molotovs",
	FullDisplayName = (not statisticExtinguishes2 and "" or statisticExtinguishes2.FullDisplayName .. " " or "") .. "molotovs",
	IsStatisticFolder = false,
	ParentDataName = "StatisticExtinguishes",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticExtinguishes2 and statisticExtinguishes2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticExtinguishes3 = StatisticsLibrary.Info.StatisticExtinguishes
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticExtinguishesFlareGuns",
	DisplayName = "flare guns",
	FullDisplayName = (not statisticExtinguishes3 and "" or statisticExtinguishes3.FullDisplayName .. " " or "") .. "flare guns",
	IsStatisticFolder = false,
	ParentDataName = "StatisticExtinguishes",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticExtinguishes3 and statisticExtinguishes3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticExtinguishes4 = StatisticsLibrary.Info.StatisticExtinguishes
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticExtinguishesFlamethrowers",
	DisplayName = "flamethrowers",
	FullDisplayName = (not statisticExtinguishes4 and "" or statisticExtinguishes4.FullDisplayName .. " " or "") .. "flamethrowers",
	IsStatisticFolder = false,
	ParentDataName = "StatisticExtinguishes",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticExtinguishes4 and statisticExtinguishes4.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBlinds",
	DisplayName = "Players Blinded",
	FullDisplayName = "Players Blinded",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://17814211801"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticBlinds = StatisticsLibrary.Info.StatisticBlinds
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBlindsSelf",
	DisplayName = "self blinded",
	FullDisplayName = (not statisticBlinds and "" or statisticBlinds.FullDisplayName .. " " or "") .. "self blinded",
	IsStatisticFolder = false,
	ParentDataName = "StatisticBlinds",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticBlinds and statisticBlinds.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticBlinds2 = StatisticsLibrary.Info.StatisticBlinds
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBlindsEnemies",
	DisplayName = "enemies blinded",
	FullDisplayName = "Enemies Blinded",
	IsStatisticFolder = false,
	ParentDataName = "StatisticBlinds",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticBlinds2 and statisticBlinds2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticBlinds3 = StatisticsLibrary.Info.StatisticBlinds
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBlindsTeammates",
	DisplayName = "teammates blinded",
	FullDisplayName = (not statisticBlinds3 and "" or statisticBlinds3.FullDisplayName .. " " or "") .. "teammates blinded",
	IsStatisticFolder = false,
	ParentDataName = "StatisticBlinds",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticBlinds3 and statisticBlinds3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticSmokeds",
	DisplayName = "Players Smoked",
	FullDisplayName = "Players Smoked",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://18387088796"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticSmokeds = StatisticsLibrary.Info.StatisticSmokeds
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticSmokedsSelf",
	DisplayName = "self smoked",
	FullDisplayName = (not statisticSmokeds and "" or statisticSmokeds.FullDisplayName .. " " or "") .. "self smoked",
	IsStatisticFolder = false,
	ParentDataName = "StatisticSmokeds",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticSmokeds and statisticSmokeds.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticSmokeds2 = StatisticsLibrary.Info.StatisticSmokeds
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticSmokedsEnemies",
	DisplayName = "enemies smoked",
	FullDisplayName = "Enemies Smoked",
	IsStatisticFolder = false,
	ParentDataName = "StatisticSmokeds",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticSmokeds2 and statisticSmokeds2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticSmokeds3 = StatisticsLibrary.Info.StatisticSmokeds
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticSmokedsTeammates",
	DisplayName = "teammates smoked",
	FullDisplayName = (not statisticSmokeds3 and "" or statisticSmokeds3.FullDisplayName .. " " or "") .. "teammates smoked",
	IsStatisticFolder = false,
	ParentDataName = "StatisticSmokeds",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticSmokeds3 and statisticSmokeds3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFreezes",
	DisplayName = "Players Frozen",
	FullDisplayName = "Players Frozen",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://18428668944"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFreezes = StatisticsLibrary.Info.StatisticFreezes
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFreezesSelf",
	DisplayName = "self freezes",
	FullDisplayName = (not statisticFreezes and "" or statisticFreezes.FullDisplayName .. " " or "") .. "self freezes",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFreezes",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticFreezes and statisticFreezes.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticFreezes2 = StatisticsLibrary.Info.StatisticFreezes
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticFreezesEnemies",
	DisplayName = "enemies frozen",
	FullDisplayName = "Enemies Frozen",
	IsStatisticFolder = false,
	ParentDataName = "StatisticFreezes",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticFreezes2 and statisticFreezes2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEmpowers",
	DisplayName = "Players Empowered",
	FullDisplayName = "Players Empowered",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://86874311663826"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEmpowers = StatisticsLibrary.Info.StatisticEmpowers
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEmpowersSelf",
	DisplayName = "self empowers",
	FullDisplayName = (not statisticEmpowers and "" or statisticEmpowers.FullDisplayName .. " " or "") .. "self empowers",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEmpowers",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEmpowers and statisticEmpowers.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticEmpowers2 = StatisticsLibrary.Info.StatisticEmpowers
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticEmpowersTeammates",
	DisplayName = "teammates empowered",
	FullDisplayName = (not statisticEmpowers2 and "" or statisticEmpowers2.FullDisplayName .. " " or "") .. "teammates empowered",
	IsStatisticFolder = false,
	ParentDataName = "StatisticEmpowers",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticEmpowers2 and statisticEmpowers2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticAbsorbs",
	DisplayName = "Damage Absorbed",
	FullDisplayName = "Damage Absorbed",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://106392169866153"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticAbsorbs = StatisticsLibrary.Info.StatisticAbsorbs
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticAbsorbsBehind",
	DisplayName = "from behind",
	FullDisplayName = (not statisticAbsorbs and "" or statisticAbsorbs.FullDisplayName .. " " or "") .. "from behind",
	IsStatisticFolder = false,
	ParentDataName = "StatisticAbsorbs",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticAbsorbs and statisticAbsorbs.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBounces",
	DisplayName = "Players Bounced",
	FullDisplayName = "Players Bounced",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://18436038478"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticBounces = StatisticsLibrary.Info.StatisticBounces
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBouncesSelf",
	DisplayName = "self bounces",
	FullDisplayName = (not statisticBounces and "" or statisticBounces.FullDisplayName .. " " or "") .. "self bounces",
	IsStatisticFolder = false,
	ParentDataName = "StatisticBounces",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticBounces and statisticBounces.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticBounces2 = StatisticsLibrary.Info.StatisticBounces
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBouncesTeammates",
	DisplayName = "teammates bounced",
	FullDisplayName = (not statisticBounces2 and "" or statisticBounces2.FullDisplayName .. " " or "") .. "teammates bounced",
	IsStatisticFolder = false,
	ParentDataName = "StatisticBounces",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticBounces2 and statisticBounces2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticBounces3 = StatisticsLibrary.Info.StatisticBounces
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBouncesEnemies",
	DisplayName = "enemies bounced",
	FullDisplayName = (not statisticBounces3 and "" or statisticBounces3.FullDisplayName .. " " or "") .. "enemies bounced",
	IsStatisticFolder = false,
	ParentDataName = "StatisticBounces",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticBounces3 and statisticBounces3.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticVortexesSpawned",
	DisplayName = "Vortexes Spawned",
	FullDisplayName = "Vortexes Spawned",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticPortalsSpawned",
	DisplayName = "Portals Spawned",
	FullDisplayName = "Portals Spawned",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://76793585944473"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticWarps",
	DisplayName = "Warps",
	FullDisplayName = "Warps",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://17735783844"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticLeaps",
	DisplayName = "Leaps",
	FullDisplayName = "Leaps",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticSlams",
	DisplayName = "Slams",
	FullDisplayName = "Slams",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticSlams = StatisticsLibrary.Info.StatisticSlams
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticSlamsHits",
	DisplayName = "hits",
	FullDisplayName = (not statisticSlams and "" or statisticSlams.FullDisplayName .. " " or "") .. "hits",
	IsStatisticFolder = false,
	ParentDataName = "StatisticSlams",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticSlams and statisticSlams.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticZombies",
	DisplayName = "Zombies",
	FullDisplayName = "Zombies",
	IsStatisticFolder = true,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticZombies = StatisticsLibrary.Info.StatisticZombies
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = true,
	DataName = "StatisticZombiesDamageDealt",
	DisplayName = "damage dealt",
	FullDisplayName = (not statisticZombies and "" or statisticZombies.FullDisplayName .. " " or "") .. "damage dealt",
	IsStatisticFolder = false,
	ParentDataName = "StatisticZombies",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticZombies and statisticZombies.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticZombies2 = StatisticsLibrary.Info.StatisticZombies
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = true,
	DataName = "StatisticZombiesEliminations",
	DisplayName = "eliminations",
	FullDisplayName = (not statisticZombies2 and "" or statisticZombies2.FullDisplayName .. " " or "") .. "eliminations",
	IsStatisticFolder = false,
	ParentDataName = "StatisticZombies",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticZombies2 and statisticZombies2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticHooks",
	DisplayName = "Hooks",
	FullDisplayName = "Hooks",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = "rbxassetid://101933751328343"
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticHooks = StatisticsLibrary.Info.StatisticHooks
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticHooksEnvironment",
	DisplayName = "environment",
	FullDisplayName = (not statisticHooks and "" or statisticHooks.FullDisplayName .. " " or "") .. "environment",
	IsStatisticFolder = false,
	ParentDataName = "StatisticHooks",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticHooks and statisticHooks.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticHooks2 = StatisticsLibrary.Info.StatisticHooks
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticHooksEnemies",
	DisplayName = "enemies",
	FullDisplayName = "Enemies Hooked",
	IsStatisticFolder = false,
	ParentDataName = "StatisticHooks",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticHooks2 and statisticHooks2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticThrows",
	DisplayName = "Throws",
	FullDisplayName = "Throws",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticThrows = StatisticsLibrary.Info.StatisticThrows
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticThrowsPierces",
	DisplayName = "enemies pierced",
	FullDisplayName = (not statisticThrows and "" or statisticThrows.FullDisplayName .. " " or "") .. "enemies pierced",
	IsStatisticFolder = false,
	ParentDataName = "StatisticThrows",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticThrows and statisticThrows.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticThrows2 = StatisticsLibrary.Info.StatisticThrows
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticThrowsWalls",
	DisplayName = "walls hit",
	FullDisplayName = (not statisticThrows2 and "" or statisticThrows2.FullDisplayName .. " " or "") .. "walls hit",
	IsStatisticFolder = false,
	ParentDataName = "StatisticThrows",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticThrows2 and statisticThrows2.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticPaintGrenades",
	DisplayName = "Paint Grenades",
	FullDisplayName = "Paint Grenades",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
local statisticPaintGrenades = StatisticsLibrary.Info.StatisticPaintGrenades
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticPaintGrenadesHits",
	DisplayName = "hits",
	FullDisplayName = (not statisticPaintGrenades and "" or statisticPaintGrenades.FullDisplayName .. " " or "") .. "hits",
	IsStatisticFolder = false,
	ParentDataName = "StatisticPaintGrenades",
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = statisticPaintGrenades and statisticPaintGrenades.Image or ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)
ReplicatedStorage = {
	Index = #StatisticsLibrary.Order + 1,
	IsCareerStatistic = true,
	OnlyDisplayNonZero = nil,
	DataName = "StatisticBackstabs",
	DisplayName = "Backstabs",
	FullDisplayName = "Backstabs",
	IsStatisticFolder = false,
	ParentDataName = nil,
	DefaultValue = 0,
	ValueType = "number",
	TostringFunction = pretty_number_tostring,
	Image = ""
}
StatisticsLibrary.Info[ReplicatedStorage.DataName] = ReplicatedStorage
table.insert(StatisticsLibrary.Order, ReplicatedStorage.DataName)

local function add_item(p, items, descriptions)
	local dataNames = {}

	for _, item in pairs(items) do
		table.insert(dataNames, "Statistic" .. item)
	end

	StatisticsLibrary.Items[p] = {
		DataNames = dataNames,
		Descriptions = descriptions
	}
end

add_item("MISSING_WEAPON", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Note to self" }
})
add_item("Flare Gun", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Shoots a fireball that constantly burns nearby enemies" }
})
add_item("Assault Rifle", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "A standard rifle useful in all scenarios" }
})
add_item("Handgun", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "A reliable sidearm useful in all scenarios" }
})
add_item("Burst Rifle", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Hit and run with this three-round burst rifle" }
})
add_item("Sniper", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtNoscope",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsNoscope",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Long ranged rifle that can deal devastating damage" }
})
add_item("RPG", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHitsSelf",
	"UsesHits",
	"UsesHitPercent",
	"UsesHitsDirect",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "A powerful explosive launcher" }
})
add_item("Shorty", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "A quick sidearm that can be deadly up close" }
})
add_item("Shotgun", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Deadly up close" }
})
add_item("Bow", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Projectile weapon that rewards accuracy" },
	{ 2, "Charge up your arrows to deal heavy damage" },
	{ 1, "Allows you to double jump" }
})
add_item("Uzi", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Light enemies up with this automatic sidearm" },
	{ 1, "Slightly inaccurate" }
})
add_item("Revolver", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "A slow but powerful handgun" },
	{ 2, "Fan the hammer to unload the entire chamber" }
})
add_item("Paintball Gun", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"PaintGrenades",
	"PaintGrenadesHits",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Splatter your enemies screens with this colorful rifle" }
})
add_item("Slingshot", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtBouncing",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsBouncing",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Unleash a barrage of bouncy balls" }
})
add_item("Grenade Launcher", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHitsSelf",
	"UsesHits",
	"UsesHitPercent",
	"UsesHitsDirect",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Quickly rain explosives on your enemies" },
	{ 2, "Switch between impact grenades and bouncy grenades" }
})
add_item("Minigun", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Probably dangerous" }
})
add_item("Exogun", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Pew pew pew" }
})
add_item("Fists", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Allows you to double jump" }
})
add_item("Knife", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Backstabs",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Backstab enemies for an instant elimination" }
})
add_item("Chainsaw", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Mow enemies down at frightening speeds" }
})
add_item("Katana", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtDeflecting",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsDeflecting",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Deflects",
	"DeflectsHits",
	"DeflectsCriticalHits",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Can deflect bullets back at enemies" }
})
add_item("Scythe", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtDashing",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsDashing",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Dashes",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Allows you to quickly dash in any direction" }
})
add_item("Trowel", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"WallsBuilt",
	"WallsBuiltBricksLayed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Build walls to defend yourself" },
	{ 2, "Send the bricks flying to harden them in place" }
})
add_item("Grenade", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHitsSelf",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Quick & reliable explosive" }
})
add_item("Molotov", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "An unethical way of setting your enemies on fire" }
})
add_item("Flashbang", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Blinds",
	"BlindsSelf",
	"BlindsEnemies",
	"BlindsTeammates",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Blinds enemies for a long time" }
})
add_item("Smoke Grenade", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Smokeds",
	"SmokedsSelf",
	"SmokedsEnemies",
	"SmokedsTeammates",
	"Extinguishes",
	"ExtinguishesPlayers",
	"ExtinguishesMolotovs",
	"ExtinguishesFlareGuns",
	"ExtinguishesFlamethrowers",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 3, "Creates a smoke cloud which obscures vision and extinguishes all flames" }
})
add_item("Medkit", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"Deaths",
	"Uses",
	"UsesQuick",
	"Inspects",
	"InspectsAfterElimination",
	"HealsGiven"
}, {
	{ 2, "Allows you to heal in the midst of a battle" }
})
add_item("Subspace Tripmine", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHitsSelf",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 3, "An invisible explosive that deals heavy damage and sends enemies flying" }
})
add_item("Flamethrower", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Airblasts",
	"AirblastsHits",
	"AirblastsSmokesCleared",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Set your enemies on fire" },
	{ 2, "Use the Airblast to push enemies & smoke clouds" }
})
add_item("Freeze Ray", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Freezes",
	"FreezesSelf",
	"FreezesEnemies"
}, {
	{ 2, "Freeze your enemies with this splash projectile weapon" }
})
add_item("Elixir", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHitsSelf",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"HealsGiven",
	"HealsGivenTeammates",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Splash your enemies to deal damage over time" },
	{ 2, "Splash your teammates to heal over time" }
})
add_item("War Horn", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"Deaths",
	"Uses",
	"UsesQuick",
	"Inspects",
	"InspectsAfterElimination",
	"Empowers",
	"EmpowersSelf",
	"EmpowersTeammates"
}, {
	{ 2, "Charge your team into battle with this global speed boost" }
})
add_item("Satchel", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHitsSelf",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Stick multiple explosive charges onto walls" },
	{ 2, "Detonate or shoot the satchels to cause a chain explosion" },
	{ 1, "Can stick to Riot Shields" }
})
add_item("Battle Axe", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtDashing",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsDashing",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Dashes",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Use the spin attack to slice through the competition" }
})
add_item("Riot Shield", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtDeflecting",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsDeflecting",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Absorbs",
	"AbsorbsBehind",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Shove your enemies out of the way" },
	{ 1, "Absorbs most damage sources" },
	{ 2, "Absorbs damage from behind while unequipped" }
})
add_item("Scepter", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Casts a magic spell that grows in speed & power" }
})
add_item("Daggers", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Burst your enemies down with these nimble projectiles" },
	{ 1, "Allows you to double jump" }
})
add_item("Energy Pistols", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Harness the power of laser beams" }
})
add_item("Energy Rifle", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtBouncing",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsBouncing",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Shoots a beam of energy that can bounce off walls" }
})
add_item("Spray", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "This five-round burst pistol might be illegal" },
	{ 3, "Loaded with illegally-modified armor-piercing-rounds that break through shields & deflects" }
})
add_item("Crossbow", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "An agile, long-ranged weapon" }
})
add_item("Gunblade", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtGunMode",
	"DamageDealtBladeMode",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsGunMode",
	"EliminationsBladeMode",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Dashes",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Shoot an enemy to switch to Blade Mode" },
	{ 2, "Slash an enemy to switch to Gun Mode" },
	{ 1, "Aim while in Gun Mode" },
	{ 1, "Dash while in Blade Mode" }
})
add_item("Jump Pad", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"Deaths",
	"Uses",
	"UsesQuick",
	"Inspects",
	"InspectsAfterElimination",
	"Bounces",
	"BouncesSelf",
	"BouncesTeammates",
	"BouncesEnemies"
}, {
	{ 2, "Place down a jump pad for all players to use" }
})
add_item("Glass Cannon", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "The weakest yet strongest weapon" }
})
add_item("Glast Shard", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Literally a piece of glass" }
})
add_item("RNG Dice", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"Deaths",
	"Uses",
	"UsesQuick",
	"Inspects",
	"InspectsAfterElimination"
}, {
	{ 2, "Is today your lucky day?" }
})
add_item("Distortion", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"VortexesSpawned",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Trap players inside a gravitational vortex" }
})
add_item("Warper", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"Deaths",
	"Uses",
	"Inspects",
	"InspectsAfterElimination",
	"PortalsSpawned"
}, {
	{ 2, "Spawn two portals and instantly warp from one place to another" }
})
add_item("Warpstone", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Warps",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Throw this odd stone to instantly warp away from danger" }
})
add_item("Maul", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"DamageDealtDashing",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"EliminationsDashing",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"Leaps",
	"Slams",
	"SlamsHits",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "A slow, powerful weapon that pushes enemies" },
	{ 2, "Use your ability while grounded to leap into the air" },
	{ 2, "Use your ability while airborne to slam into the ground" }
})
add_item("Permafrost", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Freezes",
	"FreezesSelf",
	"FreezesEnemies",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Slow your enemies down with these chilled bullets" },
	{ 2, "Throw whatever's left of your magazine to freeze your enemies" }
})
add_item("Spear", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesQuick",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Throws",
	"ThrowsPierces",
	"ThrowsWalls",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 1, "Poke enemies from a distance" },
	{ 2, "Throw this at your enemies to pierce through them" },
	{ 2, "Throw this at a wall for it to stick and help you jump over" }
})
add_item("Grappler", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"Deaths",
	"Uses",
	"UsesQuick",
	"Inspects",
	"InspectsAfterElimination",
	"Hooks",
	"HooksEnvironment",
	"HooksEnemies"
}, {
	{ 1, "Pull yourself towards any wall" },
	{ 1, "Pull enemies towards you" }
})
add_item("Wildcat", {
	"Playtime",
	"PlaytimeUnequipped",
	"RoundsPlayed",
	"RoundsWon",
	"RoundsLost",
	"RoundsWinPercent",
	"RankedRoundsPlayed",
	"RankedRoundsWon",
	"RankedRoundsLost",
	"RankedRoundsWinPercent",
	"DamageDealt",
	"DamageDealtSliding",
	"DamageDealtCrouching",
	"DamageDealtAirborne",
	"DamageDealtBlinded",
	"DamageDealtDead",
	"Eliminations",
	"EliminationsSliding",
	"EliminationsCrouching",
	"EliminationsAirborne",
	"EliminationsBlinded",
	"EliminationsDead",
	"Deaths",
	"DeathsRatio",
	"Assists",
	"AssistsDead",
	"Uses",
	"UsesHits",
	"UsesHitPercent",
	"UsesCriticalHits",
	"UsesCriticalHitPercent",
	"Inspects",
	"InspectsAfterElimination",
	"AmmoUsed",
	"Reloads",
	"Zombies",
	"ZombiesDamageDealt",
	"ZombiesEliminations"
}, {
	{ 2, "Pull downwards while shooting to control the recoil" },
	{ 3, "Jungle-style magazines allow you to reload quicker than usual" }
})

local function add_map(k, options)
	local v = {
		"Playtime",
		"RoundsPlayed",
		"RoundsWon",
		"RoundsLost",
		"RoundsWinPercent",
		"RankedRoundsPlayed",
		"RankedRoundsWon",
		"RankedRoundsLost",
		"RankedRoundsWinPercent",
		"DamageDealt",
		"DamageDealtSliding",
		"DamageDealtCrouching",
		"DamageDealtAirborne",
		"DamageDealtBlinded",
		"DamageDealtDead",
		"Eliminations",
		"EliminationsSliding",
		"EliminationsCrouching",
		"EliminationsAirborne",
		"EliminationsBlinded",
		"EliminationsDead",
		"Deaths",
		"DeathsRatio",
		"Assists",
		"AssistsDead"
	}

	for _, v2 in pairs(options or {}) do
		table.insert(v, v2)
	end

	local dataNames = {}

	for _, v3 in pairs(v) do
		table.insert(dataNames, "Statistic" .. v3)
	end

	StatisticsLibrary.Maps[k] = {
		DataNames = dataNames
	}
end

for k, _ in pairs(DuelLibrary.Maps) do
	add_map(k, k == "Zombie Tower" and {
		"Zombies",
		"ZombiesDamageDealt",
		"ZombiesEliminations",
		"ZombiesEliminations"
	} or nil)
end

local function generate_visible_career_statistics()
	local v = {}

	for _, v2 in pairs(ShopLibrary:GetReleasedOwnableWeapons(CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET)) do
		v[v2] = true
	end

	StatisticsLibrary.CareerStatistics = StatisticsLibrary:GetCareerStatistics(v)
end

generate_visible_career_statistics()

-- equivalent calls inferred from this helper; original call sites unknown
local function assert_items()
	for k in pairs(ItemLibrary.Items) do
		assert(StatisticsLibrary.Items[k], k)
	end
end

assert_items() -- equivalent call inferred; original call site unknown
return StatisticsLibrary