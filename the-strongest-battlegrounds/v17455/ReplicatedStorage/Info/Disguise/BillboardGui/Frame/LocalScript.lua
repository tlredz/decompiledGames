script.Parent.Done.TextButton.MouseButton1Click:Connect(function()
	local textsByName = {}

	for _, textBox in pairs(script.Parent:GetChildren()) do
		if textBox:IsA("TextBox") then
			textsByName[textBox.Name] = textBox.Text
		end
	end

	script.Parent.RemoteEvent:FireServer(textsByName)
	script.Parent.Visible = false
end)