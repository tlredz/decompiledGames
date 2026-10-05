require(game.ReplicatedStorage.DevPackages.UILabs)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return {
	name = script.Parent.Name,
	react = React,
	reactRoblox = ReactRoblox,
	groupRoots = true,
	storyRoots = { script.Parent }
}