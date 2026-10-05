require(script.Parent.Parent.Types)
return function(data, data2)
	local v = {}
	table.insert(data._postCycleCallbacks, function()
		for _, v2 in v do
			v2.RowColumnIndex = 0
		end
	end)
	data.WidgetConstructor("Table", {
		hasState = false,
		hasChildren = true,
		Args = {
			NumColumns = 1,
			RowBg = 2,
			BordersOuter = 3,
			BordersInner = 4
		},
		Events = {
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(state)
			v[state.ID] = state
			state.InitialNumColumns = -1
			state.RowColumnIndex = 0
			state.ColumnInstances = {}
			state.CellInstances = {}
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Table"
			frame.Size = UDim2.new(data._config.ItemWidth, UDim.new(0, 0))
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ZIndex = state.ZIndex + 1024
			frame.LayoutOrder = state.ZIndex
			frame.ClipsDescendants = true
			data2.UIListLayout(frame, Enum.FillDirection.Horizontal, UDim.new(0, 0))
			data2.UIStroke(frame, 1, data._config.TableBorderStrongColor, data._config.TableBorderStrongTransparency)
			return frame
		end,
		Update = function(state)
			local instance = state.Instance

			if state.arguments.BordersOuter == false then
				instance.UIStroke.Thickness = 0
			else
				instance.UIStroke.Thickness = 1
			end

			if state.InitialNumColumns == -1 then
				if state.arguments.NumColumns == nil then
					error("Iris.Table NumColumns argument is required", 5)
				end

				state.InitialNumColumns = state.arguments.NumColumns

				for i = 1, state.InitialNumColumns do
					local v2 = state.ZIndex + 1 + i
					local frame = Instance.new("Frame")
					frame.Name = `Column_{i}`
					frame.Size = UDim2.new(1 / state.InitialNumColumns, 0, 0, 0)
					frame.AutomaticSize = Enum.AutomaticSize.Y
					frame.BackgroundTransparency = 1
					frame.BorderSizePixel = 0
					frame.ZIndex = v2
					frame.LayoutOrder = v2
					frame.ClipsDescendants = true
					data2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, 0))
					state.ColumnInstances[i] = frame
					frame.Parent = instance
				end
			elseif state.arguments.NumColumns ~= state.InitialNumColumns then
				error("Iris.Table NumColumns Argument must be static")
			end

			if state.arguments.RowBg == false then
				for _, cellInstance in state.CellInstances do
					cellInstance.BackgroundTransparency = 1
				end
			else
				for k, cellInstance in state.CellInstances do
					local backgroundTransparency

					if math.ceil(k / state.InitialNumColumns) % 2 == 0 then
						backgroundTransparency = data._config.TableRowBgAltTransparency
					else
						backgroundTransparency = data._config.TableRowBgTransparency
					end

					cellInstance.BackgroundTransparency = backgroundTransparency
				end
			end

			if state.arguments.BordersInner == false then
				for _, cellInstance in state.CellInstances do
					cellInstance.UIStroke.Thickness = 0
				end
			else
				for _, cellInstance in state.CellInstances do
					cellInstance.UIStroke.Thickness = 0.5
				end
			end
		end,
		Discard = function(p)
			v[p.ID] = nil
			p.Instance:Destroy()
		end,
		ChildAdded = function(state)
			if state.RowColumnIndex == 0 then
				state.RowColumnIndex = 1
			end

			local cellInstance = state.CellInstances[state.RowColumnIndex]

			if cellInstance then
				return cellInstance
			end

			local columnInstance = state.ColumnInstances[(state.RowColumnIndex - 1) % state.InitialNumColumns + 1]
			local v2 = columnInstance.ZIndex + state.RowColumnIndex
			local frame = Instance.new("Frame")
			frame.Name = `Cell_{state.RowColumnIndex}`
			frame.Size = UDim2.new(1, 0, 0, 0)
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ZIndex = v2
			frame.LayoutOrder = v2
			frame.ClipsDescendants = true
			data2.UIPadding(frame, data._config.CellPadding)
			data2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, data._config.ItemSpacing.Y))

			if state.arguments.BordersInner == false then
				data2.UIStroke(frame, 0, data._config.TableBorderLightColor, data._config.TableBorderLightTransparency)
			else
				data2.UIStroke(
					frame,
					0.5,
					data._config.TableBorderLightColor,
					data._config.TableBorderLightTransparency
				)
			end

			if state.arguments.RowBg ~= false then
				local v3 = math.ceil(state.RowColumnIndex / state.InitialNumColumns)
				local tableRowBgAltColor

				if v3 % 2 == 0 then
					tableRowBgAltColor = data._config.TableRowBgAltColor
				else
					tableRowBgAltColor = data._config.TableRowBgColor
				end

				local tableRowBgAltTransparency

				if v3 % 2 == 0 then
					tableRowBgAltTransparency = data._config.TableRowBgAltTransparency
				else
					tableRowBgAltTransparency = data._config.TableRowBgTransparency
				end

				frame.BackgroundColor3 = tableRowBgAltColor
				frame.BackgroundTransparency = tableRowBgAltTransparency
			end

			state.CellInstances[state.RowColumnIndex] = frame
			frame.Parent = columnInstance
			return frame
		end
	})
end