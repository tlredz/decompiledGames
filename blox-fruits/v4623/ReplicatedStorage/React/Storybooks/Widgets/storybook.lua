require(game.ReplicatedStorage.DevPackages.UILabs)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return {
	name = script.Name:gsub(".storybook", ""),
	react = React,
	reactRoblox = ReactRoblox,
	groupRoots = true,
	storyRoots = {
		game.ReplicatedStorage.React.Components.ConfirmationDialog,
		game.ReplicatedStorage.React.Components.LoadingIcon,
		game.ReplicatedStorage.React.Components.Button,
		game.ReplicatedStorage.React.Components.ParallaxBackground,
		game.ReplicatedStorage.React.Components.Beam,
		game.ReplicatedStorage.React.Components.ParticleEmitter,
		game.ReplicatedStorage.React.Components.TextField,
		game.ReplicatedStorage.React.Components.Dropdown
	}
}