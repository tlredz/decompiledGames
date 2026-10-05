local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local State = require(parent.State)
local Util = require(parent.Util)
local React = require(shared.React)
local useSignal = require(hooks.useSignal)
local useStyleSheet = require(hooks.useStyleSheet)
require(hooks.useRelicsAssetInfo)
local components = parent.Components
local ItemTile = require(components.ItemTile)
local VirtualGrid = require(components.VirtualGrid)
require(shared.GamePasses)
require(shared.Signal)

local function ItemInventory(p)
	local v = useStyleSheet("Tweaks")
	local v2 = React.useContext(State.Context)
	local ref = React.useRef(nil)
	local children = {}

	for k, item in p.Items do
		children[k] = React.createElement(ItemTile, {
			[React.Tag] = p[React.Tag],
			Target = item.Target,
			LayoutOrder = item.Order or 0,
			OverrideBackgroundImage = item.OverrideBackgroundImage,
			OverrideStrokeColor = item.OverrideStrokeColor,
			OverrideGlowImage = item.OverrideGlowImage,
			OverrideRender = item.OverrideRender
		})
	end

	useSignal(v2.ReturnEvent, function()
		local current = ref.current

		if current and current.CanvasPosition.Y > 0 then
			current.CanvasPosition = Vector2.zero
		else
			v2.WidgetReturn()
		end
	end)
	return React.createElement("Frame", {
		[React.Tag] = Util.ClassNames("PurchaseableItemsContainer", p[React.Tag])
	}, {
		Items = next(children) and React.createElement(VirtualGrid, {
			CanvasSize = UDim2.fromScale(1, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Transparency = 1,
			ZIndex = 0,
			CellSize = UDim2.new(1 / v("Tweak-MaxVirtualGridCells", 1), -12, 1 / v("Tweak-MaxVirtualGridCells", 1), -12),
			CellPadding = UDim2.fromOffset(9, 9),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirectionMaxCells = v("Tweak-MaxVirtualGridCells", 1),
			ScrollRef = ref
		}, children)
	})
end

return ItemInventory