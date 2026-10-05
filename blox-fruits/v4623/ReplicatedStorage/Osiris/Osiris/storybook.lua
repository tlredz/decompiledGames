require(game.ReplicatedStorage.DevPackages.UILabs)
return {
	name = script.Name:gsub(".storybook", ""),
	groupRoots = true,
	storyRoots = { script.Parent.Widgets, script.Parent.Components }
}