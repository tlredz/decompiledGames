local React = require(game.ReplicatedStorage.Packages.React)
local Controls = require(script.Parent.Controls)
local Motion = require(script.Parent.Motion)
local TextMetrics = require(script.Parent.TextMetrics)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement
local v = {
	Color3.fromRGB(248, 151, 138),
	Color3.fromRGB(251, 178, 115),
	Color3.fromRGB(245, 203, 92),
	Color3.fromRGB(180, 214, 92),
	Color3.fromRGB(112, 217, 157),
	Color3.fromRGB(83, 205, 194),
	Color3.fromRGB(95, 190, 238),
	Color3.fromRGB(132, 169, 245),
	Color3.fromRGB(181, 157, 246),
	Color3.fromRGB(238, 145, 205),
	Color3.fromRGB(250, 154, 172),
	Color3.fromRGB(207, 184, 113),
	Color3.fromRGB(143, 214, 121),
	Color3.fromRGB(111, 211, 219),
	Color3.fromRGB(154, 189, 250),
	Color3.fromRGB(214, 157, 237),
	Color3.fromRGB(246, 158, 142),
	Color3.fromRGB(237, 198, 105)
}

local function seedForName(value: string)
	local v2 = 0

	for i = 1, #value do
		v2 = (v2 * 33 + string.byte(value, i)) % 2147483647
	end

	return (math.max(1, v2))
end

local function legacyCategoryColor(value: string)
	local v2 = 0

	for i = 1, #value do
		v2 = (v2 * 33 + string.byte(value, i)) % 2147483647
	end

	local random = Random.new((math.max(1, v2)))
	local number = random:NextNumber()
	local number2 = random:NextNumber(0.34, 0.5)
	local number3 = random:NextNumber(0.9, 1)
	return Color3.fromHSV(number, number2, number3)
end

local function categoryColor(value: string)
	if value == "Debug" then
		return legacyCategoryColor("Debug")
	end

	local v2 = 0

	for i = 1, #value do
		v2 = (v2 * 33 + string.byte(value, i)) % 2147483647
	end

	return v[(math.max(1, v2) + #value * 7) % #v + 1]
end

local function resolveCategoryColor(p, p2: string)
	local getCategoryColor = p.GetCategoryColor
	local v2 = getCategoryColor and getCategoryColor(p2)

	if v2 then
		return v2
	end

	return categoryColor(p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function categoryName(category: string?, defaultCategory: string?)
	if category == nil or category == "" then
		return defaultCategory or "Uncategorized"
	end

	return category
end

local function defaultCompareCategories(value: string, value2: string)
	local v2 = string.lower(value)
	local v3 = string.lower(value2)

	if v2 == v3 then
		return value < value2
	end

	return v2 < v3
end

local memo = React.memo(function(data)
	local rotation, v3 = Motion.useNumberMotion(data.Open and 0 or -90)
	local rowHeight = data.RowHeight
	local textSize = math.max(10, (math.min(Theme.ControlTextSize + 3, rowHeight - 4)))
	local formatted = `({data.Count})`
	local v5 = math.ceil(TextMetrics.measurePlain(formatted, Theme.ControlTextSize, Theme.FontBold).X) + 2
	local v6 = data.Collapsible and 24 or 8
	local v7 = data.Collapsible and "TextButton" or "Frame"
	local onTogglesByActivated = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = data.LayoutOrder,
		Size = UDim2.new(1, 0, 0, rowHeight),
		ZIndex = data.ZIndex
	}
	React.useEffect(function()
		v3(data.Open and 0 or -90, Motion.Rotate)
	end, { data.Open })

	if data.Collapsible then
		onTogglesByActivated.AutoButtonColor = false
		onTogglesByActivated.Text = ""
		onTogglesByActivated[React.Event.Activated] = data.OnToggle
	end

	local chevron2

	if data.Collapsible then
		local chevron = Controls.Chevron
		local v12 = {
			Color = data.Color,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 14, 0.5, 0),
			Rotation = rotation,
			ZIndex = 0
		}
		local zIndex

		if data.ZIndex then
			zIndex = data.ZIndex + 1
		end

		v12.ZIndex = zIndex
		chevron2 = createElement(chevron, v12)
	end

	local v13 = {
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		Position = UDim2.fromOffset(v6, 0),
		RichText = false,
		Size = UDim2.new(1, -(v6 + v5 + 8 + 6), 1, 0),
		Text = data.Category,
		TextColor3 = data.Color,
		TextSize = textSize,
		TextStrokeTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 0
	}
	local zIndex2

	if data.ZIndex then
		zIndex2 = data.ZIndex + 1
	end

	v13.ZIndex = zIndex2
	local v9 = {
		Chevron = chevron2,
		Label = createElement("TextLabel", v13),
		Count = 0
	}
	local v17 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		Position = UDim2.new(1, -8, 0, 0),
		RichText = false,
		Size = UDim2.fromOffset(v5, rowHeight),
		Text = formatted,
		TextColor3 = Theme.TextSubtle,
		TextSize = Theme.ControlTextSize,
		TextStrokeTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 0
	}
	local zIndex3

	if data.ZIndex then
		zIndex3 = data.ZIndex + 1
	end

	v17.ZIndex = zIndex3
	v9.Count = createElement("TextLabel", v17)
	return createElement(v7, onTogglesByActivated, v9)
end)

