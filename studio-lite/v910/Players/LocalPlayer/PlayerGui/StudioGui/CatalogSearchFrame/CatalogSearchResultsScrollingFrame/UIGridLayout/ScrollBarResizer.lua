script.Parent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	local uDim = UDim2.new(0, 0, 0.5, script.Parent.AbsoluteContentSize.Y)
	script.Parent.Parent.CanvasSize = uDim
end)