local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundFigures = require(ReplicatedStorage.UserGenerated.Math.RoundFigures)
local StableExp10 = require(ReplicatedStorage.UserGenerated.Math.StableExp10)
local TrimmedNumberString = require(ReplicatedStorage.UserGenerated.Strings.TrimmedNumberString)
local v = {
	"",
	"k",
	"m",
	"b",
	"t",
	"q",
	"Qt",
	"Sx",
	"Sp",
	"o",
	"n",
	"d",
	"u",
	"Du",
	"Tr"
}

local function FormatAbbreviated(value: number)
	assert(type(value) == "number")

	if value ~= value then
		return "NaN"
	end

	if value == 1e999 then
		return "Infinity"
	elseif value == -1e999 then
		return "-Infinity"
	end

	local v2 = {}

	if value < 0 then
		table.insert(v2, "-")
		value = -value
	end

	local v3 = math.floor(value)

	if v3 >= 1000 then
		local v4 = math.clamp(math.floor(math.log10(v3) / 3) + 1, 1, #v)
		local roundFigures = RoundFigures(StableExp10(v3, (v4 - 1) * -3), 3, nil, math.floor)
		table.insert(v2, TrimmedNumberString(roundFigures))
		table.insert(v2, v[v4])
	else
		table.insert(v2, TrimmedNumberString(v3))
	end

	return table.concat(v2)
end

return FormatAbbreviated