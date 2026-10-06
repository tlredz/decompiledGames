local TweenService = game:GetService("TweenService")
local v = {
	CalculateItemSize = function(self)
		local nativeLayout = self.NativeLayout
		local size = self.Template.Size
		local absoluteSize = self.List.AbsoluteSize
		local vector, vector2

		if nativeLayout and nativeLayout:IsA("UIListLayout") then
			local padding = nativeLayout.Padding
			vector = Vector2.new(
				size.X.Scale * absoluteSize.X + size.X.Offset,
				size.Y.Scale * absoluteSize.Y + size.Y.Offset
			)
			vector2 = Vector2.new(
				padding.Scale * absoluteSize.X + padding.Offset,
				padding.Scale * absoluteSize.Y + padding.Offset
			)
		elseif nativeLayout and nativeLayout:IsA("UIGridLayout") then
			local cellSize = nativeLayout.CellSize
			local cellPadding = nativeLayout.CellPadding
			vector = Vector2.new(
				cellSize.X.Scale * absoluteSize.X + cellSize.X.Offset,
				cellSize.Y.Scale * absoluteSize.Y + cellSize.Y.Offset
			)
			vector2 = Vector2.new(
				cellPadding.X.Scale * absoluteSize.X + cellPadding.X.Offset,
				cellPadding.Y.Scale * absoluteSize.Y + cellPadding.Y.Offset
			)
		else
			vector = Vector2.new(
				size.X.Scale * absoluteSize.X + size.X.Offset,
				size.Y.Scale * absoluteSize.Y + size.Y.Offset
			)
			vector2 = Vector2.new(0, 0)
		end

		if vector then
			self.ItemSize = vector
		end

		if vector2 then
			self.ItemPadding = vector2
		end

		self.HorizontalAlignment = nativeLayout and nativeLayout.HorizontalAlignment or Enum.HorizontalAlignment.Left
		self.VerticalAlignment = nativeLayout and nativeLayout.VerticalAlignment or Enum.VerticalAlignment.Top
	end,
	_TotalItemSize = function(self)
		if self.ItemPadding then
			return Vector2.new(self.ItemSize.X + self.ItemPadding.X, self.ItemSize.Y + self.ItemPadding.Y)
		end

		return Vector2.new(self.ItemSize.X, self.ItemSize.Y)
	end,
	_Metrics = function(self)
		if not self.ItemSize then
			self:CalculateItemSize()
		end

		if not self.ItemSize then
			return nil
		end

		local absoluteSize = self.List.AbsoluteSize

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return nil
		end

		local _TotalItemSize = self:_TotalItemSize()
		local itemsPerRow = math.max(1, (math.floor(absoluteSize.X / _TotalItemSize.X)))
		local count = #self.Items
		local rowCount = not (count > 0) and 0 or math.ceil(count / itemsPerRow)
		local v4 = rowCount * _TotalItemSize.Y
		local v5 = self.VerticalAlignment == Enum.VerticalAlignment.Center and 0.5 or self.VerticalAlignment == Enum.VerticalAlignment.Bottom and 1 or 0
		local contentBaseY = math.max(0, absoluteSize.Y - v4) * v5
		return {
			ViewportSize = absoluteSize,
			TotalItemSize = _TotalItemSize,
			ItemsPerRow = itemsPerRow,
			TotalItems = count,
			RowCount = rowCount,
			ContentBaseY = contentBaseY,
			CanvasHeight = math.max(absoluteSize.Y, contentBaseY + v4),
			HorizontalFactor = self.HorizontalAlignment == Enum.HorizontalAlignment.Center and 0.5 or self.HorizontalAlignment == Enum.HorizontalAlignment.Right and 1 or 0
		}
	end,
	_GetItemRect = function(self, data, p2: number)
		if p2 < 1 or data.TotalItems < p2 then
			return nil
		end

		local v2 = math.floor((p2 - 1) / data.ItemsPerRow)
		local v3 = (p2 - 1) % data.ItemsPerRow
		local v4 = v2 * data.ItemsPerRow + 1
		local v5 = math.min(data.TotalItems, v4 + data.ItemsPerRow - 1) - v4 + 1
		local v6 = not self.ItemPadding and 0 or self.ItemPadding.X or 0
		local v7 = v5 * self.ItemSize.X + math.max(0, v5 - 1) * v6
		return {
			X = math.max(0, data.ViewportSize.X - v7) * data.HorizontalFactor + v3 * data.TotalItemSize.X,
			Y = data.ContentBaseY + v2 * data.TotalItemSize.Y
		}
	end,
	_CreateItem = function(self)
		if self.MaxPoolSize and self.TotalFrames >= self.MaxPoolSize then
			return nil
		end

		local clone = self.Template:Clone()
		clone.AnchorPoint = Vector2.new(0, 0)
		self.TotalFrames += 1
		return clone
	end,
	_ReleaseItem = function(self, instance)
		if self.ReleaseCallback then
			self.ReleaseCallback(instance)
		end

		if self.MaxPoolSize and #self.FramePool >= self.MaxPoolSize then
			instance:Destroy()
			self.TotalFrames -= 1
		else
			instance.Visible = false
			table.insert(self.FramePool, instance)
		end
	end,
	_Render = function(self, items)
		for _, item in items do
			if item.Item and item.Item.Parent then
				self.RenderCallback(item.ID, item.Item)
			end
		end
	end,
	RenderID = function(p, p2: string)
		local v2 = p.Pool[p2]

		if not v2 then
			return
		end

		p.RenderCallback(p2, v2)
	end,
	RenderAll = function(p)
		for k, v2 in p.Pool do
			p.RenderCallback(k, v2)
		end
	end,
	GetVisibleItemCount = function(p)
		local count = 0

		for _ in p.Pool do
			count += 1
		end

		return count
	end,
	GetItemsPerRow = function(self)
		local _Metrics = self:_Metrics()
		return _Metrics and _Metrics.ItemsPerRow or 0
	end,
	GetRowCount = function(self)
		local _Metrics = self:_Metrics()
		return _Metrics and _Metrics.RowCount or 0
	end,
	ScrollToID = function(self, p: string, flag: boolean?, value: string?)
		local _Metrics = self:_Metrics()

		if not _Metrics then
			return
		end

		local v2 = nil

		for k, item in self.Items do
			if item ~= p then
				continue
			end

			v2 = k
			break
		end

		if not v2 then
			return
		end

		local _GetItemRect = self:_GetItemRect(_Metrics, v2)

		if not _GetItemRect then
			return
		end

		local v4 = value or "Top"
		local Y = _GetItemRect.Y

		if v4 == "Center" then
			Y -= math.max(0, (_Metrics.ViewportSize.Y - self.ItemSize.Y) * 0.5)
		elseif v4 == "Bottom" then
			Y -= math.max(0, _Metrics.ViewportSize.Y - self.ItemSize.Y)
		end

		local v5 = math.clamp(Y, 0, (math.max(0, _Metrics.CanvasHeight - _Metrics.ViewportSize.Y)))
		local vector = Vector2.new(self.List.CanvasPosition.X, v5)

		if flag then
			TweenService:Create(self.List, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CanvasPosition = vector
			}):Play()
		else
			self.List.CanvasPosition = vector
		end
	end,
	Suspend = function(self)
		if self.Suspended then
			return
		end

		self.Suspended = true
		self._LastStartIndex = nil
		self._LastEndIndex = nil

		for k, v2 in self.Pool do
			self.Pool[k] = nil
			self:_ReleaseItem(v2)
		end
	end,
	Resume = function(p)
		p.Suspended = nil
	end,
	Update = function(self)
		if self.IsUpdating or self.Suspended then
			return
		end

		local _Metrics = self:_Metrics()

		if not _Metrics then
			return
		end

		self.IsUpdating = true
		self.List.CanvasSize = UDim2.fromOffset(0, _Metrics.CanvasHeight)

		if _Metrics.TotalItems == 0 or _Metrics.ItemsPerRow <= 0 then
			self._LastStartIndex = nil
			self._LastEndIndex = nil

			for k, v2 in self.Pool do
				self.Pool[k] = nil
				self:_ReleaseItem(v2)
			end

			self.IsUpdating = nil
		else
			local canvasPosition = self.List.CanvasPosition
			local Y = _Metrics.TotalItemSize.Y
			local v2 = (self.BufferRows or math.ceil(_Metrics.ViewportSize.Y / Y)) * Y
			local v3 = math.max(0, (math.floor((canvasPosition.Y - _Metrics.ContentBaseY - v2) / Y)))
			local v4 = math.min(
				_Metrics.RowCount - 1,
				(math.floor((canvasPosition.Y + _Metrics.ViewportSize.Y - _Metrics.ContentBaseY + v2 - 1) / Y))
			)

			if v4 < v3 then
				self._LastStartIndex = nil
				self._LastEndIndex = nil

				for k, v5 in self.Pool do
					self.Pool[k] = nil
					self:_ReleaseItem(v5)
				end

				self.IsUpdating = nil
			else
				local lastStartIndex = v3 * _Metrics.ItemsPerRow + 1
				local lastEndIndex = math.min(_Metrics.TotalItems, (v4 + 1) * _Metrics.ItemsPerRow)
				local v7 = self.Items ~= self._LastItems
				local v8 = self._LastItemSize ~= self.ItemSize or self._LastItemsPerRow ~= _Metrics.ItemsPerRow
				self._LastItems = self.Items
				self._LastItemSize = self.ItemSize
				self._LastItemsPerRow = _Metrics.ItemsPerRow

				if not v7 and not v8 and self._LastStartIndex == lastStartIndex and self._LastEndIndex == lastEndIndex then
					self.IsUpdating = nil
					return
				end

				self._LastStartIndex = lastStartIndex
				self._LastEndIndex = lastEndIndex
				local v9 = {}
				local v10 = {}
				local v11 = {}

				for i = lastStartIndex, lastEndIndex do
					local item = self.Items[i]

					if item then
						v9[item] = i
					end
				end

				for k, v12 in self.Pool do
					if v9[k] then
						continue
					end

					table.insert(v10, v12)
					self.Pool[k] = nil
				end

				for k, v12 in v9 do
					local v13 = self.Pool[k]

					if not v13 then
						v13 = table.remove(v10, 1) or table.remove(self.FramePool) or self:_CreateItem()

						if not v13 then
							continue
						end

						v13.Name = "Item"
						v13.Visible = false
						v13.Parent = self.List
						self.Pool[k] = v13
					end

					local _GetItemRect = self:_GetItemRect(_Metrics, v12)

					if _GetItemRect then
						v13.Position = UDim2.fromOffset(_GetItemRect.X, _GetItemRect.Y)
						v13.Size = UDim2.fromOffset(self.ItemSize.X, self.ItemSize.Y)
					end

					table.insert(v11, {
						ID = k,
						Item = v13
					})
				end

				for _, v12 in v10 do
					self:_ReleaseItem(v12)
				end

				if #v11 > 0 then
					self:_Render(v11)
				end

				self.IsUpdating = nil
			end
		end
	end,
	Destroy = function(self)
		for _, connection in self.Connections do
			connection:Disconnect()
		end

		table.clear(self.Connections)

		for _, v2 in self.Pool do
			v2:Destroy()
		end

		table.clear(self.Pool)

		for _, v2 in self.FramePool do
			v2:Destroy()
		end

		table.clear(self.FramePool)
		self.TotalFrames = 0

		if self.NativeLayout then
			self.NativeLayout:Destroy()
			self.NativeLayout = nil
		end
	end
}
return table.freeze({
	New = function(data)
		if not data or typeof(data) ~= "table" or (not data.Render or typeof(data.Render) ~= "function") then
			return
		end

		if data.Release and typeof(data.Release) ~= "function" then
			return
		end

		if not data.List or typeof(data.List) ~= "Instance" or not data.List:IsA("ScrollingFrame") then
			return
		end

		if not data.Template or typeof(data.Template) ~= "Instance" or not data.Template:IsA("GuiObject") then
			return
		end

		local object = setmetatable({}, {
			__index = v
		})
		object.List = data.List
		object.Template = data.Template
		object.RenderCallback = data.Render
		object.ReleaseCallback = data.Release
		object.BufferRows = data.BufferRows
		object.MaxPoolSize = data.MaxPoolSize
		object.Pool = {}
		object.Items = {}
		object.Connections = {}
		object.FramePool = {}
		object.TotalFrames = 0
		object.NativeLayout = data.List:FindFirstChildOfClass("UIListLayout") or data.List:FindFirstChildOfClass("UIGridLayout")

		if object.NativeLayout then
			object.NativeLayout.Parent = nil
		end

		object.List.AutomaticCanvasSize = Enum.AutomaticSize.None
		object.List.ClipsDescendants = true
		object.Connections.Position = data.List:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			object:Update()
		end)
		object.Connections.Size = data.List:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			object:CalculateItemSize()
			object:Update()
		end)
		return object
	end
})