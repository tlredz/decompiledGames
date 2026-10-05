local React = require(game.ReplicatedStorage.Packages.React)
local SectionHeader = require(script.Parent.Parent.SectionHeader)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local fragment = React.Fragment
	local v3 = {
		Header = createElement(SectionHeader, {
			Text = "ROBLOX PREMIUM - MONTHLY",
			LayoutOrder = p.LayoutOrder
		}),
		Card = 0
	}
	local v6 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = 0,
		Size = 0,
		SizeConstraint = 0,
		ZIndex = 0
	}
	local layoutOrder

	if p.LayoutOrder then
		layoutOrder = p.LayoutOrder + 1
	end

	v6.LayoutOrder = layoutOrder
	v6.Size = UDim2.fromScale(1, 0.22)
	v6.SizeConstraint = Enum.SizeConstraint.RelativeXX
	v6.ZIndex = CONSTANTS.LAYER.RAISED
	v3.Card = createElement("Frame", v6, {
		TextLabel = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			Position = UDim2.fromScale(0.22, 0),
			RichText = true,
			Size = UDim2.fromScale(0.78, 1),
			Text = "<b>In-game benefits:</b><br/>- 20% off Blox Fruits Dealer Cousin.<br/>- 10% additional earned exp boost.<br/>- 10% additional earned money boost.",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		Pack1 = createElement("ImageButton", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			LayoutOrder = 1,
			Position = UDim2.fromScale(0.012, 0),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(0.19, 0.23),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			SliceCenter = Rect.new(4, 4, 16, 16),
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.Activated] = p.OnClick
		}, {
			ImageLabel = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://2882228740",
				ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				ImageRectOffset = Vector2.new(0, 4),
				ImageRectSize = Vector2.new(20, 16),
				LayoutOrder = 1,
				Position = UDim2.fromScale(0, 0.8),
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 0.2),
				SliceCenter = Rect.new(4, 0, 12, 12),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				ImageLabel = createElement("ImageLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://2882228740",
					ImageColor3 = Color3.fromRGB(4, 211, 70),
					ImageRectOffset = Vector2.new(0, 4),
					ImageRectSize = Vector2.new(20, 16),
					LayoutOrder = 1,
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.fromScale(1, 1),
					SliceCenter = Rect.new(4, 0, 12, 12),
					ZIndex = CONSTANTS.LAYER.RAISED
				}),
				UIPadding = createElement("UIPadding", {
					PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
				}),
				TextLabel = createElement("TextLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					Position = UDim2.fromScale(0, 0.05),
					Size = UDim2.fromScale(1, 0.9),
					Text = "Buy",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH
				})
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 3),
				PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
				PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
				PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
			}),
			Rwar = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "http://www.roblox.com/asset/?id=9999319457",
				ImageRectOffset = Vector2.new(203, 416),
				ImageRectSize = Vector2.new(203, 139),
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 1),
				SliceCenter = Rect.new(4, 4, 16, 16)
			}),
			Middle = createElement("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(184, 233, 255),
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Image = "rbxassetid://2750909498",
				ImageTransparency = 0.55,
				Position = UDim2.fromScale(0, 0.2),
				Size = UDim2.fromScale(1, 0.6),
				SliceCenter = Rect.new(4, 4, 16, 16),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				ImageLabel = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "http://www.roblox.com/asset/?id=6069315711",
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(1, 0.7),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					ZIndex = CONSTANTS.LAYER.RAISED
				})
			}),
			Top = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://2882228740",
				ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				ImageRectSize = Vector2.new(20, 16),
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 0.2),
				SliceCenter = Rect.new(4, 4, 16, 16),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.XXS
				}),
				ImageLabel = createElement("ImageLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://2882228740",
					ImageColor3 = Color3.fromRGB(239, 193, 75),
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
					})
				}),
				TextLabel = createElement("TextLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					Position = UDim2.fromScale(0, 0.05),
					Size = UDim2.fromScale(1, 0.9),
					Text = "PREMIUM",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH
				})
			})
		})
	})
	return createElement(fragment, {}, v3)
end