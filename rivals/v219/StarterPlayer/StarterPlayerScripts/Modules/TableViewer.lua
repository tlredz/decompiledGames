local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local entry = script:WaitForChild("Entry")
local gui = script:WaitForChild("Gui")
local TableViewer = {}
TableViewer.__index = TableViewer

function TableViewer.new(root)
	local self = setmetatable({}, TableViewer)
	self.Root = root
	self.ScreenGui = gui:Clone()
	self._entry_to_children = {}
	self._entry_to_parent = {}
	self:_Init()
	return self
end

function TableViewer:Destroy()
	self.ScreenGui:Destroy()
	self._entry_to_children = nil
	self._entry_to_parent = nil
	self.Root = nil
end

function TableViewer:_GetTabString(count)
	return string.rep(" <font transparency=\"0.75\">|</font>  ", count)
end

function TableViewer:_ColorBasedOnType(p, value)
	if typeof(value) == "string" then
		return "<font color=\"rgb(0,255,0)\">" .. p .. "</font>"
	end

	if typeof(value) == "number" then
		return "<font color=\"rgb(255,198,0)\">" .. p .. "</font>"
	end

	if typeof(value) == "boolean" then
		return "<font color=\"rgb(8,123,255)\">" .. p .. "</font>"
	end

	if typeof(value) == "Instance" then
		return value.ClassName .. ": <font color=\"rgb(0,255,0)\">\"" .. p .. "\"</font>"
	end

	return p
end

function TableViewer:_DeleteDescendants(p)
	for _, v in pairs(self._entry_to_children[p] or {}) do
		self:_DeleteDescendants(v)
		self._entry_to_children[v] = nil
		self._entry_to_parent[v] = nil
		v:Destroy()
	end
end

function TableViewer:_CreateEntry(p)
	local clone = entry:Clone()
	self._entry_to_children[clone] = {}
	self._entry_to_parent[clone] = p

	if p then
		table.insert(self._entry_to_children[p], clone)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_size()
		clone.Size = UDim2.new(
			0,
			math.max(clone.Title.TextBounds.X, self.ScreenGui.MainFrame.List.AbsoluteCanvasSize.X),
			clone.Size.Y.Scale,
			clone.Size.Y.Offset
		)
	end

	clone.Title:GetPropertyChangedSignal("TextBounds"):Connect(update_size)
	update_size() -- equivalent call inferred; original call site unknown
	return clone
end

function TableViewer:_Generate(items, p, p2)
	local v = {}

	for k in pairs(items) do
		table.insert(v, k)
	end

	table.sort(v, function(a, b)
		return Utility:StringLessThan(tostring(a), (tostring(b)))
	end)
	local v2 = not p2 and 0 or p2.LayoutOrder or 0

	for k in pairs(self._entry_to_children) do
		if v2 < k.LayoutOrder then
			k.LayoutOrder += #v + (p2 and 1 or 0)
		end
	end

	for k, v3 in pairs(v) do
		local item = items[v3]
		local v4 = typeof(item) == "table"
		local v5 = v4 and next(item) ~= nil
		local _GetTabString = self:_GetTabString(p)
		local v6

		if typeof(v3) == "string" then
			v6 = "\"" .. v3 .. "\""
		else
			v6 = tostring(v3)
		end

		local _ColorBasedOnType = self:_ColorBasedOnType(v6, v3)
		local v7

		if typeof(item) == "string" then
			v7 = "\"" .. item .. "\""
		else
			v7 = tostring(item)
		end

		local _ColorBasedOnType2 = self:_ColorBasedOnType(v7, item)
		local _CreateEntry = self:_CreateEntry(p2)
		_CreateEntry.Title.Text = string.format(
			"%s[%s] = %s;",
			_GetTabString,
			_ColorBasedOnType,
			v4 and "{}" or _ColorBasedOnType2
		)
		_CreateEntry.LayoutOrder = v2 + k
		_CreateEntry.Parent = self.ScreenGui.MainFrame.List.Container

		if not v5 then
			continue
		end

		local v8 = false
		-- equivalent calls inferred from this helper; original call sites unknown
		local v9 = _CreateEntry
		local v10 = _GetTabString
		local v11 = _ColorBasedOnType

		local function update_text()
			v9.Title.Text = string.format("%s[%s] = %s", v10, v11, v8 and "{" or "{...};")
		end

		update_text() -- equivalent call inferred; original call site unknown
		local v12 = _CreateEntry
		local v13 = _GetTabString
		local v14 = _ColorBasedOnType
		local v15 = item
		_CreateEntry.Button.MouseButton1Click:Connect(function()
			v8 = not v8
			update_text() -- equivalent call inferred; original call site unknown

			if v8 then
				self:_Generate(v15, p + 1, v12)
			else
				self:_DeleteDescendants(v12)
			end
		end)
	end

	if p2 then
		local _CreateEntry = self:_CreateEntry(p2)
		_CreateEntry.Title.Text = self:_GetTabString(p - 1) .. "};"
		_CreateEntry.LayoutOrder = v2 + #v + 1
		_CreateEntry.Parent = self.ScreenGui.MainFrame.List.Container
	end
end

function TableViewer:_UpdateList()
	self.ScreenGui.MainFrame.List.CanvasSize = UDim2.new(
		0,
		self.ScreenGui.MainFrame.List.Container.Layout.AbsoluteContentSize.X,
		0,
		self.ScreenGui.MainFrame.List.Container.Layout.AbsoluteContentSize.Y
	)
end

function TableViewer:_UpdateSize()
	self.ScreenGui.MainFrame.List.Container.Size = UDim2.new(
		0,
		self.ScreenGui.MainFrame.AbsoluteSize.X,
		0,
		self.ScreenGui.MainFrame.AbsoluteSize.Y
	)
end

function TableViewer:_Init()
	self.ScreenGui.MainFrame.Top.Button.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
	self.ScreenGui.MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSize()
	end)
	self.ScreenGui.MainFrame.List.Container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateList()
	end)
	self:_Generate(self.Root, 0, nil)
	self:_UpdateSize()
	self:_UpdateList()
end

return TableViewer