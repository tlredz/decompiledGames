local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local Util = require(game.ReplicatedStorage.React.Components.Map.Util)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local guiPosition = Util.getGuiPosition(props.A.X, props.A.Z, props.MapBounds, props.AbsoluteCanvasSize, true)
	local guiPosition2 = Util.getGuiPosition(props.B.X, props.B.Z, props.MapBounds, props.AbsoluteCanvasSize, true)
	local lerped = guiPosition:Lerp(guiPosition2, 0.5)
	return createElement("Frame", {
		Size = UDim2.fromOffset(
			4,
			Vector2.new(guiPosition2.X.Offset - guiPosition.X.Offset, guiPosition2.Y.Offset - guiPosition.Y.Offset).Magnitude
		),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		BackgroundColor3 = props.Color,
		Position = lerped,
		BackgroundTransparency = props.Transparency,
		Rotation = math.deg((math.atan2(
			guiPosition2.X.Offset - guiPosition.X.Offset,
			-(guiPosition2.Y.Offset - guiPosition.Y.Offset)
		))),
		ZIndex = props.ZIndex
	})
end