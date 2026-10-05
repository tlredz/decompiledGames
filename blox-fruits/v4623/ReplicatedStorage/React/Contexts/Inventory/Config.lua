local React = require(game.ReplicatedStorage.Packages.React)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local v = {
	Title = "Items",
	TileCategoryIconOverride = Spritesheets.MAP_WITH_EXT["Badge Gear.png"],
	FavoritingEnabled = true,
	NewCountEnabled = true,
	Layout = {
		[PseudoEnum.InventoryItemGroup.Backpack] = {
			SortingTypes = { PseudoEnum.InventorySortType.Rarity },
			Brackets = {
				PseudoEnum.InventoryItemBracket.Swords,
				PseudoEnum.InventoryItemBracket.Guns,
				PseudoEnum.InventoryItemBracket.Gear,
				PseudoEnum.InventoryItemBracket.Consumables
			}
		},
		[PseudoEnum.InventoryItemGroup.Treasure] = {
			SortingTypes = { PseudoEnum.InventorySortType.Rarity },
			Brackets = { PseudoEnum.InventoryItemBracket.Fruits, PseudoEnum.InventoryItemBracket.Premium }
		},
		[PseudoEnum.InventoryItemGroup.Wardrobe] = {
			SortingTypes = { PseudoEnum.InventorySortType.Rarity },
			Brackets = {
				PseudoEnum.InventoryItemBracket.Accessories,
				PseudoEnum.InventoryItemBracket.Trinkets,
				PseudoEnum.InventoryItemBracket.Configurables
			}
		},
		[PseudoEnum.InventoryItemGroup.Stash] = {
			SortingTypes = { PseudoEnum.InventorySortType.Rarity },
			Brackets = {
				PseudoEnum.InventoryItemBracket.Usables,
				PseudoEnum.InventoryItemBracket.Materials,
				PseudoEnum.InventoryItemBracket.Fish
			}
		},
		[PseudoEnum.InventoryItemGroup.Build] = {
			SortingTypes = {},
			Brackets = {}
		}
	}
}
TableUtil.deepFreeze(v)
return React.createContext(v)