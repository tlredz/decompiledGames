local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundFigures = require(ReplicatedStorage.UserGenerated.Math.RoundFigures)
local Commas = require(ReplicatedStorage.UserGenerated.Strings.Commas)

local function FormatFigures(p: number, p2: number?, p3: number?, callback)
	return Commas(RoundFigures(p, p2, p3, callback))
end

return FormatFigures