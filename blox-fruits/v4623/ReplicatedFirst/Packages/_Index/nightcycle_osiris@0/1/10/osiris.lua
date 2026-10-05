local Iris = require(script.Parent.Iris)

function toParams(p: string, p2, items, ...)
	local result = {}

	if p2 then
		assert(Iris.Args[p], (`bad args for "{p}"`))

		for k, v in Iris.Args[p] do
			result[v] = p2[k]
		end
	end

	local count = 0
	local result2 = {}

	if items then
		for k, item in items do
			result2[k] = item
			count += 1
		end
	end

	if not (count > 0) then
		result2 = nil
	end

	return result, result2, ...
end

local Osiris = {
	Disabled = Iris.Disabled,
	TemplateConfig = Iris.TemplateConfig,
	Internal = Iris.Internal,
	Connect = function(self, callback)
		return Iris:Connect(callback)
	end,
	Append = Iris.Append,
	ForceRefresh = Iris.ForceRefresh,
	Init = Iris.Init,
	PopConfig = Iris.PopConfig,
	PopId = Iris.PopId,
	PushConfig = Iris.PushConfig,
	PushId = Iris.PushId,
	SetFocusedWindow = Iris.SetFocusedWindow,
	SetNextWidgetID = Iris.SetNextWidgetID,
	ShowDemoWindow = Iris.ShowDemoWindow,
	Shutdown = Iris.Shutdown,
	State = function(p)
		return Iris.State(p)
	end,
	WeakState = function(p)
		return Iris.WeakState(p)
	end,
	VariableState = function(p, callback)
		return Iris.VariableState(p, callback)
	end,
	TableState = function(p, p2, callback)
		return Iris.TableState(p, p2, callback)
	end,
	ComputedState = function(p, callback)
		return Iris.ComputedState(p, callback)
	end,
	UpdateGlobalConfig = Iris.UpdateGlobalConfig,
	Widget = {}
}

function Osiris.Widget.Window(p, callback)
	local window = Iris.Window(toParams("Window", p.Arguments, p.States))
	callback(window)
	Iris.End()
	return window
end

function Osiris.Widget.Tooltip(p)
	return Iris.Tooltip(toParams("Tooltip", p.Arguments))
end

function Osiris.Widget.MenuBar(_, callback)
	local menuBar = Iris.MenuBar()
	callback(menuBar)
	Iris.End()
	return menuBar
end

function Osiris.Widget.Menu(p, callback)
	local menu = Iris.Menu(toParams("Menu", p.Arguments, p.States))
	callback(menu)
	Iris.End()
	return menu
end

function Osiris.Widget.MenuItem(p)
	return Iris.MenuItem(toParams("MenuItem", p.Arguments))
end

function Osiris.Widget.MenuToggle(p)
	return Iris.MenuToggle(toParams("MenuToggle", p.Arguments, p.States))
end

function Osiris.Widget.Separator(_)
	return Iris.Separator()
end

function Osiris.Widget.Indent(p, callback)
	local indent = Iris.Indent(toParams("Indent", p.Arguments))
	callback(indent)
	Iris.End()
	return indent
end

function Osiris.Widget.SameLine(p, callback)
	local sameLine = Iris.SameLine(toParams("SameLine", p.Arguments))
	callback(sameLine)
	Iris.End()
	return sameLine
end

function Osiris.Widget.Group(_, callback)
	local group = Iris.Group()
	callback(group)
	Iris.End()
	return group
end

function Osiris.Widget.InputText(p)
	return Iris.InputText(toParams("InputText", p.Arguments, p.States))
end

function Osiris.Widget.SeparatorText(p)
	return Iris.SeparatorText(toParams("SeparatorText", p.Arguments))
end

function Osiris.Widget.Text(p)
	return Iris.Text(toParams("Text", p.Arguments))
end

function Osiris.Widget.Button(p)
	return Iris.Button(toParams("Button", p.Arguments))
end

function Osiris.Widget.SmallButton(p)
	return Iris.SmallButton(toParams("SmallButton", p.Arguments))
end

function Osiris.Widget.Checkbox(p)
	return Iris.Checkbox(toParams("Checkbox", p.Arguments, p.States))
end

function Osiris.Widget.RadioButton(p)
	return Iris.RadioButton(toParams("RadioButton", p.Arguments, p.States))
end

function Osiris.Widget.Tree(p, callback)
	local tree = Iris.Tree(toParams("Tree", p.Arguments, p.States))
	callback(tree)
	Iris.End()
	return tree
end

function Osiris.Widget.CollapsingHeader(p, callback)
	local collapsingHeader = Iris.CollapsingHeader(toParams("CollapsingHeader", p.Arguments, p.States))
	callback(collapsingHeader)
	Iris.End()
	return collapsingHeader
end

function Osiris.Widget.TabBar(p, callback)
	local tabBar = Iris.TabBar(toParams("TabBar", nil, p.States))
	callback(tabBar)
	Iris.End()
	return tabBar
end

function Osiris.Widget.Tab(p, callback)
	local tab = Iris.Tab(toParams("Tab", p.Arguments, p.States))
	callback(tab)
	Iris.End()
	return tab
