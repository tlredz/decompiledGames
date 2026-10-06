script.Parent.Activated:Connect(function()
	local assetTypeDropDownScrollingFrame = script.Parent.Parent.Parent.AssetTypeDropDownScrollingFrame

	if assetTypeDropDownScrollingFrame.Visible then
		assetTypeDropDownScrollingFrame.Visible = false
	else
		assetTypeDropDownScrollingFrame.Visible = true
	end
end)