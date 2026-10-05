require(game.ReplicatedStorage.DevPackages.UILabs)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return {
	name = script.Name:gsub(".storybook", ""),
	react = React,
	reactRoblox = ReactRoblox,
	groupRoots = true,
	storyRoots = {
		game.ReplicatedStorage.React.Components.JuiceMenu,
		game.ReplicatedStorage.React.Components.TradeMenu,
		game.ReplicatedStorage.React.Components.TitlesMenu,
		game.ReplicatedStorage.React.Components.ModificationsMenu,
		game.ReplicatedStorage.React.Components.DragonSelectionMenu,
		game.ReplicatedStorage.React.Components.TeamSelection,
		game.ReplicatedStorage.React.Components.StatsMenu
	}
}