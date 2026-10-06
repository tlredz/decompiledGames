local CloneStarterGuiForEditOrPlayModule = {}
CloneStarterGuiForEditOrPlayModule.__index = CloneStarterGuiForEditOrPlayModule

function CloneStarterGuiForEditOrPlayModule.Edit(_, _)
	local sLWorkspaceFrame = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9):WaitForChild("SLWorkspaceFrame")
	sLWorkspaceFrame:ClearAllChildren()

	for _, child in pairs(game.StarterGui:GetChildren()) do
		if not (child.ClassName == "ScreenGui" and child.Name ~= "StudioGui") then
			continue
		end

		local frame = Instance.new("Frame")
		frame.Name = child.Name
		frame.Active = false
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Position = UDim2.new(0, 0, 0, 0)
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.Visible = child.Enabled
		frame.Parent = sLWorkspaceFrame

		for _, child2 in pairs(child:GetChildren()) do
			local clone = child2:Clone()
			clone.Parent = frame
		end
	end
end

function CloneStarterGuiForEditOrPlayModule.Stop(_)
	for _, child in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
		if not (child.ClassName == "ScreenGui" and child.Name ~= "StudioGui" and child.Name ~= "BubbleChat" and child.Name ~= "TouchGui") then
			continue
		end

		if not (child.Name ~= "Chat" and child.Name ~= "Freecam" and child.Name ~= "VehiclePromptScreenGui") then
			continue
		end

		child:Destroy()
	end
end

return CloneStarterGuiForEditOrPlayModule