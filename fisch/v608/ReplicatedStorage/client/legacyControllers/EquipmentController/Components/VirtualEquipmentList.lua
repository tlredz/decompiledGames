local VirtualEquipmentList = {}
VirtualEquipmentList.__index = VirtualEquipmentList

function VirtualEquipmentList.new(config)
	local object = setmetatable({
		_config = config,
		_scroll = config.ScrollingFrame,
		_entries = {},
		_displayed = {},
		_buffered = {},
		_layout = "List",
		_active = false,
		_lastFirst = 0,
		_lastLast = -1,
		_lastCanvasSize = nil,
		_itemPadding = config.ItemPadding or 4,
		_viewportBuffer = config.ViewportBuffer or 1
	}, VirtualEquipmentList)
	object:_applyLayoutProperties()
	object._scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		object:Refresh()
	end)
	object._scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		object:_invalidatePositions()
		object:Refresh(true)
	end)
	config.MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if config.MainFrame.Visible then
			object:Refresh()
		end
	end)
	return object
end

function VirtualEquipmentList:_applyLayoutProperties()
	local v = self._layout == "Grid"
	self._scroll.ScrollingDirection = v and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X
	self._scroll.HorizontalScrollBarInset = v and Enum.ScrollBarInset.ScrollBar or Enum.ScrollBarInset.None
end

function VirtualEquipmentList:_invalidatePositions()
	for _, _entry in self._entries do
		_entry.cachedIndex = nil
	end
end

function VirtualEquipmentList:_getListItemWidth()
	return self._scroll.AbsoluteSize.X * self._config.ListItemWidthScale
end

function VirtualEquipmentList:_getGridCellSize()
	local absoluteSize = self._scroll.AbsoluteSize
	return absoluteSize.X * self._config.GridItemWidthScale, absoluteSize.Y * self._config.GridItemHeightScale
end

function VirtualEquipmentList:_getVisibleRange()
	local count = #self._displayed

	if count == 0 then
		return 1, 0
	end

	local gridColumns = self._config.GridColumns
	local _itemPadding = self._itemPadding
	local _viewportBuffer = self._viewportBuffer

	if self._layout == "Grid" then
		local _, v = self:_getGridCellSize()
		local v2 = v + _itemPadding

		if v <= 0 then
			return 1, 0
		end

		local Y = self._scroll.CanvasPosition.Y
		local Y2 = self._scroll.AbsoluteSize.Y
		local v3 = math.max(0, math.floor(Y / v2) - _viewportBuffer)
		local v4 = math.ceil((Y + Y2) / v2) + _viewportBuffer
		return math.max(1, v3 * gridColumns + 1), (math.min(count, (v4 + 1) * gridColumns))
	else
		local _getListItemWidth = self:_getListItemWidth()
		local v = _getListItemWidth + _itemPadding

		if _getListItemWidth <= 0 then
			return 1, 0
		end

		local X = self._scroll.CanvasPosition.X
		local X2 = self._scroll.AbsoluteSize.X
		return
			math.max(1, math.floor(X / v) + 1 - _viewportBuffer),
			(math.min(count, math.ceil((X + X2) / v) + _viewportBuffer))
	end
end

function VirtualEquipmentList:_position(p, cachedIndex: number)
	if p.cachedIndex == cachedIndex then
		return
	end

	p.cachedIndex = cachedIndex
	local activeTemplate = self:GetActiveTemplate(p)

	if not activeTemplate then
		return
	end

	if self._layout == "Grid" then
		local _getGridCellSize, v = self:_getGridCellSize()
		local gridColumns = self._config.GridColumns
		local v2 = (cachedIndex - 1) // gridColumns
		local v3 = (cachedIndex - 1) % gridColumns
		activeTemplate.Position = UDim2.new(
			0,
			v3 * (_getGridCellSize + self._itemPadding),
			0,
			v2 * (v + self._itemPadding)
		)
	else
		local v = self:_getListItemWidth() + self._itemPadding
		activeTemplate.Position = UDim2.new(0, (cachedIndex - 1) * v, self._config.ListAnchorYScale or 0.485, 0)
	end
end

function VirtualEquipmentList:_mount(state, p: number)
	self:_position(state, p)

	if state.mounted then
		return
	end

	state.mounted = true
	local activeTemplate = self:GetActiveTemplate(state)

	if activeTemplate then
		state.mountedFrame = activeTemplate
		activeTemplate.Parent = self._scroll
	end

	local v = self._buffered[state.key]

	if v then
		self._buffered[state.key] = nil

		for k in v do
			self._config.RunUpdate(state, k)
		end
	end
end

