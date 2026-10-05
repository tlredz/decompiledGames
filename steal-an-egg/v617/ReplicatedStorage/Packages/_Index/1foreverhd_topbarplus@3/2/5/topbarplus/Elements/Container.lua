local v = false
local v2 = 0
return function(state)
	local GuiService = game:GetService("GuiService")
	local GoodSignal = require(script.Parent.Parent.Packages.GoodSignal)
	local v4 = GoodSignal.new()
	local guiInset = GuiService:GetGuiInset()
	local v5 = 0
	local v6 = 0
	local v7 = 0
	local count = 0
	local checkInset

	checkInset = function(p)
		local height = GuiService.TopbarInset.Height
		local isOldTopbar = height <= 36
		local isTenFootInterface = GuiService:IsTenFootInterface()
		state.isOldTopbar = isOldTopbar
		count += 1

		if height == 0 and p == nil then
			task.delay(5, function()
				checkInset("ForceConvertToOld")
			end)
		elseif count == 1 then
			task.delay(5, function()
				if count == 1 then
					checkInset()
				end
			end)
		end

		if state.isOldTopbar and not isTenFootInterface and v == false and (height ~= 0 or p == "ForceConvertToOld") then
			v = true
			task.defer(function()
				local themes = script.Parent.Parent.Features.Themes
				local Classic = require(themes.Classic)
				state.modifyBaseTheme(Classic)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function decideToHideTopbar()
					if GuiService.MenuIsOpen then
						state.setTopbarEnabled(false, true)
					else
						state.setTopbarEnabled()
					end
				end

				GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(decideToHideTopbar)
				decideToHideTopbar() -- equivalent call inferred; original call site unknown
			end)
		end

		v5 = isOldTopbar and 12 or guiInset.Y - 50
		v6 = isOldTopbar and 2 or 0
		v7 = -2

		if isTenFootInterface then
			v5 = 10
			v6 = -9
		end

		if GuiService.TopbarInset.Height == 0 and not v then
			v6 += 13
			v7 = 50
		end

		v4:Fire(guiInset)
		local Y = guiInset.Y

		if Y ~= v2 then
			v2 = Y
			task.defer(function()
				state.insetHeightChanged:Fire(Y)
			end)
		end
	end

	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(checkInset)
	checkInset("FirstTime")
	local screenGui = Instance.new("ScreenGui")
	v4:Connect(function()
		screenGui:SetAttribute("StartInset", v5)
	end)
	screenGui.Name = "TopbarStandard"
	screenGui.Enabled = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	local v3 = {
		[screenGui.Name] = screenGui
	}
	state.baseDisplayOrderChanged:Connect(function()
		screenGui.DisplayOrder = state.baseDisplayOrder
	end)
	local frame = Instance.new("Frame")
	frame.Name = "Holders"
	frame.BackgroundTransparency = 1
	v4:Connect(function()
		frame.Position = UDim2.new(0, 0, 0, v6)
		frame.Size = UDim2.new(1, 0, 1, v7)
	end)
	frame.Visible = true
	frame.ZIndex = 1
	frame.Parent = screenGui
	local clone = screenGui:Clone()
	local holders = clone.Holders

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCenteredHoldersHeight()
		holders.Size = UDim2.new(1, 0, 0, GuiService.TopbarInset.Height + v7)
	end

	clone.Name = "TopbarCentered"
	clone.ScreenInsets = Enum.ScreenInsets.None
	state.baseDisplayOrderChanged:Connect(function()
		clone.DisplayOrder = state.baseDisplayOrder
	end)
	v3[clone.Name] = clone
	v4:Connect(updateCenteredHoldersHeight)
	updateCenteredHoldersHeight() -- equivalent call inferred; original call site unknown
	local clone2 = screenGui:Clone()
	clone2.Name ..= "Clipped"
	clone2.DisplayOrder += 1
	state.baseDisplayOrderChanged:Connect(function()
		clone2.DisplayOrder = state.baseDisplayOrder + 1
	end)
	v3[clone2.Name] = clone2
	local clone3 = clone:Clone()
	clone3.Name ..= "Clipped"
	clone3.DisplayOrder += 1
	state.baseDisplayOrderChanged:Connect(function()
		clone3.DisplayOrder = state.baseDisplayOrder + 1
	end)
	v3[clone3.Name] = clone3
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame:SetAttribute("IsAHolder", true)
	scrollingFrame.Name = "Left"
	v4:Connect(function()
		scrollingFrame.Position = UDim2.fromOffset(v5, 0)
	end)
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
	v4:Connect(function()
		uIListLayout.Padding = UDim.new(0, v5)
	end)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uIListLayout.Parent = scrollingFrame
	local clone4 = scrollingFrame:Clone()
	v4:Connect(function()
		clone4.UIListLayout.Padding = UDim.new(0, v5)
	end)
	clone4.ScrollingEnabled = false
	clone4.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	clone4.Name = "Center"
	clone4.Parent = holders
	local clone5 = scrollingFrame:Clone()
	v4:Connect(function()
		clone5.UIListLayout.Padding = UDim.new(0, v5)
	end)
	clone5.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	clone5.Name = "Right"
	clone5.AnchorPoint = Vector2.new(1, 0)
	clone5.Position = UDim2.new(1, -12, 0, 0)
	clone5.Parent = frame
	v4:Fire(guiInset)
	return v3
end