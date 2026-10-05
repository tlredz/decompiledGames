local ReplicatedStorage = game:GetService("ReplicatedStorage")
require("../Util")
local spears = require(ReplicatedStorage.shared.modules.library.spears)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.utils.NumberUtils)
local v = {}
local SpearRecipes = {}

for k, spear in spears do
	if not spear.Recipe then
		continue
	end

	local list = {}
	local navigationTargets = {}

	for i, material in ipairs(spear.Recipe.Materials) do
		if not material[3] then
			table.insert(navigationTargets, {
				Tags = { v[material[1]] or material[1] },
				Objectives = { i },
				OnlyNearest = true
			})
		end

		table.insert(list, lib.ObtainItem({
			Item = material[1],
			RequiredAmount = material[2],
			RequiredAttributes = {
				Mutation = material[3]
			}
		}))
	end

	table.insert(navigationTargets, {
		Zone = "Lost Jungle",
		Tags = { "SpearCrafting" },
		AllComplete = true
	})
	SpearRecipes[`Recipe/{k}`] = {
		Id = `Recipe/{k}`,
		DisplayName = `Spear Crafting: {k}`,
		Icon = "rbxassetid://113705241307272",
		IconColor = spear.Color,
		QuestType = "Recipe",
		NavigationTargets = navigationTargets,
		Description = "",
		CompletedDescription = `You've gathered all the materials for the {k}! Head back to the Lost Jungle to craft it!`,
		Prerequisites = {
			Level = spear.Recipe.LevelRequired
		},
		List = list,
		Rewards = {
			{ "DisplayOnly", k }
		}
	}
end

return SpearRecipes