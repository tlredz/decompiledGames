local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local v = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
return {
	{
		Name = `{v.SeasonData.Currency.Name}Tier1`,
		Price = 60,
		Amount = 200,
		ProductId = 3269126081,
		GiftName = `{v.SeasonData.Currency.Name} Tier 1`
	},
	{
		Name = `{v.SeasonData.Currency.Name}Tier2`,
		Price = 180,
		Amount = 1000,
		ProductId = 3269126082,
		GiftName = `{v.SeasonData.Currency.Name} Tier 2`
	},
	{
		Name = `{v.SeasonData.Currency.Name}Tier3`,
		Price = 480,
		Amount = 3500,
		ProductId = 3269126085,
		GiftName = `{v.SeasonData.Currency.Name} Tier 3`
	},
	{
		Name = `{v.SeasonData.Currency.Name}Tier4`,
		Price = 900,
		Amount = 7000,
		ProductId = 3269126084,
		GiftName = `{v.SeasonData.Currency.Name} Tier 4`
	},
	{
		Name = `{v.SeasonData.Currency.Name}Tier5`,
		Price = 1800,
		Amount = 15000,
		ProductId = 3269126083,
		GiftName = `{v.SeasonData.Currency.Name} Tier 5`
	}
}