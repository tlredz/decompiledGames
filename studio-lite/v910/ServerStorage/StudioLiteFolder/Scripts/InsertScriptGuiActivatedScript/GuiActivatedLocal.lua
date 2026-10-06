local guiActivated = script.Parent:WaitForChild("GuiActivated", 99999)
script.Parent.Parent.Activated:Connect(function()
	guiActivated:FireServer()
end)