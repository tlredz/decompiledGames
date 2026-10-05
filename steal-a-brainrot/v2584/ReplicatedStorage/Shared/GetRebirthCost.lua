local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rebirth = require(ReplicatedStorage.Datas.Rebirth)
local ABTests = require(ReplicatedStorage.UserGenerated.ABTests)

local function GetRebirthCost(p, p2: number)
	return (ABTests.GetAttribute(p, `Rebirth.Cost.{p2}`, Rebirth[p2].Requirements.Cash))
end

return GetRebirthCost