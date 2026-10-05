return function()
	local frame = Instance.new("Frame")
	frame.Name = "ScrollingFrame"
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = 3
	frame.Size = UDim2.new(1, 0, 0, 60)
	frame.Visible = false
	local frame2 = Instance.new("Frame")
	frame2.Name = "ScrollBG"
	frame2.AnchorPoint = Vector2.new(1, 1)
	frame2.BackgroundColor3 = Color3.new()
	frame2.BorderColor3 = Color3.new()
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromScale(1, 1)
	frame2.Size = UDim2.new(0, 10, 1, 0)
	frame2.Parent = frame
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "Content"
	scrollingFrame.Active = true
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BottomImage = "rbxassetid://5168609593"
	scrollingFrame.MidImage = "rbxassetid://5168609593"
	scrollingFrame.ScrollBarImageTransparency = 0.75
	scrollingFrame.ScrollBarThickness = 10
	scrollingFrame.Size = UDim2.fromScale(1, 1)
	scrollingFrame.TopImage = "rbxassetid://5168609593"
	scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scrollingFrame.ZIndex = 50
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = scrollingFrame
	scrollingFrame.Parent = frame
	return frame
end