end

function Osiris.Widget.Image(p)
	return Iris.Image(toParams("Image", p.Arguments))
end

function Osiris.Widget.ImageButton(p)
	return Iris.ImageButton(toParams("ImageButton", p.Arguments))
end

function Osiris.Widget.InputNum(p)
	return Iris.InputNum(toParams("InputNum", p.Arguments, p.States))
end

function Osiris.Widget.InputVector2(p)
	return Iris.InputVector2(toParams("InputVector2", p.Arguments, p.States))
end

function Osiris.Widget.InputVector3(p)
	return Iris.InputVector3(toParams("InputVector3", p.Arguments, p.States))
end

function Osiris.Widget.InputUDim(p)
	return Iris.InputUDim(toParams("InputUDim", p.Arguments, p.States))
end

function Osiris.Widget.InputUDim2(p)
	return Iris.InputUDim2(toParams("InputUDim2", p.Arguments, p.States))
end

function Osiris.Widget.InputRect(p)
	return Iris.InputRect(toParams("InputRect", p.Arguments, p.States))
end

function Osiris.Widget.InputColor3(p)
	return Iris.InputColor3(toParams("InputColor3", p.Arguments, p.States))
end

function Osiris.Widget.InputColor4(p)
	return Iris.InputColor4(toParams("InputColor4", p.Arguments, p.States))
end

function Osiris.Widget.DragNum(p)
	return Iris.DragNum(toParams("DragNum", p.Arguments, p.States))
end

function Osiris.Widget.DragVector2(p)
	return Iris.DragVector2(toParams("DragVector2", p.Arguments, p.States))
end

function Osiris.Widget.DragVector3(p)
	return Iris.DragVector3(toParams("DragVector3", p.Arguments, p.States))
end

function Osiris.Widget.DragUDim(p)
	return Iris.DragUDim(toParams("DragUDim", p.Arguments, p.States))
end

function Osiris.Widget.DragUDim2(p)
	return Iris.DragUDim2(toParams("DragUDim2", p.Arguments, p.States))
end

function Osiris.Widget.DragRect(p)
	return Iris.DragRect(toParams("DragRect", p.Arguments, p.States))
end

function Osiris.Widget.SliderNum(p)
	return Iris.SliderNum(toParams("SliderNum", p.Arguments, p.States))
end

function Osiris.Widget.SliderVector2(p)
	return Iris.SliderVector2(toParams("SliderVector2", p.Arguments, p.States))
end

function Osiris.Widget.SliderVector3(p)
	return Iris.SliderVector3(toParams("SliderVector3", p.Arguments, p.States))
end

function Osiris.Widget.SliderUDim(p)
	return Iris.SliderUDim(toParams("SliderUDim", p.Arguments, p.States))
end

function Osiris.Widget.SliderUDim2(p)
	return Iris.SliderUDim2(toParams("SliderUDim2", p.Arguments, p.States))
end

function Osiris.Widget.SliderRect(p)
	return Iris.SliderRect(toParams("SliderRect", p.Arguments, p.States))
end

function Osiris.Widget.Selectable(p)
	return Iris.Selectable(toParams("Selectable", p.Arguments, p.States))
end

function Osiris.Widget.Combo(p)
	return (Iris.Combo(toParams("Combo", p.Arguments, p.States)))
end

function Osiris.Widget.ComboArray(data)
	return (Iris.ComboArray(toParams("Combo", data.Arguments, data.States, data.Extra.selectionArray)))
end

function Osiris.Widget.ComboEnum(data)
	return (Iris.ComboEnum(toParams("Combo", data.Arguments, data.States, data.Extra.enumType)))
end

function Osiris.Widget.ProgressBar(p)
	return Iris.ProgressBar(toParams("ProgressBar", p.Arguments, p.States))
end

function Osiris.Widget.PlotLines(p)
	return Iris.PlotLines(toParams("PlotLines", p.Arguments, p.States))
end

function Osiris.Widget.PlotHistogram(p)
	return Iris.PlotHistogram(toParams("PlotHistogram", p.Arguments, p.States))
end

function Osiris.Widget.Table(p, callback)
	local table = Iris.Table(toParams("Table", p.Arguments, p.States))
	local v = {
		ID = table.ID,
		type = table.type,
		lastCycleTick = table.lastCycleTick,
		parentWidget = table.parentWidget,
		Instance = table.Instance,
		ZIndex = table.ZIndex,
		arguments = table.arguments,
		hovered = table.hovered,
		NextColumn = Iris.NextColumn,
		NextRow = Iris.NextRow,
		SetColumIndex = Iris.SetColumnIndex,
		SetRowIndex = Iris.SetRowIndex,
		NextHeaderColumn = Iris.NextHeaderColumn,
		SetHeaderColumnIndex = Iris.SetHeaderColumnIndex,
		SetColumnWidth = Iris.SetColumnWidth
	}
	callback(v)
	Iris.End()
	return v
end

setmetatable(Osiris, {
	__newindex = function(p, p2: string, disabled)
		if p2 == "Disabled" then
			Iris.Disabled = disabled
			rawset(p, "Disabled", disabled)
		end
	end
})
return Osiris