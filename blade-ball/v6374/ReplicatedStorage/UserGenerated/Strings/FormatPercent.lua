local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FormatFigures = require(ReplicatedStorage.UserGenerated.Strings.FormatFigures)

local function FormatPercent(p: number)
	return FormatFigures(p * 100, 4, 5) .. "%"
end

return FormatPercent