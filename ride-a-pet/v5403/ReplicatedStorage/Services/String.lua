game:GetService("HttpService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StringService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("StringService"))
local String = {}
String.Abbreviate = StringService.Abbreviate
String.FormatOdds = StringService.FormatOdds

function String.AddComma(_, p)
	return StringService.AddComma(p)
end

function String.FormatCurrency(_, p)
	return StringService.FormatCurrency(p)
end

function String.FormatTime(_, p)
	local v = math.max(0, (math.floor(tonumber(p) or 0)))
	local v2 = math.floor(v / 60)
	local v3 = v % 60
	return string.format("%d:%02d", v2, v3)
end

function String.FormatTimeInInitials(_, p)
	local v = tonumber(p) or 0
	local v2 = math.floor(v / 3600)
	local v3 = v - v2 * 3600
	local v4 = math.floor(v3 / 60)
	local v5 = v3 - v4 * 60
	local v6 = {}

	if v2 > 0 then
		table.insert(v6, v2 .. "h")
	end

	if v4 > 0 then
		table.insert(v6, v4 .. "m")
	end

	if v5 > 0 or #v6 == 0 then
		table.insert(v6, math.floor(v5) .. "s")
	end

	return table.concat(v6, " ")
end

function String.ConvertTimeIntoWords(_, p: number)
	if p < 0 then
		return "Invalid time"
	end

	local count = 0
	local v = {}

	for _, v2 in ipairs({
		{
			name = "Year",
			seconds = 31536000
		},
		{
			name = "Month",
			seconds = 2592000
		},
		{
			name = "Day",
			seconds = 86400
		},
		{
			name = "Hour",
			seconds = 3600
		},
		{
			name = "Minute",
			seconds = 60
		},
		{
			name = "Second",
			seconds = 1
		}
	}) do
		if count >= 2 then
			break
		end

		local v3 = math.floor(p / v2.seconds)

		if not (v3 > 0) then
			continue
		end

		table.insert(v, v3 .. " " .. v2.name .. (v3 > 1 and "s" or ""))
		p %= v2.seconds
		count += 1
	end

	return table.concat(v, ", ")
end

function String.Filter(_, value: string, p: number)
	if RunService:IsClient() then
		return script:WaitForChild("FilterText"):InvokeServer(value)
	end

	local v = {}

	for k in string.gmatch(value, "%S+") do
		local v2 = k
		local success, result = pcall(function()
			return TextService:FilterStringAsync(v2, p):GetNonChatStringForUserAsync(p)
		end)

		if not success or result ~= k then
			result = string.rep("#", #k)
		end

		table.insert(v, result)
	end

	return table.concat(v, " ")
end

function String.ConvertToHMS(_, p)
	local function Format(p2)
		return string.format("%02i", p2)
	end

	local v = (p - p % 60) / 60
	local v2 = p - v * 60
	local v3 = (v - v % 60) / 60
	local v4 = v - v3 * 60
	return string.format("%i", v3) .. ":" .. string.format("%02i", v4) .. ":" .. string.format("%02i", v2)
end

function String:ConvertToDHMS(p)
	return self:ConvertToUnits(p)
end

function String:ConvertToUnits(p)
	local v = math.max(0, (math.floor(tonumber(p) or 0)))
	local v2 = math.floor(v / 86400)
	local v3 = math.floor(v % 86400 / 3600)
	local v4 = math.floor(v % 3600 / 60)
	local v5 = v % 60

	if v2 > 0 then
		return string.format("%dD%s%dH%s%dM%s%dS", v2, ", ", v3, ", ", v4, ", ", v5)
	end

	if v3 > 0 then
		return string.format("%dH%s%dM%s%dS", v3, ", ", v4, ", ", v5)
	end

	if v4 > 0 then
		return string.format("%dM%s%dS", v4, ", ", v5)
	end

	return string.format("%dS", v5)
end

function String.ConvertSecondsToMS(_, p)
	return string.format("%i:%02i", p / 60 % 60, p % 60)
end

function String.GetNumberInString(_, value)
	local v = ""

	for i = 1, #value do
		local v2 = value:sub(i, i)

		if tonumber(v2) then
			v ..= v2
		end
	end

	return tonumber(v) or 0
end

function String.FormatGuess(_, value)
	if #value < 2 then
		return value
	end

	local v = {}

	for k in value:gmatch(".") do
		table.insert(v, k)
	end

	local v2 = { v[1] }
	local v3 = math.random(2, #v)

	for i = 2, #v do
		if i == v3 then
			table.insert(v2, v[i])
		else
			table.insert(v2, "_")
		end
	end

	return table.concat(v2, " ")
end

function String.FormatDecimal(_, p: number, p2: number)
	return string.format("%." .. p2 .. "f", p)
end

function String.HasSameContent(_, value, value2)
	local function splitToWords(value3)
		local result = {}

		for k in value3:gmatch("%S+") do
			table.insert(result, k)
		end

		return result
	end

	local function allWordsInTable(list, value3)
		for _, v in ipairs(list) do
			if not value3:find(v, 1, true) then
				return false
			end
		end

		return true
	end

	if value:find(value2, 1, true) or value2:find(value, 1, true) then
		return true
	end

	if value:gsub("%s+", "") == value2:gsub("%s+", "") then
		return true
	end

	local v = {}

	for k in value:gmatch("%S+") do
		table.insert(v, k)
	end

	local v2 = {}

	for k in value2:gmatch("%S+") do
		table.insert(v2, k)
	end

	return allWordsInTable(v, value2) or allWordsInTable(v2, value)
end

function String.Jumble(_, value)
	local v = {}

	for i = 1, #value do
		table.insert(v, value:sub(i, i))
	end

	for i = #v, 2, -1 do
		local v2 = math.random(1, i)
		local v3 = v[v2]
		local v4 = v[i]
		v[i] = v3
		v[v2] = v4
	end

	return (table.concat(v))
end

return String