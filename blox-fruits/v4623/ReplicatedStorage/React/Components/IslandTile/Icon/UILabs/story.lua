local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
require(game.ReplicatedStorage.React.Components.Map.Types)
require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local v = {}

for _, child in script.Parent.Library:GetChildren() do
	local name = child.Name

	for _, child2 in child:GetChildren() do
		v[`{child2.Name} ({name})`] = {
			Sea = name,
			Name = child2.Name,
			Component = require(child2)
		}
	end
end

local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Island = UILabs.Choose(TableUtil.keys(v)),
		Mode = UILabs.Choose({
			"Default",
			"OneStar",
			"TwoStar",
			"ThreeStar",
			"Completed"
		}, 1),
		IsLooping = true
	}
}, function(p)
	return createElement(v[p.controls.Island].Component, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.6),
		Size = UDim2.fromScale(0.4, 0.4),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		IsLooping = p.controls.IsLooping,
		Mode = p.controls.Mode
	})
end)