local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Util.TypeUtil)
local Icon = require(game.ReplicatedStorage.React.Components.Icon)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local uDim = UDim2.fromScale(0.95, 0.8)
local uDim2 = UDim2.fromScale(0.9, 0.9)
local PRIMARY = CONSTANTS.COLOR.PRIMARY
local font = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local createElement = React.createElement
return function(props)
	local colorScheme = props.ColorScheme
	local highlightColor3 = props.HighlightColor3
	local borderColor3 = props.BorderColor3
	local backgroundColor3 = props.BackgroundColor3
	local textColor3 = props.TextColor3
	local strokeColor3 = props.StrokeColor3
	local v = colorScheme and CONSTANTS.COLOR[colorScheme] or PRIMARY
	local backgroundColor = highlightColor3 or v.HIGHLIGHT
	local borderColor = borderColor3 or v.BORDER
	local backgroundColor2 = backgroundColor3 or v.BACKGROUND
	local v5 = textColor3 or v.TEXT
	local v6 = strokeColor3 or v.STRORE
	local strokeThickness = props.StrokeThickness or CONSTANTS.THICKNESS.OUTLINE.REGULAR
	local labelSize = props.LabelSize or uDim
	local mergeTextButton = RobloxTypes.mergeTextButton({
		BackgroundColor3 = backgroundColor2,
		BorderColor3 = borderColor,
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

	if backgroundColor ~= backgroundColor2 then
		if props.HighlightVariant == "Centered" then
			trans = createElement("Frame", {
				Active = false,
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = backgroundColor,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.94, 0.47)
			})
		else
			trans = createElement("Frame", {
				BackgroundColor3 = backgroundColor,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 0.4, 0),
				ZIndex = CONSTANTS.LAYER.BASE
			})
		end
	end

	local v9 = {
		UIAspectRatioConstraint = uIAspectRatioConstraint,
		UISizeConstraint = uISizeConstraint,
		Trans = trans,
		Icon = props.Icon and createElement(Icon, {
			Icon = props.Icon,
			BorderIcon = props.IconOutline,
			BorderOffset = props.IconBorderOffset,
			BorderColor3 = v6,
			ImageColor3 = v5,
			ScaleType = props.IconScaleType,
			Size = props.IconSize or uDim2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}),
		Label = 0
	}
	local label

	if props.Label then
		label = createElement("TextLabel", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = font,
			Position = UDim2.fromScale(0.5, 0.55),
			RichText = true,
			Size = labelSize,
			Text = props.Label,
			TextColor3 = v6,
			TextScaled = true,
			ZIndex = 4
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = strokeThickness
			}),
			TextLabel = createElement("TextLabel", {
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = font,
				Position = UDim2.fromScale(0.5, 0.45),
				RichText = true,
				Size = UDim2.fromScale(1, 1),
				Text = props.Label,
				TextColor3 = v5,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = strokeThickness
				})
			})
		})
	end

	v9.Label = label
	return createElement("TextButton", mergeTextButton, v9)
end