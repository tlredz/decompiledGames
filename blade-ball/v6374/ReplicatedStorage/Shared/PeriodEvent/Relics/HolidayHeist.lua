local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local ingredients = require3(script.Parent).HolidayHeist.ingredients
return {
	DropChance = {
		Common = 77,
		Rare = 20,
		Legendary = 3,
		Secret = 1
	},
	RelicItems = {
		Common = {
			{
				item = v.createPeriodEventIngredientReward(
					"CandyWrappers",
					ingredients.CandyWrappers.DisplayName,
					ingredients.CandyWrappers.Icon
				),
				chance = 60
			},
			{
				item = v.createPeriodEventIngredientReward(
					"BrokenNutcracker",
					ingredients.BrokenNutcracker.DisplayName,
					ingredients.BrokenNutcracker.Icon
				),
				chance = 40
			}
		},
		Rare = {
			{
				item = v.createPeriodEventIngredientReward(
					"ChristmasPresent",
					ingredients.ChristmasPresent.DisplayName,
					ingredients.ChristmasPresent.Icon
				),
				chance = 100
			}
		},
		Legendary = {
			{
				item = v.createSwordReward("Northstar Sword"),
				chance = 33
			},
			{
				item = v.createSwordReward("Krampus Slice"),
				chance = 33
			},
			{
				item = v.createSwordReward("Dual Iceblade"),
				chance = 33
			}
		}
	}
}