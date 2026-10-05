local relicsPlayer = script:FindFirstAncestor("RelicsPlayer")
local shared = relicsPlayer.Parent.Shared
local React = require(shared.React)
local hooks = relicsPlayer.Hooks
local useProperty = require(hooks.useProperty)
local parent = script.Parent
local ScaleMeasure = require(parent.ScaleMeasure)

local function VirtualGrid(props)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(Vector2.zero)
	local scrollRef = React.useRef(nil)
	local state3, setState3 = React.useState(1)

	if props.ScrollRef then
		scrollRef = props.ScrollRef
	end

	React.useEffect(function()
		setState((assert(scrollRef.current)))
	end, {})
	local absoluteSize = useProperty(state, function(p)
		return p and p.AbsoluteSize
	end) or Vector2.zero

	if state then
		absoluteSize = state.AbsoluteSize
	end

	local v = absoluteSize / state3
	local v2 = state2 / state3
	local cellPadding = props.CellPadding or UDim2.fromOffset(5, 5)
	local cellSize = props.CellSize or UDim2.new(0.3333333333333333, -5, 0.3333333333333333, -5)
	local cellSizeConstraint = props.CellSizeConstraint or Enum.SizeConstraint.RelativeXX
	local v3 = cellSize.X.Scale * v.X + cellSize.X.Offset
	local v4 = cellSize.Y.Scale * v.Y + cellSize.Y.Offset
	local v5 = v3 + (cellPadding.X.Scale * v.X + cellPadding.X.Offset)
	local v6 = v4 + (cellPadding.Y.Scale * v.Y + cellPadding.Y.Offset)

	if cellSizeConstraint ~= Enum.SizeConstraint.RelativeYY and cellSizeConstraint == Enum.SizeConstraint.RelativeXX then
		v6 = v5
	end

	local vector = Vector2.new(v5, v6)
	local v7 = math.max(math.floor(v.X / vector.X), 1)

	if props.FillDirectionMaxCells then
		v7 = math.min(v7, props.FillDirectionMaxCells)
	end

	local v8 = math.ceil(v.Y / vector.Y) + 1
	local v9 = math.floor(v2.Y / vector.Y)
	local v10 = v9 * v7
	local v11 = (v9 + v8) * v7
	local lazySort = props.LazySort
	local v12, v13, v14 = React.useMemo(function()
		local v15 = {}
		local v16 = {}
		local v17 = lazySort and 1e999 or 0
		React.Children.forEach(props.children, function(child, p2)
			if not React.isValidElement(child) then
				v16[p2] = child
				return
			end

			local props2 = child.props
			local order = props2 and (props2.Order or props2.LayoutOrder)

			if type(order) ~= "number" then
				v16[p2] = child
				return
			end

			if lazySort and order < v17 then
				v17 = order
			end

			table.insert(v15, {
				Child = child,
				Order = order
			})
		end)

		if not lazySort then
			table.sort(v15, function(a, b)
				return a.Order < b.Order
			end)
		end

		return v15, v16, v17
	end, { props.children, lazySort })
	local v15 = math.min(v10, #v12 - v8 * v7)
	local children = {}

	for i, v16 in ipairs(v12) do
		local v17

		if props.LazySort then
			v17 = v16.Order - v14
		else
			v17 = i
		end

		local v18

		if v15 < v17 and v17 <= v11 then
			v18 = v12[i]
		end

		if not v18 then
			continue
		end

		local v19 = v17 - 1
		table.insert(children, React.createElement("Frame", {
			Size = cellSize,
			SizeConstraint = cellSizeConstraint,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset((v19 % v7 + 0.5) * vector.X, (v19 // v7 + 0.5) * vector.Y)
		}, {
			Render = v18.Child
		}))
	end

	local v16 = math.ceil(#v12 / v7)
	return React.createElement("ScrollingFrame", {
		AutomaticSize = props.AutomaticSize,
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		SizeConstraint = props.SizeConstraint,
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BackgroundColor3 = props.BackgroundColor3,
		BorderSizePixel = props.BorderSizePixel or 0,
		BorderColor3 = props.BorderColor3,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		LayoutOrder = props.LayoutOrder,
		ClipsDescendants = props.ClipsDescendants,
		CanvasSize = UDim2.fromOffset(v7 * vector.X, v16 * vector.Y),
		MidImage = props.MidImage,
		TopImage = props.TopImage,
		BottomImage = props.BottomImage,
		ScrollBarThickness = props.ScrollBarThickness,
		ScrollBarImageColor3 = props.ScrollBarImageColor3,
		VerticalScrollBarInset = props.VerticalScrollBarInset,
		ScrollBarImageTransparency = props.ScrollBarImageTransparency,
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		[React.Change.CanvasPosition] = function(p)
			setState2(p.CanvasPosition)
		end,
		ref = scrollRef
	}, {
		ScaleMeasure = React.createElement(ScaleMeasure, {
			SetScale = setState3
		}),
		Canvas = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, v.Y),
			BackgroundTransparency = 1
		}, children, v13)
	})
end

return VirtualGrid