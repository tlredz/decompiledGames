local v = {
	Measure = function(point: Vector2)
		local width = point.X * 0.5271577
		local height = width / 1.2553575
		local header = height < 400 and 48 or 64
		return {
			Width = width,
			Height = height,
			Header = header,
			GridTop = header + 90
		}
	end
}

function v:Apply(point: Vector2)
	local measured = v.Measure(point)
	self.Size = UDim2.fromOffset(measured.Width, measured.Height)
	local uIAspectRatioConstraint = self:FindFirstChildOfClass("UIAspectRatioConstraint")

	if uIAspectRatioConstraint then
		uIAspectRatioConstraint.AspectRatio = measured.Width / measured.Height
	end

	local header = self:FindFirstChild("Header")
	header.AnchorPoint = Vector2.new(0.5, 0)
	header.Position = UDim2.fromScale(0.5, 0)
	header.Size = UDim2.new(1, 0, 0, measured.Header)
	local close = self:FindFirstChild("Close")
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -8, 0, (measured.Header - 44) / 2)
	close.Size = UDim2.fromOffset(44, 44)
	local title = self:FindFirstChild("Title")
	title.AnchorPoint = Vector2.zero
	title.Position = UDim2.fromOffset(16, measured.Header + 6)
	title.Size = UDim2.new(1, -32, 0, 26)
	local includeEquipped = self:FindFirstChild("IncludeEquipped")
	includeEquipped.AnchorPoint = Vector2.zero
	includeEquipped.Position = UDim2.fromOffset(16, measured.Header + 36)
	includeEquipped.Size = UDim2.new(1, -32, 0, 44)
	local scrollingFrame = self:FindFirstChild("ScrollingFrame")
	scrollingFrame.AnchorPoint = Vector2.zero
	scrollingFrame.Position = UDim2.fromOffset(12, measured.GridTop)
	scrollingFrame.Size = UDim2.new(1, -24, 1, -measured.GridTop - 12)
	local emptyState = self:FindFirstChild("EmptyState")
	emptyState.AnchorPoint = Vector2.zero
	emptyState.Position = UDim2.fromOffset(24, measured.GridTop)
	emptyState.Size = UDim2.new(1, -48, 1, -measured.GridTop - 12)
	local frame = self:FindFirstChild("Frame")
	frame.AnchorPoint = Vector2.zero
	frame.Position = UDim2.fromOffset(8, measured.Header)
	frame.Size = UDim2.new(1, -16, 1, -measured.Header - 8)
end

return table.freeze(v)