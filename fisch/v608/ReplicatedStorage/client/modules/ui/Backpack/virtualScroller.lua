local function virtualScroller(data)
	local scrollingFrame = data.scrollingFrame
	local v = {}
	local buf = buffer.create(32)
	local v2 = nil
	local absoluteSize = scrollingFrame.AbsoluteSize
	local absoluteCanvasSize = scrollingFrame.AbsoluteCanvasSize
	local absoluteWindowSize = scrollingFrame.AbsoluteWindowSize
	local canvasPosition = scrollingFrame.CanvasPosition

	local function updateGrid(p)
		local itemSize = data.getItemSize()
		local itemPadding = data.getItemPadding()
		local v3 = math.clamp(canvasPosition.Y, 0, (math.max(1, absoluteCanvasSize.Y - absoluteWindowSize.Y)))
		local maxItems = data.maxItems()
		local v4 = (absoluteSize.X + itemPadding) // (itemSize + itemPadding)
		local v5 = v3 // (itemSize + itemPadding)
		local v6 = v5 + math.ceil(absoluteSize.Y / (itemSize + itemPadding))
		buffer.writef64(buf, 0, v5)
		buffer.writef64(buf, 8, v6)
		buffer.writef64(buf, 16, v4)
		buffer.writef64(buf, 24, maxItems)

		if v2 == buffer.tostring(buf) then
			if p then
				data.reconcile(v, v4)
			end
		else
			v2 = buffer.tostring(buf)
			local count = 0

			for i = v5, v6 do
				if count == data then
					break
				end

				for i2 = 1, v4 do
					count += 1
					v[count] = i * v4 + i2

					if count == maxItems then
						break
					end
				end
			end

			for i = count + 1, #v do
				v[i] = nil
			end

			local v7 = math.ceil(maxItems / v4) * (itemSize + itemPadding)
			scrollingFrame.CanvasSize = UDim2.fromOffset(0, v7 + itemSize)
			data.reconcile(v, v4)
		end
	end

	updateGrid(true)
	scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		absoluteSize = scrollingFrame.AbsoluteSize
		updateGrid()
	end)
	scrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		absoluteCanvasSize = scrollingFrame.AbsoluteCanvasSize
		updateGrid()
	end)
	scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		absoluteWindowSize = scrollingFrame.AbsoluteWindowSize
		updateGrid()
	end)
	scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		canvasPosition = scrollingFrame.CanvasPosition
		updateGrid(true)
	end)
	return updateGrid
end

return virtualScroller