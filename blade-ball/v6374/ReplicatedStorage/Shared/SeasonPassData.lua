local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local v = require3(script.CurrencyData)
local v2 = require3(script.SeasonRewards)
require3(ReplicatedStorage2.ServerInfo)
require3(script:FindFirstChild("10"))
local SeasonPassData = {
	CurrentSeason = 24,
	SeasonName = "Blackhole",
	CurrencyName = v.CurrencyName,
	CurrencyIcon = v.CurrencyIcon,
	CurrencyColor = v.CurrencyColor,
	GachaName = v2.GachaName,
	ExplosionCrateName = v2.ExplosionCrateName,
	ExplosionCrateId = v2.ExplosionCrateId,
	SeasonPassProductId = 3296281126,
	GiftSeasonPassProductId = 3296281128,
	PreviousSeasonPassProductIds = {
		1830441833,
		1665530884,
		1693004822,
		1712415917,
		1741195867,
		1771584321,
		1804499612,
		1858489355,
		1903171136,
		1936733947,
		2654098044,
		2687610490,
		2836952097,
		3239117933,
		3269127136
	},
	PreviousGiftSeasonPassProductId = {
		1830441902,
		1665530884,
		1693011426,
		1712415917,
		1741195694,
		1771584320,
		1804499610,
		1858489359,
		1903171141,
		1936734812,
		2654098029,
		2687610492,
		2836952096,
		3239117934,
		3269127134
	},
	ExplosionCratePrice = 150,
	BattlepassShopRefreshTime = 43200,
	Seasons = {}
}

for _, moduleScript in script:GetChildren() do
	if moduleScript:IsA("ModuleScript") and tonumber(moduleScript.Name) then
		SeasonPassData.Seasons[tonumber(moduleScript.Name)] = require3(moduleScript)
	end
end

SeasonPassData.CurrentSeasonData = SeasonPassData.Seasons[SeasonPassData.CurrentSeason]
return SeasonPassData