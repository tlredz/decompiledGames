local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.packages.Trove)
local BestiaryGrid = {}
BestiaryGrid.__index = BestiaryGrid

local function connectActivated(button, onActivated)
	if button:IsA("GuiButton") then
		return button.Activated:Connect(onActivated)
	end

	return button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			onActivated()
		end
	end)
end

function BestiaryGrid.new(config)
	local object = setmetatable({}, BestiaryGrid)
	object._config = config
	object._scroll = config.scroll
	object._columns = config.columns or 4
	object._buffer = config.viewportBuffer or 1
	object._columnGap = config.columnGapScale or 0
	object._rowGap = config.rowGapScale or 0
	object._bottomPadding = config.bottomPaddingScale or 0
	object._entries = {}
	object._order = {}
	object._displayed = {}
	object._predicate = nil
	object._lastFirst = 0
	object._lastLast = -1
	object._lastCanvasSize = nil
	object._trove = Trove.new()
	object._offscreen = Instance.new("Folder")
	object._offscreen.Name = "gridOffscreen"
	object._offscreen.Parent = script
	object._trove:Add(object._scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		object:Refresh(false)
	end))
	object._trove:Add(object._scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		for _, _entry in object._entries do
			_entry.cachedIndex = nil
		end

		object:Refresh(true)
	end))
	return object
end

function BestiaryGrid:_getCellSize()
	local absoluteSize = self._scroll.AbsoluteSize
	return absoluteSize.X * self._config.widthScale, absoluteSize.Y * self._config.heightScale
end

function BestiaryGrid:_getColumnStride()
	local X = self._scroll.AbsoluteSize.X
	return X * self._config.widthScale + X * self._columnGap
end

function BestiaryGrid:_getRowStride()
	local _, v = self:_getCellSize()
	return v + self._scroll.AbsoluteSize.Y * self._rowGap
end

function BestiaryGrid:_getVisibleRange(p: number)
	local count = #self._displayed

	if count == 0 then
		return 1, 0
	end

	local _getRowStride = self:_getRowStride()

	if _getRowStride <= 0 then
		return 1, 0
	end

	local Y = self._scroll.AbsoluteSize.Y
	local v = math.max(0, p - Y)
	local v2 = math.clamp(self._scroll.CanvasPosition.Y, 0, v)
	local v3 = math.max(0, math.floor(v2 / _getRowStride) - self._buffer)
	local v4 = math.ceil((v2 + Y) / _getRowStride) + self._buffer
	return math.max(1, v3 * self._columns + 1), (math.min(count, (v4 + 1) * self._columns))
end

function BestiaryGrid:_position(state, cachedIndex: number)
	if state.cachedIndex == cachedIndex then
		return
	end

	state.cachedIndex = cachedIndex
	local frame = state.Frame

	if not frame then
		return
	end

	local _getCellSize, v = self:_getCellSize()
	local _getColumnStride = self:_getColumnStride()
	local _getRowStride = self:_getRowStride()
	local v2 = (cachedIndex - 1) // self._columns
	local v3 = (cachedIndex - 1) % self._columns
	frame.Size = UDim2.fromOffset(_getCellSize, v)
	frame.Position = UDim2.fromOffset(v3 * _getColumnStride, v2 * _getRowStride)
end

function BestiaryGrid:_ensureFrame(state)
	local frame = state.Frame

	if frame then
		return frame
	end

	local clone = self._config.cardTemplate:Clone()
	clone.AnchorPoint = Vector2.new(0, 0)
	clone.Name = state.key
	state.Frame = clone
	local key = state.key
	state.trove:Add(connectActivated(clone, function()
		self._config.onSelect(key)
	end))
	return clone
end

function BestiaryGrid:_mount(state, p: number)
	local _ensureFrame = self:_ensureFrame(state)
	self:_position(state, p)

	if not state.mounted then
		state.mounted = true
		_ensureFrame.Parent = self._scroll
		self._config.renderCard(_ensureFrame, state.key)
	end
end

