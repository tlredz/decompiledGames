require(game.ReplicatedStorage.DevPackages.UILabs)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return {
	name = script.Name:gsub(".storybook", ""),
	react = React,
	reactRoblox = ReactRoblox,
	groupRoots = true,
	storyRoots = {
		game.ReplicatedStorage.React.Components.Map,
		game.ReplicatedStorage.React.Components.IslandTile,
		game.ReplicatedStorage.React.Components.IslandVictorySequence,
		game.ReplicatedStorage.React.Components.WorldTeleporter
	}
}