local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local uDim = UDim2.fromScale(0, 0)
local v3 = {}

local function createScroll(data)
	local scrollingFrame = assert(data.Container, "Expected config.Container to exist")

	if v3[scrollingFrame] then
		return v3[scrollingFrame]
	end

	assert(scrollingFrame:IsA("ScrollingFrame"), "Expected config.Container to be a ScrollingFrame")
	local v4 = assert(scrollingFrame:FindFirstChildWhichIsA("UIGridLayout"), "UIGridLayout not found")
	local maid = v2.new()
	local parent = maid:Add(Instance.new("Folder", scrollingFrame))
	local vector2 = createVector(0, 0, 0)
	local vector3 = createVector(0, 0, 0)
	local uDim2 = nil
	local v6 = {}
	local instances = {}
	local v8 = {}

	local function getSlot(instance)
		local clone = table.remove(v8, 1)

		if not clone then
			clone = instance:Clone()
			clone.Visible = true
			clone.Parent = parent
		end

		clone.Visible = true
		return clone
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function returnSlot(p)
		p.Visible = false
		table.insert(v8, p)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function destroyItem(p)
		local v9 = v6[p]

		if not v9 then
			return
		end

		returnSlot(v9[1]) -- equivalent call inferred; original call site unknown

		if v9[2] then
			xpcall(v9[2], function(p2)
				local traceback = debug.traceback(p2, 3)
				task.spawn(error, traceback)
			end)
		end

		v6[p] = nil
	end

	local anchorPoint = data.Template.AnchorPoint
	local cellSize = v4.CellSize
	maid:Add(v4:GetPropertyChangedSignal("CellSize"):Connect(function()
		cellSize = v4.CellSize
	end))
	local cellPadding = v4.CellPadding
	maid:Add(v4:GetPropertyChangedSignal("CellPadding"):Connect(function()
		cellPadding = v4.CellPadding
	end))
	local horizontalAlignment = v4.HorizontalAlignment
	maid:Add(v4:GetPropertyChangedSignal("HorizontalAlignment"):Connect(function()
		horizontalAlignment = v4.HorizontalAlignment
	end))
	local guiObject = scrollingFrame:FindFirstAncestorWhichIsA("GuiObject")
	local layerCollector = scrollingFrame:FindFirstAncestorWhichIsA("LayerCollector")
	maid:Add(scrollingFrame.AncestryChanged:Connect(function()
		guiObject = scrollingFrame:FindFirstAncestorWhichIsA("GuiObject")
		layerCollector = scrollingFrame:FindFirstAncestorWhichIsA("LayerCollector")
	end))
	local automaticCanvasSize = scrollingFrame.AutomaticCanvasSize
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
	maid:Add(function()
		scrollingFrame.AutomaticCanvasSize = automaticCanvasSize
	end)
	local dominantAxis = nil
	local aspectType = nil

	local function updateAspectRatio()
		local uIAspectRatioConstraint = v4:FindFirstChildWhichIsA("UIAspectRatioConstraint")

		if uIAspectRatioConstraint then
			aspectType = uIAspectRatioConstraint.AspectType
			dominantAxis = uIAspectRatioConstraint.DominantAxis

			if uIAspectRatioConstraint.AspectType ~= Enum.AspectType.FitWithinMaxSize then
				warn((`[VirtualGridScroll] UIAspectRatios with AspectType of "{uIAspectRatioConstraint.AspectType.Name}" are not supported`))
			elseif uIAspectRatioConstraint.DominantAxis ~= Enum.DominantAxis.Width then
				warn((`[VirtualGridScroll] UIAspectRatios with AspectType of "{uIAspectRatioConstraint.AspectType.Name}" with DominantAxis of "{uIAspectRatioConstraint.DominantAxis}" are not supported`))
			end
		else
			aspectType = nil
			dominantAxis = nil
		end
	end

	updateAspectRatio()
	maid:Add(v4.ChildAdded:Connect(updateAspectRatio))
	maid:Add(v4.ChildRemoved:Connect(updateAspectRatio))
	local canvasPosition = nil
	maid:Add(RunService.PreRender:Connect(function()
		if guiObject and layerCollector and layerCollector.Enabled and scrollingFrame.Visible then
			if #instances <= 0 then
				if not canvasPosition then
					canvasPosition = scrollingFrame.CanvasPosition
				end

				scrollingFrame.CanvasSize = uDim

				for k in pairs(v6) do
					destroyItem(k) -- equivalent call inferred; original call site unknown
				end
			else
				debug.profilebegin((`VirtualScroll::Update {scrollingFrame:GetFullName()}`))
				debug.profilebegin("VirtualScroll::Calculate")
				local absoluteSize = scrollingFrame.AbsoluteSize
				local absoluteWindowSize = scrollingFrame.AbsoluteWindowSize
				local size = scrollingFrame.Size
				vector3 = Vector3.new(
					cellPadding.X.Offset + cellPadding.X.Scale * absoluteSize.X,
					cellPadding.Y.Offset + cellPadding.Y.Scale * absoluteSize.Y
				)
				vector2 = Vector3.new(
					cellSize.X.Offset + cellSize.X.Scale * absoluteSize.X,
					cellSize.Y.Offset + cellSize.Y.Scale * absoluteSize.Y
				)

				if aspectType == Enum.AspectType.FitWithinMaxSize then
					vector2 = Vector3.new(vector2.Y, vector2.Y)
				end

				uDim2 = UDim2.fromOffset(vector2.X, vector2.Y)
				local v9 = (size.X.Offset + size.X.Scale * guiObject.AbsoluteSize.X) // vector2.X
				scrollingFrame.CanvasSize = UDim2.fromOffset(0, -(#instances // -v9) * (vector2.Y + vector3.Y))

				if canvasPosition then
					scrollingFrame.CanvasPosition = canvasPosition
					canvasPosition = nil
				end

				local Y = scrollingFrame.CanvasPosition.Y
				local v10 = vector2.X + vector3.X
				local v11 = vector2.Y + vector3.Y
				local v12 = anchorPoint.X * v10
				local v13 = anchorPoint.Y * v11

				if horizontalAlignment == Enum.HorizontalAlignment.Center then
					v12 += (absoluteSize.X - v10 * v9) * 0.5 - (not (absoluteWindowSize.Y > absoluteSize.Y) and 0 or scrollingFrame.ScrollBarThickness)
				elseif horizontalAlignment == Enum.HorizontalAlignment.Right then
					v12 += absoluteSize.X - v10 * v9 - (not (absoluteWindowSize.Y > absoluteSize.Y) and 0 or scrollingFrame.ScrollBarThickness)
				end

				local v14 = math.clamp(Y // v11 * v9 + 1, 1, #instances)
				local v15 = math.clamp((-((Y + absoluteWindowSize.Y) // -v11) + 1) * v9, v14, #instances)
				debug.profileend()
				debug.profilebegin("VirtualScroll::DestroyOutOfBounds")

				for k, _ in pairs(v6) do
					if not (k < v14 or v15 < k) then
						continue
					end

					destroyItem(k) -- equivalent call inferred; original call site unknown
				end

				debug.profileend()
				debug.profilebegin("VirtualScroll::UpdatePositions")

				for i = v14, v15 do
					local v16 = v6[i]

					if not (v16 and v16[3] ~= instances[i]) then
						continue
					end

					local v17 = nil

					for i2 = v14, v15 do
						if i2 == i then
							continue
						end

						local v18 = v6[i2]

						if not (v18 and v18[3] == v16[3]) then
							continue
						end

						v17 = i2
						break
					end

					if v17 then
						local v18 = v6[v17]
						v6[v17] = v16
						v6[i] = v18
					else
						debug.profilebegin("VirtualScroll::Destroy")
						destroyItem(i) -- equivalent call inferred; original call site unknown
						debug.profileend()
					end
				end

				debug.profileend()
				debug.profilebegin("VirtualScroll::DestroyOutOfBounds")

				for i = v14, v15 do
					debug.profilebegin("VirtualScroll::UpdateItem")
					local v16 = v6[i]
					local clone

					if v16 then
						clone = v16[1]
					end

					if not clone then
						debug.profilebegin("VirtualScroll::Render")
						local v17 = instances[i]
						debug.profilebegin("VirtualScroll::GetSlot")
						local template = v17.Template
						clone = table.remove(v8, 1)

						if not clone then
							clone = template:Clone()
							clone.Visible = true
							clone.Parent = parent
						end

						clone.Visible = true
						debug.profileend()
						debug.profilebegin("VirtualScroll::Constructor")
						local constructor = v17.Constructor(v17.Instance, clone, i)
						debug.profileend()
						v6[i] = { clone, constructor, v17 }
						clone.Visible = true
						debug.profileend()
					end

					debug.profilebegin("VirtualScroll::UpdatePositions")
					clone.Name = tostring(i)
					clone.Size = uDim2
					clone.Position = UDim2.fromOffset(v12 + (i - 1) % v9 * v10, v13 + (-(i // -v9) - 1) * v11)
					debug.profileend()
					debug.profileend()
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
		for k in pairs(v6) do
			destroyItem(k) -- equivalent call inferred; original call site unknown
		end

		table.clear(instances)

		for _, v9 in v8 do
			v9:Destroy()
		end

		table.clear(v8)
	end)
	local thread = nil

	local function sort()
		if data.Sort and not (thread or #instances <= 1) then
			thread = task.defer(function()
				thread = nil

				if #instances <= 1 then
					return
				end

				debug.profilebegin("VirtualScroll::Sort")
				table.sort(instances, function(a, b)
					return data.Sort(a.Instance, b.Instance)
				end)
				debug.profileend()
			end)
		end
	end

	local v9 = {
		Trove = maid,
		Instances = instances,
		Sort = sort,
		DestroyItem = destroyItem,
		Destroy = function()
			maid:Destroy()
			v3[data.Container] = nil
		end,
		Connections = {}
	}
	v3[data.Container] = v9
	return v9
end

local create

create = function(merged)
	local scroll = createScroll(merged)

	if scroll.Trove._cleaning then
		warn("Tried to create VirtualGridScroll while cleaning", debug.traceback())
	end

	local maid = scroll.Trove:Extend()
	local v4 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getIndex(p)
		for k, instance in scroll.Instances do
			if instance.Instance == p then
				return k
			end
		end

		return nil
	end

	local function removeInstance(p)
		local index = getIndex(p) -- equivalent call inferred; original call site unknown

		if index then
			scroll.DestroyItem(index)
			table.remove(scroll.Instances, index)
			scroll.Sort()
			local index2 = table.find(v4, p)

			if index2 then
				table.remove(v4, index2)
			end
		end
	end

	local function addInstance(instance)
		-- equivalent call inferred; original call site unknown
		if not getIndex(instance) then
			table.insert(scroll.Instances, {
				Instance = instance,
				Template = merged.Template,
				Constructor = merged.Constructor
			})
			scroll.Sort()
			table.insert(v4, instance)
		end

		return function()
			return removeInstance(instance)
		end
	end

	maid:Add(function()
		for i = #scroll.Instances, 1, -1 do
			local instance = scroll.Instances[i]

			if not table.find(v4, instance.Instance) then
				continue
			end

			scroll.DestroyItem(i)
			table.remove(scroll.Instances, i)
		end

		table.clear(v4)
		scroll.Sort()
	end)
	table.insert(scroll.Connections, maid)
	return {
		Sort = scroll.Sort,
		AddInstance = addInstance,
		RemoveInstance = removeInstance,
		Move = function(container)
			local v5 = create(v.Dictionary.merge(merged, {
				Container = container
			}))

			for _, v6 in v4 do
				removeInstance(v6)
				v5.AddInstance(v6)
			end

			return v5
		end,
		Destroy = function()
			maid:Destroy()
			local index = table.find(scroll.Connections, maid)

			if index then
				table.remove(scroll.Connections, index)
			end
		end
	}
end

return create