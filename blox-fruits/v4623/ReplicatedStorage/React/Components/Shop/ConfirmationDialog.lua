local React = require(game.ReplicatedStorage.Packages.React)
local Header = require(game.ReplicatedStorage.React.Components.Header)
local SimpleButton = require(game.ReplicatedStorage.React.Components.SimpleButton)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = useMatch(props.ItemId)
	assert(v, "bad itemConfig")
	local v2 = useViewportSize()
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.HALF,
		Size = UDim2.new(
			0,
			v2.X * ((not props.Size and 1 or props.Size.X.Scale or 1) * 0.6) + (not props.Size and 0 or props.Size.X.Offset or 0),
			0,
			v2.Y * ((not props.Size and 1 or props.Size.Y.Scale or 1) * 0.6) + (not props.Size and 0 or props.Size.Y.Offset or 0)
		)
	}, props)
	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Title = createElement(Header, {
			Text = "Confirm Purchase",
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			Size = UDim2.fromScale(1, 0.168727),
			LayoutOrder = 1
		}),
		Body = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			BorderColor3 = Color3.fromRGB(255, 197, 20),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 2,
			Size = UDim2.fromScale(1.00126, 0.3)
		}, {
			UIFlexItem = createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Fill,
				ItemLineAlignment = Enum.ItemLineAlignment.Stretch
			}),
			TextLabel = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Size = UDim2.fromScale(0.85, 0.6),
				Text = "Purchase this product for yourself or for a friend?",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			}),
			UIListLayout = createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.04, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		}),
		UICorner = createElement("UICorner", {
			BottomLeftRadius = UDim.new(0.02, 0),
			BottomRightRadius = UDim.new(0.02, 0),
			CornerRadius = UDim.new(0.02, 0),
			TopLeftRadius = UDim.new(0.02, 0),
			TopRightRadius = UDim.new(0.02, 0)
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Footer = 0,
		UIAspectRatioConstraint = 0,
		UISizeConstraint = 0
	}
	local v7 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		LayoutOrder = 3,
		Size = UDim2.fromScale(1, 0.25)
	}
	local v8 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		Buy = 0,
		Cancel = 0,
		UICorner = 0,
		GiftButton = 0
	}
	local buy

	if props.OnBuy then
		buy = createElement(SimpleButton, {
			LayoutOrder = 1,
			BackgroundColor3 = CONSTANTS.COLOR.PURCHASE.BACKGROUND,
			HighlightColor3 = CONSTANTS.COLOR.PURCHASE.HIGHLIGHT,
			BorderColor3 = CONSTANTS.COLOR.PURCHASE.BORDER,
			Size = UDim2.fromScale(0.3, 0.7),
			Label = "Buy",
			[React.Event.Activated] = function()
				props.OnBuy()
			end
		}) or nil
	end

	v8.Buy = buy
	v8.Cancel = createElement(SimpleButton, {
		LayoutOrder = 3,
		BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		HighlightColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
		Size = UDim2.fromScale(0.2, 0.7),
		Label = "Cancel",
		[React.Event.Activated] = function()
			props.OnCancel()
		end
	}) or nil
	v8.UICorner = createElement("UICorner", {
		BottomLeftRadius = UDim.new(0.04, 0),
		BottomRightRadius = UDim.new(0.04, 0),
		CornerRadius = UDim.new(0.04, 0),
		TopLeftRadius = UDim.new(0.04, 0),
		TopRightRadius = UDim.new(0.04, 0)
	})
	local giftButton

	if props.OnGift and v.Economy and v.Economy.IsGiftable then
		giftButton = createElement(SimpleButton, {
			LayoutOrder = 2,
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			HighlightColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
			BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
			Size = UDim2.fromScale(0.2, 0.7),
			Label = "Gift",
			[React.Event.Activated] = function()
				props.OnGift()
			end
		}) or nil
	end

	v8.GiftButton = giftButton
	children.Footer = createElement("Frame", v7, v8)
	children.UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 2.25
	})
	children.UISizeConstraint = createElement("UISizeConstraint", {
		MaxSize = Vector2.new(550, 550)
	})
	return createElement("Frame", mergeFrame, children)
end