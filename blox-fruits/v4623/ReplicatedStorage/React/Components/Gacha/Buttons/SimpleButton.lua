local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Spritesheets)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.354059, Color3.fromRGB(255, 93, 177)),
	ColorSequenceKeypoint.new(0.666667, Color3.fromRGB(156, 106, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 221, 255))
})
local color = Color3.fromRGB(255, 243, 13)
local color2 = Color3.fromRGB(1, 220, 255)
local color3 = Color3.fromRGB(255, 0, 0)
local v = {
	Yellow = {
		BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
		TransBackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT
	},
	Green = {
		BackgroundColor3 = Color3.fromRGB(50, 185, 65),
		BorderColor3 = CONSTANTS.COLOR.PURCHASE.BORDER,
		TransBackgroundColor3 = Color3.fromRGB(76, 214, 90)
	},
	Grey = {
		BackgroundColor3 = Color3.fromRGB(132, 132, 132),
		BorderColor3 = Color3.fromRGB(91, 91, 91),
		TransBackgroundColor3 = Color3.fromRGB(194, 193, 193)
	},
	Red = {
		BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
		BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
		TransBackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT
	},
	Rainbow = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderColor3 = Color3.fromRGB(86, 86, 86),
		TransBackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		Gradient = colorSequence
	}
}
local createElement = React.createElement
return function(props)
	local v2 = v[props.IsDisabled and "Grey" or props.Variant]
	local backgroundColor3 = v2.BackgroundColor3
	local left = props.ApplyCorner and (props.ApplyCorner.Left or props.ApplyCorner.Right)
	local backgroundColor

	if props.Variant == "Rainbow" then
		backgroundColor = color
	else
		backgroundColor = backgroundColor3
	end

	local backgroundColor2

	if props.Variant == "Rainbow" then
		backgroundColor2 = color2
	else
		backgroundColor2 = backgroundColor3
	end

	local mergeTextButton = RobloxTypes.mergeTextButton
	local backgroundTransparency

	if left then
		backgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	else
		backgroundTransparency = CONSTANTS.ALPHA.OPAQUE
	end

	local v9 = mergeTextButton({
		BackgroundColor3 = backgroundColor3,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Text = "",
		AutoButtonColor = props.AutoButtonColor ~= false
	}, props)
	local uIStroke

	if props.StrokeAllowed ~= false then
		local v14 = {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = v2.BorderColor3,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			LineJoinMode = Enum.LineJoinMode.Miter
		}
		local gradient

		if v2.Gradient then
			gradient = createElement("UIGradient", {
				Color = colorSequence
			})
		end

		uIStroke = createElement("UIStroke", v14, {
			Gradient = gradient
		})
	end

	local uIBackgroundGradient

	if v2.Gradient and left ~= true then
		uIBackgroundGradient = createElement("UIGradient", {
			Color = v2.Gradient
		})
	end

	local background

	if left and props.ApplyCorner then
		local v16 = {
			Active = false,
			Selectable = false,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
			BackgroundColor3 = backgroundColor3,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}
		local uIBackgroundGradient2

		if v2.Gradient then
			uIBackgroundGradient2 = createElement("UIGradient", {
				Color = v2.Gradient
			})
		end

		local children = {
			UIBackgroundGradient = uIBackgroundGradient2,
			UICorner = createElement("UICorner", {
				CornerRadius = props.ApplyCorner.CornerRadius
			}),
			ClipTopLeft = createElement("Frame", {
				Size = UDim2.new(0.07, 0, props.ApplyCorner.CornerRadius.Scale, props.ApplyCorner.CornerRadius.Offset),
				BackgroundColor3 = backgroundColor,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
			}),
			ClipTopRight = createElement("Frame", {
				Size = UDim2.new(0.07, 0, props.ApplyCorner.CornerRadius.Scale, props.ApplyCorner.CornerRadius.Offset),
				Position = UDim2.fromScale(1, 0),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = backgroundColor2,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
			}),
			ClipBottomRight = 0,
			ClipBottomLeft = 0
		}
		local clipBottomRight

		if props.ApplyCorner.Right ~= true then
			clipBottomRight = createElement("Frame", {
				Size = UDim2.new(0.07, 0, props.ApplyCorner.CornerRadius.Scale, props.ApplyCorner.CornerRadius.Offset),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = backgroundColor2,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
			})
		end

		children.ClipBottomRight = clipBottomRight
		local clipBottomLeft

		if props.ApplyCorner.Left ~= true then
			clipBottomLeft = createElement("Frame", {
				Size = UDim2.new(0.05, 0, props.ApplyCorner.CornerRadius.Scale, props.ApplyCorner.CornerRadius.Offset),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = backgroundColor,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
			})
		end

		children.ClipBottomLeft = clipBottomLeft
		background = createElement("Frame", v16, children)
	end

	local trans

	if v2.Gradient then
		trans = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = v2.TransBackgroundColor3,
			BackgroundTransparency = 0.55,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.98, 0.45),
			ZIndex = CONSTANTS.LAYER.CONTENT
		})
	else
		trans = createElement("Frame", {
			BackgroundColor3 = v2.TransBackgroundColor3,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0),
			ZIndex = CONSTANTS.LAYER.CONTENT
		})
	end

	local v17 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = 0,
		Size = 0,
		ZIndex = 4
	}
	local position

	if props.Sprite or props.SubText then
		position = UDim2.fromScale(0.5, 0.45)
	else
		position = UDim2.fromScale(0.5, 0.55)
	end

	v17.Position = position
	v17.Size = UDim2.fromScale(1, 1)
	local v22 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = 0,
		BackgroundTransparency = 0,
		FontFace = 0,
		Position = 0,
		Size = 0,
		Text = 0,
		TextColor3 = 0,
		TextScaled = true,
		ZIndex = 0
	}
	local automaticSize

	if not props.TextLabelSize then
		automaticSize = Enum.AutomaticSize.X
	end

	v22.AutomaticSize = automaticSize
	v22.BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	v22.FontFace = CONSTANTS.FONT.FACE.DISPLAY
	local position2

	if props.Sprite or props.SubText then
		position2 = UDim2.fromScale(0.660843, 0.5)
	else
		position2 = UDim2.fromScale(0.5, 0.5)
	end

	v22.Position = position2
	v22.Size = props.TextLabelSize or UDim2.fromScale(0, 0.8)
	v22.Text = props.Text
	v22.TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK
	v22.ZIndex = CONSTANTS.LAYER.RAISED_HIGH
	local v19 = {
		TextLabel = createElement("TextLabel", v22, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			}),
			TextLabel = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Size = UDim2.fromScale(1, 1),
				Text = props.Text,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				})
			})
		}),
		Icon = 0,
		SubText = 0,
		UIListLayout = 0
	}
	local icon

	if props.Sprite and props.SubText == nil then
		icon = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = props.Sprite.Image,
			ImageRectOffset = props.Sprite.ImageRectOffset,
			ImageRectSize = props.Sprite.ImageRectSize,
			LayoutOrder = -999,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.328146, 0.876338)
		}, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	v19.Icon = icon
	local subText

	if props.SubText and props.Sprite == nil then
		local v29 = {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Size = props.TextLabelSize or UDim2.fromScale(0.6, 0.81),
			Text = props.SubText.Text,
			TextColor3 = props.SubText.TextColor or color3,
			TextScaled = true,
			ZIndex = 4
		}
		local frame

		if props.SubText.CrossedOut then
			frame = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = color3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Rotation = -8,
				Size = UDim2.fromScale(1.2, 0.06)
			})
		end

		subText = createElement("TextLabel", v29, {
			Frame = frame
		}, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 2.2
			})
		})
	end

	v19.SubText = subText
	local uIListLayout

	if props.Sprite or props.SubText then
		uIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(props.Sprite and 0.01 or 0.03, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		})
	end

	v19.UIListLayout = uIListLayout
	return createElement("TextButton", v9, {
		UIStroke = uIStroke,
		UIBackgroundGradient = uIBackgroundGradient,
		Background = background,
		Trans = trans,
		Frame = createElement("Frame", v17, v19)
	})
end