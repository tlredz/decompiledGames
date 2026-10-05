local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local ingredients = require3(script.Parent).SerpentBreakout.ingredients
return {
	DropChance = {
		Common = 80,
		Rare = 20
	},
	RelicItems = {
		Common = {
			{
				item = v.createPeriodEventIngredientReward(
					"SerpentScales",
					ingredients.SerpentScales.DisplayName,
					ingredients.SerpentScales.Icon
				),
				chance = 60
			},
			{
				item = v.createPeriodEventIngredientReward(
					"SerpentEyes",
					ingredients.SerpentEyes.DisplayName,
					ingredients.SerpentEyes.Icon
				),
				chance = 40
			}
		},
		Rare = {
			{
				item = v.createPeriodEventIngredientReward(
					"VenomCores",
					ingredients.VenomCores.DisplayName,
					ingredients.VenomCores.Icon
				),
				chance = 100
			}
		}
	}
}