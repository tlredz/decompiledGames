local React = require(game.ReplicatedStorage.Packages.React)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local SimpleButton = require(game.ReplicatedStorage.React.Components.SimpleButton)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local font = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	}, props)
	local v3 = {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		UIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
				ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
			})
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = font,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.8, 0.8),
			Text = props.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = font,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = props.Text,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		RightButtons = 0
	}
	local v6 = {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromScale(0.4, 1),
		Active = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}
	local v7 = {
		UIListLayout = createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.LG
		}),
		UIPadding = createElement("UIPadding", {
			PaddingRight = CONSTANTS.SPACING.PADDING.SCALE.MD,
			PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XXL,
			PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.XXL
		}),
		Close = 0,
		Gift = 0,
		Help = 0
	}
	local onExit = props.OnExit

	if onExit then
		onExit = createElement(SimpleButton, {
			AnchorPoint = Vector2.new(1, 0.5),
			AspectRatio = 1,
			HighlightVariant = "Centered",
			Icon = {
				Image = "rbxassetid://127503254560275",
				ImageRectSize = Vector2.new(100, 100),
				ImageRectOffset = Vector2.zero
			},
			ColorScheme = "DANGER",
			IconSize = UDim2.fromScale(1, 1),
			LayoutOrder = 10,
			Position = UDim2.fromScale(0.99, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.Activated] = props.OnExit
		})
	end

	v7.Close = onExit
	local gift

	if props.OnGift then
		local onGiftsByActivated = {
			AnchorPoint = Vector2.new(1, 0.5),
			AspectRatio = 1,
			HighlightVariant = "Centered",
			Icon = SpriteMap.UI.Gift,
			IconBorderOffset = UDim2.fromScale(0, -0.04),
			IconOutline = SpriteMap.UI.Gift_Outline,
			IconSize = UDim2.fromScale(0.85, 0.85),
			LabelSize = UDim2.fromScale(0.95, 0.95),
			Position = UDim2.fromScale(0.899201, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.GREY_500,
			BorderColor3 = CONSTANTS.COLOR.DISABLED.BORDER,
			HighlightColor3 = CONSTANTS.COLOR.PALETTE.GREY_450,
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.Activated] = props.OnGift
		}
		gift = createElement(SimpleButton, onGiftsByActivated) or nil
	end

	v7.Gift = gift
	local help

	if props.OnHelp then
		local onHelpsByActivated = {
			AnchorPoint = Vector2.new(1, 0.5),
			AspectRatio = 1,
			HighlightVariant = "Centered",
			Label = "?",
			LabelSize = UDim2.fromScale(0.95, 0.95),
			Position = UDim2.fromScale(0.899201, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.SECONDARY.BORDER,
			HighlightColor3 = CONSTANTS.COLOR.SECONDARY.HIGHLIGHT,
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.Activated] = props.OnHelp
		}
		help = createElement(SimpleButton, onHelpsByActivated) or nil
	end

	v7.Help = help
	v3.RightButtons = createElement("Frame", v6, v7)
	return createElement("Frame", mergeFrame, v3)
end