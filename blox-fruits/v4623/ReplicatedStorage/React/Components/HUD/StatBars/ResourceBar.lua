local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local overflowAlpha = props.OverflowAlpha
	local state, setState = React.useState(nil)
	local v4 = RobloxTypes.mergeFrame({
		BackgroundColor3 = Color3.fromRGB(0, 13, 1),
		BorderColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		[React.Change.AbsoluteSize] = function(p)
			local Y = math.round(p.AbsoluteSize.Y)

			if Y ~= state then
				setState(Y)
			end
		end
	}, props)
	local children = {
		UISizeConstraint = state and createElement("UISizeConstraint", {
			MinSize = Vector2.new(state * (4 + props.Label:len() + props.ValueText:len()) * 0.16, 0),
			MaxSize = Vector2.new(1e999, 1e999)
		}),
		Fill = 0,
		TextContainer = 0,
		OverFill = 0,
		UIStroke = 0
	}
	local v7 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = true,
		Size = UDim2.fromScale(props.Alpha, 1),
		ZIndex = -9
	}
	local color

	if props.Variant == "Green" then
		color = Color3.fromRGB(59, 255, 0)
	elseif props.Variant == "Blue" then
		color = Color3.fromRGB(0, 222, 255)
	elseif props.Variant == "Red" then
		color = Color3.fromRGB(255, 59, 0)
	end

	local v8 = {
		Trans = createElement("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.5, 0),
			ZIndex = -9
		}, {
			UIGradient = createElement("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.388813, 0),
					NumberSequenceKeypoint.new(1, 0.675)
				})
			})
		}),
		UIGradient = 0,
		UIStroke = 0
	}
	local colorSequence

	if props.Variant == "Green" then
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 198, 0)),
			ColorSequenceKeypoint.new(0.39551, Color3.fromRGB(29, 199, 4)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 159, 0))
		})
	elseif props.Variant == "Blue" then
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 173, 225)),
			ColorSequenceKeypoint.new(0.39551, Color3.fromRGB(0, 173, 225)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 182))
		})
	elseif props.Variant == "Red" then
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(198, 26, 0)),
			ColorSequenceKeypoint.new(0.39551, Color3.fromRGB(199, 29, 4)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(159, 21, 0))
		})
	end

	v8.UIGradient = createElement("UIGradient", {
		Color = colorSequence,
		Rotation = 90
	})
	local v17 = {
		BorderStrokePosition = Enum.BorderStrokePosition.Inner,
		Color = CONSTANTS.COLOR.PALETTE.WHITE,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Thickness = 0.03,
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local colorSequence2

	if props.Variant == "Green" then
		colorSequence2 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 214, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(47, 226, 0))
		})
	elseif props.Variant == "Blue" then
		colorSequence2 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 179, 233)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 195, 231))
		})
	elseif props.Variant == "Red" then
		colorSequence2 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(214, 35, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(226, 47, 0))
		})
	end

	v8.UIStroke = createElement("UIStroke", v17, {
		UIGradient = createElement("UIGradient", {
			Color = colorSequence2,
			Rotation = 90
		})
	})
	children.Fill = createElement("Frame", v7, v8)
	children.TextContainer = createElement("Frame", {
		Active = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.95, 0.9),
		ZIndex = -7
	}, {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		HealthText = createElement("TextLabel", {
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 0.8),
			Text = props.Label,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			UIStroke = createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Transparency = CONSTANTS.ALPHA.MID,
				Thickness = 0.04
			})
		}),
		AmountText = createElement("TextLabel", {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 0.8),
			Text = props.ValueText,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right
		}, {
			UIStroke = createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Transparency = CONSTANTS.ALPHA.MID,
				Thickness = 0.04
			})
		})
	})
	children.OverFill = overflowAlpha and overflowAlpha > 0 and createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 98, 255),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Size = UDim2.fromScale(overflowAlpha, 1),
		ZIndex = -8
	}, {
		InnerGlow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "http://www.roblox.com/asset/?id=7488323191",
			ImageColor3 = Color3.fromRGB(0, 243, 255),
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(1, 1),
			SliceCenter = Rect.new(60, 60, 103, 132),
			ZIndex = -8
		}),
		OutterGlow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "http://www.roblox.com/asset/?id=10996413451",
			ImageColor3 = Color3.fromRGB(0, 136, 255),
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.new(1, 8, 1, 8),
			SliceCenter = Rect.new(4, 4, 6, 6),
			ZIndex = -8
		}),
		Trans = createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(0, 98, 173),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.new(0, 2, 0.6, -2),
			Size = UDim2.new(1, -4, 0.4, 0),
			ZIndex = -8
		}, {
			UISizeConstraint = createElement("UISizeConstraint")
		})
	}) or nil
	children.UIStroke = createElement("UIStroke", {
		Color = CONSTANTS.COLOR.PALETTE.BLACK,
		LineJoinMode = Enum.LineJoinMode.Miter,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Thickness = 0.05
	})
	return createElement("Frame", v4, children)
end