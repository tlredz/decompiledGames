return function(data)
	local GuiService = game:GetService("GuiService")
	local isOldTopbar = data.isOldTopbar
	local guiInset = GuiService:GetGuiInset()
	local isTenFootInterface = GuiService:IsTenFootInterface()
	local v2 = isOldTopbar and 12 or guiInset.Y - 46
	local v3 = isTenFootInterface and 10 or v2
	local screenGui = Instance.new("ScreenGui")
	screenGui:SetAttribute("StartInset", v3)
	screenGui.Name = "TopbarStandard"
	screenGui.Enabled = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	local v = {
		[screenGui.Name] = screenGui
	}
	screenGui.DisplayOrder = data.baseDisplayOrder
	data.baseDisplayOrderChanged:Connect(function()
		screenGui.DisplayOrder = data.baseDisplayOrder
	end)
	local frame = Instance.new("Frame")
	local v4 = isOldTopbar and 2 or 0
	local v5

	if isTenFootInterface then
		v4 += 13
		v5 = 50
	else
		v5 = -2
	end

	frame.Name = "Holders"
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.new(0, 0, 0, v4)
	frame.Size = UDim2.new(1, 0, 1, v5)
	frame.Visible = true
	frame.ZIndex = 1
	frame.Parent = screenGui
	local clone = screenGui:Clone()
	local holders = clone.Holders
	local GuiService2 = game:GetService("GuiService")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCenteredHoldersHeight()
		holders.Size = UDim2.new(1, 0, 0, GuiService2.TopbarInset.Height + v5)
	end

	clone.Name = "TopbarCentered"
	clone.ScreenInsets = Enum.ScreenInsets.None
	data.baseDisplayOrderChanged:Connect(function()
		clone.DisplayOrder = data.baseDisplayOrder
	end)
	v[clone.Name] = clone
	GuiService2:GetPropertyChangedSignal("TopbarInset"):Connect(updateCenteredHoldersHeight)
	updateCenteredHoldersHeight() -- equivalent call inferred; original call site unknown
	local clone2 = screenGui:Clone()
	clone2.Name ..= "Clipped"
	clone2.DisplayOrder += 1
	data.baseDisplayOrderChanged:Connect(function()
		clone2.DisplayOrder = data.baseDisplayOrder + 1
	end)
	v[clone2.Name] = clone2
	local clone3 = clone:Clone()
	clone3.Name ..= "Clipped"
	clone3.DisplayOrder += 1
	data.baseDisplayOrderChanged:Connect(function()
		clone3.DisplayOrder = data.baseDisplayOrder + 1
	end)
	v[clone3.Name] = clone3

	if isOldTopbar then
		task.defer(function()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function decideToHideTopbar()
				if GuiService2.MenuIsOpen then
					data.setTopbarEnabled(false, true)
				else
					data.setTopbarEnabled()
				end
			end

			GuiService2:GetPropertyChangedSignal("MenuIsOpen"):Connect(decideToHideTopbar)
			decideToHideTopbar() -- equivalent call inferred; original call site unknown
		end)
	end

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame:SetAttribute("IsAHolder", true)
	scrollingFrame.Name = "Left"
	scrollingFrame.Position = UDim2.fromOffset(v3, 0)
	scrollingFrame.Size = UDim2.new(1, -24, 1, 0)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.Visible = true
	scrollingFrame.ZIndex = 1
	scrollingFrame.Active = false
	scrollingFrame.ClipsDescendants = true
	scrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 1, -1)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
	scrollingFrame.ScrollBarThickness = 0
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Selectable = false
	scrollingFrame.ScrollingEnabled = false
	scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
	scrollingFrame.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Padding = UDim.new(0, v3)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uIListLayout.Parent = scrollingFrame
	local clone4 = scrollingFrame:Clone()
	clone4.ScrollingEnabled = false
	clone4.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	clone4.Name = "Center"
	clone4.Parent = holders
	local clone5 = scrollingFrame:Clone()
	clone5.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	clone5.Name = "Right"
	clone5.AnchorPoint = Vector2.new(1, 0)
	clone5.Position = UDim2.new(1, -12, 0, 0)
	clone5.Parent = frame
	return v
end