local function buildBuckets(props)
	local v2 = {}
	local result = {}

	for _, item in props.Items do
		local name = categoryName(props.GetCategory(item), props.DefaultCategory) -- equivalent call inferred; original call site unknown
		local v4 = v2[name]

		if v4 == nil then
			v4 = {
				Name = name,
				Items = {}
			}
			v2[name] = v4
			table.insert(result, v4)
		end

		table.insert(v4.Items, item)
	end

	local compareItems = props.CompareItems

	if compareItems then
		for _, v3 in result do
			table.sort(v3.Items, compareItems)
		end
	end

	local compareCategories = props.CompareCategories or defaultCompareCategories
	table.sort(result, function(a, b)
		return compareCategories(a.Name, b.Name)
	end)
	return result
end

local function renderItemCell(props, item, color: Color3, layoutOrder: number, p2: number, rowHeightPx: number, gapPx: number, columnWidthPx: number, flag: boolean, zIndex: number?, categoryLineWidthPx: number, categoryLineOffsetPx: number, itemInsetPx: number)
	if props.ShowCategoryLines == false then
		return props.RenderItem(item, layoutOrder, zIndex)
	end

	local v2 = (layoutOrder - 1) % p2 + 1
	local v3 = v2 == 1 and 0 or gapPx
	local v4 = (flag or v2 == p2) and 0 or gapPx
	local v7 = {
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromOffset(columnWidthPx, rowHeightPx),
		ZIndex = zIndex
	}
	local v11 = {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(categoryLineOffsetPx, -v3),
		Size = UDim2.new(0, categoryLineWidthPx, 1, v3 + v4),
		ZIndex = 0
	}
	local zIndex2

	if zIndex then
		zIndex2 = zIndex + 1
	end

	v11.ZIndex = zIndex2
	return createElement("Frame", v7, {
		CategoryLine = createElement("Frame", v11, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, (math.ceil(categoryLineWidthPx / 2)))
			})
		}),
		ItemHost = createElement("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(itemInsetPx, 0),
			Size = UDim2.new(1, -itemInsetPx, 1, 0),
			ZIndex = zIndex
		}, {
			Content = props.RenderItem(item, layoutOrder, zIndex)
		})
	})
end

