local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Tile = require(game.ReplicatedStorage.React.Components.Tile)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useViewportSize().X > 800 and 5 or 4
	local v2 = {}

	for _, v3 in ItemConfig.map(p.Adornees) do
		local v4

		if v3.Moveset and v3.Moveset.Type == "Fruit" and v3.Moveset.Physical then
			v4 = ItemConfig.match(v3.Moveset.Physical):unwrap()
		else
			v4 = v3
		end

		local storageKey = v3.Index.StorageKey
		local v7 = {
			Icon = v4.Display.Sprite,
			LayoutOrder = 1000 * (v4.Quality.RarityValue or 0),
			OutlineIcon = v4.Display.OutlineSprite,
			OutlineIconColor = CONSTANTS.COLOR.PALETTE.BLACK,
			Title = v4.Display.Title or v4.Display.Name or v4.Index.StorageKey,
			Rarity = v4.Quality.Rarity,
			IsSelected = false,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Variant = "Elevated"
		}
		local v8 = v3

		v7[React.Event.Activated] = function()
			p.OnSelect(v8.Index.ItemId)
		end

		v2[storageKey] = createElement(Tile, v7)
	end

	return createElement("ScrollingFrame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		CanvasSize = UDim2.new(),
		Position = UDim2.fromScale(0.5, 0.5),
		ScrollBarImageColor3 = Color3.fromRGB(133, 133, 133),
		ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.THICK,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Size = UDim2.fromScale(1, 1),
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	}, {
		Tiles = createElement(React.Fragment, {}, v2),
		UIGridLayout = createElement("UIGridLayout", {
			CellPadding = UDim2.fromScale(0.02, 0.02),
			CellSize = UDim2.fromScale((1 - (v - 1) * 0.02) / v, (1 - (v - 1) * 0.02) / v),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				DominantAxis = Enum.DominantAxis.Width,
				AspectType = Enum.AspectType.ScaleWithParentSize
			})
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.LG,
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.LG,
			PaddingRight = UDim.new(0, 6),
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.LG
		})
	})
end