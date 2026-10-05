local ReplicatedStorage = game:GetService("ReplicatedStorage")
require("../Util")
local harpoonGuns = require(ReplicatedStorage.shared.modules.library.harpoonGuns)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.utils.NumberUtils)
local v = {
	["Heat-Proof Metal"] = "DeepHunterDan",
	["Thermal Harpoon"] = "DeepVesper"
}
local HarpoonGunRecipes = {}

for k, harpoonGun in harpoonGuns do
	if not harpoonGun.Recipe then
		continue
	end

	local list = {}
	local navigationTargets = {}

	for i, material in ipairs(harpoonGun.Recipe.Materials) do
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
		Zone = "Ancient Archives",
		Tags = { "HarpoonGunCrafting" },
		AllComplete = true
	})
	HarpoonGunRecipes[`Recipe/{k}`] = {
		Id = `Recipe/{k}`,
		DisplayName = `Harpoon Gun Crafting: {k}`,
		Icon = "rbxassetid://70502746092006",
		IconColor = harpoonGun.Color,
		QuestType = "Recipe",
		NavigationTargets = navigationTargets,
		Description = "",
		CompletedDescription = `You've gathered all the materials for the {k}! Head back to the Ancient Archives to craft it!`,
		Prerequisites = {
			Level = harpoonGun.Recipe.LevelRequired
		},
		List = list,
		Rewards = {
			{ "HarpoonGun", k }
		}
	}
end

return HarpoonGunRecipes