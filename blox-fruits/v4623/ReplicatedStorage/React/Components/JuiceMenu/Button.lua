local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local mergeTextButton = RobloxTypes.mergeTextButton
	local color

	if props.IsDisabled then
		color = Color3.fromHex("848484")
	elseif props.Variant == "Yellow" then
		color = CONSTANTS.COLOR.PRIMARY.BACKGROUND
	else
		color = Color3.fromRGB(89, 255, 0)
	end

	local color2

	if props.IsDisabled then
		color2 = Color3.fromHex("212117")
	elseif props.Variant == "Yellow" then
		color2 = Color3.fromRGB(255, 240, 69)
	else
		color2 = Color3.fromRGB(49, 188, 59)
	end

	local v4 = mergeTextButton({
		BackgroundColor3 = color,
		BorderColor3 = color2,
		FontFace = CONSTANTS.FONT.FACE.BODY_LIGHT,
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		Active = not props.IsDisabled,
		Selectable = not props.IsDisabled,
		AutoButtonColor = not props.IsDisabled,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	}, props)
	local color3

	if props.IsDisabled then
		color3 = Color3.fromHex("C2C2C2")
	elseif props.Variant == "Yellow" then
		color3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT
	else
		color3 = Color3.fromRGB(155, 255, 133)
	end

	local v5 = {
		Trans = createElement("Frame", {
			BackgroundColor3 = color3,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0),
			ZIndex = 4
		}),
		TextContainer = 0
	}
	local textContainer

	if props.Icon then
		textContainer = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}, {
			ImageLabel = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = props.Icon,
				ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(0.7, 0.7),
				SizeConstraint = Enum.SizeConstraint.RelativeYY
			}, {
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = CONSTANTS.SPACING.PADDING.SCALE.LG,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0, 1),
				Text = props.Text,
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			})
		})
	else
		textContainer = createElement(React.Fragment, {}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.8),
				Text = props.Text,
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.OVERLAY
			})
		})
	end

	v5.TextContainer = textContainer
	return createElement("TextButton", v4, v5)
end