local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Years = 31556926,
	Months = 2629744,
	Weeks = 604800,
	Days = 86400,
	Hours = 3600,
	Minutes = 60,
	Seconds = 1
}
local v2 = {}

for k, _ in pairs(v) do
	table.insert(v2, k)
end

local fuzzyFinder = Util.MakeFuzzyFinder(v2)

local function stringToSecondDuration(value)
	if value == nil or value == "" then
		return nil
	end

	local v3 = tonumber(value)

	if v3 and v3 == 0 then
		return 0, 0, true
	end

	local match = value:gsub("-?%d+%a+", ""):match("-?%d+")

	if match then
		return nil, tonumber(match), true
	end

	local v4 = nil
	local v5 = nil

	for k in value:gmatch("-?%d+%a+") do
		local v6
		v5, v6 = k:match("(-?%d+)(%a+)")
		local v7 = fuzzyFinder(v6)

		if #v7 == 0 then
			return nil, (tonumber(v5))
		else
			v4 = (v4 == nil and 0 or v4) + (v6:lower() == "m" and 60 or v[v7[1]]) * tonumber(v5)
		end
	end

	if v4 == nil then
		return nil
	end

	return v4, (tonumber(v5))
end

local function mapUnits(items, value, p, value2)
	local v3 = value2 or 1
	local result = {}

	for k, item in pairs(items) do
		if p == 1 then
			result[k] = value .. item:sub(v3, #item - 1)
		else
			result[k] = value .. item:sub(v3)
		end
	end

	return result
end

local v3 = {
	Transform = function(p)
		return p, stringToSecondDuration(p)
	end,
	Validate = function(_, p)
		return p ~= nil
	end,
	Autocomplete = function(value, p, p2, p3, p4)
		local v4 = {}

		if p3 or p4 then
			if p3 == true then
				p4 = fuzzyFinder("") or p4
			end

			if p3 == true then
				return (mapUnits(p4, value, p2))
			end

			return (mapUnits(p4, value, value:match("^.*(%a+)$"):len() + 1))
		else
			if p == nil then
				return v4
			end

			local match = value:match("^.*-?%d+(%a+)%s?$")
			v4 = mapUnits(fuzzyFinder(match), value, p2, #match + 1)
			table.sort(v4)
			return v4
		end
	end,
	Parse = function(_, p)
		return p
	end
}
return function(registry)
	registry:RegisterType("duration", v3)
	registry:RegisterType("durations", Util.MakeListableType(v3))
end