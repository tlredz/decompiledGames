script.Parent.MouseButton1Click:Connect(function()
	local publishToChoicesFrame = script.Parent.Parent.PublishToChoicesFrame

	if publishToChoicesFrame.Visible then
		publishToChoicesFrame.Visible = false
	else
		publishToChoicesFrame.Visible = true
	end
end)