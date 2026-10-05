function Fix()
	local total = 4

	for _, frame in pairs(script.Parent:GetChildren()) do
		if frame:IsA("Frame") and frame.Visible then
			total += frame.AbsoluteSize.X + 6
		end
	end

	script.Parent.CanvasSize = UDim2.fromOffset(total, 0)

	if script.Parent.AbsoluteSize.X < total then
		script.Parent.UIPadding.PaddingBottom = UDim.new(0, 2)
	else
		script.Parent.UIPadding.PaddingBottom = UDim.new(0, 0)
	end
end

script.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fix)
Fix()