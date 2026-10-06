script.Parent.MouseButton1Click:Connect(function()
	local rigsSearchChoicesFrame = script.Parent.Parent.RigsSearchChoicesFrame

	if rigsSearchChoicesFrame.Visible then
		rigsSearchChoicesFrame.Visible = false
	else
		rigsSearchChoicesFrame.Visible = true
	end
end)