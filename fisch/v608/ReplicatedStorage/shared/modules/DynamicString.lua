local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DynamicString = {}
local stats = require(ReplicatedStorage.shared.modules.library.stats)

local function commaValue(p: number, flag: boolean?)
	local v = tostring((tonumber(string.format("%.3f", p))))

	if p >= 1000 or p <= -1000 then
		repeat
			local v2
			v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
		until v2 == 0
	end

	if flag and p > 0 then
		p = "+" .. p
	end

	return v
end

function DynamicString.StatDisplayValue(_, p: string, p2: number, flag: boolean?)
	local stat = stats[p]

	if stat == nil then
		return (commaValue(p2, flag))
	end

	if stat.Multiply ~= nil then
		p2 *= stat.Multiply
	end

	local v = commaValue(p2, flag)

	if stat.Suffix ~= nil then
		return v .. stat.Suffix
	end

	return v
end

function DynamicString:StatDisplay(p: string, p2: number, flag: boolean?)
	local stat = stats[p]

	if stat == nil then
		return commaValue(p2, flag) .. " " .. p
	end

	if stat.Multiply ~= nil then
		p2 *= stat.Multiply
	end

	local v = commaValue(p2, flag)

	if stat.Suffix ~= nil then
		v ..= stat.Suffix
	end

	return v .. " " .. stat.DisplayName
end

function DynamicString:StatDisplayList(items, flag: boolean?)
	local v = {}

	for k, item in items do
		if not flag or item ~= 0 then
			table.insert(v, k)
		end
	end

	table.sort(v, function(a, b)
		local stat = stats[a]
		local stat2 = stats[b]
		return (stat and stat.Order or 10000) < (stat2 and stat2.Order or 10000)
	end)
	local result = table.create(#v)

	for i, v2 in ipairs(v) do
		result[i] = DynamicString:StatDisplay(v2, items[v2], flag)
	end

	return result
end

function DynamicString:ReadVariable(value: string, joined, flag: boolean?)
	local v = false
	local match, v2 = value:match("^(.-)::(.+)$")
	local v3, v4

	if match and v2 then
		if match:sub(1, 1) == "+" then
			match = match:sub(2)
			v = true
		end

		v3 = (match == "Percent" or match == "Percent-1") and 100 or 1
		v4 = match == "Percent-1" and -1 or 0
		value = v2
	else
		v4 = 0
		v3 = 1
	end

	for _, v5 in value:split(".") do
		if not joined or typeof(joined) ~= "table" then
			break
		end

		local v6 = tonumber(v5)

		if v6 and joined[v6] ~= nil then
			joined = joined[v6]
		else
			joined = joined[v5]
		end
	end

	if flag then
		return joined
	end

	if match == "StatsBullet" then
		joined = "• " .. table.concat(DynamicString:StatDisplayList(joined, v), "\n• ")
	elseif match == "StatsComma" then
		joined = table.concat(DynamicString:StatDisplayList(joined, v), ", ")
	end

	if joined == nil then
		return "??"
	end

	if typeof(joined) == "string" then
		return joined
	end

	if typeof(joined) == "number" then
		return (commaValue((joined + v4) * v3, v))
	end

	return (tostring(joined))
end

function DynamicString:ResolveObject(p, p2)
	if typeof(p) ~= "table" then
		return p
	end

	if p._var_ then
		return DynamicString:ReadVariable(p._var_, p2, true)
	end

	local result = {}

	for k, v in p do
		result[k] = DynamicString:ResolveObject(v, p2)
	end

	return result
end

function DynamicString.Format(_, value: string, p)
	if typeof(p) == "table" then
		return (value:gsub("<%$(.-)%$>", function(p2)
			return DynamicString:ReadVariable(p2, p)
		end))
	end

	return value
end

return DynamicString