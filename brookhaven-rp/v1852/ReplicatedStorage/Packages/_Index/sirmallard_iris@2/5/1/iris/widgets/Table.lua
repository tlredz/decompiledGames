require(script.Parent.Parent.Types)
return function(data, data2)
	local v = {}
	local v2 = {}
	local v3 = false
	local v4 = nil
	local v5 = 0
	local v6 = -1
	local v7 = -1
	local X = 0

	local function CalculateMinColumnWidth(k, k2: number)
		local v8 = 0

		for _, _cellInstance in k._cellInstances do
			for _, guiObject in _cellInstance[k2]:GetChildren() do
				if guiObject:IsA("GuiObject") then
					v8 = math.max(v8, guiObject.AbsoluteSize.X)
				end
			end
		end

		k._minWidths[k2] = v8 + 2 * data._config.CellPadding.X
	end

	table.insert(data._postCycleCallbacks, function()
		for _, v8 in v do
			for k, _rowCycle in v8._rowCycles do
				if not (_rowCycle < data._cycleTick - 1) then
					continue
				end

				local _rowInstance = v8._rowInstances[k]
				local _rowBorder = v8._rowBorders[k - 1]

				if _rowInstance ~= nil then
					_rowInstance:Destroy()
				end

				if _rowBorder ~= nil then
					_rowBorder:Destroy()
				end

				v8._rowInstances[k] = nil
				v8._rowBorders[k - 1] = nil
				v8._cellInstances[k] = nil
				v8._rowCycles[k] = nil
			end

			v8._rowIndex = 1
			v8._columnIndex = 1
			v8.Instance.BorderContainer.Size = UDim2.new(1, 0, 0, v8._rowContainer.AbsoluteSize.Y)
			v8._columnBorders[0].Size = UDim2.fromOffset(5, v8._rowContainer.AbsoluteSize.Y)
		end

		for k, list in v2 do
			local flag = false

			for k2, _ in list do
				CalculateMinColumnWidth(k, k2)
				flag = true
			end

			if not flag then
				continue
			end

			table.clear(list)
			data._widgets.Table.UpdateState(k)
		end
	end)

	local function UpdateActiveColumn()
		if v3 == false or v4 == nil then
			return
		end

		local widths = v4.state.widths
		local numColumns = v4.arguments.NumColumns
		local instance = v4.Instance
		local borderContainer = instance.BorderContainer
		local fixedWidth = v4.arguments.FixedWidth
		local v8 = 2 * data._config.CellPadding.X

		if v6 == -1 then
			v6 = widths.value[v5]

			if v6 == 0 then
				v6 = v8 / instance.AbsoluteSize.X
			end

			v7 = widths.value[v5 + 1] or -1

			if v7 == 0 then
				v7 = v8 / instance.AbsoluteSize.X
			end
		end

		local X2 = instance.AbsolutePosition.X
		local v9 = v5 == 1 and 0 or math.floor(borderContainer:FindFirstChild((`Border_{v5 - 1}`)).AbsolutePosition.X + 3 - X2)
		local v10 = v5
		local X3

		if numColumns - 1 <= v10 then
			X3 = instance.AbsoluteSize.X
		else
			X3 = math.floor(borderContainer:FindFirstChild((`Border_{v5 + 1}`)).AbsolutePosition.X + 3 - X2)
		end

		local v11 = X2 - data2.GuiOffset.X
		local v12 = math.clamp(data2.getMouseLocation().X, v9 + v11 + v8, X3 + v11 - v8) - X
		local v13 = X - v11 - v9
		local v14 = v6 / v13

		if fixedWidth then
			widths.value[v5] = math.clamp(math.round(v6 + v12), v8, instance.AbsoluteSize.X - v9)
		else
			local v15 = v14 * v12
			widths.value[v5] = math.clamp(v6 + v15, 0, (X3 - v9 - v8) / instance.AbsoluteSize.X)

			if v5 < numColumns then
				widths.value[v5 + 1] = math.clamp(v7 - v15, 0, 1)
			end
		end

		widths:set(widths.value, true)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ColumnMouseDown(p, p2: number)
		v3 = true
		v4 = p
		v5 = p2
		v6 = -1
		v7 = -1
		X = data2.getMouseLocation().X
	end

	data2.registerEvent("InputChanged", function()
		if not data._started then
			return
		end

		UpdateActiveColumn()
	end)
	data2.registerEvent("InputEnded", function(p)
		if not data._started then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 and v3 then
			v3 = false
			v4 = nil
			v5 = 0
			v6 = -1
			v7 = -1
			X = 0
		end
	end)

	local function GenerateCell(_, i: number, udim: UDim, flag: boolean)
		local v8

		if flag then
			v8 = Instance.new("TextButton")
			v8.Text = ""
			v8.AutoButtonColor = false
		else
			v8 = Instance.new("Frame")
		end

		v8.Name = `Cell_{i}`
		v8.AutomaticSize = Enum.AutomaticSize.Y
		v8.Size = UDim2.new(udim, UDim.new())
		v8.BackgroundTransparency = 1
		v8.ZIndex = i
		v8.LayoutOrder = i
		v8.ClipsDescendants = true

		if flag then
			data2.applyInteractionHighlights("Background", v8, v8, {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderActiveColor,
				ActiveTransparency = data._config.HeaderActiveTransparency
			})
		end

		data2.UIPadding(v8, data._config.CellPadding)
		data2.UIListLayout(v8, Enum.FillDirection.Vertical, UDim.new())
		data2.UISizeConstraint(v8, Vector2.new(2 * data._config.CellPadding.X, 0))
		return v8
	end

	local function GenerateColumnBorder(state, zIndex: number, p: string)
		local imageButton = Instance.new("ImageButton")
		imageButton.Name = `Border_{zIndex}`
		imageButton.Size = UDim2.new(0, 5, 1, 0)
		imageButton.BackgroundTransparency = 1
		imageButton.Image = ""
		imageButton.ImageTransparency = 1
		imageButton.AutoButtonColor = false
		imageButton.ZIndex = zIndex
		imageButton.LayoutOrder = zIndex * 2
		local v8 = zIndex == state.arguments.NumColumns and 3 or 2
		local frame = Instance.new("Frame")
		frame.Name = "Line"
		frame.Size = UDim2.new(0, 1, 1, 0)
		frame.Position = UDim2.fromOffset(v8, 0)
		frame.BackgroundColor3 = data._config[`TableBorder{p}Color`]
		frame.BackgroundTransparency = data._config[`TableBorder{p}Transparency`]
		frame.BorderSizePixel = 0
		frame.Parent = imageButton
		local frame2 = Instance.new("Frame")
		frame2.Name = "Hover"
		frame2.Position = UDim2.fromOffset(v8, 0)
		frame2.Size = UDim2.new(0, 1, 1, 0)
		frame2.BackgroundColor3 = data._config[`TableBorder{p}Color`]
		frame2.BackgroundTransparency = data._config[`TableBorder{p}Transparency`]
		frame2.BorderSizePixel = 0
		frame2.Visible = state.arguments.Resizable
		frame2.Parent = imageButton
		data2.applyInteractionHighlights("Background", imageButton, frame2, {
			Color = data._config.ResizeGripColor,
			Transparency = 1,
			HoveredColor = data._config.ResizeGripHoveredColor,
			HoveredTransparency = data._config.ResizeGripHoveredTransparency,
			ActiveColor = data._config.ResizeGripActiveColor,
			ActiveTransparency = data._config.ResizeGripActiveTransparency
		})
		data2.applyButtonDown(imageButton, function()
			if state.arguments.Resizable then
				ColumnMouseDown(state, zIndex) -- equivalent call inferred; original call site unknown
			end
		end)
		return imageButton
	end

	local function GenerateRow(data3, _rowIndex: number)
		local frame = Instance.new("Frame")
		frame.Name = `Row_{_rowIndex}`
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.Size = UDim2.fromScale(1, 0)

		if _rowIndex == 0 then
			frame.BackgroundColor3 = data._config.TableHeaderColor
			frame.BackgroundTransparency = data._config.TableHeaderTransparency
		elseif data3.arguments.RowBackground == true then
			if _rowIndex % 2 == 0 then
				frame.BackgroundColor3 = data._config.TableRowBgAltColor
				frame.BackgroundTransparency = data._config.TableRowBgAltTransparency
			else
				frame.BackgroundColor3 = data._config.TableRowBgColor
				frame.BackgroundTransparency = data._config.TableRowBgTransparency
			end
		else
			frame.BackgroundTransparency = 1
		end

		frame.BorderSizePixel = 0
		frame.ZIndex = _rowIndex * 2 - 1
		frame.LayoutOrder = _rowIndex * 2 - 1
		frame.ClipsDescendants = true
		data2.UIListLayout(frame, Enum.FillDirection.Horizontal, UDim.new())
		data3._cellInstances[_rowIndex] = table.create(data3.arguments.NumColumns)

		for i = 1, data3.arguments.NumColumns do
			local generateCell = GenerateCell(data3, i, data3._widths[i], _rowIndex == 0)
			generateCell.Parent = frame
			data3._cellInstances[_rowIndex][i] = generateCell
		end

		data3._rowInstances[_rowIndex] = frame
		return frame
	end

	local function GenerateRowBorder(_, p: number, p2: string)
		local frame = Instance.new("Frame")
		frame.Name = `Border_{p}`
		frame.Size = UDim2.fromScale(1, 0)
		frame.BackgroundTransparency = 1
		frame.ZIndex = p * 2
		frame.LayoutOrder = p * 2
		local frame2 = Instance.new("Frame")
		frame2.Name = "Line"
		frame2.AnchorPoint = Vector2.new(0, 0.5)
		frame2.Size = UDim2.new(1, 0, 0, 1)
		frame2.BackgroundColor3 = data._config[`TableBorder{p2}Color`]
		frame2.BackgroundTransparency = data._config[`TableBorder{p2}Transparency`]
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
		return frame
	end

	data.WidgetConstructor("Table", {
		hasState = true,
		hasChildren = true,
		Args = {
			NumColumns = 1,
			Header = 2,
			RowBackground = 3,
			OuterBorders = 4,
			InnerBorders = 5,
			Resizable = 6,
			FixedWidth = 7,
			ProportionalWidth = 8,
			LimitTableWidth = 9
		},
		Events = {},
		Generate = function(state)
			v[state.ID] = state
			v2[state] = {}
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Table"
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.fromScale(1, 0)
			frame.BackgroundTransparency = 1
			local frame2 = Instance.new("Frame")
			frame2.Name = "RowContainer"
			frame2.AutomaticSize = Enum.AutomaticSize.Y
			frame2.Size = UDim2.fromScale(1, 0)
			frame2.BackgroundTransparency = 1
			frame2.ZIndex = 1
			data2.UISizeConstraint(frame2)
			data2.UIListLayout(frame2, Enum.FillDirection.Vertical, UDim.new())
			frame2.Parent = frame
			state._rowContainer = frame2
			local frame3 = Instance.new("Frame")
			frame3.Name = "BorderContainer"
			frame3.Size = UDim2.fromScale(1, 1)
			frame3.BackgroundTransparency = 1
			frame3.ZIndex = 2
			frame3.ClipsDescendants = true
			data2.UISizeConstraint(frame3)
			data2.UIListLayout(frame3, Enum.FillDirection.Horizontal, UDim.new())
			data2.UIStroke(frame3, 1, data._config.TableBorderStrongColor, data._config.TableBorderStrongTransparency)
			frame3.Parent = frame
			state._columnIndex = 1
			state._rowIndex = 1
			state._rowInstances = {}
			state._cellInstances = {}
			state._rowBorders = {}
			state._columnBorders = {}
			state._rowCycles = {}
			local v8 = #data._postCycleCallbacks + 1
			local v9 = data._cycleTick + 1

			data._postCycleCallbacks[v8] = function()
				if v9 <= data._cycleTick then
					if state.lastCycleTick ~= -1 then
						state.state.widths.lastChangeTick = data._cycleTick
						data._widgets.Table.UpdateState(state)
					end

					data._postCycleCallbacks[v8] = nil
				end
			end

			return frame
		end,
		GenerateState = function(state)
			local numColumns = state.arguments.NumColumns

			if state.state.widths == nil then
				local v8 = table.create(numColumns, 1 / numColumns)
				state.state.widths = data._widgetState(state, "widths", v8)
			end

			state._widths = table.create(numColumns, UDim.new())
			state._minWidths = table.create(numColumns, 0)
			local instance = state.Instance
			local borderContainer = instance.BorderContainer
			state._cellInstances[-1] = table.create(numColumns)

			for i = 1, numColumns do
				local parent = GenerateColumnBorder(state, i, "Light")
				parent.Visible = state.arguments.InnerBorders
				state._columnBorders[i] = parent
				parent.Parent = borderContainer
				local generateCell = GenerateCell(state, i, state._widths[i], false)
				local uISizeConstraint = generateCell:FindFirstChild("UISizeConstraint")
				uISizeConstraint.MinSize = Vector2.new(
					2 * data._config.CellPadding.X + (i > 1 and -2 or 0) + (i < numColumns and -3 or 0),
					0
				)
				generateCell.LayoutOrder = i * 2 - 1
				state._cellInstances[-1][i] = generateCell
				generateCell.Parent = borderContainer
			end

			local parent2 = GenerateColumnBorder(state, numColumns, "Strong")
			state._columnBorders[0] = parent2
			parent2.Parent = instance
		end,
		Update = function(data3)
			local numColumns = data3.arguments.NumColumns
			assert(numColumns >= 1, "Iris.Table must have at least one column.")

			if data3._widths ~= nil and #data3._widths ~= numColumns then
				data3.arguments.NumColumns = #data3._widths
				warn("NumColumns cannot change once set. See documentation.")
			end

			for k, _rowInstance in data3._rowInstances do
				if k == 0 then
					_rowInstance.BackgroundColor3 = data._config.TableHeaderColor
					_rowInstance.BackgroundTransparency = data._config.TableHeaderTransparency
				elseif data3.arguments.RowBackground == true then
					if k % 2 == 0 then
						_rowInstance.BackgroundColor3 = data._config.TableRowBgAltColor
						_rowInstance.BackgroundTransparency = data._config.TableRowBgAltTransparency
					else
						_rowInstance.BackgroundColor3 = data._config.TableRowBgColor
						_rowInstance.BackgroundTransparency = data._config.TableRowBgTransparency
					end
				else
					_rowInstance.BackgroundTransparency = 1
				end
			end

			for _, _rowBorder in data3._rowBorders do
				_rowBorder.Visible = data3.arguments.InnerBorders
			end

			for _, _columnBorder in data3._columnBorders do
				_columnBorder.Visible = data3.arguments.InnerBorders or data3.arguments.Resizable
			end

			for _, _columnBorder in data3._columnBorders do
				local hover = _columnBorder:FindFirstChild("Hover")

				if hover then
					hover.Visible = data3.arguments.Resizable
				end
			end

			if data3._columnBorders[numColumns] ~= nil then
				data3._columnBorders[numColumns].Visible = not data3.arguments.LimitTableWidth and (data3.arguments.Resizable or data3.arguments.InnerBorders)
				data3._columnBorders[0].Visible = data3.arguments.LimitTableWidth and (data3.arguments.Resizable or data3.arguments.OuterBorders)
			end

			local _rowInstance = data3._rowInstances[0]
			local _rowBorder = data3._rowBorders[0]

			if _rowInstance ~= nil then
				_rowInstance.Visible = data3.arguments.Header
			end

			if _rowBorder ~= nil then
				_rowBorder.Visible = data3.arguments.Header and data3.arguments.InnerBorders
			end

			data3.Instance.BorderContainer.UIStroke.Enabled = data3.arguments.OuterBorders

			for i = 1, data3.arguments.NumColumns do
				v2[data3][i] = true
			end

			if data3._widths ~= nil then
				data._widgets.Table.UpdateState(data3)
			end
		end,
		UpdateState = function(data3)
			local instance = data3.Instance
			local borderContainer = instance.BorderContainer
			local rowContainer = instance.RowContainer
			local numColumns = data3.arguments.NumColumns
			local value = data3.state.widths.value
			local _minWidths = data3._minWidths
			local fixedWidth = data3.arguments.FixedWidth
			local proportionalWidth = data3.arguments.ProportionalWidth

			if not data3.arguments.Resizable then
				if fixedWidth then
					if proportionalWidth then
						for i = 1, numColumns do
							value[i] = _minWidths[i]
						end
					else
						local v8 = 0

						for _, _minWidth in _minWidths do
							v8 = math.max(v8, _minWidth)
						end

						for i = 1, numColumns do
							value[i] = v8
						end
					end
				elseif proportionalWidth then
					local total = 0

					for _, _minWidth in _minWidths do
						total += _minWidth
					end

					local v8 = 1 / total

					for i = 1, numColumns do
						value[i] = v8 * _minWidths[i]
					end
				else
					local v8 = 1 / numColumns

					for i = 1, numColumns do
						value[i] = v8
					end
				end
			end

			local uDim = UDim.new()

			for i = 1, numColumns do
				local v8 = value[i]
				local uDim2 = UDim.new(
					fixedWidth and 0 or math.clamp(v8, 0, 1),
					not fixedWidth and 0 or math.max(v8, 0)
				)
				data3._widths[i] = uDim2
				uDim += uDim2

				for _, _cellInstance in data3._cellInstances do
					_cellInstance[i].Size = UDim2.new(uDim2, UDim.new())
				end

				data3._cellInstances[-1][i].Size = UDim2.new(uDim2 + UDim.new(0, (i > 1 and -2 or 0) - 3), UDim.new())
			end

			local offset = uDim.Offset
			local v8 = not (data3.arguments.FixedWidth and data3.arguments.LimitTableWidth) and 1e999 or offset
			borderContainer.UISizeConstraint.MaxSize = Vector2.new(v8, 1e999)
			rowContainer.UISizeConstraint.MaxSize = Vector2.new(v8, 1e999)
			data3._columnBorders[0].Position = UDim2.fromOffset(v8 - 3, 0)
		end,
		ChildAdded = function(data3, _)
			local _rowIndex = data3._rowIndex
			local _columnIndex = data3._columnIndex
			local _rowInstance = data3._rowInstances[_rowIndex]
			data3._rowCycles[_rowIndex] = data._cycleTick
			v2[data3][_columnIndex] = true

			if _rowInstance ~= nil then
				return data3._cellInstances[_rowIndex][_columnIndex]
			end

			local generateRow = GenerateRow(data3, _rowIndex)

			if _rowIndex == 0 then
				generateRow.Visible = data3.arguments.Header
			end

			generateRow.Parent = data3._rowContainer

			if _rowIndex > 0 then
				local parent = GenerateRowBorder(data3, _rowIndex - 1, _rowIndex == 1 and "Strong" or "Light")
				parent.Visible = data3.arguments.InnerBorders and (_rowIndex ~= 1 or data3.arguments.Header and data3.arguments.InnerBorders and data3._rowInstances[0] ~= nil)
				data3._rowBorders[_rowIndex - 1] = parent
				parent.Parent = data3._rowContainer
			end

			return data3._cellInstances[_rowIndex][_columnIndex]
		end,
		ChildDiscarded = function(p, p2)
			local parent = p2.Instance.Parent
			local v8 = parent ~= nil and tonumber(parent.Name:sub(6))

			if v8 then
				v2[p][v8] = true
			end
		end,
		Discard = function(p)
			v[p.ID] = nil
			v2[p] = nil
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})
end