function VirtualEquipmentList:_unmount(state)
	if not state.mounted then
		return
	end

	state.mounted = false
	local mountedFrame = state.mountedFrame or self:GetActiveTemplate(state)
	state.mountedFrame = nil

	if mountedFrame then
		pcall(function()
			mountedFrame.Parent = self._config.OffscreenParent
		end)
	end
end

function VirtualEquipmentList:GetActiveTemplate(p2)
	if self._layout == "Grid" then
		return p2.gridFrame
	end

	return p2.Frame
end

function VirtualEquipmentList:GetEntries()
	return self._entries
end

function VirtualEquipmentList:GetEntry(p2: string)
	return self._entries[p2]
end

function VirtualEquipmentList:AddEntry(p2: string, p3)
	self._entries[p2] = p3
end

function VirtualEquipmentList:RemoveEntry(p: string)
	local _entry = self._entries[p]

	if not _entry then
		return
	end

	self:_unmount(_entry)
	self._entries[p] = nil
	self._buffered[p] = nil
end

function VirtualEquipmentList:ScheduleUpdate(p: string, p2: string)
	local _entry = self._entries[p]

	if not _entry then
		return
	end

	if _entry.mounted then
		self._config.RunUpdate(_entry, p2)
		local v = self._buffered[p]

		if v then
			v[p2] = nil
		end
	else
		local v = self._buffered[p]

		if not v then
			v = {}
			self._buffered[p] = v
		end

		v[p2] = true
	end
end

function VirtualEquipmentList:Refresh(flag: boolean?)
	if not self._active then
		return
	end

	local count = #self._displayed
	local uDim

	if self._layout == "Grid" then
		local _, v = self:_getGridCellSize()
		local v2 = math.max(0, math.ceil(count / self._config.GridColumns) * (v + self._itemPadding))
		uDim = UDim2.new(0, 0, 0, v2)
	else
		local v = math.max(0, count * (self:_getListItemWidth() + self._itemPadding) - self._itemPadding)
		uDim = UDim2.new(0, v, 0, 0)
	end

	local offset = self._layout == "Grid" and uDim.Y.Offset or uDim.X.Offset

	if self._lastCanvasSize ~= offset then
		self._lastCanvasSize = offset
		self._scroll.CanvasSize = uDim
	end

	local _getVisibleRange, lastLast = self:_getVisibleRange()

	if not flag and _getVisibleRange == self._lastFirst and lastLast == self._lastLast then
		return
	end

	local v2 = {}

	for i = _getVisibleRange, lastLast do
		local v3 = self._displayed[i]

		if v3 then
			v2[v3] = true
		end
	end

	if flag then
		for _, _entry in self._entries do
			if not _entry.mounted or v2[_entry] then
				continue
			end

			self:_unmount(_entry)
		end
	else
		for i = self._lastFirst, self._lastLast do
			if not (i < _getVisibleRange or lastLast < i) then
				continue
			end

			local v3 = self._displayed[i]

			if v3 and v3.mounted then
				self:_unmount(v3)
			end
		end
	end

	for i = _getVisibleRange, lastLast do
		local v3 = self._displayed[i]

		if not v3 then
			continue
		end

		if v3.mounted then
			self:_position(v3, i)
		else
			self:_mount(v3, i)
		end
	end

	self._lastFirst = _getVisibleRange
	self._lastLast = lastLast
end

function VirtualEquipmentList:Rebuild()
	local _entries = {}

	for _, _entry in self._entries do
		table.insert(_entries, _entry)
	end

	table.sort(_entries, self._config.Compare)
	table.clear(self._displayed)

	for _, v in _entries do
		if v.searchVisible then
			table.insert(self._displayed, v)
		end
	end

	self:_invalidatePositions()
	self:Refresh(true)
end

function VirtualEquipmentList:GetLayout()
	return self._layout
end

function VirtualEquipmentList:SetLayout(layout: string)
	if layout == self._layout or layout ~= "List" and layout ~= "Grid" then
		return
	end

	for _, _entry in self._entries do
		self:_unmount(_entry)
		_entry.cachedIndex = nil
	end

	self._layout = layout
	self:_applyLayoutProperties()
	self._lastFirst = 0
	self._lastLast = -1
	self._lastCanvasSize = nil
	self._scroll.CanvasPosition = Vector2.new(0, 0)
	self:Refresh(true)
end

function VirtualEquipmentList:SetActive(flag: boolean)
	if flag == self._active then
		return
	end

	if flag then
		self._active = true
		self._lastFirst = 0
		self._lastLast = -1
		self:Refresh(true)
	else
		for _, _entry in self._entries do
			self:_unmount(_entry)
		end

		self._active = false
	end
end

return VirtualEquipmentList