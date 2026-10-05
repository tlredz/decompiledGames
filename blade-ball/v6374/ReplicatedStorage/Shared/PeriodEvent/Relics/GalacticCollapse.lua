local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local ingredients = require3(script.Parent).GalacticCollapse.ingredients
return {
	DropChance = {
		Common = 72,
		Rare = 25,
		Legendary = 3
	},
	RelicItems = {
		Common = {
			{
				item = v.createPeriodEventIngredientReward(
					"PulsarFragments",
					ingredients.PulsarFragments.DisplayName,
					ingredients.PulsarFragments.Icon
				),
				chance = 60
			},
			{
				item = v.createPeriodEventIngredientReward(
					"RiftTendrils",
					ingredients.SingularityTears.DisplayName,
					ingredients.RiftTendrils.Icon
				),
				chance = 40
			}
		},
		Rare = {
			{
				item = v.createPeriodEventIngredientReward(
					"SingularityTears",
					ingredients.SingularityTears.DisplayName,
					ingredients.SingularityTears.Icon
				),
				chance = 100
			}
		},
		Legendary = {
			{
				item = v.createExplosionReward("Alienated Portal"),
				chance = 33
			},
			{
				item = v.createSwordReward("Alien's Slicer"),
				chance = 33
			},
			{
				item = v.createSwordReward("Alien Spiderblade"),
				chance = 33
			}
		}
	}
}