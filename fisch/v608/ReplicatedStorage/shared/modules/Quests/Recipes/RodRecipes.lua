local ReplicatedStorage = game:GetService("ReplicatedStorage")
require("../Util")
local recipes = require(ReplicatedStorage.shared.modules.library.recipes)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local v = {
	["Titanium Shaft"] = "DeepSledge",
	["Titanium Reel"] = "DeepForgeHandMarcus",
	["Line of the Deep"] = "DeepCartographer",
	["Lucid Reel"] = "Tessael",
	["Toxinburst Handle"] = "Caleb",
	["Toxinburst Line"] = "Plagued Reaper",
	["Toxinburst Shaft"] = "Felix",
	["Evil Sigil"] = "CrimsonKing",
	["Mysterious Spine"] = "PaleontologistPetri",
	["Sandy Rod Shaft"] = "SandcastleReferee",
	["Sandy Handle"] = "SandyFinn"
}
local RodRecipes = {}

for _, recipe in recipes do
	local rod = rods[recipe.Output]
	local list = {}
	local navigationTargets = {}

	for i, item in ipairs(recipe.Items) do
		if not item[3] then
			table.insert(navigationTargets, {
				Tags = { v[item[1]] or item[1] },
				Objectives = { i },
				OnlyNearest = true
			})
		end

		table.insert(list, lib.ObtainItem({
			Item = item[1],
			RequiredAmount = item[2],
			RequiredAttributes = {
				Mutation = item[3]
			}
		}))
	end

	if recipe.Cost and recipe.Cost > 0 then
		table.insert(list, {
			"DataInstanceValue",
			not recipe.Currency and "Stats.coins" or `LocalCurrencies.{recipe.Currency}`,
			recipe.Cost,
			(`Obtain {NumberUtils:Comma(recipe.Cost)} {recipe.Currency or "C$"}`)
		})
	end

	table.insert(navigationTargets, {
		Zone = "Ancient Archives",
		Tags = { "RodCrafting" },
		AllComplete = true
	})
	RodRecipes[`Recipe/{recipe.Name}`] = {
		Id = `Recipe/{recipe.Name}`,
		DisplayName = `{recipe.Type} Crafting: {recipe.Output}`,
		Icon = "rbxassetid://110276457326464",
		IconColor = rod and rod.Color or Color3.new(1, 1, 1),
		QuestType = "Recipe",
		NavigationTargets = navigationTargets,
		Description = "",
		CompletedDescription = `You've gathered all the materials for the {recipe.Output}! Head back to the Ancient Archives to craft it!`,
		IsRepeatable = not recipe.CraftOnce,
		Prerequisites = {
			Level = recipe.Level
		},
		List = list,
		Rewards = {
			{ recipe.Type, recipe.Output }
		}
	}
end

return RodRecipes