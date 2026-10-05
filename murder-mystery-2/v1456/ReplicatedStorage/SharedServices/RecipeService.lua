local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local RecipeService = {}

function RecipeService.IsItemSalvageable(_, p: string)
	if p == nil then
		return false
	end

	local weapon = Sync.Weapons[p]

	if not weapon or Sync.Codes[p] then
		return false
	end

	local rarity = weapon.Rarity
	local rewards = Sync.SalvageRewards[p] and Sync.SalvageRewards[p].Rewards
	local rewards2 = Sync.SalvageRewards[rarity] and Sync.SalvageRewards[rarity].Rewards

	if weapon.Event ~= nil and not rewards or weapon.Season ~= nil or weapon.ItemType == "Misc" then
		return false
	end

	if rewards2 or rewards then
		return true
	end

	return false
end

function RecipeService.GetCraftingResult(_, list)
	for k, recipe in Sync.Recipes do
		local _ = recipe.Materials
		local count = 0
		local count2 = 0

		for k2, material in recipe.Materials do
			count += 1

			for _, v in list do
				if v.itemID == k2 and v.amount == material then
					count2 += 1
				end
			end
		end

		if count2 == count and #list == count2 then
			return k
		end
	end

	return nil
end

return RecipeService