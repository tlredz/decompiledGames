return function(object)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "Menu"
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.Visible = true
	scrollingFrame.ZIndex = 1
	scrollingFrame.Size = UDim2.fromScale(1, 1)
	scrollingFrame.ClipsDescendants = true
	scrollingFrame.TopImage = ""
	scrollingFrame.BottomImage = ""
	scrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 1, -1)
	scrollingFrame.ScrollingEnabled = true
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
	scrollingFrame.ZIndex = 20
	scrollingFrame.ScrollBarThickness = 3
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	scrollingFrame.ScrollBarImageTransparency = 0.8
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Selectable = false
	local iconModule = require(object.iconModule)
	local clone = iconModule.container.TopbarStandard:FindFirstChild("UIListLayout", true):Clone()
	clone.Name = "MenuUIListLayout"
	clone.VerticalAlignment = Enum.VerticalAlignment.Center
	clone.Parent = scrollingFrame
	local frame = Instance.new("Frame")
	frame.Name = "MenuGap"
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.AnchorPoint = Vector2.new(0, 0.5)
	frame.ZIndex = 5
	frame.Parent = scrollingFrame
	local flag = false
	local Themes = require(script.Parent.Parent.Features.Themes)

	local function totalChildrenChanged()
		local menuJanitor = object.menuJanitor
		local v = #object.menuIcons

		if flag then
			if v <= 0 then
				menuJanitor:clean()
				flag = false
			end
		else
			flag = true
			menuJanitor:add(object.toggled:Connect(function()
				if #object.menuIcons > 0 then
					object.updateSize:Fire()
				end
			end))
			local _, v2 = object:modifyTheme({
				{ "Menu", "Active", true }
			})
			task.defer(function()
				menuJanitor:add(function()
					object:removeModification(v2)
				end)
			end)
			local X = scrollingFrame.AbsoluteCanvasSize.X

			local function rightAlignCanvas()
				if object.alignment == "Right" then
					local X2 = scrollingFrame.AbsoluteCanvasSize.X
					local v3 = X - X2
					X = X2
					scrollingFrame.CanvasPosition = Vector2.new(scrollingFrame.CanvasPosition.X - v3, 0)
				end
			end

			menuJanitor:add(object.selected:Connect(rightAlignCanvas))
			menuJanitor:add(scrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(rightAlignCanvas))
			local stateGroup = object:getStateGroup()

			if Themes.getThemeValue(stateGroup, "IconImage", "Image", "Deselected") == Themes.getThemeValue(
				stateGroup,
				"IconImage",
				"Image",
				"Selected"
			) then
				local rbxassetfontsfamiliesFredokaOnejson = Font.new(
					"rbxasset://fonts/families/FredokaOne.json",
					Enum.FontWeight.Light,
					Enum.FontStyle.Normal
				)
				object:removeModificationWith("IconLabel", "Text", "Viewing")
				object:removeModificationWith("IconLabel", "Image", "Viewing")
				object:modifyTheme({
					{
						"IconLabel",
						"FontFace",
						rbxassetfontsfamiliesFredokaOnejson,
						"Selected"
					},
					{
						"IconLabel",
						"Text",
						"X",
						"Selected"
					},
					{
						"IconLabel",
						"TextSize",
						20,
						"Selected"
					},
					{
						"IconLabel",
						"TextStrokeTransparency",
						0.8,
						"Selected"
					},
					{
						"IconImage",
						"Image",
						"",
						"Selected"
					}
				})
			end

			local instance = object:getInstance("MenuGap")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateAlignent()
				local v3, layoutOrder

				if object.alignment == "Right" then
					v3 = 99999
					layoutOrder = 99998
				else
					v3 = -99999
					layoutOrder = -99998
				end

				object:modifyTheme({ "IconSpot", "LayoutOrder", v3 })
				instance.LayoutOrder = layoutOrder
			end

			menuJanitor:add(object.alignmentChanged:Connect(updateAlignent))
			updateAlignent() -- equivalent call inferred; original call site unknown
			scrollingFrame:GetAttributeChangedSignal("MenuCanvasWidth"):Connect(function()
				local menuCanvasWidth = scrollingFrame:GetAttribute("MenuCanvasWidth")
				local Y = scrollingFrame.CanvasSize.Y
				scrollingFrame.CanvasSize = UDim2.new(0, menuCanvasWidth, Y.Scale, Y.Offset)
			end)
			menuJanitor:add(object.updateMenu:Connect(function()
				local maxIcons = scrollingFrame:GetAttribute("MaxIcons")

				if not maxIcons then
					return
				end

				local v3 = {}

				for _, child in pairs(scrollingFrame:GetChildren()) do
					if child:GetAttribute("WidgetUID") and child.Visible then
						table.insert(v3, { child, child.AbsolutePosition.X })
					end
				end

				table.sort(v3, function(a, b)
					return a[2] < b[2]
				end)
				local total = 0

				for i = 1, maxIcons do
					local v4 = v3[i]

					if not v4 then
						break
					end

					total += v4[1].AbsoluteSize.X + clone.Padding.Offset
				end

				scrollingFrame:SetAttribute("MenuWidth", total)
			end))

			-- equivalent calls inferred from this helper; original call sites unknown
			local function startMenuUpdate()
				task.delay(0.1, function()
					object.startMenuUpdate:Fire()
				end)
			end

			menuJanitor:add(scrollingFrame.ChildAdded:Connect(startMenuUpdate))
			menuJanitor:add(scrollingFrame.ChildRemoved:Connect(startMenuUpdate))
			menuJanitor:add(scrollingFrame:GetAttributeChangedSignal("MaxIcons"):Connect(startMenuUpdate))
			menuJanitor:add(scrollingFrame:GetAttributeChangedSignal("MaxWidth"):Connect(startMenuUpdate))
			startMenuUpdate() -- equivalent call inferred; original call site unknown
		end
	end

	object.menuChildAdded:Connect(totalChildrenChanged)
	object.menuSet:Connect(function(items)
		for _, menuIcon in pairs(object.menuIcons) do
			iconModule.getIconByUID(menuIcon):destroy()
		end

		if type(items) == "table" then
			for _, item in pairs(items) do
				item:joinMenu(object)
			end
		end
	end)
	return scrollingFrame
end