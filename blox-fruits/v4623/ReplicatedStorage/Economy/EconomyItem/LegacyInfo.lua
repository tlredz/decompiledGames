require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Option)
local Type = require(game.ReplicatedStorage.Packages.Type)
local Display = require(game.ReplicatedStorage.Packages.Display)
local TypeUtil = require(game.ReplicatedStorage.Economy.TypeUtil)
local class = {}
class.__index = class

function class.__tostring(p)
	local clone = table.clone(p)
	setmetatable(clone, nil)
	return (`{script.Name}<{Display.JSON.new():display(clone)}>`)
end

function class.new(category: string, p2: string, isDeprecated: boolean, robuxItemType: string)
	local self = setmetatable({
		Category = category,
		Key = p2,
		IsDeprecated = isDeprecated,
		RobuxItemType = robuxItemType
	}, class)
	table.freeze(self)
	return self
end

return {
	Type = {
		check = Type.intersection(Type.strictInterface({
			Category = Type.literal("Bundles", "CachedSales", "FruitBoxes", "Items", "Outline", "Robux", "Sales"),
			Key = Type.string,
			IsDeprecated = Type.boolean,
			RobuxItemType = Type.literal(
				"FruitBox",
				"Bundle",
				"AuraSkin",
				"FruitSkin",
				"FruitMutation",
				"Currency",
				"Gamepass",
				"Fruit",
				"ExpProduct",
				"PhysicalRocketFruit",
				"NamedProduct",
				"StoredProduct",
				"SkinBundle",
				"SkinnedFruit",
				"MutatedFruit",
				"DungeonProduct",
				"MasteryProduct",
				"Sword",
				"SwordSkin",
				"ProfileItem"
			)
		}), TypeUtil.Metatable.Type.check(class))
	},
	Class = class
}