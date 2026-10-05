require(game.ReplicatedStorage.DevPackages.UILabs)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return {
	name = script.Name:gsub(".storybook", ""),
	react = React,
	reactRoblox = ReactRoblox,
	groupRoots = true,
	storyRoots = {
		game.ReplicatedStorage.React.Components.Tile,
		game.ReplicatedStorage.React.Components.FruitShop.FruitCard.Card.Profile.FruitTile,
		game.ReplicatedStorage.React.Components.Inventory.Main.TileGrid.FastTile
	}
}