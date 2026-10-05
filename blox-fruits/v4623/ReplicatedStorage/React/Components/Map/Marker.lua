local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Spritesheets)
local Util = require(game.ReplicatedStorage.React.Components.Map.Util)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local useWeightedPosition = require(game.ReplicatedStorage.React.Hooks.Map.useWeightedPosition)
local useMapDefinition = require(game.ReplicatedStorage.React.Hooks.Map.useMapDefinition)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v3, _ = useWeightedPosition(
		useMapDefinition((useCurrentSea())),
		props.Marker.Position,
		props.MapBounds,
		props.AbsoluteCanvasSize
	)
	return createElement("Frame", {
		Position = Util.getGuiPosition(v3.X, v3.Z, props.MapBounds, props.AbsoluteCanvasSize, true),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.04, 0.04),
		BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
		BackgroundColor3 = props.Marker.FillColor,
		Active = false,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH
	}, {
		Icon = createElement("ImageLabel", {
			ImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = props.Marker.Icon.Image,
			ImageRectOffset = props.Marker.Icon.ImageRectOffset,
			ImageRectSize = props.Marker.Icon.ImageRectSize,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.77, 0.77),
			Active = false
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		UIStroke = createElement("UIStroke", {
			Color = CONSTANTS.COLOR.PALETTE.WHITE,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		})
	})
end