require(game.ReplicatedStorage.DevPackages.UILabs)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return {
	name = script.Name:gsub(".storybook", ""),
	react = React,
	reactRoblox = ReactRoblox,
	groupRoots = true,
	storyRoots = {
		game.ReplicatedStorage.Packages,
		game.ReplicatedStorage.Util.Trajectory,
		game.ServerScriptService.Services.BonusMomentsService,
		game.ServerScriptService.Services.MapServices,
		game.ReplicatedStorage.ClientComponents.SimulationHubController,
		game.ReplicatedStorage.Controllers.ThrowController,
		game.ReplicatedStorage.Controllers.UI.FruitShop,
		game.ReplicatedStorage.Controllers.IslandController.WorldTeleporter,
		game.ReplicatedFirst.Packages._Index["nightcycle_noise@1.0.0"]
	}
}