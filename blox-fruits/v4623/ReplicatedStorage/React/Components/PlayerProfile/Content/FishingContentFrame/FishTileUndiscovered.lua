local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(_)
	return createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.184211, -1.24731e-7),
		Size = UDim2.fromOffset(100, 137)
	}, {
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.529, 1),
			Size = UDim2.fromScale(1, 0.288021),
			Text = "Rainbow Carp",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.MID,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}, {
			uIStroke = createElement("UIStroke"),
			uITextSizeConstraint = createElement("UITextSizeConstraint", {
				MaxTextSize = 30
			})
		}),
		undiscoveredState = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			LayoutOrder = -1,
			Position = UDim2.fromScale(0.5, 0.01),
			Size = UDim2.fromScale(1, 1)
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.08, 0)
			}),
			uIStroke = createElement("UIStroke", {
				Color = CONSTANTS.COLOR.DIVIDER.BORDER,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			}),
			fishIcon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://98130889923069",
				ImageColor3 = CONSTANTS.COLOR.DIVIDER.BORDER,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.4, 0.4)
			}),
			fishNumber = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0.07, 0.05),
				Size = UDim2.fromScale(0.673, 0.25),
				Text = "02",
				TextColor3 = Color3.fromRGB(103, 103, 103),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS.LAYER.RAISED
			})
		})
	})
end