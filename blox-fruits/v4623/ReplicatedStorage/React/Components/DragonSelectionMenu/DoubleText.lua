local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local text = props.Text
	local fontFace = props.FontFace or CONSTANTS.FONT.FACE.BODY
	local borderColor3 = props.BorderColor3 or CONSTANTS.COLOR.PALETTE.BLACK
	local textColor3 = props.TextColor3 or CONSTANTS.COLOR.PALETTE.WHITE
	local textXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
	local textYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	return createElement("Frame", RobloxTypes.mergeGuiObject({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props), {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.015, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}),
		OverLabel = createElement("TextLabel", {
			Size = UDim2.fromScale(0, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			AutomaticSize = Enum.AutomaticSize.X,
			FontFace = fontFace or CONSTANTS.FONT.FACE.BODY,
			TextXAlignment = textXAlignment,
			TextYAlignment = textYAlignment,
			Text = text,
			TextColor3 = borderColor3,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			}),
			UnderLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = fontFace or CONSTANTS.FONT.FACE.BODY,
				TextXAlignment = textXAlignment,
				TextYAlignment = textYAlignment,
				Position = UDim2.new(0.5, 0, 0.5, -3),
				Size = UDim2.fromScale(1, 1),
				Text = text,
				TextColor3 = textColor3,
				TextScaled = true,
				TextSize = 14,
				TextWrapped = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIStroke1 = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				})
			})
		})
	})
end