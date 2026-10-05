local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FormatAbbreviated = require(ReplicatedStorage.UserGenerated.Strings.FormatAbbreviated)

local function FormatOdds(value: number)
	assert(type(value) == "number")

	if value == 0 then
		return "0"
	elseif value == 1e999 then
		return "Infinity"
	elseif value == -1e999 then
		return "-Infinity"
	end

	if value == value then
		return "1/" .. FormatAbbreviated(1 / value)
	end

	return "NaN"
end

return FormatOdds