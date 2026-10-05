require(script.Parent.Types)
return function(state)
	local _Insert = state.Internal._Insert

	local function wrapper(p: string)
		return function(p2, p3)
			return _Insert(p, p2, p3)
		end
	end

	local v = "Window"

	function state.Window(p, p2)
		return _Insert(v, p, p2)
	end

	local v2 = "ScrollingFrame"

	function state.ScrollingFrame(p, p2)
		return _Insert(v2, p, p2)
	end

	state.SetFocusedWindow = state.Internal.SetFocusedWindow
	local v3 = "Tooltip"

	function state.Tooltip(p, p2)
		return _Insert(v3, p, p2)
	end

	local v4 = "MenuBar"

	function state.MenuBar(p, p2)
		return _Insert(v4, p, p2)
	end

	local v5 = "Menu"

	function state.Menu(p, p2)
		return _Insert(v5, p, p2)
	end

	local v6 = "MenuItem"

	function state.MenuItem(p, p2)
		return _Insert(v6, p, p2)
	end

	local v7 = "MenuToggle"

	function state.MenuToggle(p, p2)
		return _Insert(v7, p, p2)
	end

	local v8 = "Separator"

	function state.Separator(p, p2)
		return _Insert(v8, p, p2)
	end

	local v9 = "Indent"

	function state.Indent(p, p2)
		return _Insert(v9, p, p2)
	end

	local v10 = "SameLine"

	function state.SameLine(p, p2)
		return _Insert(v10, p, p2)
	end

	local v11 = "Group"

	function state.Group(p, p2)
		return _Insert(v11, p, p2)
	end

	local v12 = "Text"

	function state.Text(p, p2)
		return _Insert(v12, p, p2)
	end

	function state:TextWrapped()
		self[2] = true
		return (state.Internal._Insert("Text", self))
	end

	function state:TextColored()
		self[3] = self[2]
		self[2] = nil
		return (state.Internal._Insert("Text", self))
	end

	local v13 = "SeparatorText"

	function state.SeparatorText(p, p2)
		return _Insert(v13, p, p2)
	end

	local v14 = "InputText"

	function state.InputText(p, p2)
		return _Insert(v14, p, p2)
	end

	local v15 = "Button"

	function state.Button(p, p2)
		return _Insert(v15, p, p2)
	end

	local v16 = "SmallButton"

	function state.SmallButton(p, p2)
		return _Insert(v16, p, p2)
	end

	local v17 = "Checkbox"

	function state.Checkbox(p, p2)
		return _Insert(v17, p, p2)
	end

	local v18 = "RadioButton"

	function state.RadioButton(p, p2)
		return _Insert(v18, p, p2)
	end

	local v19 = "Image"

	function state.Image(p, p2)
		return _Insert(v19, p, p2)
	end

	local v20 = "ImageButton"

	function state.ImageButton(p, p2)
		return _Insert(v20, p, p2)
	end

	local v21 = "Tree"

	function state.Tree(p, p2)
		return _Insert(v21, p, p2)
	end

	local v22 = "CollapsingHeader"

	function state.CollapsingHeader(p, p2)
		return _Insert(v22, p, p2)
	end

	local v23 = "TabBar"

	function state.TabBar(p, p2)
		return _Insert(v23, p, p2)
	end

	local v24 = "Tab"

	function state.Tab(p, p2)
		return _Insert(v24, p, p2)
	end

	local v25 = "InputNum"

	function state.InputNum(p, p2)
		return _Insert(v25, p, p2)
	end

	local v26 = "InputVector2"

	function state.InputVector2(p, p2)
		return _Insert(v26, p, p2)
	end

	local v27 = "InputVector3"

	function state.InputVector3(p, p2)
		return _Insert(v27, p, p2)
	end

	local v28 = "InputUDim"

	function state.InputUDim(p, p2)
		return _Insert(v28, p, p2)
	end

	local v29 = "InputUDim2"

	function state.InputUDim2(p, p2)
		return _Insert(v29, p, p2)
	end

	local v30 = "InputRect"

	function state.InputRect(p, p2)
		return _Insert(v30, p, p2)
	end

	local v31 = "DragNum"

	function state.DragNum(p, p2)
		return _Insert(v31, p, p2)
	end

	local v32 = "DragVector2"

	function state.DragVector2(p, p2)
		return _Insert(v32, p, p2)
	end

	local v33 = "DragVector3"

	function state.DragVector3(p, p2)
		return _Insert(v33, p, p2)
	end

	local v34 = "DragUDim"

	function state.DragUDim(p, p2)
		return _Insert(v34, p, p2)
	end

	local v35 = "DragUDim2"

	function state.DragUDim2(p, p2)
		return _Insert(v35, p, p2)
	end

	local v36 = "DragRect"

	function state.DragRect(p, p2)
		return _Insert(v36, p, p2)
	end

	local v37 = "InputColor3"

	function state.InputColor3(p, p2)
		return _Insert(v37, p, p2)
	end

	local v38 = "InputColor4"

	function state.InputColor4(p, p2)
		return _Insert(v38, p, p2)
	end

	local v39 = "SliderNum"

	function state.SliderNum(p, p2)
		return _Insert(v39, p, p2)
	end

	local v40 = "SliderVector2"

	function state.SliderVector2(p, p2)
		return _Insert(v40, p, p2)
	end

	local v41 = "SliderVector3"

	function state.SliderVector3(p, p2)
		return _Insert(v41, p, p2)
	end

	local v42 = "SliderUDim"

	function state.SliderUDim(p, p2)
		return _Insert(v42, p, p2)
	end

	local v43 = "SliderUDim2"

	function state.SliderUDim2(p, p2)
		return _Insert(v43, p, p2)
	end

	local v44 = "SliderRect"

	function state.SliderRect(p, p2)
		return _Insert(v44, p, p2)
	end

	local v45 = "Selectable"

	function state.Selectable(p, p2)
		return _Insert(v45, p, p2)
	end

	local v46 = "Combo"

	function state.Combo(p, p2)
		return _Insert(v46, p, p2)
	end

	function state.ComboArray(p, p2, list)
		if p2 == nil then
			p2 = state.State(list[1])
		end

		local _Insert2 = state.Internal._Insert("Combo", p, p2)
		local index = _Insert2.state.index

		for _, v47 in list do
			state.Internal._Insert("Selectable", { v47, v47 }, {
				index = index
			})
		end

		state.End()
		return _Insert2
	end

	function state.ComboEnum(p, p2, object)
		if p2 == nil then
			p2 = state.State(object:GetEnumItems()[1])
		end

		local _Insert2 = state.Internal._Insert("Combo", p, p2)
		local index = _Insert2.state.index

		for _, v47 in object:GetEnumItems() do
			state.Internal._Insert("Selectable", { v47.Name, v47 }, {
				index = index
			})
		end

		state.End()
		return _Insert2
	end

	state.InputEnum = state.ComboEnum
	local v47 = "ProgressBar"

	function state.ProgressBar(p, p2)
		return _Insert(v47, p, p2)
	end

	local v48 = "PlotLines"

	function state.PlotLines(p, p2)
		return _Insert(v48, p, p2)
	end

	local v49 = "PlotHistogram"

	function state.PlotHistogram(p, p2)
		return _Insert(v49, p, p2)
	end

	local v50 = "Table"

	function state.Table(p, p2)
		return _Insert(v50, p, p2)
	end

	function state.NextColumn()
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget.type == "Table", "Iris.NextColumn() can only be called within a table.")
		_GetParentWidget.RowColumnIndex += 1
	end

	function state.SetColumnIndex(p: number)
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget.type == "Table", "Iris.SetColumnIndex() can only be called within a table.")
		assert(_GetParentWidget.InitialNumColumns <= p, "Iris.SetColumnIndex() argument must be in column range.")
		_GetParentWidget.RowColumnIndex = math.floor(_GetParentWidget.RowColumnIndex / _GetParentWidget.InitialNumColumns) + (p - 1)
	end

	function state.NextRow()
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget.type == "Table", "Iris.NextColumn() can only be called within a table.")
		local initialNumColumns = _GetParentWidget.InitialNumColumns
		_GetParentWidget.RowColumnIndex = math.floor((_GetParentWidget.RowColumnIndex + 1) / initialNumColumns) * initialNumColumns
	end
end