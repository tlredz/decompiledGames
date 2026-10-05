local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local Util = require(parent.Util)

local function ScrollFrame(data)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local scrollRef = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local list = data.List
	local grid = data.Grid

	if data.ScrollRef then
		scrollRef = data.ScrollRef
	end

	React.useEffect(function()
		local current = ref.current
		local current2 = ref3.current
		local current3 = ref2.current
		local current4 = scrollRef.current

		if not (current and current4 and current3 and current2) then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			local v = current.AbsoluteSize.X / 2000
			local v2 = current2.AbsoluteContentSize / v
			current4.CanvasSize = UDim2.fromOffset(v2.X, v2.Y)
		end

		local propertyChangedSignal = current4:GetPropertyChangedSignal("AbsoluteSize")
		local propertyChangedSignal2 = current2:GetPropertyChangedSignal("AbsoluteContentSize")
		local propertyChangedSignal3 = current:GetPropertyChangedSignal("AbsoluteSize")
		local connection = propertyChangedSignal:Connect(update)
		local connection2 = propertyChangedSignal3:Connect(update)
		local connection3 = propertyChangedSignal2:Connect(update)
		update() -- equivalent call inferred; original call site unknown
		return function()
			connection:Disconnect()
			connection2:Disconnect()
			connection3:Disconnect()
		end
	end, {})
	return React.createElement(React.Fragment, nil, {
		ScrollingFrame = React.createElement("ScrollingFrame", {
			[React.Tag] = Util.ClassNames("ScrollFrame", data[React.Tag]),
			Size = data.Size,
			Position = data.Position,
			LayoutOrder = data.LayoutOrder,
			AnchorPoint = data.AnchorPoint,
			ClipsDescendants = data.ClipsDescendants,
			BorderSizePixel = data.BorderSizePixel,
			BorderColor3 = data.BorderColor,
			ScrollingDirection = data.ScrollingDirection,
			ScrollBarThickness = data.ScrollBarThickness,
			ScrollBarImageTransparency = data.ScrollBarImageTransparency,
			ScrollBarImageColor3 = data.ScrollBarImageColor3,
			BackgroundTransparency = data.Transparency,
			BackgroundColor3 = data.Color,
			TopImage = data.TopImage,
			MidImage = data.MidImage,
			BottomImage = data.BottomImage,
			ElasticBehavior = data.ElasticBehavior,
			HorizontalScrollBarInset = data.HorizontalScrollBarInset,
			VerticalScrollBarInset = data.VerticalScrollBarInset,
			[React.Change.CanvasPosition] = data.OnPositionChanged,
			ZIndex = data.ZIndex,
			ref = scrollRef
		}, {
			Canvas = React.createElement("Frame", {
				[React.Tag] = "Canvas",
				AutomaticSize = data.AutomaticCanvasSize,
				Size = data.CanvasSize,
				ref = ref2
			}, data.children, {
				List = list and not grid and React.createElement("UIListLayout", {
					Padding = list.Padding,
					Wraps = list.Wraps,
					FillDirection = list.FillDirection,
					HorizontalFlex = list.HorizontalFlex,
					HorizontalAlignment = list.HorizontalAlignment,
					ItemLineAlignment = list.ItemLineAlignment,
					VerticalAlignment = list.VerticalAlignment,
					VerticalFlex = list.VerticalFlex,
					SortOrder = list.SortOrder,
					ref = ref3
				}),
				Grid = grid and not list and React.createElement("UIGridLayout", {
					CellSize = grid.CellSize,
					CellPadding = grid.CellPadding,
					FillDirection = grid.FillDirection,
					HorizontalAlignment = grid.HorizontalAlignment,
					VerticalAlignment = grid.VerticalAlignment,
					StartCorner = grid.StartCorner,
					SortOrder = grid.SortOrder,
					ref = ref3
				})
			}),
			MeasureScale = React.createElement("Frame", {
				[React.Tag] = "MeasureScale",
				ref = ref
			})
		})
	})
end

return ScrollFrame