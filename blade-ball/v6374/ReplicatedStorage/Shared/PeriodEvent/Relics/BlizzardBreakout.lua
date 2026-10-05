local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local ingredients = require3(script.Parent).BlizzardBreakout.ingredients
return {
	DropChance = {
		Common = 77,
		Rare = 20,
		Legendary = 3
	},
	RelicItems = {
		Common = {
			{
				item = v.createPeriodEventIngredientReward(
					"FrostShards",
					ingredients.FrostShards.DisplayName,
					ingredients.FrostShards.Icon
				),
				chance = 60
			},
			{
				item = v.createPeriodEventIngredientReward(
					"SnowmenEyes",
					ingredients.SnowmenEyes.DisplayName,
					ingredients.SnowmenEyes.Icon
				),
				chance = 40
			}
		},
		Rare = {
			{
				item = v.createPeriodEventIngredientReward(
					"GlacierCores",
					ingredients.GlacierCores.DisplayName,
					ingredients.GlacierCores.Icon
				),
				chance = 100
			}
		},
		Legendary = {
			{
				item = v.createSwordReward("Winter's Aurora"),
				chance = 33
			},
			{
				item = v.createSwordReward("Iced Katana"),
				chance = 33
			},
			{
				item = v.createSwordReward("Frost Pop"),
				chance = 33
			}
		},
		Secret = {
			{
				item = v.createSpecialTrainingEventCurrency(1),
				chance = 100
			}
		}
	}
}