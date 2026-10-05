local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Themes = require(script.Parent.Parent.Features.Themes)
return function(object)
	local frame = Instance.new("Frame")
	frame.Name = "Dropdown"
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 1, 10)
	frame.ZIndex = -2
	frame.ClipsDescendants = true
	frame.Parent = object.widget
	local GuiService = game:GetService("GuiService")
	object:setBehaviour("Dropdown", "BackgroundTransparency", function(p)
		local v = p * GuiService.PreferredTransparency

		if p == 1 then
			return 1
		end

		return v
	end)
	object.janitor:add(GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		object:refreshAppearance(frame, "BackgroundTransparency")
	end))
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
	scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.None
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
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "DropdownSpeed"
	numberValue.Value = 0.07
	numberValue.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "DropdownPadding"
	uIPadding.PaddingTop = UDim.new(0, 0)
	uIPadding.PaddingBottom = UDim.new(0, 0)
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
			{ "IconCorners", "CornerRadius", UDim.new(0, 10) },
			{ "Widget", "MinimumWidth", 190 },
			{ "Widget", "MinimumHeight", 58 },
			{ "IconLabel", "TextSize", 20 },
			{ "IconOverlay", "Size", UDim2.new(1, 0, 1, 0) },
			{ "PaddingLeft", "Size", UDim2.fromOffset(25, 0) },
			{ "Notice", "Position", UDim2.new(1, -24, 0, 5) },
			{ "ContentsList", "HorizontalAlignment", Enum.HorizontalAlignment.Left },
			{ "Selection", "Size", UDim2.new(1, -0, 1, -0) },
			{ "Selection", "Position", UDim2.new(0, 0, 0, 0) }
		})
		task.defer(function()
			object2.joinJanitor:add(function()
				object2:removeModification(v)
			end)
		end)
	end)
	object.dropdownSet:Connect(function(items)
		for _, dropdownIcon in pairs(object.dropdownIcons) do
			iconModule.getIconByUID(dropdownIcon):destroy()
		end

		if type(items) == "table" then
			for _, item in pairs(items) do
				item:joinDropdown(object)
			end
		end
	end)

	local function updateMaxIcons()
		local maxIcons = frame:GetAttribute("MaxIcons")

		if not maxIcons then
			return 0
		end

		local guiObjects = {}

		for _, guiObject in pairs(scrollingFrame:GetChildren()) do
			if guiObject:IsA("GuiObject") and guiObject.Visible then
				table.insert(guiObjects, guiObject)
			end
		end

		table.sort(guiObjects, function(a, b)
			return a.AbsolutePosition.Y < b.AbsolutePosition.Y
		end)
		local v = math.ceil(maxIcons)
		local total = 0

		for i = 1, v do
			local v2 = guiObjects[i]

			if not v2 then
				break
			end

			local Y = v2.AbsoluteSize.Y
			local v3

			if i == v then
				v3 = v ~= maxIcons
			else
				v3 = false
			end

			if v3 then
				Y *= maxIcons - v + 1
			end

			total += Y
		end

		return total + (uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset)
	end

	local v = nil
	local v2 = nil
	local v3 = nil
	local v4 = nil

	local function getTweenInfo()
		local v5 = Themes.getInstanceValue(frame, "MaxIcons") or 1

		if v3 and v3 == v5 and v4 then
			return v4
		end

		local tweenInfo = TweenInfo.new(numberValue.Value * v5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		v4 = tweenInfo
		v3 = v5
		return tweenInfo
	end

	local function updateVisibility()
		local v5 = Themes.getInstanceValue(frame, "MaxIcons") or 1
		local tweenInfo

		if v3 and v3 == v5 and v4 then
			tweenInfo = v4
		else
			tweenInfo = TweenInfo.new(numberValue.Value * v5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			v4 = tweenInfo
			v3 = v5
		end

		if v then
			v:Cancel()
			v = nil
		end

		if v2 then
			v2:Cancel()
			v2 = nil
		end

		if object.isSelected then
			local v6 = updateMaxIcons()
			frame.Visible = true
			frame.BackgroundTransparency = 0
			frame.Size = UDim2.new(0, frame.Size.X.Offset, 0, 0)
			v = TweenService:Create(frame, tweenInfo, {
				Size = UDim2.new(0, frame.Size.X.Offset, 0, v6)
			})
			v:Play()
			v.Completed:Connect(function()
				v = nil
			end)
		else
			v2 = TweenService:Create(frame, TweenInfo.new(0), {
				Size = UDim2.new(0, frame.Size.X.Offset, 0, 0)
			})
			v2:Play()
			v2.Completed:Connect(function()
				v2 = nil
			end)
		end
	end

	dropdownJanitor:add(object.toggled:Connect(updateVisibility))
	updateVisibility()

	local function updateChildSize()
		local v5 = Themes.getInstanceValue(frame, "MaxIcons") or 1
		local tweenInfo

		if v3 and v3 == v5 and v4 then
			tweenInfo = v4
		else
			tweenInfo = TweenInfo.new(numberValue.Value * v5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			v4 = tweenInfo
			v3 = v5
		end

		if not object.isSelected then
			return
		end

		if v then
			v:Cancel()
			v = nil
		end

		if v2 then
			v2:Cancel()
			v2 = nil
		end

		RunService.Heartbeat:Wait()
		local v6 = updateMaxIcons()
		v = TweenService:Create(frame, tweenInfo, {
			Size = UDim2.new(0, frame.Size.X.Offset, 0, v6)
		})
		v:Play()
		v.Completed:Connect(function()
			v = nil
		end)
	end

	dropdownJanitor:add(object.toggled:Connect(updateVisibility))
	local count = 0
	local flag = false
	local updateMaxIconsListener

	updateMaxIconsListener = function()
		count += 1

		if flag then
			return
		end

		local v5 = count
		flag = true
		task.defer(function()
			flag = false

			if count ~= v5 then
				updateMaxIconsListener()
			end
		end)
		local maxIcons = frame:GetAttribute("MaxIcons")

		if not maxIcons then
			return
		end

		local v6 = {}

		for _, guiObject in pairs(scrollingFrame:GetChildren()) do
			if guiObject:IsA("GuiObject") and guiObject.Visible then
				table.insert(v6, { guiObject, guiObject.AbsolutePosition.Y })
			end
		end

		table.sort(v6, function(a, b)
			return a[2] < b[2]
		end)
		local v7 = math.ceil(maxIcons)
		local total = 0
		local flag2 = false

		for i = 1, v7 do
			local v8 = v6[i]

			if not v8 then
				break
			end

			local v9 = v8[1]
			local Y = v9.AbsoluteSize.Y
			local v10

			if i == v7 then
				v10 = v7 ~= maxIcons
			else
				v10 = false
			end

			if v10 then
				Y *= maxIcons - v7 + 1
			end

			total += Y

			if v10 then
				continue
			end

			local widgetUID = v9:GetAttribute("WidgetUID")
			local v11 = widgetUID and iconModule.getIconByUID(widgetUID)

			if not v11 then
				continue
			end

			local nextSelectionUp

			if not flag2 then
				nextSelectionUp = object:getInstance("ClickRegion")
				flag2 = true
			end

			local instance = v11:getInstance("ClickRegion")
			instance.NextSelectionUp = nextSelectionUp
		end

		local v8 = total + (uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset)
		scrollingFrame.Size = UDim2.fromOffset(0, v8)
	end

	dropdownJanitor:add(scrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateMaxIconsListener))
	dropdownJanitor:add(scrollingFrame.ChildAdded:Connect(updateMaxIconsListener))
	dropdownJanitor:add(scrollingFrame.ChildRemoved:Connect(updateChildSize))
	dropdownJanitor:add(scrollingFrame.ChildRemoved:Connect(updateMaxIconsListener))
	dropdownJanitor:add(frame:GetAttributeChangedSignal("MaxIcons"):Connect(updateMaxIconsListener))
	dropdownJanitor:add(frame:GetAttributeChangedSignal("MaxIcons"):Connect(updateChildSize))
	dropdownJanitor:add(object.childThemeModified:Connect(updateMaxIconsListener))
	updateMaxIconsListener()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connectVisibilityListeners(guiObject)
		if guiObject:IsA("GuiObject") then
			guiObject:GetPropertyChangedSignal("Visible"):Connect(updateChildSize)
			guiObject:GetPropertyChangedSignal("Size"):Connect(updateChildSize)
		end
	end

	for _, child in pairs(scrollingFrame:GetChildren()) do
		connectVisibilityListeners(child) -- equivalent call inferred; original call site unknown
	end

	scrollingFrame.ChildAdded:Connect(function(child)
		RunService.Heartbeat:Wait()
		connectVisibilityListeners(child) -- equivalent call inferred; original call site unknown
		updateChildSize()
	end)
	frame.Visible = false
	return frame
end