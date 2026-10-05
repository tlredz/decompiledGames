local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.StatsMenu.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Yellow = {
		Background = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		Border = CONSTANTS.COLOR.PRIMARY.BORDER,
		Highlight = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT
	},
	Grey = {
		Background = Color3.fromHex("#9E9E9E"),
		Border = CONSTANTS.COLOR.DISABLED.BORDER,
		Highlight = Color3.fromHex("#BFBFBF")
	},
	Blue = {
		Background = CONSTANTS.COLOR.SECONDARY.BACKGROUND,
		Border = CONSTANTS.COLOR.SECONDARY.BORDER,
		Highlight = CONSTANTS.COLOR.SECONDARY.HIGHLIGHT
	},
	Red = {
		Background = CONSTANTS.COLOR.DANGER.BACKGROUND,
		Border = CONSTANTS.COLOR.DANGER.BORDER,
		Highlight = CONSTANTS.COLOR.DANGER.HIGHLIGHT
	}
}
local uDim = UDim2.fromScale(0.95, 0.8)
local uDim2 = UDim2.fromScale(0.9, 0.9)
local createElement = React.createElement
return function(props)
	local v2 = v[props.Variant]
	local strokeThickness = props.StrokeThickness or CONSTANTS.THICKNESS.OUTLINE.REGULAR
	local labelSize = props.LabelSize or uDim
	local font = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	local mergeTextButton = RobloxTypes.mergeTextButton({
		BackgroundColor3 = v2.Background,
		BorderColor3 = v2.Border,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	}, props)
	local uIAspectRatioConstraint

	if props.AspectRatio then
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio
		})
	end

	local uISizeConstraint

	if props.MinSize then
		uISizeConstraint = createElement("UISizeConstraint", {
			MinSize = props.MinSize
		})
	end

	local trans

	if props.HighlightVariant == "Centered" then
		trans = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = v2.Highlight,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.94, 0.47)
		})
	else
		trans = createElement("Frame", {
			BackgroundColor3 = v2.Highlight,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0),
			ZIndex = CONSTANTS.LAYER.BASE
		})
	end

	local icon

	if props.Icon then
		icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = props.Icon,
			ImageRectOffset = props.IconRectOffset,
			ImageRectSize = props.IconRectSize,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = props.IconScaleType,
			Size = props.IconSize or uDim2,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	end

	local label

	if props.Label then
		label = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = font,
			Position = UDim2.fromScale(0.5, 0.55),
			RichText = true,
			Size = labelSize,
			Text = props.Label,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			ZIndex = 4
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = strokeThickness
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = font,
				Position = UDim2.fromScale(0.5, 0.45),
				RichText = true,
				Size = UDim2.fromScale(1, 1),
				Text = props.Label,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = strokeThickness
				})
			})
		})
	end

	return createElement("TextButton", mergeTextButton, {
		UIAspectRatioConstraint = uIAspectRatioConstraint,
		UISizeConstraint = uISizeConstraint,
		Trans = trans,
		Icon = icon,
		Label = label
	})
end