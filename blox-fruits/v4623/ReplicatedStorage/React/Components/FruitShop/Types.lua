local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.Spritesheets)
local EconomyItem = require(game.ReplicatedStorage.Economy.EconomyItem)
local Util = require(game.ReplicatedStorage.React.Util)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local intersection = Type.intersection(TypeUtil.Types.FrozenTable, Type.strictInterface({
	Art = Util.Types.ImageData,
	Icon = Util.Types.ImageData
}))
local intersection2 = Type.intersection(TypeUtil.Types.FrozenTable, Type.strictInterface({
	Key = Type.EnumItem,
	StarCount = Type.number,
	DisplayName = Type.string
}))
local intersection3 = Type.intersection(TypeUtil.Types.FrozenTable, Type.strictInterface({
	Text = Type.optional(Type.string),
	Icon = Type.optional(Type.string)
}))
local intersection4 = Type.intersection(TypeUtil.Types.FrozenTable, Type.strictInterface({
	Name = Type.string,
	Color = Type.Color3,
	Value = Type.number,
	IdleBackground = Type.optional(Util.Types.ImageData),
	HoverBackground = Type.optional(Util.Types.ImageData)
}))
return {
	Types = {
		TexturePack = intersection,
		FruitSkill = intersection2,
		FruitFact = intersection3,
		FruitRarity = intersection4,
		FruitData = Type.intersection(TypeUtil.Types.FrozenTable, Type.strictInterface({
			Name = Type.string,
			AssetId = Type.integer,
			DisplayName = Type.string,
			Icon = Util.Types.ImageData,
			Item = EconomyItem.Type.check,
			Rarity = intersection4,
			PermanentOnly = Type.boolean,
			IsAnimatedBackground = Type.boolean,
			ArtworkIcon = Type.optional(Util.Types.ImageData),
			Description = Type.optional(Type.string),
			HasMutations = Type.boolean,
			Price = Type.optional(Type.number),
			PermanentRobuxPrice = Type.optional(Type.number),
			SortOrderOffset = Type.optional(Type.number),
			Skills = Type.array(intersection2),
			Facts = Type.array(intersection3)
		}))
	}
}