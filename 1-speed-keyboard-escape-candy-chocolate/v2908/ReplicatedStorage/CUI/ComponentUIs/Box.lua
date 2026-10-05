return function()
	local frame = Instance.new("Frame")
	frame.Name = "Box"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 20)
	frame.Visible = false
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = frame
	return frame
end