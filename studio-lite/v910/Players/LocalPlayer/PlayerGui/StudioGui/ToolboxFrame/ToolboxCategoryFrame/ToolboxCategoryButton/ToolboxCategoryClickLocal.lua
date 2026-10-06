script.Parent.MouseButton1Click:Connect(function()
	local toolboxCategoryChoicesFrame = script.Parent.Parent.Parent.ToolboxCategoryChoicesFrame

	if toolboxCategoryChoicesFrame.Visible then
		toolboxCategoryChoicesFrame.Visible = false
	else
		toolboxCategoryChoicesFrame.Visible = true
	end
end)