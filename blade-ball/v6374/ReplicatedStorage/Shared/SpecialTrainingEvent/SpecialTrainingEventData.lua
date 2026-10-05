local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Common.RewardInfo)
return table.freeze({
	IsAutoClaimEnabled = true,
	EndTimestamp = DateTime.fromUniversalTime(2026, 3, 14, 14).UnixTimestamp,
	StartTimestamp = DateTime.fromUniversalTime(2025, 2, 28, 14).UnixTimestamp,
	EventId = "GalacticCollapse",
	Currency = "Present",
	CurrencyIcon = "🎁",
	CurrencyNeededToCraft = 5,
	CraftItemStockId = "Heart of Winter",
	MapNames = {},
	CustomNPCs = {}
})