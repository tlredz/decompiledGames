return function(object)
	local frame = Instance.new("Frame")
	frame.Name = "Dropdown"
	frame.AutomaticSize = Enum.AutomaticSize.XY
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 1, 10)
	frame.ZIndex = -2
	frame.ClipsDescendants = true
	frame.Parent = object.widget
	local uICorner = Instance.new("UICorner")
	uICorner.Name = "DropdownCorner"
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = frame
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "DropdownScroller"
	scrollingFrame.AutomaticSize = Enum.AutomaticSize.X
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.AnchorPoint = Vector2.new(0, 0)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollingFrame.ZIndex = -1
	scrollingFrame.ClipsDescendants = true
	scrollingFrame.Visible = true
	scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	scrollingFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	scrollingFrame.Active = false
	scrollingFrame.ScrollingEnabled = true
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.ScrollBarThickness = 5
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	scrollingFrame.ScrollBarImageTransparency = 0.8
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.Selectable = false
	scrollingFrame.Active = true
	scrollingFrame.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "DropdownPadding"
	uIPadding.PaddingTop = UDim.new(0, 8)
	uIPadding.PaddingBottom = UDim.new(0, 8)
	uIPadding.Parent = scrollingFrame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "DropdownList"
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
	uIListLayout.Parent = scrollingFrame
	local dropdownJanitor = object.dropdownJanitor
	local iconModule = require(object.iconModule)
	object.dropdownChildAdded:Connect(function(object2)
		local _, v = object2:modifyTheme({
			{ "Widget", "BorderSize", 0 },
			{ "IconCorners", "CornerRadius", UDim.new(0, 4) },
			{ "Widget", "MinimumWidth", 190 },
			{ "Widget", "MinimumHeight", 56 },
			{ "IconLabel", "TextSize", 19 },
			{ "PaddingLeft", "Size", UDim2.fromOffset(25, 0) },
			{ "Notice", "Position", UDim2.new(1, -24, 0, 5) },
			{ "ContentsList", "HorizontalAlignment", Enum.HorizontalAlignment.Left },
			{ "Selection", "Size", UDim2.new(1, -8, 1, -8) },
			{ "Selection", "Position", UDim2.new(0, 4, 0, 4) }
		})
		task.defer(function()
			object2.joinJanitor:add(function()
				object2:removeModification(v)
			end)
		end)
	end)
	object.dropdownSet:Connect(function(list)
		for _, dropdownIcon in pairs(object.dropdownIcons) do
			iconModule.getIconByUID(dropdownIcon):destroy()
		end

		local _ = #list

		if type(list) == "table" then
			for _, v in pairs(list) do
				v:joinDropdown(object)
			end
		end
	end)
	local Utility = require(script.Parent.Parent.Utility)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateVisibility()
		Utility.setVisible(frame, object.isSelected, "InternalDropdown")
	end

	dropdownJanitor:add(object.toggled:Connect(updateVisibility))
	updateVisibility() -- equivalent call inferred; original call site unknown
	local count = 0
	local flag = false
	local updateMaxIcons

	updateMaxIcons = function()
		count += 1

		if flag then
			return
		end

		local v = count
		flag = true
		task.defer(function()
			flag = false

			if count ~= v then
				updateMaxIcons()
			end
		end)
		local maxIcons = frame:GetAttribute("MaxIcons")

		if not maxIcons then
			return
		end

		local v2 = {}

		for _, guiObject in pairs(scrollingFrame:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				table.insert(v2, { guiObject, guiObject.AbsolutePosition.Y })
			end
		end

		table.sort(v2, function(a, b)
			return a[2] < b[2]
		end)
		local total = 0
		local flag2 = false

		for i = 1, maxIcons do
			local v3 = v2[i]

			if not v3 then
				break
			end

			local v4 = v3[1]
			total += v4.AbsoluteSize.Y
			local widgetUID = v4:GetAttribute("WidgetUID")
			local v5 = widgetUID and iconModule.getIconByUID(widgetUID)

			if not v5 then
				continue
			end

			local nextSelectionUp

			if not flag2 then
				nextSelectionUp = object:getInstance("ClickRegion")
				flag2 = true
			end

			local instance = v5:getInstance("ClickRegion")
			instance.NextSelectionUp = nextSelectionUp
		end

		local v3 = total + uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset
		scrollingFrame.Size = UDim2.fromOffset(0, v3)
	end

	dropdownJanitor:add(scrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateMaxIcons))
	dropdownJanitor:add(scrollingFrame.ChildAdded:Connect(updateMaxIcons))
	dropdownJanitor:add(scrollingFrame.ChildRemoved:Connect(updateMaxIcons))
	dropdownJanitor:add(frame:GetAttributeChangedSignal("MaxIcons"):Connect(updateMaxIcons))
	dropdownJanitor:add(object.childThemeModified:Connect(updateMaxIcons))
	updateMaxIcons()
	return frame
end