local Notifications = require(script.Parent.Notifications)
local Leaderboards = require(script.Parent.Leaderboards)
local Gamepasses = require(script.Parent.Gamepasses)
local v = {
	MaximumLeaderboardTags = 3,
	SelectionAttribute = "ChatTagSelection",
	UniqueTags = {
		[4420601962] = {
			Name = "Birulinha",
			Colors = {
				Color3.fromHex("#5B1FD6"),
				Color3.fromHex("#9B4DFF"),
				Color3.fromHex("#E2B8FF"),
				Color3.fromHex("#9B4DFF"),
				Color3.fromHex("#5B1FD6")
			}
		}
	},
	Roles = {
		{
			Minimum = 254,
			Name = "Owner",
			Color = Color3.new(1, 1, 1)
		},
		{
			Rank = 253,
			Name = "Co Owner",
			Color = Color3.new(1, 1, 1)
		},
		{
			Rank = 250,
			Name = "StarX Team",
			Color = Color3.new(0.392157, 1, 0.32549)
		},
		{
			Rank = 200,
			Name = "Director",
			Color = Color3.new(0.1, 0.2, 1)
		},
		{
			Rank = 199,
			Name = "Staff",
			Color = Color3.new(1, 0.5, 0)
		},
		{
			Rank = 33,
			Name = "Early Access",
			Color = Color3.new(0.376471, 1, 0.854902)
		},
		{
			Rank = 32,
			Name = "Early Access",
			Color = Color3.new(0.376471, 1, 0.854902)
		},
		{
			Rank = 12,
			Name = "Senior CC",
			Color = Color3.new(1, 0, 0)
		},
		{
			Rank = 11,
			Name = "Junior CC",
			Color = Color3.new(1, 0, 0)
		},
		{
			Rank = 10,
			Name = "Beginner CC",
			Color = Color3.new(1, 0, 0)
		},
		{
			Rank = 2,
			Name = "Tester",
			Color = Color3.new(0.792157, 0.376471, 1)
		}
	},
	LeaderboardLabels = {
		["Total Power"] = "Power",
		["Total Damage"] = "Damage",
		["Highest DPS"] = "DPS",
		["Total Yen"] = "Yen",
		["Defeated Enemies"] = "Kills",
		["Stars Opened"] = "Stars",
		["Time Played"] = "Time",
		["Robux Spent"] = "Robux"
	}
}

local function FormatTag(p: string, color: Color3)
	return string.format("<font color='#%s'>[%s]</font>", color:ToHex(), Notifications.Escape(p))
end

local function ComparePositions(data, data2)
	if data.Rank ~= data2.Rank then
		return data.Rank < data2.Rank
	end

	local index = Leaderboards.List[data.Name].Index
	local index2 = Leaderboards.List[data2.Name].Index

	if index ~= index2 then
		return index < index2
	end

	if data.Category == data2.Category then
		return false
	end

	return data.Category == "Global" or data2.Category ~= "Global" and data.Category < data2.Category
end

function v.GetKey(p: string, p2: string)
	return p .. "|" .. p2
end

function v.IsValidKey(value)
	if typeof(value) ~= "string" then
		return false
	end

	local v2, v3 = string.match(value, "^(.+)|(.+)$")

	if not v2 then
		return false
	end

	local v4 = Leaderboards.List[v2]

	if v4 and v.LeaderboardLabels[v2] then
		return v4.Categories[v3] ~= nil
	end

	return false
end

function v.NormalizeSelection(items)
	local result = {}

	if typeof(items) ~= "table" then
		return result
	end

	local v2 = {}

	for _, item in items do
		if #result >= v.MaximumLeaderboardTags then
			break
		end

		if v2[item] or not v.IsValidKey(item) then
			continue
		end

		v2[item] = true
		table.insert(result, item)
	end

	return result
end

function v.EncodeSelection(p)
	return table.concat(v.NormalizeSelection(p), ",")
end

function v.DecodeSelection(value)
	if typeof(value) == "string" and value ~= "" then
		return v.NormalizeSelection(string.split(value, ","))
	end

	return {}
end

function v.FormatUniqueTag(p: string)
	return string.format("<font color='#FFFFFF'>[%s]</font>", Notifications.Escape(p))
end

function v.BuildRegionSequence(list, value: number, value2: number)
	local color = Color3.new(1, 1, 1)
	local v2 = math.clamp(value, 0, 1)
	local v3 = math.clamp(value2, 0, 1)

	if v3 - v2 < 0.01 or #list == 0 then
		return ColorSequence.new(color)
	end

	local v4 = v2 <= 0.002 and 0 or v2
	local v5 = v3 >= 0.998 and 1 or v3
	local colorSequenceKeypoints = {}

	if v4 > 0 then
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(0, color))
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v4 - 0.002, color))
	end

	for k, v6 in list do
		local v7 = not (#list > 1) and 0 or (k - 1) / (#list - 1) or 0
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v4 + v7 * (v5 - v4), v6))
	end

	if v5 < 1 then
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v5 + 0.002, color))
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, color))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function v.SortPositions(options)
	local result = {}

	for _, v2 in options or {} do
		local v3 = Leaderboards.List[v2.Name]

		if not (v3 and v.LeaderboardLabels[v2.Name] and v3.Categories[v2.Category] and Notifications.IsFinite(v2.Rank)) then
			continue
		end

		if v2.Rank < 1 or v2.Rank > v3.Size or v2.Rank % 1 ~= 0 then
			continue
		end

		table.insert(result, v2)
	end

	table.sort(result, ComparePositions)
	return result
end

function v.Build(p: number?, flag: boolean?, p2, p3, p4: number?)
	local v2 = {}
	local v3 = p4 and v.UniqueTags[p4]

	if v3 then
		table.insert(v2, v.FormatUniqueTag(v3.Name))
	else
		for _, role in v.Roles do
			if not (role.Rank and p == role.Rank or role.Minimum and p and role.Minimum <= p) then
				continue
			end

			table.insert(v2, FormatTag(role.Name, role.Color))
			break
		end
	end

	if flag then
		table.insert(v2, FormatTag("VIP", Gamepasses["V.I.P"].Color))
	end

	local sortPositions = v.SortPositions(p2)
	local sortPositions2 = {}

	for _, sortPosition in sortPositions do
		sortPositions2[v.GetKey(sortPosition.Name, sortPosition.Category)] = sortPosition
	end

	local v4 = {}
	local v5 = {}

	for _, v6 in v.NormalizeSelection(p3) do
		local v7 = sortPositions2[v6]

		if not v7 then
			continue
		end

		v4[v7] = true
		table.insert(v5, v7)
	end

	for _, sortPosition in sortPositions do
		if not v4[sortPosition] then
			table.insert(v5, sortPosition)
		end
	end

	for k, v6 in v5 do
		if v.MaximumLeaderboardTags < k then
			break
		end

		local v7 = Leaderboards.List[v6.Name]
		local v8 = v6.Category == "Global" and "" or " " .. v6.Category
		local v9 = string.format("#%d %s%s", v6.Rank, v.LeaderboardLabels[v6.Name], v8)
		table.insert(v2, FormatTag(v9, v7.Gradient.Keypoints[1].Value))
	end

	return table.concat(v2, " ")
end

return table.freeze(v)