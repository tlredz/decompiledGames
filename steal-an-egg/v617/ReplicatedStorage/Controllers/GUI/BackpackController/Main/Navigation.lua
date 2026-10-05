local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local function available(parent, folder)
	if not parent.Selectable then
		return false
	end

	while parent and parent ~= folder do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		else
			parent = parent.Parent
		end
	end

	return parent == folder
end

local function nearest(items, p, p2)
	local v = p.AbsolutePosition + p.AbsoluteSize / 2
	local v2 = nil
	local v3 = nil

	for _, item in items do
		local v4 = math.abs((item.AbsolutePosition + item.AbsoluteSize / 2)[p2] - v[p2])

		if not (not v2 or v4 < v2) then
			continue
		end

		v3 = item
		v2 = v4
	end

	return v3
end

local function readingOrder(p, p2)
	local absolutePosition = p.AbsolutePosition
	local absolutePosition2 = p2.AbsolutePosition

	if math.abs(absolutePosition.Y - absolutePosition2.Y) > math.min(p.AbsoluteSize.Y, p2.AbsoluteSize.Y) / 2 then
		return absolutePosition.Y < absolutePosition2.Y
	end

	return absolutePosition.X < absolutePosition2.X
end

return function(folder, instance, p, p2, ancestor)
	folder.SelectionGroup = true
	folder.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	folder.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	folder.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
	folder.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
	local v = true
	local connections = {}
	local v2 = {}

	local function invalidate()
		v = true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connect(propertyChangedSignal, invalidate2)
		table.insert(connections, propertyChangedSignal:Connect(invalidate2))
	end

	local function watch(guiObject)
		if not guiObject:IsA("GuiObject") or v2[guiObject] then
			return
		end

		local connections2 = {}

		for _, propertyName in {
			"Visible",
			"Selectable",
			"AbsolutePosition",
			"AbsoluteSize",
			"LayoutOrder"
		} do
			table.insert(connections2, guiObject:GetPropertyChangedSignal(propertyName):Connect(invalidate))
		end

		v2[guiObject] = connections2
		v = true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function relevant(button)
		return button.Parent == p or button.Parent == p2 or button.Parent == ancestor or button:IsA("GuiButton") and button:IsDescendantOf(ancestor)
	end

	local v3 = {}

	for _, button in folder:GetDescendants() do
		if relevant(button) then
			watch(button)
		end
	end

	table.insert(connections, folder.DescendantAdded:Connect(function(button)
		if relevant(button) then
			watch(button)
		end
	end))
	table.insert(connections, folder.DescendantRemoving:Connect(function(descendant)
		if v2[descendant] then
			for _, connection in v2[descendant] do
				connection:Disconnect()
			end

			v2[descendant] = nil
			v = true
		end
	end))
	connect(instance:GetPropertyChangedSignal("Visible"), invalidate) -- equivalent call inferred; original call site unknown
	connect(folder:GetPropertyChangedSignal("Visible"), invalidate) -- equivalent call inferred; original call site unknown

	local function collect(folder2, p3)
		local buttons = {}
		local v4

		if p3 then
			v4 = folder2:GetDescendants()
		else
			v4 = folder2:GetChildren()
		end

		for _, button in v4, nil, nil do
			if not (button:IsA("GuiButton") and available(button, folder) and (p3 or button:GetAttribute("IsInventorySlot") ~= nil)) then
				continue
			end

			table.insert(buttons, button)
		end

		table.sort(buttons, readingOrder)
		return buttons
	end

	local function rebuild()
		local v4 = collect(p, false)
		local v5 = collect(p2, false)
		local v6 = collect(ancestor, true)
		local v7 = {}

		for _, v8 in v4 do
			local v9 = v7[#v7]

			if not v9 or math.abs(v8.AbsolutePosition.Y - v9[1].AbsolutePosition.Y) > v8.AbsoluteSize.Y / 2 then
				v9 = {}
				table.insert(v7, v9)
			end

			table.insert(v9, v8)
		end

		local v8 = v3
		v3 = {}
		local count = 0

		for k, v9 in v7 do
			for k2, v10 in v9 do
				count += 1
				v3[v10] = true
				v10.NextSelectionRight = v4[count + 1] or v5[1] or v10
				v10.NextSelectionLeft = v9[k2 - 1] or nearest(v6, v10, "Y") or v4[count - 1] or v10
				local nextSelectionUp

				if k > 1 then
					nextSelectionUp = nearest(v7[k - 1], v10, "X")
				end

				v10.NextSelectionUp = nextSelectionUp
				v10.NextSelectionDown = nearest(v7[k + 1] or v5, v10, "X") or v10
			end
		end

		for k, v9 in v5 do
			v3[v9] = true
			v9.NextSelectionRight = v5[k + 1] or v4[1] or v9
			v9.NextSelectionLeft = v5[k - 1] or nearest(v6, v9, "Y") or v9
			v9.NextSelectionUp = nearest(v7[#v7] or v6, v9, "X") or v9
			v9.NextSelectionDown = nil
		end

		for k, nextSelectionLeft in v6 do
			v3[nextSelectionLeft] = true
			nextSelectionLeft.NextSelectionUp = v6[k - 1] or nextSelectionLeft
			nextSelectionLeft.NextSelectionDown = v6[k + 1] or v5[1] or nextSelectionLeft
			nextSelectionLeft.NextSelectionLeft = nextSelectionLeft
			nextSelectionLeft.NextSelectionRight = nearest(v7[1] or v5, nextSelectionLeft, "Y") or nextSelectionLeft
		end

		local selectedObject = GuiService.SelectedObject

		if selectedObject and v8[selectedObject] and not v3[selectedObject] then
			GuiService.SelectedObject = v6[1] or v4[1] or v5[1]
		end
	end

	table.insert(connections, RunService.RenderStepped:Connect(function()
		if v and instance.Visible and folder.Visible then
			v = false
			rebuild()
		end
	end))
	table.insert(connections, folder.Destroying:Connect(function()
		for _, connection in connections do
			connection:Disconnect()
		end

		for _, v4 in v2 do
			for _, connection in v4 do
				connection:Disconnect()
			end
		end
	end))
end