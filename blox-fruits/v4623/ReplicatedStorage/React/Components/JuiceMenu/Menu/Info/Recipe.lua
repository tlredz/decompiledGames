local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.Definitions.Skin)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local count = 0
	local children = {}

	for k, ingredient in p.Definition.Ingredients do
		count += 1
		local v = p.CraftingInventory[k] or 0
		local unwrapped = ItemConfig.match(k):unwrap()
		children[unwrapped.Index.StorageKey] = createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			Size = UDim2.new(1, 0, 0.14285714285714285, -6),
			SizeConstraint = Enum.SizeConstraint.RelativeXX
		}, {
			EtcItem = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
				Position = UDim2.fromScale(0.15, 0.5),
				RichText = true,
				Size = UDim2.fromScale(0.6, 0.7),
				Text = unwrapped.Display.Name or unwrapped.Index.StorageKey,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			}),
			Count = createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				AutoLocalize = false,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
				Position = UDim2.new(1, -5, 0.5, 0),
				RichText = true,
				Size = UDim2.fromScale(0.5, 0.6),
				Text = `{v}/{ingredient}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
				TextXAlignment = Enum.TextXAlignment.Right
			}),
			ImageLabel = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(29, 29, 29),
				BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				Image = not unwrapped.Display.Sprite and "rbxasset://textures/ui/PlayerList/Block@3x.png" or unwrapped.Display.Sprite.Image or "rbxasset://textures/ui/PlayerList/Block@3x.png",
				ImageRectOffset = unwrapped.Display.Sprite and unwrapped.Display.Sprite.ImageRectOffset,
				ImageRectSize = unwrapped.Display.Sprite and unwrapped.Display.Sprite.ImageRectSize,
				Position = UDim2.fromScale(0, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 4
			}, {
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			})
		})
	end

	return createElement("ScrollingFrame", {
		AnchorPoint = Vector2.new(0.5, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		CanvasSize = UDim2.new(0, 0, count * 0.14285714285714285, (count - 1) * 6 + 8 + 8),
		LayoutOrder = 2,
		Position = UDim2.fromScale(0.5, 1),
		ScrollBarImageColor3 = Color3.fromRGB(195, 195, 195),
		ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.THICK,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Selectable = false,
		Size = UDim2.fromScale(1, 0.7),
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	}, {
		UIListLayout = createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 8)
		}),
		Ingredients = createElement(React.Fragment, {}, children)
	})
end