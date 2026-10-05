local React = require(game.ReplicatedStorage.Packages.React)
require(script.Parent.Types)
local Button = require(script.Parent.Button)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("Frame", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		LayoutOrder = 3,
		Position = UDim2.fromScale(0, 0.7715),
		Size = UDim2.fromScale(1, 0.08)
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.SM,
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM,
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM,
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.SM
		}),
		Close = createElement(Button, {
			AnchorPoint = Vector2.new(0, 1),
			LayoutOrder = 1,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(0.15, -2, 1, 0),
			Text = "Back",
			Variant = "Yellow",
			ZIndex = 4,
			[React.Event.Activated] = function()
				p.OnAction({
					Type = "Back"
				})
			end
		}),
		Purchase = createElement(Button, {
			AnchorPoint = Vector2.new(1, 0.5),
			LayoutOrder = 3,
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.new(0.15, -2, 1, 0),
			Text = "Purchase",
			Variant = "Yellow",
			Visible = false,
			ZIndex = 4
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
			LayoutOrder = 2,
			Position = UDim2.new(0.85, -2, 0.5, 0),
			RichText = true,
			Size = UDim2.fromScale(0.65, 1),
			Text = p.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE
		})
	})
end