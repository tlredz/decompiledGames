local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local useStats = require(game.ReplicatedStorage.React.Hooks.Item.useStats)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local StatRow = require(script.StatRow)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v, v2, _ = useSelection()
	local v3 = useStats(v, v2)
	local state, setState = React.useState(0)
	local children = {}

	if v3 then
		for k, statValue in v3 do
			local v5

			if statValue.Index.StatType == "Complex" then
				v5 = `Stat{k}-{statValue.Index.StatType}_{statValue.Index.Variant}`
			else
				v5 = `Stat{k}-{statValue.Index.StatType}`
			end

			children[v5] = createElement(StatRow, {
				Active = false,
				LayoutOrder = k,
				Size = UDim2.fromScale(1, 0.125),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				StatValue = statValue
			})
		end
	end

	return createElement("ScrollingFrame", RobloxTypes.mergeScrollingFrame({
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		CanvasSize = UDim2.fromOffset(0, (math.ceil(state))),
		HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.THIN,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.Always
	}, p), {
		UIListLayout = createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = CONSTANTS.SPACING.PADDING.OFFSET.XS,
			SortOrder = Enum.SortOrder.LayoutOrder,
			[React.Change.AbsoluteContentSize] = function(p2)
				setState(p2.AbsoluteContentSize.Y)
			end
		}),
		Rows = createElement(React.Fragment, {}, children)
	})
end