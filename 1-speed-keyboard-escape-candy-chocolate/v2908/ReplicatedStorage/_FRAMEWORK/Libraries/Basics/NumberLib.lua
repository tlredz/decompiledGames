local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local NumberLib = {}

function NumberLib.toCommas(p: number)
	return Numbers.formatComma(p)
end

function NumberLib.toShort(p: number)
	return (p < 0 and "-" or "") .. Numbers.formatNumber(math.abs(p), 2)
end

function NumberLib.shortenTime(p: number, value: number?)
	local v = math.max(0, (math.floor(p)))
	local v2 = math.max(0, (math.floor(value or 2)))
	local v3 = {}
	local v4 = math.floor(v / 86400)
	local v5 = math.floor(v % 86400 / 3600)
	local v6 = math.floor(v % 3600 / 60)
	local v7 = v % 60

	if v4 > 0 then
		table.insert(v3, (`{v4}d`))
	end

	if v5 > 0 then
		table.insert(v3, (`{v5}h`))
	end

	if v6 > 0 then
		table.insert(v3, (`{v6}m`))
	end

	if v7 > 0 then
		table.insert(v3, (`{v7}s`))
	end

	if #v3 == 0 or v2 == 0 then
		return "0s"
	end

	local v8 = {}

	for i = 1, math.min(#v3, v2) do
		table.insert(v8, v3[i])
	end

	return table.concat(v8, " ")
end

function NumberLib.increment(p: number, p2: number, value: string?)
	assert(p2 ~= 0, "increment cannot be zero")
	local v = p / p2
	local v2 = value or "round"

	if v2 == "floor" then
		return math.floor(v) * p2
	elseif v2 == "ceil" then
		return math.ceil(v) * p2
	end

	return math.round(v) * p2
end

function NumberLib.fixDecimal(p: number)
	local v, v2 = string.match(tostring(p), "^([^%.]+)%.?(.*)$")

	if v == nil or v2 == nil or v2 == "" then
		return p
	end

	return tonumber((`{v}.{string.sub(v2, 1, 3)}`)) or 0
end

return NumberLib