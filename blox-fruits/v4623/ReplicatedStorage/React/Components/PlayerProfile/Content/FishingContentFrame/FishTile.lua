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
		tile = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			selectedImg = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "http://www.roblox.com/asset/?id=9810799683",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.new(0.925, 20, 0.925, 20),
				SliceCenter = Rect.new(16, 16, 43, 43),
				Visible = false,
				ZIndex = 6
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "http://www.roblox.com/asset/?id=15243506332",
				ImageRectOffset = Vector2.new(750, 450),
				ImageRectSize = Vector2.new(150, 150),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.89, 0.89),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}),
			background = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://109093383837997",
				ImageRectOffset = Vector2.new(218, 225),
				ImageRectSize = Vector2.new(218, 225),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1)
			}),
			counter = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.2,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-1.18977e-6, 0.0700002),
				Size = UDim2.fromScale(0.59, 0.23),
				Visible = false,
				ZIndex = 10
			}, {
				uIGradient = createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.542964, 0.38125),
						NumberSequenceKeypoint.new(0.768369, 0.675),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				shadow = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.15, 0.6),
					Size = UDim2.fromScale(1, 1),
					Text = "x3",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				}, {
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.TITLE,
						Position = UDim2.fromScale(0.45, 0.425),
						Size = UDim2.fromScale(1, 1),
						Text = "x3",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left
					}, {
						uIStroke = createElement("UIStroke", {
							Thickness = 0.5
						})
					})
				})
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.98
			}),
			heaviestWeightShadow = createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.94, 0.925),
				Size = UDim2.fromScale(0.794, 0.225),
				Text = "21 kg",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.MID,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				Visible = false,
				ZIndex = CONSTANTS.LAYER.OVERLAY
			}, {
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(1, 1),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.99, 0.92),
					Size = UDim2.fromScale(1, 1),
					Text = "21 kg",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextStrokeTransparency = CONSTANTS.ALPHA.MID,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					ZIndex = CONSTANTS.LAYER.OVERLAY
				}, {
					uIStroke = createElement("UIStroke")
				})
			})
		}),
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
		})
	})
end