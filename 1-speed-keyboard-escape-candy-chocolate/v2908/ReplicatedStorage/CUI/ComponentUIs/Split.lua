return function()
	local frame = Instance.new("Frame")
	frame.Name = "Split"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 20)
	frame.Visible = false
	local frame2 = Instance.new("Frame")
	frame2.Name = "Left"
	frame2.BackgroundTransparency = 1
	frame2.Size = UDim2.fromScale(0.5, 1)
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = frame2
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "Right"
	frame3.AnchorPoint = Vector2.new(1, 0)
	frame3.BackgroundTransparency = 1
	frame3.Position = UDim2.fromScale(1, 0)
	frame3.Size = UDim2.fromScale(0.5, 1)
	local uIListLayout2 = Instance.new("UIListLayout")
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.Parent = frame3
	frame3.Parent = frame
	return frame
end