function BestiaryGrid:_unmount(state)
	if not state.mounted then
		return
	end

	state.mounted = false
	local frame = state.Frame

	if frame then
		if self._config.onUnmount then
			self._config.onUnmount(frame)
		end

		frame.Parent = self._offscreen
	end
end

function BestiaryGrid:Refresh(flag: boolean?)
	local v = #self._displayed
	local _getRowStride = self:_getRowStride()
	local lastCanvasSize = math.max(0, math.ceil(v / self._columns) * _getRowStride)

	if lastCanvasSize > 0 then
		lastCanvasSize += self._scroll.AbsoluteSize.Y * self._bottomPadding
	end

	if self._lastCanvasSize ~= lastCanvasSize then
		self._lastCanvasSize = lastCanvasSize
		self._scroll.CanvasSize = UDim2.new(0, 0, 0, lastCanvasSize)
	end

	local _getVisibleRange, lastLast = self:_getVisibleRange(lastCanvasSize)

	if not flag and _getVisibleRange == self._lastFirst and lastLast == self._lastLast then
		return
	end

	local v4 = {}

	for i = _getVisibleRange, lastLast do
		local v5 = self._displayed[i]

		if v5 then
			v4[v5] = true
		end
	end

	if flag then
		for _, _entry in self._entries do
			if not _entry.mounted or v4[_entry] then
				continue
			end

			self:_unmount(_entry)
		end
	else
		for i = self._lastFirst, self._lastLast do
			if not (i < _getVisibleRange or lastLast < i) then
				continue
			end

			local v5 = self._displayed[i]

			if v5 and v5.mounted then
				self:_unmount(v5)
			end
		end
	end

	for i = _getVisibleRange, lastLast do
		local v5 = self._displayed[i]

		if not v5 then
			continue
		end

		if v5.mounted then
			self:_position(v5, i)
		else
			self:_mount(v5, i)
		end
	end

	self._lastFirst = _getVisibleRange
	self._lastLast = lastLast
end

function BestiaryGrid:_rebuildDisplayed()
	table.clear(self._displayed)

	for _, v in self._order do
		local _entry = self._entries[v]

		if _entry and _entry.searchVisible then
			table.insert(self._displayed, _entry)
		end
	end

	for _, _entry in self._entries do
		_entry.cachedIndex = nil
	end

	self:Refresh(true)
end

function BestiaryGrid:SetKeys(p)
	for _, _entry in self._entries do
		_entry.trove:Destroy()

		if _entry.Frame then
			_entry.Frame:Destroy()
		end
	end

	table.clear(self._entries)
	table.clear(self._order)
	self._lastFirst = 0
	self._lastLast = -1
	self._lastCanvasSize = nil
	self._order = table.clone(p)

	if self._config.comparator then
		table.sort(self._order, self._config.comparator)
	end

	for _, v in self._order do
		self._entries[v] = {
			key = v,
			searchVisible = true,
			mounted = false,
			cachedIndex = nil,
			trove = Trove.new()
		}
	end

	self._scroll.CanvasPosition = Vector2.new(0, 0)

	if self._predicate then
		self:ApplySearch(self._predicate)
	else
		self:_rebuildDisplayed()
	end
end

function BestiaryGrid:ApplySearch(predicate)
	self._predicate = predicate

	for k, _entry in self._entries do
		_entry.searchVisible = predicate(k)
	end

	self:_rebuildDisplayed()
end

function BestiaryGrid:RefreshVisuals()
	for _, _entry in self._entries do
		if _entry.mounted and _entry.Frame then
			self._config.renderCard(_entry.Frame, _entry.key)
		end
	end
end

function BestiaryGrid:Destroy()
	for _, _entry in self._entries do
		_entry.trove:Destroy()

		if _entry.Frame then
			_entry.Frame:Destroy()
		end
	end

	table.clear(self._entries)
	table.clear(self._order)
	table.clear(self._displayed)
	self._trove:Destroy()
	self._offscreen:Destroy()
end

return BestiaryGrid