game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").ChildAdded:Connect(function(proximityPrompt)
	if proximityPrompt:IsA("ProximityPrompt") then
		proximityPrompt.Enabled = false
	end
end)