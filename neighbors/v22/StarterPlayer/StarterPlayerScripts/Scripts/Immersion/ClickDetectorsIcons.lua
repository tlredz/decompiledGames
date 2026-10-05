for _, clickDetector in workspace:GetDescendants() do
	if clickDetector:IsA("ClickDetector") then
		clickDetector.CursorIcon = "rbxassetid://15491289548"
	end
end

workspace.DescendantAdded:Connect(function(clickDetector)
	if clickDetector:IsA("ClickDetector") then
		clickDetector.CursorIcon = "rbxassetid://15491289548"
	end
end)