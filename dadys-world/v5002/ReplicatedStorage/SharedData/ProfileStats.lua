local ProfileStats = {}

local function addCommas(p: number)
	local v = tostring((math.floor(p)))

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local v = {
	Count = function(p: number)
		return (addCommas(p))
	end,
	Distance = function(p: number)
		return addCommas(p) .. "m"
	end,
	Floor = function(p: number)
		return "Floor " .. addCommas(p)
	end,
	Days = function(p: number)
		local v2 = math.floor(p)
		return addCommas(v2) .. (v2 == 1 and " day" or " days")
	end,
	Duration = function(p: number)
		local v2 = math.max(0, (math.floor(p)))
		local v3 = v2 // 3600
		local v4 = v2 % 3600 // 60

		if v3 > 0 then
			return string.format("%dh %dm", v3, v4)
		end

		return string.format("%dm", v4)
	end
}
local v2 = {
	TravelDistance = {
		"Statistics",
		"Distance",
		"Meters Walked",
		true
	},
	GeneratorsCompleted = {
		"Statistics",
		"Count",
		"Machines Finished",
		true
	},
	ItemsPickedUp = {
		"Statistics",
		"Count",
		"Items Picked Up",
		true
	},
	HighestFloor = {
		"Statistics",
		"Floor",
		"Furthest Floor",
		true
	},
	FloorsTraveled = {
		"Statistics",
		"Count",
		"Floors Survived",
		true
	},
	TotalIchorEarned = {
		"Statistics",
		"Count",
		"Earned Ichor",
		true
	},
	DandyGossipsHeard = {
		"Statistics",
		"Count",
		"Unique Dandy Gossip",
		true
	},
	DyleGossipsHeard = {
		"Statistics",
		"Count",
		"Unique Dyle Gossip",
		true
	},
	IchorDonated = {
		"Statistics",
		"Count",
		"Donated Ichor",
		false
	},
	DyleMapCompletions = {
		"Statistics",
		"Count",
		"Dyle Map Completions",
		true
	},
	HighestDailyStreak = {
		"Statistics",
		"Days",
		"Longest Daily Streak",
		true
	},
	CurrentDailyStreak = {
		"Statistics",
		"Days",
		"Daily Streak",
		true
	},
	GiftsSent = {
		"Statistics",
		"Count",
		"Gifts Sent",
		true
	},
	GiftsReceived = {
		"Statistics",
		"Count",
		"Gifts Received",
		true
	},
	BudsHelped = {
		"Statistics",
		"Count",
		"Buds Helped",
		true
	},
	Highscore_SwimmyBarnaby = {
		"Statistics",
		"Count",
		"Swimmy Barnaby Highscore",
		true
	},
	Coin = {
		"Root",
		"Count",
		"Ichor",
		true
	},
	Blackouts = {
		"Root",
		"Count",
		"Blackouts",
		true
	},
	DandyItemsPurchased = {
		"Root",
		"Count",
		"Dandy Items Purchased",
		true
	},
	Towers = {
		"CountOwned",
		"Count",
		"Toons Owned",
		true
	},
	Trinkets = {
		"CountOwned",
		"Count",
		"Trinkets Owned",
		true
	},
	Skins = {
		"CountOwned",
		"Count",
		"Skins Owned",
		true
	}
}
local v3 = {
	"HighestFloor",
	"FloorsTraveled",
	"GeneratorsCompleted",
	"Blackouts",
	"TravelDistance",
	"ItemsPickedUp",
	"TotalIchorEarned",
	"Coin",
	"BudsHelped",
	"DyleMapCompletions",
	"DandyItemsPurchased",
	"CurrentDailyStreak",
	"HighestDailyStreak",
	"DandyGossipsHeard",
	"DyleGossipsHeard",
	"GiftsSent",
	"GiftsReceived",
	"Towers",
	"Trinkets",
	"Skins",
	"Highscore_SwimmyBarnaby"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function toEntry(p: string)
	local v4 = v2[p]

	if v4 then
		return {
			Key = p,
			Source = v4[1],
			Format = v4[2],
			DisplayName = v4[3],
			Enabled = v4[4]
		}
	end

	return nil
end

local function extractName(value)
	if type(value) == "string" then
		return value
	end

	if type(value) == "table" then
		local selected = value[1] or value.Name

		if type(selected) == "string" then
			return selected
		end
	end

	return nil
end

function ProfileStats.IsEnabled(p: string)
	local v4 = v2[p]
	return v4 ~= nil and v4[4] == true
end

function ProfileStats.Get(value: string)
	if type(value) ~= "string" then
		return nil
	end

	local v4 = toEntry(value) -- equivalent call inferred; original call site unknown

	if v4 and v4.Enabled then
		return v4
	end

	return nil
end

function ProfileStats.GetEnabledOrdered()
	local result = {}
	local v4 = {}

	for _, v5 in ipairs(v3) do
		if not ProfileStats.IsEnabled(v5) then
			continue
		end

		table.insert(result, v5)
		v4[v5] = true
	end

	local v5 = {}

	for k in pairs(v2) do
		if v4[k] or not ProfileStats.IsEnabled(k) then
			continue
		end

		table.insert(v5, k)
	end

	table.sort(v5)

	for _, v6 in ipairs(v5) do
		table.insert(result, v6)
	end

	return result
end

function ProfileStats.ReadValue(p, p2: string)
	local entry = toEntry(p2) -- equivalent call inferred; original call site unknown

	if not entry or type(p) ~= "table" then
		return 0
	end

	if entry.Source == "Statistics" then
		local statistics = p.Statistics
		local v5 = type(statistics) == "table" and statistics[p2] or nil
		return type(v5) == "number" and math.max(0, v5) or 0
	else
		if entry.Source == "Root" then
			local v5 = p[p2]
			return type(v5) == "number" and v5 or 0
		end

		if entry.Source ~= "CountOwned" then
			return 0
		end

		local v5 = p[p2]

		if type(v5) ~= "table" then
			return 0
		end

		local v6 = {}
		local count = 0

		for _, v7 in pairs(v5) do
			if type(v7) ~= "string" then
				if type(v7) == "table" then
					v7 = v7[1] or v7.Name

					if type(v7) ~= "string" then
						v7 = nil
					end
				else
					v7 = nil
				end
			end

			if not v7 or v6[v7] then
				continue
			end

			v6[v7] = true
			count += 1
		end

		return count
	end
end

function ProfileStats.Format(p: string, value: number?)
	local entry = toEntry(p) -- equivalent call inferred; original call site unknown
	local v5 = type(value) == "number" and value or 0
	return (entry and v[entry.Format] or v.Count)(v5)
end

function ProfileStats.GetDisplayName(displayName: string)
	local entry = toEntry(displayName) -- equivalent call inferred; original call site unknown

	if entry then
		displayName = entry.DisplayName or displayName
	end

	return displayName
end

return ProfileStats