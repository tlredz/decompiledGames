local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Trove)
local uDim = UDim2.fromScale(0, 0)

local function isStaticEntry(p)
	return p.Static ~= nil
end

local function create(data)
	local scrollingFrame = assert(data.Container, "Expected config.Container to exist")
	assert(scrollingFrame:IsA("ScrollingFrame"), "Expected config.Container to be a ScrollingFrame")
	local padding = data.Padding or 0
	local layout = data.Layout
	local maid = v.new()
	local flag = true

	local function markDirty()
		flag = true
	end

	local folder = Instance.new("Folder")
	folder.Name = "VirtualSlots"
	folder.Parent = scrollingFrame
	maid:Add(folder)
	local uIListLayout = scrollingFrame:FindFirstChildWhichIsA("UIListLayout")

	if uIListLayout then
		local parent = uIListLayout.Parent
		uIListLayout.Parent = nil
		maid:Add(function()
			if parent and parent.Parent then
				uIListLayout.Parent = parent
			end
		end)
	end

	local automaticCanvasSize = scrollingFrame.AutomaticCanvasSize
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
	maid:Add(function()
		if scrollingFrame.Parent then
			scrollingFrame.AutomaticCanvasSize = automaticCanvasSize
		end
	end)
	local v2 = {}

	local function getSlot(instance)
		local v3 = v2[instance]
		local v4 = v3 and table.remove(v3)

		if v4 then
			v4.Visible = true
			return v4
		end

		local clone = instance:Clone()
		clone.Visible = true
		clone.Parent = folder
		return clone
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function returnSlot(template, slot)
		slot.Visible = false
		local v3 = v2[template]

		if not v3 then
			v3 = {}
			v2[template] = v3
		end

		table.insert(v3, slot)
	end

	local v3 = {}
	local v4 = {}

	for _, config in layout do
		if config.Static ~= nil then
			local static = config.Static
			local v6 = {
				Kind = "Static",
				Config = config,
				Static = static,
				OriginalPosition = static.Position,
				OriginalAnchorPoint = static.AnchorPoint,
				StartY = 0,
				EndY = 0
			}
			static.AnchorPoint = Vector2.new(0.5, 0)
			maid:Add(function()
				if static.Parent then
					static.Position = v6.OriginalPosition
					static.AnchorPoint = v6.OriginalAnchorPoint
				end
			end)
			maid:Add(static:GetPropertyChangedSignal("Visible"):Connect(markDirty))
			maid:Add(static:GetPropertyChangedSignal("AbsoluteSize"):Connect(markDirty))
			table.insert(v3, v6)
		else
			assert(config.Id, "Grid section requires an Id")
			local container = assert(config.Container, (`Section "{config.Id}" missing Container`))
			local gridLayout = assert(
				container:FindFirstChildWhichIsA("UIGridLayout"),
				(`Section "{config.Id}" container has no UIGridLayout`)
			)
			local anchor = config.Anchor

			if not anchor and type(config.Template) ~= "function" then
				anchor = config.Template.AnchorPoint
			end

			local point = anchor or Vector2.zero
			local v8 = {
				Kind = "Grid",
				Id = config.Id,
				Config = config,
				Container = container,
				GridLayout = gridLayout,
				Items = {},
				Membership = {},
				Rendered = {},
				ContainerOriginalVisible = container.Visible,
				ContainerOriginalSize = container.Size,
				Anchor = point,
				DeferSortThread = nil,
				StartY = 0,
				EndY = 0,
				Cols = 1,
				CellWidth = 0,
				CellHeight = 0,
				InnerCellSize = uDim,
				OffsetX = 0,
				PrefixCount = 0
			}

			for _, propertyName in { "CellSize", "CellPadding", "HorizontalAlignment" } do
				maid:Add(gridLayout:GetPropertyChangedSignal(propertyName):Connect(markDirty))
			end

			container.Visible = false
			container.Size = UDim2.new()
			maid:Add(function()
				if container.Parent then
					container.Visible = v8.ContainerOriginalVisible
					container.Size = v8.ContainerOriginalSize
				end
			end)
			local prefix = config.Prefix

			if prefix then
				for _, v11 in prefix do
					v11.AnchorPoint = point
					v11.Parent = folder
					maid:Add(v11:GetPropertyChangedSignal("Visible"):Connect(markDirty))
				end

				local parent = container
				local prefix2 = prefix
				maid:Add(function()
					if parent.Parent then
						for k, v13 in prefix2 do
							if v13.Parent == folder then
								v13.Parent = parent
							end
						end
					end
				end)
			end

			table.insert(v3, v8)
			v4[config.Id] = v8
		end
	end

	local function applySort(p)
		if p.Config.Sort and #p.Items > 1 then
			debug.profilebegin("SectionedVirtualScroll::Sort")
			table.sort(p.Items, p.Config.Sort)
			debug.profileend()
		end

		flag = true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function deferSort(p)
		if p.DeferSortThread then
			return
		end

		p.DeferSortThread = task.defer(function()
			p.DeferSortThread = nil
			applySort(p)
		end)
	end

	local function destroyRendered(p, p2: number)
		local v5 = p.Rendered[p2]

		if not v5 then
			return
		end

		p.Rendered[p2] = nil

		if v5.Destructor then
			xpcall(v5.Destructor, function(p3)
				local traceback = debug.traceback(p3, 3)
				task.spawn(error, traceback)
			end)
		end

		returnSlot(v5.Template, v5.Slot) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function destroyAllRendered(p)
		for k in p.Rendered do
			destroyRendered(p, k)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function findRenderedCellForItem(p, p2)
		for k, v5 in p.Rendered do
			if v5.Item == p2 then
				return k
			end
		end

		return nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function findItemIndex(p, p2)
		for k, item in p.Items do
			if item == p2 then
				return k
			end
		end

		return nil
	end

	local guiObject = scrollingFrame:FindFirstAncestorWhichIsA("GuiObject")
	local layerCollector = scrollingFrame:FindFirstAncestorWhichIsA("LayerCollector")
	maid:Add(scrollingFrame.AncestryChanged:Connect(function()
		guiObject = scrollingFrame:FindFirstAncestorWhichIsA("GuiObject")
		layerCollector = scrollingFrame:FindFirstAncestorWhichIsA("LayerCollector")
		flag = true
	end))

	for _, propertyName in {
		"CanvasPosition",
		"AbsoluteSize",
		"AbsoluteWindowSize",
		"Visible",
		"ScrollBarThickness",
		"VerticalScrollBarInset",
		"HorizontalScrollBarInset"
	} do
		maid:Add(scrollingFrame:GetPropertyChangedSignal(propertyName):Connect(markDirty))
	end

	if layerCollector then
		maid:Add(layerCollector:GetPropertyChangedSignal("Enabled"):Connect(markDirty))
	end

	local canvasPosition = nil
	maid:Add(RunService.PreRender:Connect(function()
		if not flag then
			return
		end

		flag = false

		if guiObject and layerCollector and layerCollector.Enabled and scrollingFrame.Visible then
			debug.profilebegin((`SectionedVirtualScroll::Update {scrollingFrame:GetFullName()}`))
			debug.profilebegin("Layout")
			local absoluteSize = scrollingFrame.AbsoluteSize
			local absoluteWindowSize = scrollingFrame.AbsoluteWindowSize
			local scrollBarThickness = scrollingFrame.ScrollBarThickness
			local X = absoluteWindowSize.X
			local Y = absoluteWindowSize.Y

			if scrollingFrame.VerticalScrollBarInset == Enum.ScrollBarInset.Always and absoluteSize.X <= X then
				X = math.max(0, absoluteSize.X - scrollBarThickness)
			end

			if scrollingFrame.HorizontalScrollBarInset == Enum.ScrollBarInset.Always and absoluteSize.Y <= Y then
				Y = math.max(0, absoluteSize.Y - scrollBarThickness)
			end

			local total = 0
			local endY = 0
			local v5 = true

			for _, v6 in v3 do
				local Y2 = 0

				if v6.Kind == "Static" then
					if v6.Static.Visible then
						Y2 = v6.Static.AbsoluteSize.Y
					end
				else
					local gridLayout = v6.GridLayout
					local cellSize = gridLayout.CellSize
					local cellPadding = gridLayout.CellPadding
					local horizontalAlignment = gridLayout.HorizontalAlignment
					local v7 = cellSize.X.Offset + cellSize.X.Scale * X
					local v8 = cellSize.Y.Offset + cellSize.Y.Scale * Y
					local v9 = cellPadding.X.Offset + cellPadding.X.Scale * X
					local v10 = cellPadding.Y.Offset + cellPadding.Y.Scale * Y
					local uIAspectRatioConstraint = gridLayout:FindFirstChildWhichIsA("UIAspectRatioConstraint")

					if uIAspectRatioConstraint then
						local aspectRatio = uIAspectRatioConstraint.AspectRatio

						if aspectRatio > 0 then
							if uIAspectRatioConstraint.DominantAxis == Enum.DominantAxis.Width then
								v8 = v7 / aspectRatio
							else
								v7 = v8 * aspectRatio
							end
						end
					end

					local cellWidth = v7 + v9
					local cellHeight = v8 + v10
					local v13 = not (cellWidth > 0) and 1 or math.floor((X + v9) / cellWidth)
					local cols = v13 < 1 and 1 or v13
					local prefix = v6.Config.Prefix
					local count = 0

					if prefix then
						for _, v15 in prefix do
							if v15.Visible then
								count += 1
							end
						end
					end

					v6.PrefixCount = count
					local v15 = count + #v6.Items

					if v15 > 0 then
						local v16 = -(v15 // -cols) * cellHeight - v10
						Y2 = v16 < 0 and 0 or v16
						total += v15
					end

					local offsetX = v6.Anchor.X * cellWidth

					if horizontalAlignment == Enum.HorizontalAlignment.Center then
						offsetX += (X - cellWidth * cols) * 0.5
					elseif horizontalAlignment == Enum.HorizontalAlignment.Right then
						offsetX += X - cellWidth * cols
					end

					v6.Cols = cols
					v6.CellWidth = cellWidth
					v6.CellHeight = cellHeight
					v6.OffsetX = offsetX
					v6.InnerCellSize = UDim2.fromOffset(v7, v8)
				end

				if Y2 <= 0 then
					v6.StartY = endY
					v6.EndY = endY
				else
					if not v5 then
						endY += padding
					end

					v6.StartY = endY
					v6.EndY = endY + Y2
					endY = v6.EndY
					v5 = false
				end
			end

			if total <= 0 then
				scrollingFrame.CanvasSize = uDim

				for _, v6 in v3 do
					if v6.Kind ~= "Grid" then
						continue
					end

					destroyAllRendered(v6) -- equivalent call inferred; original call site unknown
				end

				if not canvasPosition then
					canvasPosition = scrollingFrame.CanvasPosition
				end

				debug.profileend()
				debug.profileend()
			else
				scrollingFrame.CanvasSize = UDim2.fromOffset(0, endY)

				if canvasPosition then
					scrollingFrame.CanvasPosition = canvasPosition
					canvasPosition = nil
				end

				local Y2 = scrollingFrame.CanvasPosition.Y
				local v6 = Y2 + absoluteWindowSize.Y
				debug.profileend()
				debug.profilebegin("Render")

				for _, v7 in v3 do
					if v7.Kind == "Static" then
						if v7.Static.Visible then
							v7.Static.Position = UDim2.new(0.5, 0, 0, v7.StartY)
						end
					elseif v7.EndY < Y2 or v6 < v7.StartY then
						destroyAllRendered(v7) -- equivalent call inferred; original call site unknown
					else
						local cols = v7.Cols
						local cellWidth = v7.CellWidth
						local cellHeight = v7.CellHeight
						local innerCellSize = v7.InnerCellSize
						local offsetX = v7.OffsetX
						local anchor = v7.Anchor
						local startY = v7.StartY
						local prefix = v7.Config.Prefix
						local prefixCount = v7.PrefixCount
						local items = v7.Items
						local v8 = prefixCount + #items

						if v8 <= 0 then
							destroyAllRendered(v7) -- equivalent call inferred; original call site unknown
						else
							local v9 = math.max(0, Y2 - startY)
							local v10 = math.max(0, v6 - startY)
							local v11 = math.max(0, v9 // cellHeight - 1)
							local v12 = v10 // cellHeight + 1
							local v13 = math.clamp(v11 * cols + 1, 1, v8)
							local v14 = math.clamp((v12 + 1) * cols, v13, v8)
							debug.profilebegin("DestroyOutOfBounds")

							for k in v7.Rendered do
								if k < v13 or v14 < k then
									destroyRendered(v7, k)
								end
							end

							debug.profileend()
							debug.profilebegin("FixMismatched")

							for i = v13, v14 do
								if i <= prefixCount then
									continue
								end

								local v15 = v7.Rendered[i]

								if not v15 then
									continue
								end

								local item = items[i - prefixCount]

								if v15.Item == item then
									continue
								end

								local v16 = nil

								for i2 = v13, v14 do
									if i2 == i then
										continue
									end

									local v17 = v7.Rendered[i2]

									if not (v17 and v17.Item == item) then
										continue
									end

									v16 = i2
									break
								end

								if v16 then
									local v17 = v7.Rendered[v16]
									v7.Rendered[i] = v17
									v7.Rendered[v16] = v15
								else
									destroyRendered(v7, i)
								end
							end

							debug.profileend()
							debug.profilebegin("RenderPrefix")

							if prefixCount > 0 and prefix then
								local count = 0

								for _, v15 in prefix do
									if not v15.Visible then
										continue
									end

									local v16 = count // cols
									local v17 = count % cols
									local v18 = startY + v16 * cellHeight + anchor.Y * cellHeight
									local v19 = offsetX + v17 * cellWidth
									v15.Position = UDim2.fromOffset(v19, v18)
									v15.Size = innerCellSize
									count += 1
								end
							end

							debug.profileend()
							debug.profilebegin("RenderItems")

							for i = math.max(v13, prefixCount + 1), v14 do
								local item = items[i - prefixCount]

								if not item then
									continue
								end

								local v15 = v7.Rendered[i]

								if not v15 then
									local template

									if type(v7.Config.Template) == "function" then
										template = v7.Config.Template(item)
									else
										template = v7.Config.Template
									end

									local v16 = v2[template]
									local clone = v16 and table.remove(v16)

									if clone then
										clone.Visible = true
									else
										clone = template:Clone()
										clone.Visible = true
										clone.Parent = folder
									end

									local destructor

									if v7.Config.Constructor then
										destructor = v7.Config.Constructor(item, clone, i)
									end

									v15 = {
										Slot = clone,
										Template = template,
										Destructor = destructor,
										Item = item
									}
									v7.Rendered[i] = v15
								end

								local slot = v15.Slot
								local v16 = (i - 1) // cols
								local v17 = (i - 1) % cols
								local v18 = startY + v16 * cellHeight + anchor.Y * cellHeight
								local v19 = offsetX + v17 * cellWidth
								slot.Name = tostring(i)
								slot.Size = innerCellSize
								slot.Position = UDim2.fromOffset(v19, v18)
							end

							debug.profileend()
						end
					end
				end

				debug.profileend()
				debug.profileend()
			end
		else
			if not canvasPosition then
				canvasPosition = scrollingFrame.CanvasPosition
			end

			scrollingFrame.CanvasSize = uDim
		end
	end))
	maid:Add(function()
		for _, v5 in v4 do
			destroyAllRendered(v5) -- equivalent call inferred; original call site unknown
		end

		table.clear(v2)
	end)

	local function addInstance(p: string, p2)
		local v5 = v4[p]
		assert(v5, (`Unknown sectionId "{p}"`))

		if not v5.Membership[p2] then
			v5.Membership[p2] = true
			table.insert(v5.Items, p2)
			deferSort(v5) -- equivalent call inferred; original call site unknown
			flag = true
		end

		return function()
			local itemIndex = findItemIndex(v5, p2) -- equivalent call inferred; original call site unknown

			if itemIndex then
				table.remove(v5.Items, itemIndex)
				v5.Membership[p2] = nil
				deferSort(v5) -- equivalent call inferred; original call site unknown
				flag = true
			end

			local renderedCellForItem = findRenderedCellForItem(v5, p2) -- equivalent call inferred; original call site unknown

			if renderedCellForItem then
				destroyRendered(v5, renderedCellForItem)
			end
		end
	end

	local function removeInstance(p: string, p2)
		local v5 = v4[p]
		assert(v5, (`Unknown sectionId "{p}"`))
		local itemIndex = findItemIndex(v5, p2) -- equivalent call inferred; original call site unknown

		if itemIndex then
			table.remove(v5.Items, itemIndex)
			v5.Membership[p2] = nil
			deferSort(v5) -- equivalent call inferred; original call site unknown
			flag = true
		end

		local renderedCellForItem = findRenderedCellForItem(v5, p2) -- equivalent call inferred; original call site unknown

		if renderedCellForItem then
			destroyRendered(v5, renderedCellForItem)
		end
	end

	local function moveInstance(p, p2: string, p3: string)
		if p2 == p3 then
			return
		end

		removeInstance(p2, p)
		addInstance(p3, p)
	end

	local function setItems(p: string, items)
		local v5 = v4[p]
		assert(v5, (`Unknown sectionId "{p}"`))
		table.clear(v5.Items)
		table.clear(v5.Membership)

		for _, item in items do
			if v5.Membership[item] then
				continue
			end

			v5.Membership[item] = true
			table.insert(v5.Items, item)
		end

		applySort(v5)
	end

	local function invalidate(p)
		for _, v5 in v4 do
			for k, v6 in v5.Rendered do
				if p == nil or v6.Item == p then
					destroyRendered(v5, k)
				end
			end
		end

		flag = true
	end

	local function sortPublic(p: string?)
		if p then
			local v5 = v4[p]

			if v5 then
				deferSort(v5) -- equivalent call inferred; original call site unknown
			end
		else
			for _, v5 in v4 do
				deferSort(v5) -- equivalent call inferred; original call site unknown
			end
		end
	end

	local function getRenderedSlot(p)
		for _, v5 in v4 do
			for _, v6 in v5.Rendered do
				if v6.Item == p then
					return v6.Slot
				end
			end
		end

		return nil
	end

	local function getItems(p: string)
		local v5 = v4[p]

		if v5 then
			return v5.Items
		end

		return {}
	end

	return {
		AddInstance = addInstance,
		RemoveInstance = removeInstance,
		MoveInstance = moveInstance,
		SetItems = setItems,
		Invalidate = invalidate,
		Sort = sortPublic,
		GetRenderedSlot = getRenderedSlot,
		GetItems = getItems,
		Destroy = function()
			maid:Destroy()
		end
	}
end

return create