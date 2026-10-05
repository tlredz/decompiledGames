local React = require(game.ReplicatedStorage.Packages.React)
local IslandRing = require(game.ReplicatedStorage.React.Components.WorldTeleporter.IslandRing)
local MagicCircle = require(game.ReplicatedStorage.React.Components.WorldTeleporter.MagicCircle)
local useOrbitLayout = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useOrbitLayout)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = useOrbitLayout(props.Islands, props.Centered, props.IsExpanded)
	local children = {}

	for _, ring in v.Rings do
		local v2 = 1 - 0.15000000000000002 * ring.Presence
		children[`{ring.Id}OrbitCircle`] = createElement(MagicCircle, {
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(ring.Diameter, ring.Diameter),
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			ImageTransparency = v2,
			Thickness = 0.004,
			EdgeThickness = 0.001,
			EdgeTransparency = v2,
			BorderOffset = ring.BorderOffset,
			NoGlow = true
		})
	end

	return createElement(React.Fragment, {}, {
		Circles = createElement(React.Fragment, {}, children),
		IslandRing = createElement(IslandRing, {
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(CONSTANTS2.RING_FRAME_SCALE, CONSTANTS2.RING_FRAME_SCALE),
			ZIndex = 10,
			Islands = v.Islands,
			OnSelect = props.OnSelect
		})
	})
end