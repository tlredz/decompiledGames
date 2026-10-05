local React = require(game.ReplicatedStorage.Packages.React)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	return createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 0.05),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		Frame = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.DIVIDER.BORDER,
			BackgroundTransparency = 0,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		TextLabel = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY,
			LayoutOrder = 1,
			Position = UDim2.fromScale(0, 0.05),
			Size = UDim2.fromScale(0.75, 0.9),
			Text = props.Text,
			TextColor3 = props.TextColor3 or CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = CONSTANTS.LAYER.RAISED
		})
	})
end