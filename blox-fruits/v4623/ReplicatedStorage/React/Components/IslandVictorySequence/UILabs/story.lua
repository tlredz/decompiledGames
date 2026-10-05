local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Textures = require(game.ReplicatedStorage.Textures)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local islands = {}

for k, v in Map.DEFINITIONS do
	for _, island in v.Islands do
		if islands[island.Index.Key] then
			islands[`{island.Index.Key} ({k})`] = island
		else
			islands[island.Index.Key] = island
		end
	end
end

local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		IsLooping = true,
		Island = UILabs.Choose(TableUtil.keys(islands), 1)
	}
}, function(p)
	return createElement("ImageLabel", {
		Image = Textures.debug["generic-player-screen.jpg"],
		BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = true,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.6, 0.8),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, {
		Sequence = createElement(parentModule, {
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ClipsDescendants = true,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Island = islands[p.controls.Island],
			IsLooping = p.controls.IsLooping,
			IsPlaying = true
		})
	})
end)