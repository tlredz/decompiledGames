require(script.Parent.Types)
return function(state)
	local function wrapper(p: string)
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

	local v18 = "Tree"

	function state.Tree(p, p2)
		return state.Internal._Insert(v18, p, p2)
	end

	local v19 = "CollapsingHeader"

	function state.CollapsingHeader(p, p2)
		return state.Internal._Insert(v19, p, p2)
	end

	local v20 = "InputNum"

	function state.InputNum(p, p2)
		return state.Internal._Insert(v20, p, p2)
	end

	local v21 = "InputVector2"

	function state.InputVector2(p, p2)
		return state.Internal._Insert(v21, p, p2)
	end

	local v22 = "InputVector3"

	function state.InputVector3(p, p2)
		return state.Internal._Insert(v22, p, p2)
	end

	local v23 = "InputUDim"

	function state.InputUDim(p, p2)
		return state.Internal._Insert(v23, p, p2)
	end

	local v24 = "InputUDim2"

	function state.InputUDim2(p, p2)
		return state.Internal._Insert(v24, p, p2)
	end

	local v25 = "InputRect"

	function state.InputRect(p, p2)
		return state.Internal._Insert(v25, p, p2)
	end

	local v26 = "DragNum"

	function state.DragNum(p, p2)
		return state.Internal._Insert(v26, p, p2)
	end

	local v27 = "DragVector2"

	function state.DragVector2(p, p2)
		return state.Internal._Insert(v27, p, p2)
	end

	local v28 = "DragVector3"

	function state.DragVector3(p, p2)
		return state.Internal._Insert(v28, p, p2)
	end

	local v29 = "DragUDim"

	function state.DragUDim(p, p2)
		return state.Internal._Insert(v29, p, p2)
	end

	local v30 = "DragUDim2"

	function state.DragUDim2(p, p2)
		return state.Internal._Insert(v30, p, p2)
	end

	local v31 = "DragRect"

	function state.DragRect(p, p2)
		return state.Internal._Insert(v31, p, p2)
	end

	local v32 = "InputColor3"

	function state.InputColor3(p, p2)
		return state.Internal._Insert(v32, p, p2)
	end

	local v33 = "InputColor4"

	function state.InputColor4(p, p2)
		return state.Internal._Insert(v33, p, p2)
	end

	local v34 = "SliderNum"

	function state.SliderNum(p, p2)
		return state.Internal._Insert(v34, p, p2)
	end

	local v35 = "SliderVector2"

	function state.SliderVector2(p, p2)
		return state.Internal._Insert(v35, p, p2)
	end

	local v36 = "SliderVector3"

	function state.SliderVector3(p, p2)
		return state.Internal._Insert(v36, p, p2)
	end

	local v37 = "SliderUDim"

	function state.SliderUDim(p, p2)
		return state.Internal._Insert(v37, p, p2)
	end

	local v38 = "SliderUDim2"

	function state.SliderUDim2(p, p2)
		return state.Internal._Insert(v38, p, p2)
	end

	local v39 = "SliderRect"

	function state.SliderRect(p, p2)
		return state.Internal._Insert(v39, p, p2)
	end

	local v40 = "Selectable"

	function state.Selectable(p, p2)
		return state.Internal._Insert(v40, p, p2)
	end

	local v41 = "Combo"

	function state.Combo(p, p2)
		return state.Internal._Insert(v41, p, p2)
	end

	function state.ComboArray(p, p2, list)
		if p2 == nil then
			p2 = state.State(list[1])
		end

		local _Insert = state.Internal._Insert("Combo", p, p2)
		local index = _Insert.state.index

		for _, v42 in list do
			state.Internal._Insert("Selectable", { v42, v42 }, {
				index = index
			})
		end

		state.End()
		return _Insert
	end

	function state.ComboEnum(p, p2, list)
		if p2 == nil then
			p2 = state.State(list[1])
		end

		local _Insert = state.Internal._Insert("Combo", p, p2)
		local index = _Insert.state.index

		for _, v42 in list:GetEnumItems() do
			state.Internal._Insert("Selectable", { v42.Name, v42 }, {
				index = index
			})
		end

		state.End()
		return _Insert
	end

	state.InputEnum = state.ComboEnum
	local v42 = "Table"

	function state.Table(p, p2)
		return state.Internal._Insert(v42, p, p2)
	end

	function state.NextColumn()
		local _GetParentWidget = state.Internal._GetParentWidget()
		_GetParentWidget.RowColumnIndex += 1
	end

	function state.SetColumnIndex(p: number)
		local _GetParentWidget = state.Internal._GetParentWidget()
		assert(_GetParentWidget.InitialNumColumns <= p, "Iris.SetColumnIndex Argument must be in column range")
		_GetParentWidget.RowColumnIndex = math.floor(_GetParentWidget.RowColumnIndex / _GetParentWidget.InitialNumColumns) + (p - 1)
	end

	function state.NextRow()
		local _GetParentWidget = state.Internal._GetParentWidget()
		local initialNumColumns = _GetParentWidget.InitialNumColumns
		_GetParentWidget.RowColumnIndex = math.floor((_GetParentWidget.RowColumnIndex + 1) / initialNumColumns) * initialNumColumns
	end
end