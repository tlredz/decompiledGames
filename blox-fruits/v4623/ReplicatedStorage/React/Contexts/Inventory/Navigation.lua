local React = require(game.ReplicatedStorage.Packages.React)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.React.Contexts.ItemSelection)
return React.createContext({
	Group = PseudoEnum.InventoryItemGroup.Backpack,
	Bracket = nil,
	SortType = PseudoEnum.InventorySortType.Rarity,
	SetNavigation = function(_, _, _, _)
		print("Warning: No Inventory Navigation Context Provider found!")
	end
})