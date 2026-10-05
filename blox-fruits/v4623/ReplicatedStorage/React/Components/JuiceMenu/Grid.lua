local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local Tile = require(game.ReplicatedStorage.React.Components.Tile)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = useViewportSize().X > 800 and 3 or 2
	local v2, _, v3 = useSelection()
	local v4 = React.useMemo(function()
		local v5 = {}
		local nullables = {}

		for _, item in props.Items do
			local nullable = Modification.matchAdornee(item):asNullable()

			if not nullable or v5[nullable] then
				continue
			end

			v5[nullable] = true
			table.insert(nullables, nullable)
		end

		table.sort(nullables)
		local result = {}

		for k, v6 in nullables do
			result[v6] = k
		end

		return result
	end, { props.Items })
	local v5 = {}

	for _, v6 in ItemConfig.map(props.Items) do
		local unwrapped = Modification.matchAdornee(v6.Index.ItemId):unwrap()

		if Modification.matchDefaultSkin(unwrapped):asNullable() == v6.Index.ItemId then
			continue
		end

		local v7

		if table.find(props.Unlocked, v6.Index.ItemId) == nil then
			v7 = table.find(props.Owned, v6.Index.ItemId) == nil
		else
			v7 = false
		end

		local storageKey = v6.Index.StorageKey
		local v10 = {
			Icon = v6.Display.Sprite,
			LayoutOrder = (v4[unwrapped] or 0) * 100000 + 1000 * (v6.Quality.RarityValue or 0)
		}
		local iconColor

		if v7 then
			iconColor = CONSTANTS.COLOR.PALETTE.BLACK
		end

		v10.IconColor = iconColor
		v10.OutlineIcon = v6.Display.OutlineSprite
		v10.OutlineIconColor = CONSTANTS.COLOR.PALETTE.BLACK
		v10.Title = v7 and "???" or v6.Display.Title or v6.Display.Name or v6.Index.StorageKey
		v10.Rarity = v6.Quality.Rarity
		v10.IsSelected = v6.Index.ItemId == v2
		v10.SizeConstraint = Enum.SizeConstraint.RelativeXX
		v10.Variant = "Elevated"
		v10.Category = table.find(props.Owned, v6.Index.ItemId) ~= nil and "Owned" or Skin.Definition.Quest.match(v6.Index.ItemId):isSome() and "Quest" or nil
		local v12 = v6

		v10[React.Event.Activated] = function()
			if v12.Index.ItemId == v2 then
				v3(nil)
			else
				v3(v12.Index.ItemId)
			end
		end

		v5[storageKey] = createElement(Tile, v10)
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
		Tiles = createElement(React.Fragment, {}, v5),
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