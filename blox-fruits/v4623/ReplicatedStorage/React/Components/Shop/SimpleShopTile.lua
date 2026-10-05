local React = require(game.ReplicatedStorage.Packages.React)
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local error = MaterialIconsHD.error
local createElement = React.createElement
return function(props)
	local v = useMatch(props.ItemId)
	assert(v, (`bad itemConfig: {props.ItemId}`))
	local sprite = v.Display.Sprite or error
	local v3

	if props.RobuxPrice == nil then
		v3 = v.Index.ItemId
	end

	local robuxPrice = useRobuxPrice(v3)

	if props.RobuxPrice then
		robuxPrice = props.RobuxPrice
	end

	local v4 = useDrawContext()
	local title = props.Title or v.Display.Title or v.Display.Name or v.Index.StorageKey
	local v7 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ImageTransparency = 1,
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		LayoutOrder = props.LayoutOrder,
		Position = UDim2.fromScale(0.5, 0.04),
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.fromScale(0.19, 0.24),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		SliceCenter = Rect.new(4, 4, 16, 16),
		ZIndex = CONSTANTS.LAYER.RAISED,
		Selectable = v4 ~= "Background",
		[React.Event.Activated] = v4 == "Background" and props.OnClick and function() end or props.OnClick
	}
	local v8 = {
		UICorner = createElement("UICorner", {
			TopRightRadius = CONSTANTS.SPACING.CORNER_RADIUS.NONE,
			TopLeftRadius = CONSTANTS.SPACING.CORNER_RADIUS.NONE,
			BottomRightRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.LG,
			BottomLeftRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.LG
		}),
		Contents = 0,
		UIPadding = 0
	}
	local v11 = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v12 = {
		UIListLayout = createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = CONSTANTS.SPACING.PADDING.NONE
		}),
		Title = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			ImageRectSize = Vector2.new(20, 16),
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Slice,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Size = UDim2.fromScale(1, 0.2),
			SliceCenter = Rect.new(4, 4, 16, 16),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			ImageLabel = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://2882228740",
				ImageColor3 = props.HeaderColor3 or Color3.fromRGB(0, 132, 255),
				ImageRectSize = Vector2.new(20, 16),
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 1),
				SliceCenter = Rect.new(4, 4, 16, 16),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				ImageLabel = createElement("ImageLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://2882228740",
					ImageRectSize = Vector2.new(20, 16),
					ImageTransparency = 0.9,
					LayoutOrder = 1,
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.fromScale(1, 0.5),
					SliceCenter = Rect.new(4, 4, 16, 16),
					ZIndex = CONSTANTS.LAYER.RAISED
				}),
				TextLabel = createElement("TextLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.8, 0.75),
					AnchorPoint = Vector2.new(0.5, 0.45),
					Text = title,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					TextScaled = true,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
					})
				})
			})
		}),
		IconContainer = 0,
		RobuxLabel = 0
	}
	local v15 = {
		BackgroundColor3 = props.IconBackgroundColor3 or CONSTANTS.COLOR.PALETTE.WHITE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Image = "rbxassetid://2750909498",
		ImageTransparency = props.IconBackgroundTransparency or 0.55,
		LayoutOrder = 2,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0, 0.2),
		Size = UDim2.fromScale(1, 0.6),
		SliceCenter = Rect.new(4, 4, 16, 16),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v16 = {
		UIFlexItem = createElement("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Fill,
			ItemLineAlignment = Enum.ItemLineAlignment.Stretch
		}),
		Icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = typeof(sprite.Image) ~= "string" and "" or sprite.Image,
			ImageRectOffset = sprite.ImageRectOffset,
			ImageRectSize = sprite.ImageRectSize,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Crop,
			SizeConstraint = props.IconSizeConstraint or Enum.SizeConstraint.RelativeXY,
			Size = props.IconSize or UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		Sunburst = 0,
		Sunburst2 = 0,
		UpperHypeText = 0,
		HypeText = 0
	}
	local sunburst

	if props.Sunburst then
		sunburst = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://11850376132",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.2, 1.2),
			ZIndex = 0
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	v16.Sunburst = sunburst
	local sunburst2

	if props.Sunburst then
		sunburst2 = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://11850376132",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.2, 1.2),
			ZIndex = 0
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	v16.Sunburst2 = sunburst2
	local upperHypeText

	if props.UpperHypeText then
		upperHypeText = React.createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = props.TileFontFace or Font.new(
				"rbxasset://fonts/families/GothamSSm.json",
				Enum.FontWeight.Medium,
				Enum.FontStyle.Normal
			),
			Position = UDim2.fromScale(0, 0),
			AnchorPoint = Vector2.new(0, 0),
			Size = props.HypeTextSize or UDim2.fromScale(1, 0.25),
			Text = props.UpperHypeText,
			TextColor3 = props.HypeTextColor3 or CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = props.HypeTextStrokeColor3 or CONSTANTS.COLOR.PALETTE.WHITE,
			TextStrokeTransparency = props.HypeTextStrokeTransparency or 0,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	end

	v16.UpperHypeText = upperHypeText
	local hypeText

	if props.HypeText then
		hypeText = React.createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = props.TileFontFace or Font.new(
				"rbxasset://fonts/families/GothamSSm.json",
				Enum.FontWeight.Medium,
				Enum.FontStyle.Normal
			),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			Size = props.HypeTextSize or UDim2.fromScale(1, 0.25),
			Text = props.HypeText,
			TextColor3 = props.HypeTextColor3 or CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = props.HypeTextStrokeColor3 or CONSTANTS.COLOR.PALETTE.WHITE,
			TextStrokeTransparency = props.HypeTextStrokeTransparency or 0,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	end

	v16.HypeText = hypeText
	v12.IconContainer = createElement("ImageLabel", v15, v16)
	v12.RobuxLabel = createElement("Frame", {
		Active = false,
		BackgroundColor3 = CONSTANTS.COLOR.PURCHASE.BACKGROUND,
		BorderColor3 = CONSTANTS.COLOR.PURCHASE.BORDER,
		LayoutOrder = 3,
		Position = UDim2.fromScale(0, 0.8),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Size = UDim2.fromScale(1, 0.2),
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		Highlight = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PURCHASE.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0),
			ZIndex = CONSTANTS.LAYER.BASE
		}),
		UICorner = createElement("UICorner", {
			TopRightRadius = CONSTANTS.SPACING.CORNER_RADIUS.NONE,
			TopLeftRadius = CONSTANTS.SPACING.CORNER_RADIUS.NONE,
			BottomRightRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.LG,
			BottomLeftRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.LG
		}),
		TextLabel = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(1, 0.9),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = `{robuxPrice}`,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			FontFace = CONSTANTS.FONT.FACE.BODY,
			TextScaled = true,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			}),
			TextLabel = createElement("TextLabel", {
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY,
				Position = UDim2.fromScale(0.5, 0.45),
				RichText = true,
				Size = UDim2.fromScale(1, 1),
				Text = `{robuxPrice}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				})
			})
		})
	})
	v8.Contents = createElement("Frame", v11, v12)
	v8.UIPadding = createElement("UIPadding", {
		PaddingBottom = UDim.new(0, 3),
		PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
		PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
		PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
	})
	return createElement("ImageButton", v7, v8)
end