local function CategorizedDropdownGrid(props)
	local rowHeightPx = props.RowHeightPx or Theme.DropdownRowHeight
	local columnWidthPx = props.ColumnWidthPx or Theme.LogDropdownGridColumnWidth
	local gapPx = props.GapPx or 2
	local paddingPx = props.PaddingPx or 4
	local scrollBarThicknessPx = props.ScrollBarThicknessPx or Theme.LogDropdownScrollBarThickness
	local collapsibleCategories = props.CollapsibleCategories ~= false
	local categoryLineWidthPx = props.CategoryLineWidthPx or 3
	local categoryLineOffsetPx = props.CategoryLineOffsetPx or 7
	local itemInsetPx = props.ItemInsetPx or 13
	local v2 = math.max(rowHeightPx + paddingPx * 2, props.HeightPx)
	local fillDirectionMaxCells = math.max(
		1,
		(math.floor((math.max(rowHeightPx, v2 - paddingPx * 2 - scrollBarThicknessPx) + gapPx) / (rowHeightPx + gapPx)))
	)
	local zIndex = props.ZIndex
	local buckets = buildBuckets(props)
	local state, setState = React.useState({})
	local ref = React.useRef(state)
	ref.current = state
	local v4 = {
		UIGridLayout = createElement("UIGridLayout", {
			CellPadding = UDim2.fromOffset(gapPx, gapPx),
			CellSize = UDim2.fromOffset(columnWidthPx, rowHeightPx),
			FillDirection = Enum.FillDirection.Vertical,
			FillDirectionMaxCells = fillDirectionMaxCells,
			SortOrder = Enum.SortOrder.LayoutOrder,
			StartCorner = Enum.StartCorner.TopLeft
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, paddingPx + scrollBarThicknessPx),
			PaddingLeft = UDim.new(0, paddingPx),
			PaddingRight = UDim.new(0, paddingPx),
			PaddingTop = UDim.new(0, paddingPx)
		})
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toggleCategory(p: string)
		if not collapsibleCategories then
			return
		end

		local clone = table.clone(ref.current)

		if clone[p] then
			clone[p] = nil
		else
			clone[p] = true
		end

		ref.current = clone
		setState(clone)
	end

	local layoutOrder = 0

	for _, bucket in buckets do
		layoutOrder += 1
		local name = bucket.Name
		local getCategoryColor = props.GetCategoryColor
		local color = getCategoryColor and getCategoryColor(name)

		if not color then
			if name == "Debug" then
				color = legacyCategoryColor("Debug")
			else
				local v7 = 0

				for i = 1, #name do
					v7 = (v7 * 33 + string.byte(name, i)) % 2147483647
				end

				color = v[(math.max(1, v7) + #name * 7) % #v + 1]
			end
		end

		local renderCategory = props.RenderCategory
		local open = not collapsibleCategories or state[bucket.Name] ~= true
		local name2 = bucket.Name

		local function fn()
			toggleCategory(name2) -- equivalent call inferred; original call site unknown
		end

		local formatted = `Category:{bucket.Name}`
		local v9

		if renderCategory then
			v9 = renderCategory(bucket.Name, color, #bucket.Items, open, fn, layoutOrder, rowHeightPx, zIndex)
		else
			v9 = createElement(memo, {
				Category = bucket.Name,
				Color = color,
				Count = #bucket.Items,
				Open = open,
				Collapsible = collapsibleCategories,
				OnToggle = fn,
				LayoutOrder = layoutOrder,
				RowHeight = rowHeightPx,
				ZIndex = zIndex
			})
		end

		v4[formatted] = v9

		if not open then
			continue
		end

		for k, item in bucket.Items do
			layoutOrder += 1
			v4[`Item{layoutOrder}`] = renderItemCell(
				props,
				item,
				color,
				layoutOrder,
				fillDirectionMaxCells,
				rowHeightPx,
				gapPx,
				columnWidthPx,
				k == #bucket.Items,
				zIndex,
				categoryLineWidthPx,
				categoryLineOffsetPx,
				itemInsetPx
			)
		end
	end

	if layoutOrder == 0 then
		layoutOrder = 1
		v4.Empty = props.Empty or createElement("TextLabel", {
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			LayoutOrder = layoutOrder,
			RichText = false,
			Size = UDim2.fromOffset(columnWidthPx, rowHeightPx),
			Text = "No items",
			TextColor3 = Theme.TextSubtle,
			TextSize = Theme.ControlTextSize,
			TextStrokeTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = zIndex
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10)
			})
		})
	end

	local v6 = math.max(1, (math.ceil(layoutOrder / fillDirectionMaxCells)))
	local v7 = paddingPx * 2 + v6 * columnWidthPx + math.max(0, v6 - 1) * gapPx
	return createElement("ScrollingFrame", {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(v7, v2),
		HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		ScrollBarImageColor3 = Theme.TextSubtle,
		ScrollBarImageTransparency = 0,
		ScrollBarThickness = scrollBarThicknessPx,
		ScrollingDirection = Enum.ScrollingDirection.X,
		Size = UDim2.fromScale(1, 1),
		ZIndex = zIndex
	}, {
		Content = createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(v7, v2),
			ZIndex = zIndex
		}, v4)
	})
end

return React.memo(CategorizedDropdownGrid)