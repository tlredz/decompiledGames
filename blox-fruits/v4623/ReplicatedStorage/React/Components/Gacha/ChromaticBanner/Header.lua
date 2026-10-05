local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://2882228740",
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		ImageRectSize = Vector2.new(20, 16),
		LayoutOrder = props.LayoutOrder or 1,
		Position = props.Position or UDim2.fromScale(0, 0),
		ScaleType = Enum.ScaleType.Slice,
		Size = props.Size or UDim2.fromScale(1, 0.19),
		SliceCenter = Rect.new(4, 4, 16, 16),
		ZIndex = props.ZIndex or CONSTANTS.LAYER.RAISED
	}, props), {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.XXS
		}),
		BackgroundTexture = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = Color3.fromRGB(250, 250, 250),
			ImageRectSize = Vector2.new(20, 16),
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(1, 1),
			SliceCenter = Rect.new(4, 4, 16, 16),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.354059, Color3.fromRGB(255, 93, 177)),
					ColorSequenceKeypoint.new(0.666667, Color3.fromRGB(156, 106, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 221, 255))
				})
			})
		}),
		Contents = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.5),
				RichText = true,
				Size = UDim2.fromScale(0, 0.9),
				Text = "💎 Chromatic Gacha Box 💎",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0, 0.45),
					RichText = true,
					Size = UDim2.fromScale(1, 1),
					Text = "💎 Chromatic Gacha Box 💎",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
					})
				})
			}),
			UIPadding = createElement("UIPadding")
		})
	})
end