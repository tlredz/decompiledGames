local React = require(game.ReplicatedStorage.Packages.React)
local SimpleButton = require(game.ReplicatedStorage.React.Components.SimpleButton)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function fruitShopCard(p)
	return createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = p.LayoutOrder,
		Size = UDim2.fromScale(1, 0.32),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		More = createElement("CanvasGroup", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0.31),
			SizeConstraint = Enum.SizeConstraint.RelativeXX
		}, {
			UICorner = createElement("UICorner"),
			More = createElement("ImageButton", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://2882228740",
				ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0, 0.5),
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 1),
				SliceCenter = Rect.new(4, 4, 16, 16),
				[React.Event.Activated] = p.OnClick,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				Middle = createElement("ImageLabel", {
					BackgroundColor3 = Color3.fromRGB(184, 233, 255),
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					ClipsDescendants = true,
					Image = "rbxassetid://2750909498",
					ImageTransparency = 0.55,
					Size = UDim2.fromScale(1, 0.83),
					SliceCenter = Rect.new(4, 4, 16, 16),
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					ImageLabel = createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Image = "rbxassetid://101535361573077",
						Position = UDim2.fromScale(0.5, 0.5),
						ScaleType = Enum.ScaleType.Crop,
						Size = UDim2.fromScale(1, 0.25),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						ZIndex = CONSTANTS.LAYER.RAISED
					})
				}),
				ImageLabelBottom = createElement("ImageLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://2882228740",
					ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					ImageRectOffset = Vector2.new(0, 4),
					ImageRectSize = Vector2.new(20, 16),
					LayoutOrder = 1,
					Position = UDim2.fromScale(0, 0.82),
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.fromScale(1, 0.18),
					SliceCenter = Rect.new(4, 0, 12, 12),
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					Button = createElement(SimpleButton, {
						Active = true,
						BackgroundColor3 = CONSTANTS.COLOR.PURCHASE.BACKGROUND,
						BorderColor3 = CONSTANTS.COLOR.PURCHASE.BORDER,
						HighlightColor3 = CONSTANTS.COLOR.PURCHASE.HIGHLIGHT,
						ImageColor3 = Color3.fromRGB(4, 211, 70),
						Label = "Open Fruit Shop",
						LayoutOrder = 1,
						ScaleType = Enum.ScaleType.Slice,
						Size = UDim2.fromScale(1, 1),
						SliceCenter = Rect.new(4, 0, 12, 12),
						ZIndex = CONSTANTS.LAYER.RAISED,
						AutoButtonColor = false,
						[React.Event.Activated] = p.OnClick
					}),
					UIPadding = createElement("UIPadding", {
						PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
					})
				}),
				UIPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 3),
					PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
				}),
				ImageLabel = createElement("ImageLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "http://www.roblox.com/asset/?id=9999319457",
					ImageRectOffset = Vector2.new(406, 416),
					ImageRectSize = Vector2.new(203, 139),
					LayoutOrder = 1,
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.fromScale(1, 1),
					SliceCenter = Rect.new(4, 4, 16, 16)
				})
			})
		})
	})
end

return function(p)
	local fragment = React.Fragment
	local v3 = {
		Header = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			LayoutOrder = p.LayoutOrder,
			Size = UDim2.fromScale(1, 0.05),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			Background = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.DIVIDER.BORDER,
				BackgroundTransparency = 0,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = CONSTANTS.LAYER.RAISED
			}),
			Text = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0, 0.05),
				Size = UDim2.fromScale(0.6, 0.9),
				Text = "✨  PERMANENT FRUITS & SKINS!",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIStroke = createElement("UIStroke", {
					Color = Color3.fromRGB(143, 102, 0),
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				UIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.PALETTE.WHITE),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 225, 0))
					}),
					Rotation = 90
				})
			})
		}),
		Card = 0
	}
	local fruitShopCard2 = fruitShopCard
	local layoutOrder

	if p.LayoutOrder then
		layoutOrder = p.LayoutOrder + 1
	end

	v3.Card = createElement(fruitShopCard2, {
		LayoutOrder = layoutOrder,
		OnClick = p.OnClick
	})
	return createElement(fragment, {}, v3)
end