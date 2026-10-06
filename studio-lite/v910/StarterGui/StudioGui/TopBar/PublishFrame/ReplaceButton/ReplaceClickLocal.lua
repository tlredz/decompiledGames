script.Parent.MouseButton1Click:Connect(function()
	local placeChoicesFrame = script.Parent.Parent.PlaceChoicesFrame

	if placeChoicesFrame.Visible then
		placeChoicesFrame.Visible = false
	else
		placeChoicesFrame.Visible = true
	end
end)