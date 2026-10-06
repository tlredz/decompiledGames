local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local Perks = require(script.Parent.Perks)
local Items = require(script.Parent.Items)
local AdminPanel = {
	PublishInterval = 30,
	ServerExpiration = 120,
	CacheTime = 10,
	PollInterval = 10,
	RequestCooldown = 1,
	Window = 3600,
	BucketSize = 60,
	MaximumRecent = 5,
	MaximumNameLength = 50,
	MaximumServers = 1000,
	RangeSize = 200,
	CloseTimeout = 15,
	CloseAttempts = 3,
	CloseRetryDelay = 2,
	Shards = 32,
	MetricsInterval = 300,
	MetricsJitter = 60,
	HistoryDays = 7,
	ReadDays = 8,
	HistoryCacheTime = 60,
	FinalDelay = 300,
	CleanupDays = { 8, 9, 10 },
	MaximumKeys = 3000,
	MaximumListRows = 12,
	MetricsVersion = 1,
	DaySeconds = 86400,
	LeaderboardSize = 50,
	LeaderboardInterval = 300,
	StudioLeaderboardInterval = 30,
	LeaderboardCategory = "Global",
	GemLeaderboards = {
		{
			Name = "PaidGems",
			Title = "Paid Gems",
			Balance = "Paid"
		},
		{
			Name = "FreeGems",
			Title = "Free Gems",
			Balance = "Free"
		}
	},
	Categories = {
		{
			Name = "Live Players",
			Icon = "rbxassetid://136371292922830",
			Index = 1
		},
		{
			Name = "Overview",
			Icon = "rbxassetid://117500711948184",
			Index = 2
		},
		{
			Name = "Onboarding",
			Icon = not Perks["Player Exp"] and "rbxassetid://136371292922830" or Perks["Player Exp"].Icon or "rbxassetid://136371292922830",
			Index = 3
		},
		{
			Name = "Economy & Gacha",
			Icon = not Perks.Yen and "rbxassetid://136371292922830" or Perks.Yen.Icon or "rbxassetid://136371292922830",
			Index = 4
		},
		{
			Name = "Monetization",
			Icon = not Items.List["Paid Gems"] and "rbxassetid://136371292922830" or Items.List["Paid Gems"].Icon or "rbxassetid://136371292922830",
			Index = 5
		},
		{
			Name = "Gamemodes & Content",
			Icon = Perks.Damage and Perks.Damage.Icon or "rbxassetid://136371292922830",
			Index = 6
		},
		{
			Name = "Social",
			Icon = "rbxassetid://136371292922830",
			Index = 7
		},
		{
			Name = "Technical",
			Icon = "rbxassetid://111947316002334",
			Index = 8
		},
		{
			Name = "Trades",
			Icon = "rbxassetid://136371292922830",
			Index = 9
		},
		{
			Name = "Gems Leaderboard",
			Icon = Items.List["Free Gems"] and Items.List["Free Gems"].Icon or "rbxassetid://136371292922830",
			Index = 10
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsFinite(value)
	return typeof(value) == "number" and math.isfinite(value)
end

local function Format(value)
	local v

	if typeof(value) == "number" then
		v = math.isfinite(value)
	else
		v = false
	end

	if v then
		return module:Format((math.floor(value)))
	end

	return "0"
end

local function FormatDuration(value)
	local v

	if typeof(value) == "number" then
		v = math.isfinite(value)
	else
		v = false
	end

	if not v then
		return "0s"
	end

	local v2 = math.max(0, (math.floor(value)))

	if v2 < 60 then
		return (`{v2}s`)
	end

	if v2 < 600 then
		return (`{math.floor(v2 / 60)}m {v2 % 60}s`)
	end

	if v2 < 3600 then
		return (`{math.floor(v2 / 60)}m`)
	end

	return (`{math.floor(v2 / 3600)}h {math.floor(v2 % 3600 / 60)}m`)
end

local function FormatMinutes(value)
	local v2

	if typeof(value) == "number" then
		v2 = math.isfinite(value)
	else
		v2 = false
	end

	local v3

	if v2 then
		v3 = value * 60
	end

	return (FormatDuration(v3))
end

local function FormatPercent(value)
	local v

	if typeof(value) == "number" then
		v = math.isfinite(value)
	else
		v = false
	end

	if v then
		return (`{module:FormatDecimal(math.floor(value * 10 + 0.5) / 10)}%`)
	end

	return "0%"
end

local function FormatSeconds(value)
	local v

	if typeof(value) == "number" then
		v = math.isfinite(value)
	else
		v = false
	end

	if v then
		return (`{module:FormatDecimal(math.floor(value * 10 + 0.5) / 10)}s`)
	end

	return "0s"
end

local v = {
	Number = Format,
	Duration = FormatDuration,
	Minutes = FormatMinutes,
	Percent = FormatPercent,
	Seconds = FormatSeconds
}

local function GetSorted(options)
	local result = {}

	for k, amount in options or {} do
		if typeof(k) ~= "string" then
			continue
		end

		local v3

		if typeof(amount) == "number" then
			v3 = math.isfinite(amount)
		else
			v3 = false
		end

		if not v3 or amount <= 0 then
			continue
		end

		table.insert(result, {
			Name = k,
			Amount = amount
		})
	end

	table.sort(result, function(a, b)
		if a.Amount == b.Amount then
			return a.Name < b.Name
		end

		return a.Amount > b.Amount
	end)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddMetric(list, p: string, title: string, desc: string, p4: string, week: string?, label: string?)
	table.insert(list, {
		Key = p,
		Kind = "Metric",
		Title = title,
		Desc = desc,
		Value = p4,
		Week = week,
		Label = label
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddDivider(list, p: string, title: string)
	table.insert(list, {
		Key = p,
		Kind = "Divider",
		Title = title
	})
end

local function AddLiveList(list, p: string, title: string, desc: string, p4)
	local sorted = GetSorted(p4)

	if #sorted == 0 then
		return
	end

	AddDivider(list, `Divider:{p}`, title) -- equivalent call inferred; original call site unknown

	for _, v3 in sorted do
		local formatted = `{p}:{v3.Name}`
		local name = v3.Name
		local amount = v3.Amount
		AddMetric(
			list,
			formatted,
			name,
			desc,
			not IsFinite(amount) and "0" or module:Format((math.floor(amount))),
			nil,
			"Now"
		) -- equivalent call inferred; original call site unknown
	end
end

local function ParseMetrics(items)
	local result = {}

	if typeof(items) ~= "table" then
		return result
	end

	for k, item in items do
		if not (typeof(k) == "string" and typeof(item) == "table") then
			continue
		end

		local v2 = item[1]
		local v3

		if typeof(v2) == "number" then
			v3 = math.isfinite(v2)
		else
			v3 = false
		end

		if not v3 then
			continue
		end

		local v4 = item[2]
		local v5

		if typeof(v4) == "number" then
			v5 = math.isfinite(v4)
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		local fields = string.split(k, "|")
		local v7 = table.remove(fields, 1)
		local v8 = result[v7]

		if not v8 then
			v8 = {}
			result[v7] = v8
		end

		table.insert(v8, {
			Fields = fields,
			Count = item[1],
			Sum = item[2]
		})
	end

	return result
end

local function MergeMetrics(p, items)
	if typeof(items) ~= "table" then
		return
	end

	for k, item in items do
		if not (typeof(k) == "string" and typeof(item) == "table") then
			continue
		end

		local v2 = item[1]
		local v3

		if typeof(v2) == "number" then
			v3 = math.isfinite(v2)
		else
			v3 = false
		end

		if not v3 then
			continue
		end

		local v4 = item[2]
		local v5

		if typeof(v4) == "number" then
			v5 = math.isfinite(v4)
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		local v6 = p[k]

		if v6 then
			v6[1] += item[1]
			v6[2] += item[2]
		else
			p[k] = { item[1], item[2] }
		end
	end
end

local function Matches(fields, items)
	if not items then
		return true
	end

	for k, item in items do
		local v2 = fields[k]

		if typeof(item) == "function" then
			if not item(v2) then
				return false
			end
		elseif v2 ~= item then
			return false
		end
	end

	return true
end

local function Total(p, p2: string, p3)
	local total = 0
	local total2 = 0

	for _, v2 in p[p2] or {} do
		if not Matches(v2.Fields, p3) then
			continue
		end

		total += v2.Count
		total2 += v2.Sum
	end

	return total, total2
end

local function Group(p, p2: string, p3: number, p4, p5: number?)
	local result = {}

	for _, v2 in p[p2] or {} do
		if not Matches(v2.Fields, p4) then
			continue
		end

		local v3 = v2.Fields[p3] or ""

		if v3 == "" then
			continue
		end

		local v4 = result[v3]

		if not v4 then
			v4 = {
				Count = 0,
				Sum = 0,
				Title = 0
			}
			local title

			if p5 then
				title = v2.Fields[p5]
			else
				title = v3
			end

			v4.Title = title
			result[v3] = v4
		end

		v4.Count += v2.Count
		v4.Sum += v2.Sum
	end

	return result
end

local function Measure(p: number, p2: number, p3: string)
	if p3 == "Count" then
		return p
	elseif p3 == "Sum" then
		return p2
	end

	if p3 ~= "Average" then
		return nil
	end

	if p > 0 then
		return p2 / p
	end

	return nil
end

local function Display(p: number?, p2: string)
	if p == nil then
		return "-"
	end

	return v[p2](p)
end

local function AddStat(list, p, p2: string, title: string, desc: string, p5: string, p6: string, p7: string, p8)
	local v2, v3 = Total(p.Today, p5, p8)
	local v4, v5 = Total(p.Week, p5, p8)

	if p6 == "Count" then
		v3 = v2
	elseif p6 ~= "Sum" then
		if p6 == "Average" and v2 > 0 then
			v3 /= v2
		else
			v3 = nil
		end
	end

	local v6 = v3 == nil and "-" or v[p7](v3)

	if p6 == "Count" then
		v5 = v4
	elseif p6 ~= "Sum" then
		if p6 == "Average" and v4 > 0 then
			v5 /= v4
		else
			v5 = nil
		end
	end

	local v7, v8

	if v5 == nil then
		v7 = "-"
	else
		v7, v8 = v[p7](v5)
	end

	AddMetric(list, p2, title, desc, v6, v7, v8) -- equivalent call inferred; original call site unknown
end

local function AddGroup(list, p, data)
	local group = Group(p.Week, data.Name, data.Field, data.Filter, data.TitleField)
	local group2 = Group(p.Today, data.Name, data.Field, data.Filter, data.TitleField)
	local mode = data.Mode
	local v4 = mode == "Share" or mode == "CountShare"
	local v5 = mode == "CountShare" and "Count" or mode == "Share" and "Sum" or mode
	local total = 0
	local v6 = {}
	local total2 = 0

	for k, v7 in group do
		local count = v7.Count
		local sum = v7.Sum

		if v5 == "Count" then
			sum = count
		elseif v5 ~= "Sum" then
			if v5 == "Average" and count > 0 then
				sum /= count
			else
				sum = nil
			end
		end

		total += sum or 0
		local v8 = {
			Key = k,
			Title = v7.Title,
			Week = 0
		}
		local count2 = v7.Count
		local sum2 = v7.Sum

		if v5 == "Count" then
			sum2 = count2
		elseif v5 ~= "Sum" then
			if v5 == "Average" and count2 > 0 then
				sum2 /= count2
			else
				sum2 = nil
			end
		end

		v8.Week = sum2
		table.insert(v6, v8)
	end

	if #v6 == 0 then
		return
	end

	for _, v7 in group2 do
		local count = v7.Count
		local sum = v7.Sum

		if v5 == "Count" then
			sum = count
		elseif v5 ~= "Sum" then
			if v5 == "Average" and count > 0 then
				sum /= count
			else
				sum = nil
			end
		end

		total2 += sum or 0
	end

	if data.Order == "Numeric" then
		table.sort(v6, function(a, b)
			return (tonumber(a.Key) or 0) < (tonumber(b.Key) or 0)
		end)
	else
		table.sort(v6, function(a, b)
			if (a.Week or 0) == (b.Week or 0) then
				return a.Key < b.Key
			end

			return (a.Week or 0) > (b.Week or 0)
		end)
	end

	table.insert(list, {
		Key = `Divider:{data.Prefix}`,
		Kind = "Divider",
		Title = data.Title
	})
	local limit = data.Limit or AdminPanel.MaximumListRows

	for k, v7 in v6 do
		if limit < k then
			break
		end

		local v8 = group2[v7.Key]
		local sum

		if v8 then
			local count = v8.Count
			sum = v8.Sum

			if v5 == "Count" then
				sum = count
			elseif v5 ~= "Sum" then
				if v5 == "Average" and count > 0 then
					sum /= count
				else
					sum = nil
				end
			end
		else
			sum = v5 ~= "Average" and 0 or nil
		end

		local week = v7.Week

		if v4 then
			if total2 > 0 then
				sum = 100 * (sum or 0) / total2
			else
				sum = nil
			end

			if total > 0 then
				week = 100 * (week or 0) / total
			else
				week = nil
			end
		end

		local formatted = `{data.Prefix}:{v7.Key}`
		local title = v7.Title or v7.Key
		local desc = data.Desc
		local format = data.Format
		local v9 = sum == nil and "-" or v[format](sum)
		local format2 = data.Format
		local v10, v11

		if week == nil then
			v10 = "-"
		else
			v10, v11 = v[format2](week)
		end

		AddMetric(list, formatted, title, desc, v9, v10, v11) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDayCount(p, p2: number, p3: string, p4)
	local day = p.Days[p2]

	if day then
		return (Total(day, p3, p4))
	end

	return 0
end

local function AddRetention(list, p, p2: number)
	local v2 = { (`D{p2}`) }
	local dayCount = GetDayCount(p, p2 + 1, "NewPlayer", nil) -- equivalent call inferred; original call site unknown
	local dayCount2 = GetDayCount(p, 1, "PlayerReturned", v2) -- equivalent call inferred; original call site unknown
	local v6

	if dayCount > 0 then
		v6 = dayCount2 * 100 / dayCount
	end

	local v7 = AdminPanel.ReadDays - p2
	local week

	if v7 >= 2 then
		local total = 0
		local total2 = 0

		for i = 2, v7 do
			total += GetDayCount(p, i, "PlayerReturned", v2)
			total2 += GetDayCount(p, i + p2, "NewPlayer", nil)
		end

		local v9

		if total2 > 0 then
			v9 = total * 100 / total2
		end

		if v9 == nil then
			week = "-"
		else
			week = v.Percent(v9)
		end
	else
		week = "-"
	end

	table.insert(list, {
		Key = `Retention:D{p2}`,
		Kind = "Metric",
		Title = `D{p2} Retention`,
		Desc = `New players back on day {p2}; 7d uses closed days`,
		Value = v6 == nil and "-" or v.Percent(v6),
		Week = week,
		Label = nil
	})
end

local function BuildLive(list, p)
	local players = p.Players or {}
	local online = players.Online
	AddMetric(
		list,
		"Online",
		"Players Online",
		"All servers, staff excluded",
		not IsFinite(online) and "0" or module:Format((math.floor(online))),
		nil,
		"Now"
	) -- equivalent call inferred; original call site unknown
	local servers = p.Servers
	AddMetric(
		list,
		"Servers",
		"Active Servers",
		"Servers that reported in the last 2 minutes",
		not IsFinite(servers) and "0" or module:Format((math.floor(servers))),
		nil,
		"Now"
	) -- equivalent call inferred; original call site unknown
	local new = players.New
	AddMetric(
		list,
		"New",
		"New Players",
		"In their first session",
		not IsFinite(new) and "0" or module:Format((math.floor(new))),
		nil,
		"Now"
	) -- equivalent call inferred; original call site unknown
	local returning = players.Returning
	AddMetric(
		list,
		"Returning",
		"Returning Players",
		"Played before",
		not IsFinite(returning) and "0" or module:Format((math.floor(returning))),
		nil,
		"Now"
	) -- equivalent call inferred; original call site unknown
	AddLiveList(list, "Map", "By Map", "Players online", players.Maps)
	AddLiveList(list, "Gamemode", "In Gamemode", "Players inside", players.Gamemodes)
end

local function BuildOverview(list, view)
	AddStat(
		list,
		view,
		"Active",
		"Active Players",
		"Played that day; 7d = player-days",
		"DailyActive",
		"Count",
		"Number"
	)
	AddStat(list, view, "NewPlayers", "New Players", "First session ever", "NewPlayer", "Count", "Number")
	AddStat(list, view, "Sessions", "Sessions", "Sessions that ended", "SessionEnded", "Count", "Number")
	AddStat(list, view, "SessionLength", "Average Session", "Session length", "SessionEnded", "Average", "Duration")
	local total = Total(view.Today, "DailyActive")
	local total2 = Total(view.Week, "DailyActive")
	local _, v4 = Total(view.Today, "SessionEnded")
	local _, v5 = Total(view.Week, "SessionEnded")
	local v6

	if total > 0 then
		v6 = v4 / total
	end

	local v7 = v6 == nil and "-" or v.Duration(v6)
	local v8

	if total2 > 0 then
		v8 = v5 / total2
	end

	local v9, v10

	if v8 == nil then
		v9 = "-"
	else
		v9, v10 = v.Duration(v8)
	end

	AddMetric(list, "PlayTime", "Play Time per Player", "Per active player per day", v7, v9, v10) -- equivalent call inferred; original call site unknown
	AddDivider(list, "Divider:Retention", "Retention") -- equivalent call inferred; original call site unknown
	AddRetention(list, view, 1)
	AddRetention(list, view, 7)
end

local function BuildOnboarding(list, view)
	local group = Group(view.Week, "Onboarding", 1, nil, 2)
	local group2 = Group(view.Today, "Onboarding", 1, nil, 2)
	local v4 = not group["1"] and 0 or group["1"].Count or 0
	local v5 = {}

	for k, v6 in group do
		table.insert(v5, {
			Key = k,
			Title = v6.Title,
			Count = v6.Count
		})
	end

	table.sort(v5, function(a, b)
		return (tonumber(a.Key) or 0) < (tonumber(b.Key) or 0)
	end)

	if #v5 > 0 then
		AddDivider(list, "Divider:Onboarding", "Onboarding Steps") -- equivalent call inferred; original call site unknown

		for _, v6 in v5 do
			local v7 = group2[v6.Key]
			local v8 = not (v4 > 0) and 0 or 100 * v6.Count / v4
			local formatted = `Onboarding:{v6.Key}`
			local formatted2 = `{v6.Key}. {v6.Title}`
			local v10

			if typeof(v8) == "number" then
				v10 = math.isfinite(v8)
			else
				v10 = false
			end

			local formatted3 = `{not v10 and "0%" or `{module:FormatDecimal(math.floor(v8 * 10 + 0.5) / 10)}%`} of new players (7d)`
			local count = v7 and v7.Count or 0
			local v12 = not IsFinite(count) and "0" or module:Format((math.floor(count)))
			local count2 = v6.Count
			local v13

			if typeof(count2) == "number" then
				v13 = math.isfinite(count2)
			else
				v13 = false
			end

			local v14, v15

			if v13 then
				v14, v15 = module:Format((math.floor(count2)))
			else
				v14 = "0"
			end

			AddMetric(list, formatted, formatted2, formatted3, v12, v14, v15) -- equivalent call inferred; original call site unknown
		end
	end

	AddGroup(list, view, {
		Prefix = "Tutorial",
		Title = "Tutorial",
		Desc = "Players reaching the step",
		Name = "Funnel",
		Field = 2,
		TitleField = 3,
		Filter = { "Tutorial" },
		Mode = "Count",
		Format = "Number",
		Order = "Numeric",
		Limit = 50
	})
	AddGroup(list, view, {
		Prefix = "TutorialAnswer",
		Title = "Tutorial Answers",
		Desc = "Answers",
		Name = "TutorialAnswered",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "TutorialSkip",
		Title = "Tutorial Skipped At",
		Desc = "Skips at this step",
		Name = "TutorialSkipped",
		Field = 1,
		Mode = "Count",
		Format = "Number",
		Order = "Numeric"
	})
	AddGroup(list, view, {
		Prefix = "MainStory",
		Title = "Main Story",
		Desc = "Players reaching the step",
		Name = "Funnel",
		Field = 2,
		TitleField = 3,
		Filter = { "MainStory" },
		Mode = "Count",
		Format = "Number",
		Order = "Numeric",
		Limit = 50
	})
	AddDivider(list, "Divider:FirstSession", "First Session") -- equivalent call inferred; original call site unknown
	AddStat(
		list,
		view,
		"FirstSession",
		"First Session Length",
		"Average",
		"SessionEnded",
		"Average",
		"Duration",
		{ "1" }
	)
	AddGroup(list, view, {
		Prefix = "Load",
		Title = "Load Time by Platform",
		Desc = "Average time until playable",
		Name = "ClientLoaded",
		Field = 1,
		Mode = "Average",
		Format = "Seconds"
	})
	AddGroup(list, view, {
		Prefix = "Exit",
		Title = "Where Players Leave",
		Desc = "Sessions ending at this onboarding step",
		Name = "SessionExit",
		Field = 3,
		Filter = {
			[3] = function(p)
				return p ~= "Veteran"
			end
		},
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Source",
		Title = "New Players by Source",
		Desc = "How they joined",
		Name = "NewPlayer",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
end

local function NotAdmin(p: string?)
	return p ~= "Admin"
end

local function BuildEconomy(list, p, view, p2: number)
	local economy = p.Economy or {}
	AddDivider(list, "Divider:Hour", "Last Hour (Live Servers)") -- equivalent call inferred; original call site unknown
	local yenSource = economy.YenSource
	AddMetric(
		list,
		"Hour:YenSource",
		"Yen Earned",
		"Last hour, live servers",
		not IsFinite(yenSource) and "0" or module:Format((math.floor(yenSource))),
		nil,
		"Hour"
	) -- equivalent call inferred; original call site unknown
	local yenSink = economy.YenSink
	AddMetric(
		list,
		"Hour:YenSink",
		"Yen Spent",
		"Last hour, live servers",
		not IsFinite(yenSink) and "0" or module:Format((math.floor(yenSink))),
		nil,
		"Hour"
	) -- equivalent call inferred; original call site unknown
	local gemsSource = economy.GemsSource
	AddMetric(
		list,
		"Hour:GemsSource",
		"Gems Earned",
		"Last hour, live servers",
		not IsFinite(gemsSource) and "0" or module:Format((math.floor(gemsSource))),
		nil,
		"Hour"
	) -- equivalent call inferred; original call site unknown
	local gemsSink = economy.GemsSink
	AddMetric(
		list,
		"Hour:GemsSink",
		"Gems Spent",
		"Last hour, live servers",
		not IsFinite(gemsSink) and "0" or module:Format((math.floor(gemsSink))),
		nil,
		"Hour"
	) -- equivalent call inferred; original call site unknown
	local stars = economy.Stars
	AddMetric(
		list,
		"Hour:Stars",
		"Stars Opened",
		"Last hour, live servers",
		not IsFinite(stars) and "0" or module:Format((math.floor(stars))),
		nil,
		"Hour"
	) -- equivalent call inferred; original call site unknown
	local rarePulls = economy.RarePulls
	AddMetric(
		list,
		"Hour:RarePulls",
		"Rare Pulls",
		"Mythical or higher, last hour",
		not IsFinite(rarePulls) and "0" or module:Format((math.floor(rarePulls))),
		nil,
		"Hour"
	) -- equivalent call inferred; original call site unknown
	local recent = economy.Recent or {}

	if #recent > 0 then
		AddDivider(list, "Divider:Recent", "Recent Rare Pulls") -- equivalent call inferred; original call site unknown

		for k, v9 in recent do
			if AdminPanel.MaximumRecent < k then
				break
			else
				table.insert(list, {
					Key = `Recent:{k}`,
					Kind = "Metric",
					Title = tostring(v9.Rarity),
					Desc = tostring(v9.System),
					Value = AdminPanel.FormatAge(p2 - (v9.At or p2)),
					Week = nil,
					Label = "When"
				})
			end
		end
	end

	AddDivider(list, "Divider:Currencies", "Currencies") -- equivalent call inferred; original call site unknown
	AddStat(list, view, "YenSource", "Yen Earned", "Admin grants excluded", "Economy", "Sum", "Number", {
		[1] = "Yen",
		[2] = "Source",
		[4] = NotAdmin
	})
	AddStat(list, view, "YenSink", "Yen Spent", "All sinks", "Economy", "Sum", "Number", { "Yen", "Sink" })
	AddStat(list, view, "GemsSource", "Gems Earned", "Admin grants excluded", "Economy", "Sum", "Number", {
		[1] = "Gems",
		[2] = "Source",
		[4] = NotAdmin
	})
	AddStat(list, view, "GemsSink", "Gems Spent", "All sinks", "Economy", "Sum", "Number", { "Gems", "Sink" })
	AddStat(list, view, "AdminYen", "Admin Yen Grants", "Given by admin commands", "Economy", "Sum", "Number", {
		[1] = "Yen",
		[2] = "Source",
		[4] = "Admin"
	})
	AddGroup(list, view, {
		Prefix = "YenSourceReason",
		Title = "Yen Sources",
		Desc = "Yen earned",
		Name = "Economy",
		Field = 3,
		Filter = {
			[1] = "Yen",
			[2] = "Source",
			[4] = NotAdmin
		},
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "YenSinkReason",
		Title = "Yen Sinks",
		Desc = "Yen spent",
		Name = "Economy",
		Field = 3,
		Filter = { "Yen", "Sink" },
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "GemsSourceReason",
		Title = "Gems Sources",
		Desc = "Gems earned",
		Name = "Economy",
		Field = 3,
		Filter = {
			[1] = "Gems",
			[2] = "Source",
			[4] = NotAdmin
		},
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "GemsSinkReason",
		Title = "Gems Sinks",
		Desc = "Gems spent",
		Name = "Economy",
		Field = 3,
		Filter = { "Gems", "Sink" },
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Token",
		Title = "Tokens Moved",
		Desc = "Gained and spent",
		Name = "TokenFlow",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Wall",
		Title = "Walls by System",
		Desc = "Blocked by balance, space or policy",
		Name = "WallHit",
		Field = 2,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Lost",
		Title = "Rewards Lost",
		Desc = "Expired or no space",
		Name = "RewardLost",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Rolls",
		Title = "Rolls by System",
		Desc = "Rolls in finished sessions",
		Name = "GachaSession",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Rare",
		Title = "Rare Pulls by Rarity",
		Desc = "Mythical or higher",
		Name = "RarePull",
		Field = 2,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Pity",
		Title = "Pity by System",
		Desc = "Legendary pity hits",
		Name = "PityHit",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
end

local function BuildMonetization(list, view)
	AddDivider(list, "Divider:Sales", "Sales") -- equivalent call inferred; original call site unknown
	AddStat(list, view, "Purchases", "Purchases", "Robux purchases, own count (UTC)", "Sale", "Count", "Number")
	AddStat(list, view, "Robux", "Robux", "Own count; Roblox fees not removed", "Sale", "Sum", "Number")
	AddStat(
		list,
		view,
		"FirstRobux",
		"First Robux Purchases",
		"Players buying for the first time",
		"FirstRobuxPurchase",
		"Count",
		"Number"
	)
	AddStat(
		list,
		view,
		"FirstRobuxTime",
		"Time to First Purchase",
		"Average play time before it",
		"FirstRobuxPurchase",
		"Average",
		"Minutes"
	)
	AddStat(
		list,
		view,
		"FirstGems",
		"First Gems Purchases",
		"Players spending Gems in the shop",
		"FirstGemsPurchase",
		"Count",
		"Number"
	)
	AddStat(list, view, "Gifts", "Gifts Sent", "Robux and Gems gifts", "GiftSent", "Count", "Number")
	AddStat(
		list,
		view,
		"GiftsClaimed",
		"Gifts Claimed",
		"Gifts opened by the receiver",
		"GiftClaimed",
		"Count",
		"Number"
	)
	AddStat(
		list,
		view,
		"Revoked",
		"Gamepasses Revoked",
		"Roblox stopped reporting ownership",
		"GamepassRevoked",
		"Count",
		"Number"
	)
	AddStat(
		list,
		view,
		"ReceiptsRecovered",
		"Receipts Recovered",
		"Delivered after a retry",
		"ReceiptRecovered",
		"Count",
		"Number"
	)
	AddGroup(list, view, {
		Prefix = "Product",
		Title = "By Product",
		Desc = "Purchases",
		Name = "Sale",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "ShopFunnel",
		Title = "Shop Funnel",
		Desc = "Purchase attempts reaching the step",
		Name = "Funnel",
		Field = 2,
		TitleField = 3,
		Filter = { "ShopRobux" },
		Mode = "Count",
		Format = "Number",
		Order = "Numeric"
	})
	AddGroup(list, view, {
		Prefix = "UpsellFunnel",
		Title = "Upsell Funnel",
		Desc = "Walls reaching the step",
		Name = "Funnel",
		Field = 2,
		TitleField = 3,
		Filter = { "Upsell" },
		Mode = "Count",
		Format = "Number",
		Order = "Numeric"
	})
	AddGroup(list, view, {
		Prefix = "ShopOrigin",
		Title = "Shop Opens by Origin",
		Desc = "Where the shop was opened",
		Name = "ShopOpened",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Attempt",
		Title = "Shop Attempts",
		Desc = "Attempts by result",
		Name = "ShopAttempt",
		Field = 2,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "AttemptReason",
		Title = "Failed Attempts",
		Desc = "Why it did not go through",
		Name = "ShopAttempt",
		Field = 3,
		Filter = {
			[2] = function(p)
				return p ~= "Success"
			end
		},
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Receipt",
		Title = "Receipt Failures",
		Desc = "Not processed yet, by reason",
		Name = "ReceiptNotProcessed",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
end

local function BuildContent(list, view)
	AddDivider(list, "Divider:Matches", "Matches") -- equivalent call inferred; original call site unknown
	AddStat(
		list,
		view,
		"Matches",
		"Matches Finished",
		"Players at the end of a match",
		"GamemodeEnded",
		"Count",
		"Number"
	)
	AddStat(list, view, "MatchLength", "Average Match", "Match length", "GamemodeEnded", "Average", "Duration")
	AddStat(list, view, "LeftEarly", "Left Early", "Players who left a match", "GamemodeLeft", "Count", "Number")
	AddGroup(list, view, {
		Prefix = "Mode",
		Title = "Matches by Gamemode",
		Desc = "Players at the end",
		Name = "GamemodeEnded",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Outcome",
		Title = "Results",
		Desc = "How matches ended",
		Name = "GamemodeEnded",
		Field = 3,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Stage",
		Title = "Average Stage by Gamemode",
		Desc = "Percent of the stages reached",
		Name = "GamemodeStage",
		Field = 1,
		Mode = "Average",
		Format = "Percent"
	})
	AddGroup(list, view, {
		Prefix = "Left",
		Title = "Left Early by Gamemode",
		Desc = "Players who left",
		Name = "GamemodeLeft",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Boss",
		Title = "Bosses Killed",
		Desc = "Kills",
		Name = "BossKilled",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "BossTime",
		Title = "Boss Time to Kill",
		Desc = "Average",
		Name = "BossKilled",
		Field = 1,
		Mode = "Average",
		Format = "Duration"
	})
	AddDivider(list, "Divider:Progress", "Progress") -- equivalent call inferred; original call site unknown
	AddStat(list, view, "Prestige", "Prestiges", "Prestiges done", "PrestigeDone", "Count", "Number")
	AddGroup(list, view, {
		Prefix = "Level",
		Title = "Level Milestones",
		Desc = "Players reaching the level",
		Name = "LevelReached",
		Field = 1,
		Mode = "Count",
		Format = "Number",
		Order = "Numeric",
		Limit = 50
	})
	AddGroup(list, view, {
		Prefix = "LevelTime",
		Title = "Time to Level",
		Desc = "Average play time to reach it",
		Name = "LevelReached",
		Field = 1,
		Mode = "Average",
		Format = "Minutes",
		Order = "Numeric",
		Limit = 50
	})
	AddGroup(list, view, {
		Prefix = "MapUnlock",
		Title = "Maps Unlocked",
		Desc = "Players unlocking",
		Name = "MapUnlocked",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "MapTime",
		Title = "Time to First Visit",
		Desc = "Average play time",
		Name = "MapVisited",
		Field = 1,
		Mode = "Average",
		Format = "Minutes"
	})
	AddGroup(list, view, {
		Prefix = "QuestDone",
		Title = "Quests Completed",
		Desc = "By class",
		Name = "QuestCompleted",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "QuestClaim",
		Title = "Quests Claimed",
		Desc = "By class",
		Name = "QuestClaimed",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "QuestExpired",
		Title = "Quests Expired",
		Desc = "By state",
		Name = "QuestExpired",
		Field = 3,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Mount",
		Title = "Mounts Obtained",
		Desc = "Obtained",
		Name = "MountObtained",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "MountUse",
		Title = "Mounts Used",
		Desc = "Times mounted",
		Name = "MountUsed",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Milestone",
		Title = "Milestones Claimed",
		Desc = "By kind",
		Name = "MilestoneClaimed",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
end

local function BuildSocial(list, view)
	AddDivider(list, "Divider:Trades", "Trades") -- equivalent call inferred; original call site unknown
	AddStat(list, view, "Trades", "Trades Completed", "Counted once per trade", "TradeCompleted", "Count", "Number")
	AddStat(list, view, "TradeValue", "Average Trade Value", "RAP moved", "TradeCompleted", "Average", "Number")
	AddGroup(list, view, {
		Prefix = "Fairness",
		Title = "Trade Fairness",
		Desc = "Trades",
		Name = "TradeCompleted",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "TradeCancel",
		Title = "Trades Cancelled",
		Desc = "By reason",
		Name = "TradeCancelled",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "TradeRequest",
		Title = "Trade Requests",
		Desc = "By result",
		Name = "TradeRequest",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Guild",
		Title = "Guild Actions",
		Desc = "Actions",
		Name = "GuildAction",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Party",
		Title = "Party Actions",
		Desc = "Actions",
		Name = "PartyAction",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Campaign",
		Title = "Campaigns Received",
		Desc = "Players reached",
		Name = "CampaignReceived",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
end

local function BuildTechnical(list, view)
	AddDivider(list, "Divider:Health", "Health") -- equivalent call inferred; original call site unknown
	AddStat(list, view, "Errors", "Client Errors", "Script errors on clients", "ScriptErrors", "Sum", "Number")
	AddStat(list, view, "ProfileLoad", "Profile Load", "Average load time", "ProfileLoad", "Average", "Seconds")
	AddStat(list, view, "Idle", "Idle Time", "Average share of the session", "SessionActivity", "Average", "Percent")
	AddGroup(list, view, {
		Prefix = "ErrorSystem",
		Title = "Errors by System",
		Desc = "Client errors",
		Name = "ScriptErrors",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "ErrorPlatform",
		Title = "Errors by Platform",
		Desc = "Client errors",
		Name = "ScriptErrors",
		Field = 2,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Fps",
		Title = "Client FPS",
		Desc = "Share of samples",
		Name = "ClientPerf",
		Field = 2,
		Mode = "Share",
		Format = "Percent"
	})
	AddGroup(list, view, {
		Prefix = "Ping",
		Title = "Client Ping (ms)",
		Desc = "Share of samples",
		Name = "ClientPerf",
		Field = 3,
		Mode = "Share",
		Format = "Percent"
	})
	AddGroup(list, view, {
		Prefix = "ServerFps",
		Title = "Server FPS",
		Desc = "Share of player-minutes",
		Name = "ServerPerf",
		Field = 1,
		Mode = "Share",
		Format = "Percent"
	})
	AddGroup(list, view, {
		Prefix = "Memory",
		Title = "Server Memory (MB)",
		Desc = "Share of player-minutes",
		Name = "ServerPerf",
		Field = 2,
		Mode = "Share",
		Format = "Percent"
	})
	AddGroup(list, view, {
		Prefix = "LoadResult",
		Title = "Profile Load Results",
		Desc = "Loads",
		Name = "ProfileLoad",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Automation",
		Title = "Automation Use",
		Desc = "Share of sessions",
		Name = "SessionActivity",
		Field = 1,
		Mode = "CountShare",
		Format = "Percent"
	})
	AddGroup(list, view, {
		Prefix = "Screen",
		Title = "Screen Time",
		Desc = "Total time open",
		Name = "ScreenTime",
		Field = 1,
		Mode = "Sum",
		Format = "Duration"
	})
	AddGroup(list, view, {
		Prefix = "ScreenOpen",
		Title = "Screen Opens",
		Desc = "Times opened",
		Name = "ScreenOpens",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "Npc",
		Title = "NPC Dialogs",
		Desc = "Dialogs opened",
		Name = "NpcDialog",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
end

local function BuildTrades(list, view)
	AddGroup(list, view, {
		Prefix = "Settlement",
		Title = "Settlement Results",
		Desc = "Trades",
		Name = "TradeSettlement",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddDivider(list, "Divider:Conflicts", "Item Conflicts") -- equivalent call inferred; original call site unknown
	AddStat(
		list,
		view,
		"Conflicts",
		"Item Conflicts",
		"Item ID already in the inventory",
		"TradeConflict",
		"Count",
		"Number"
	)
	AddGroup(list, view, {
		Prefix = "ConflictStage",
		Title = "Conflicts by Stage",
		Desc = "Conflicts",
		Name = "TradeConflict",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "ConflictCategory",
		Title = "Conflicts by Category",
		Desc = "Conflicts",
		Name = "TradeConflict",
		Field = 2,
		Mode = "Count",
		Format = "Number"
	})
	AddDivider(list, "Divider:TradeGems", "Paid Gems") -- equivalent call inferred; original call site unknown
	AddStat(list, view, "TradeGems", "Paid Gems Traded", "Both sides, completed trades", "TradeGems", "Sum", "Number")
	AddStat(
		list,
		view,
		"TradeGemsTrades",
		"Trades with Gems",
		"Completed trades moving Paid Gems",
		"TradeGems",
		"Count",
		"Number"
	)
	AddStat(
		list,
		view,
		"TradeGemsAverage",
		"Average Gems per Trade",
		"Trades with Paid Gems",
		"TradeGems",
		"Average",
		"Number"
	)
	AddGroup(list, view, {
		Prefix = "TradeGemsSize",
		Title = "Trades by Gem Amount",
		Desc = "Trades",
		Name = "TradeGems",
		Field = 1,
		Mode = "Count",
		Format = "Number"
	})
	AddGroup(list, view, {
		Prefix = "TradeItems",
		Title = "Items Traded",
		Desc = "Completed trades",
		Name = "TradeItems",
		Field = 1,
		Mode = "Sum",
		Format = "Number"
	})
end

local function BuildGems(list, p)
	local gems = p.Gems or {}

	for _, gemLeaderboard in AdminPanel.GemLeaderboards do
		local v2 = gems[gemLeaderboard.Name] or {}
		table.insert(list, {
			Key = `Divider:{gemLeaderboard.Name}`,
			Kind = "Divider",
			Title = gemLeaderboard.Title
		})

		if #v2 == 0 then
			AddMetric(
				list,
				`{gemLeaderboard.Name}:Empty`,
				"No entries yet",
				"Online players are saved periodically",
				"-",
				nil,
				"Gems"
			) -- equivalent call inferred; original call site unknown
		else
			for k, v4 in v2 do
				if AdminPanel.LeaderboardSize < k then
					break
				end

				local formatted = `{gemLeaderboard.Name}:{k}`
				local formatted2 = `#{k} {v4.NickName}`
				local formatted3 = `@{v4.UserName} · ID {v4.UserId}`
				local value = v4.Value
				AddMetric(
					list,
					formatted,
					formatted2,
					formatted3,
					not IsFinite(value) and "0" or module:Format((math.floor(value))),
					nil,
					"Gems"
				) -- equivalent call inferred; original call site unknown
			end
		end
	end
end

function AdminPanel.IsFinite(value)
	return IsFinite(value)
end

function AdminPanel.GetDay(p: number)
	return os.date("!%Y-%m-%d", p)
end

function AdminPanel.GetPastDay(p: number, p2: number)
	return AdminPanel.GetDay(p - p2 * AdminPanel.DaySeconds)
end

function AdminPanel.GetServersName(p: string)
	return (`AdminPanel:Servers:{p}`)
end

function AdminPanel.GetMetricsName(p: string)
	return (`AdminPanelMetrics:{p}`)
end

function AdminPanel.GetLeaderboardName(p: string, p2: string)
	return (`AdminPanel:{p2}:{p}`)
end

function AdminPanel.GetMetricsKey(p: string, p2: number)
	return (`{p}:{p2}`)
end

function AdminPanel.GetShard(value: string)
	local v2 = 0

	for i = 1, #value do
		v2 = (v2 * 31 + string.byte(value, i)) % 2147483647
	end

	return v2 % AdminPanel.Shards + 1
end

function AdminPanel.GetRollGroup(value)
	if typeof(value) ~= "string" then
		return nil
	end

	local v2, v3 = string.match(value, "^([^:]+):(.+)$")

	if v2 == "Star" then
		return "Stars"
	elseif v2 == "Gacha" then
		return v3
	elseif v2 == "Progression" then
		return "Progression"
	end

	return value
end

function AdminPanel.SanitizeName(value)
	if typeof(value) == "string" and not (#value < 1 or #value > AdminPanel.MaximumNameLength) then
		return value
	end

	return "Other"
end

function AdminPanel.IsCategory(value)
	if typeof(value) ~= "string" then
		return false
	end

	for _, category in AdminPanel.Categories do
		if category.Name == value then
			return true
		end
	end

	return false
end

function AdminPanel.MergeMetrics(p, p2)
	MergeMetrics(p, p2)
end

function AdminPanel.FormatAge(p: number)
	local v2 = math.max(0, (math.floor(p)))

	if v2 < 60 then
		return (`{v2}s ago`)
	end

	if v2 < 3600 then
		return (`{math.floor(v2 / 60)}m ago`)
	end

	return (`{math.floor(v2 / 3600)}h ago`)
end

function AdminPanel.FormatStatus(data, p: number)
	if typeof(data) ~= "table" then
		return "Loading..."
	end

	local updatedAt = data.UpdatedAt
	local v2

	if typeof(updatedAt) == "number" then
		v2 = math.isfinite(updatedAt)
	else
		v2 = false
	end

	if not v2 then
		return "Loading..."
	end

	local v4 = not IsFinite(data.Servers) and 0 or data.Servers
	local formatted = `Updated {AdminPanel.FormatAge(p - data.UpdatedAt)} · {v4} server{v4 == 1 and "" or "s"}`

	if data.Partial then
		return (`{formatted} · partial`)
	end

	return formatted
end

function AdminPanel.BuildView(list)
	local days = {}
	local v3 = {}

	for i = 1, AdminPanel.ReadDays do
		local v4 = list[i]
		days[i] = ParseMetrics(v4)

		if i <= AdminPanel.HistoryDays then
			MergeMetrics(v3, v4)
		end
	end

	return {
		Today = days[1],
		Week = ParseMetrics(v3),
		Days = days
	}
end

function AdminPanel.BuildRows(p: string, p2, p3: number)
	local v2 = {}

	if typeof(p2) ~= "table" then
		return v2
	end

	local view = p2.View

	if p == "Live Players" then
		BuildLive(v2, p2)
		return v2
	elseif p == "Gems Leaderboard" then
		BuildGems(v2, p2)
		return v2
	end

	if not view then
		return v2
	end

	if p == "Overview" then
		BuildOverview(v2, view)
		return v2
	elseif p == "Onboarding" then
		BuildOnboarding(v2, view)
		return v2
	elseif p == "Economy & Gacha" then
		BuildEconomy(v2, p2, view, p3)
		return v2
	elseif p == "Monetization" then
		BuildMonetization(v2, view)
		return v2
	elseif p == "Gamemodes & Content" then
		BuildContent(v2, view)
		return v2
	elseif p == "Social" then
		BuildSocial(v2, view)
		return v2
	elseif p == "Technical" then
		BuildTechnical(v2, view)
		return v2
	end

	if p == "Trades" then
		BuildTrades(v2, view)
	end

	return v2
end

return AdminPanel