local RunService = game:GetService("RunService")
local CraftingRecipes = require(game.ReplicatedStorage.Modules.Data.CraftingRecipes)
local FishHelper = require(game.ReplicatedStorage.Modules.FishHelper)
local v = nil
task.spawn(function()
	local ItemData = require(game.ReplicatedStorage.Modules.Asset.ItemData)
	v = ItemData
end)
local FishingIndexInventoryData = require(game.ReplicatedStorage:WaitForChild("FishReplicated").FishingIndexInventoryData)
local CraftUtil = {
	GetMaxCraftQuantity = function(_)
		return 99
	end,
	PossibleHardcode = function(self, p, p2)
		if p == "SharkAnchor" then
			if RunService:IsClient() then
				local Inventory = require(game.ReplicatedStorage.Controllers.UI.Inventory)
				local hasTile = Inventory:HasTile("Shark Tooth Necklace", "Accessory")
				local hasTile2 = Inventory:HasTile("Terror Jaw", "Accessory")

				if not (hasTile and hasTile2) then
					return false
				end
			else
				require(game.ServerStorage.Types.PlayerData)
				local v2 = false
				local v3 = false

				for _, accessory in p2.Accessories do
					if accessory.Name == "Shark Tooth Necklace" then
						v2 = true
					elseif accessory.Name == "Terror Jaw" then
						v3 = true
					end

					if v2 and v3 then
						break
					end
				end

				if not (v2 and v3) then
					return false
				end
			end
		end

		local dragonQuest = p2.DragonQuest

		if p == "Dragonheart" then
			if not (dragonQuest and dragonQuest.Belts.Red) then
				return false
			end
		end

		if p == "Dragonstorm" then
			if not (dragonQuest and dragonQuest.Belts.Red) then
				return false
			end
		end

		return (p ~= "Volcanic Magnet" or dragonQuest and dragonQuest.Belts.Yellow) and true or false
	end
}
local v2 = {
	["Shark Rod"] = 2,
	["Shark (Corrupted)"] = 3,
	["Shell (Celestial)"] = 3,
	["Fishing Rod"] = 0,
	["Gold Rod"] = 1,
	["Shell Rod"] = 2,
	["Treasure Rod"] = 3,
	["Admin Rod"] = 4
}

function CraftUtil.Check(_, p, recipe, data)
	local craftingRecipe = CraftingRecipes[recipe]
	local v3 = {
		Required = {},
		Result = {},
		ResultStats = {}
	}
	local v4 = craftingRecipe.Reward[1]
	local count = craftingRecipe.Reward[2]
	local progressionRequirement = craftingRecipe.ProgressionRequirement

	if typeof(count) == "boolean" then
		count = nil
	end

	local type = v.Types[v4]
	local Global = require(game.ReplicatedStorage.Global)
	Global.TestGamePrint(p, recipe, data, count, type, v4, craftingRecipe)
	local v6 = nil
	local v7

	if type then
		v7 = v[type][v4]
	elseif recipe == "TerrorJaw" then
		v7 = { 3 }
	elseif recipe == "ToothNecklace" then
		v7 = { 2 }
	elseif recipe == "LeviathanBoat" or recipe == "LeviathanCrown" then
		v7 = { 3 }
	elseif recipe == "LeviathanShield" then
		v7 = { 4 }
	elseif recipe == "Dragonheart" or recipe == "Dragonstorm" then
		v7 = { 3 }
	elseif recipe == "TRexSkull" then
		v7 = { 2 }
	elseif recipe == "DinoHood" then
		v7 = { 3 }
	elseif v2[recipe] then
		v7 = { v2[recipe] }
	else
		v7 = v6
	end

	local could = CraftUtil:PossibleHardcode(recipe, data) and true or false
	local errorMessage = nil
	local craftProgressionComplete

	if craftingRecipe.HasKeyItem and not (data._acquiredKeyItems and data._acquiredKeyItems[craftingRecipe.HasKeyItem]) then
		could = false
		craftProgressionComplete = false
	end

	if progressionRequirement then
		for k, v12 in progressionRequirement do
			local v13 = data.CraftProgression[k] or 0

			if not (v13 < v12) then
				continue
			end

			errorMessage = string.format("Must craft %s more %ss to unlock!", v12 - v13, k)
			could = false
			break
		end

		craftProgressionComplete = could
	end

	for k, ingredient in craftingRecipe.Ingredients do
		local rarity = nil
		local count2 = nil
		local isChoosable

		if typeof(ingredient) == "table" then
			isChoosable = ingredient.IsChoosable
		else
			isChoosable = false
		end

		local amount

		if k == "Beli" then
			count2 = p.Data.Beli.Value
			amount = ingredient.Amount
			rarity = 4
		elseif k == "Fragments" then
			count2 = p.Data.Fragments.Value
			amount = ingredient.Amount
			rarity = 1
		elseif isChoosable then
			amount = ingredient.Amount

			if ingredient.Type == "Fish" then
				rarity = ingredient.Rarity
				count2 = 0

				for _, v11 in data.DecodedFishInventory or FishHelper.DecodeFishInventory(data.EncodedFishInventory) do
					if FishingIndexInventoryData.FishIndex[v11.Id].Rarity == rarity then
						count2 += 1
					end
				end
			end
		else
			rarity = v.Material[k][1]
			count2 = data.EtcItems[k] or 0
			amount = ingredient
		end

		table.insert(v3.Required, {
			Count = count2,
			Rarity = rarity,
			Name = k,
			Required = amount,
			IsChoosable = isChoosable
		})

		if count2 < amount then
			could = false
		end
	end

	v3.Result = {
		Recipe = recipe,
		Name = v4 == "BeastHunter" and "Beast Hunter" or v4,
		Rarity = v7[1],
		Count = count,
		Could = could,
		CraftProgressionComplete = craftProgressionComplete,
		ErrorMessage = errorMessage
	}
	return v3
end

return CraftUtil