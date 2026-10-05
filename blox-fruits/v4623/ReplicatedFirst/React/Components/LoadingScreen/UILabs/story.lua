local Global = require(game.ReplicatedFirst.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("ReactRoblox"))
local UILabs = require(ReplicatedFirst:WaitForChild("DevPackages"):WaitForChild("UILabs"))
local parentModule = require(script.Parent)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Stage = UILabs.Choose({ "Unloaded", "Loading", "Loaded" }, 1),
		DestinationName = UILabs.Choose({ "First Sea", "Second Sea", "Third Sea" }, 1),
		AssetsLoaded = UILabs.Number(0, 0, 15),
		AssetsNeeded = UILabs.Number(5, 1, 15)
	}
}, function(p)
	return createElement(parentModule, {
		Stage = p.controls.Stage,
		LoadingMessage = `Loading {p.controls.DestinationName}`,
		Size = UDim2.fromScale(1, 1),
		AssetsLoaded = p.controls.AssetsLoaded,
		AssetsNeeded = p.controls.AssetsNeeded
	})
end)