require(script.Parent.Types)
return function(state)
	local function wrapper(p)
		return function(p2, p3)
			return state.Internal._Insert(p, p2, p3)
		end
	end

	local v = "Window"

	function state.Window(p, p2)
		return state.Internal._Insert(v, p, p2)
	end

	state.SetFocusedWindow = state.Internal.SetFocusedWindow
	local v2 = "Tooltip"

	function state.Tooltip(p, p2)
		return state.Internal._Insert(v2, p, p2)
	end

	local v3 = "MenuBar"

	function state.MenuBar(p, p2)
		return state.Internal._Insert(v3, p, p2)
	end

	local v4 = "Menu"

	function state.Menu(p, p2)
		return state.Internal._Insert(v4, p, p2)
	end

	local v5 = "MenuItem"

	function state.MenuItem(p, p2)
		return state.Internal._Insert(v5, p, p2)
	end

	local v6 = "MenuToggle"

	function state.MenuToggle(p, p2)
		return state.Internal._Insert(v6, p, p2)
	end

	local v7 = "Separator"

	function state.Separator(p, p2)
		return state.Internal._Insert(v7, p, p2)
	end

	local v8 = "Indent"

	function state.Indent(p, p2)
		return state.Internal._Insert(v8, p, p2)
	end

	local v9 = "SameLine"

	function state.SameLine(p, p2)
		return state.Internal._Insert(v9, p, p2)
	end

	local v10 = "Group"

	function state.Group(p, p2)
		return state.Internal._Insert(v10, p, p2)
	end

	local v11 = "Text"

	function state.Text(p, p2)
		return state.Internal._Insert(v11, p, p2)
	end

	function state:TextWrapped()
		self[2] = true
		return state.Internal._Insert("Text", self)
	end

	function state:TextColored()
		self[3] = self[2]
		self[2] = nil
		return state.Internal._Insert("Text", self)
	end

	local v12 = "SeparatorText"

	function state.SeparatorText(p, p2)
		return state.Internal._Insert(v12, p, p2)
	end

	local v13 = "InputText"

	function state.InputText(p, p2)
		return state.Internal._Insert(v13, p, p2)
	end

	local v14 = "Button"

	function state.Button(p, p2)
		return state.Internal._Insert(v14, p, p2)
	end

	local v15 = "SmallButton"

	function state.SmallButton(p, p2)
		return state.Internal._Insert(v15, p, p2)
	end

	local v16 = "Checkbox"

	function state.Checkbox(p, p2)
		return state.Internal._Insert(v16, p, p2)
	end

	local v17 = "RadioButton"

	function state.RadioButton(p, p2)
		return state.Internal._Insert(v17, p, p2)
	end

	local v18 = "Image"

	function state.Image(p, p2)
		return state.Internal._Insert(v18, p, p2)
	end

	local v19 = "ImageButton"

	function state.ImageButton(p, p2)
		return state.Internal._Insert(v19, p, p2)
	end

	local v20 = "Tree"

	function state.Tree(p, p2)
		return state.Internal._Insert(v20, p, p2)
	end

	local v21 = "CollapsingHeader"

	function state.CollapsingHeader(p, p2)
		return state.Internal._Insert(v21, p, p2)
	end

	local v22 = "TabBar"

	function state.TabBar(p, p2)
		return state.Internal._Insert(v22, p, p2)
	end

	local v23 = "Tab"

	function state.Tab(p, p2)
		return state.Internal._Insert(v23, p, p2)
	end

	local v24 = "InputNum"

	function state.InputNum(p, p2)
		return state.Internal._Insert(v24, p, p2)
	end

	local v25 = "InputVector2"

	function state.InputVector2(p, p2)
		return state.Internal._Insert(v25, p, p2)
	end

	local v26 = "InputVector3"

	function state.InputVector3(p, p2)
		return state.Internal._Insert(v26, p, p2)
	end

	local v27 = "InputUDim"

	function state.InputUDim(p, p2)
		return state.Internal._Insert(v27, p, p2)
	end

	local v28 = "InputUDim2"

	function state.InputUDim2(p, p2)
		return state.Internal._Insert(v28, p, p2)
	end

	local v29 = "InputRect"

	function state.InputRect(p, p2)
		return state.Internal._Insert(v29, p, p2)
	end

	local v30 = "DragNum"

	function state.DragNum(p, p2)
		return state.Internal._Insert(v30, p, p2)
	end

	local v31 = "DragVector2"

	function state.DragVector2(p, p2)
		return state.Internal._Insert(v31, p, p2)
	end

	local v32 = "DragVector3"

	function state.DragVector3(p, p2)
		return state.Internal._Insert(v32, p, p2)
	end

	local v33 = "DragUDim"

	function state.DragUDim(p, p2)
		return state.Internal._Insert(v33, p, p2)
	end

	local v34 = "DragUDim2"

	function state.DragUDim2(p, p2)
		return state.Internal._Insert(v34, p, p2)
	end

	local v35 = "DragRect"

	function state.DragRect(p, p2)
		return state.Internal._Insert(v35, p, p2)
	end

	local v36 = "InputColor3"

	function state.InputColor3(p, p2)
		return state.Internal._Insert(v36, p, p2)
	end

	local v37 = "InputColor4"

	function state.InputColor4(p, p2)
		return state.Internal._Insert(v37, p, p2)
	end

	local v38 = "SliderNum"

	function state.SliderNum(p, p2)
		return state.Internal._Insert(v38, p, p2)
	end

	local v39 = "SliderVector2"

	function state.SliderVector2(p, p2)
		return state.Internal._Insert(v39, p, p2)
	end

	local v40 = "SliderVector3"

	function state.SliderVector3(p, p2)
		return state.Internal._Insert(v40, p, p2)
	end

	local v41 = "SliderUDim"

	function state.SliderUDim(p, p2)
		return state.Internal._Insert(v41, p, p2)
	end

	local v42 = "SliderUDim2"

	function state.SliderUDim2(p, p2)
		return state.Internal._Insert(v42, p, p2)
	end

	local v43 = "SliderRect"

	function state.SliderRect(p, p2)
		return state.Internal._Insert(v43, p, p2)
	end

	local v44 = "Selectable"

	function state.Selectable(p, p2)
		return state.Internal._Insert(v44, p, p2)
	end

	local v45 = "Combo"

	function state.Combo(p, p2)
		return state.Internal._Insert(v45, p, p2)
	end

	function state.ComboArray(p, p2, list)
		if p2 == nil then
			p2 = state.State(list[1])
		end

		local _Insert = state.Internal._Insert("Combo", p, p2)
		local index = _Insert.state.index

		for _, v46 in list do
			state.Internal._Insert("Selectable", { v46, v46 }, {
				index = index
			})
		end

		state.End()
		return _Insert
	end

	function state.ComboEnum(p, p2, object)
		if p2 == nil then
			p2 = state.State(object:GetEnumItems()[1])
		end

		local _Insert = state.Internal._Insert("Combo", p, p2)
		local index = _Insert.state.index

		for _, v46 in object:GetEnumItems() do
			state.Internal._Insert("Selectable", { v46.Name, v46 }, {
				index = index
			})
		end

		state.End()
		return _Insert
	end

	state.InputEnum = state.ComboEnum
	local v46 = "ProgressBar"

	function state.ProgressBar(p, p2)
		return state.Internal._Insert(v46, p, p2)
	end

	local v47 = "PlotLines"

	function state.PlotLines(p, p2)
		return state.Internal._Insert(v47, p, p2)
	end

	local v48 = "PlotHistogram"

	function state.PlotHistogram(p, p2)
		return state.Internal._Insert(v48, p, p2)
	end

	local v49 = "Table"

	function state.Table(p, p2)
		return state.Internal._Insert(v49, p, p2)
	end

	function state.NextColumn()
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget ~= nil, "Iris.NextColumn() can only called when directly within a table.")

		if _GetParentWidget._columnIndex == _GetParentWidget.arguments.NumColumns then
			_GetParentWidget._columnIndex = 1
			_GetParentWidget._rowIndex += 1
		else
			_GetParentWidget._columnIndex += 1
		end

		return _GetParentWidget._columnIndex
	end

	function state.NextRow()
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget ~= nil, "Iris.NextRow() can only called when directly within a table.")
		_GetParentWidget._columnIndex = 1
		_GetParentWidget._rowIndex += 1
		return _GetParentWidget._rowIndex
	end

	function state.SetColumnIndex(columnIndex: number)
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget ~= nil, "Iris.SetColumnIndex() can only called when directly within a table.")
		local v50

		if columnIndex >= 1 then
			v50 = columnIndex <= _GetParentWidget.arguments.NumColumns
		else
			v50 = false
		end

		assert(v50, (`The index must be between 1 and {_GetParentWidget.arguments.NumColumns}, inclusive.`))
		_GetParentWidget._columnIndex = columnIndex
	end

	function state.SetRowIndex(rowIndex: number)
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget ~= nil, "Iris.SetRowIndex() can only called when directly within a table.")
		assert(rowIndex >= 1, "The index must be greater or equal to 1.")
		_GetParentWidget._rowIndex = rowIndex
	end

	function state.NextHeaderColumn()
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget ~= nil, "Iris.NextHeaderColumn() can only called when directly within a table.")
		_GetParentWidget._rowIndex = 0
		_GetParentWidget._columnIndex = _GetParentWidget._columnIndex % _GetParentWidget.arguments.NumColumns + 1
		return _GetParentWidget._columnIndex
	end

	function state.SetHeaderColumnIndex(columnIndex: number)
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget ~= nil, "Iris.SetHeaderColumnIndex() can only called when directly within a table.")
		local v50

		if columnIndex >= 1 then
			v50 = columnIndex <= _GetParentWidget.arguments.NumColumns
		else
			v50 = false
		end

		assert(v50, (`The index must be between 1 and {_GetParentWidget.arguments.NumColumns}, inclusive.`))
		_GetParentWidget._rowIndex = 0
		_GetParentWidget._columnIndex = columnIndex
	end

	function state.SetColumnWidth(p: number, p2: number)
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget ~= nil, "Iris.SetColumnWidth() can only called when directly within a table.")
		local v50

		if p >= 1 then
			v50 = p <= _GetParentWidget.arguments.NumColumns
		else
			v50 = false
		end

		assert(v50, (`The index must be between 1 and {_GetParentWidget.arguments.NumColumns}, inclusive.`))
		local v51 = _GetParentWidget.state.widths.value[p]
		_GetParentWidget.state.widths.value[p] = p2
		_GetParentWidget.state.widths:set(_GetParentWidget.state.widths.value, p2 ~= v51)
	end
end