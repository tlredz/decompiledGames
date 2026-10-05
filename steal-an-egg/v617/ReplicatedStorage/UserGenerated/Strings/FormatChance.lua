local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FormatOdds = require(ReplicatedStorage.UserGenerated.Strings.FormatOdds)
local FormatPercent = require(ReplicatedStorage.UserGenerated.Strings.FormatPercent)

local function FormatChance(value: number, value2: number?)
	assert(type(value) == "number")
	assert(value2 == nil or type(value2) == "number")
	local v = math.clamp(value, 0, 1)
	local v2 = math.clamp(value2 or v, 0, 1)

	if v > 0 and v2 <= 0.0002 and v <= 0.001 then
		return FormatOdds(v)
	end

	return FormatPercent(v)
end

return FormatChance