local parent = script.Parent
local scrollingFrame = parent.ScrollingFrame
local back = parent.Back

function UpdateScrolling()
	local uIGridLayout = scrollingFrame.UIGridLayout
	local scrollBarThickness = scrollingFrame.ScrollBarThickness
	local v = scrollingFrame.AbsoluteSize.X - scrollBarThickness
	local Y = scrollingFrame.AbsoluteSize.Y
	local v2 = (v - 0) / 1
	local v3 = (Y - 15) / 6
	uIGridLayout.CellSize = UDim2.new(0, v2, 0, v3)
	uIGridLayout.CellPadding = UDim2.new(0, 3, 0, 3)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
end

UpdateScrolling()
scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateScrolling()
end)

function ClearFrame()
	for _, frame in pairs(scrollingFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

back.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Parent = parent.Parent
	})
	parent.Visible = nil
	ClearFrame()
end)
back.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = back,
		ZIndex = 7,
		CornerRadius = UDim.new(0.3, 0),
		Circle = true
	})
end)