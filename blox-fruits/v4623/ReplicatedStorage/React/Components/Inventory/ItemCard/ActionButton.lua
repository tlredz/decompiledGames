local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("ImageButton", RobloxTypes.mergeImageButton({
		AutoButtonColor = false,
		BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p), {
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = CONSTANTS.COLOR.PRIMARY.BORDER,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Highlight = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.94, 0.47),
			ZIndex = CONSTANTS.LAYER.CONTENT
		}),
		Text = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			LineHeight = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			Text = p.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			Stroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			})
		})
	})
end