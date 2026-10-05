local parent = script.Parent
game.Players.LocalPlayer.CharacterAdded:Connect(function()
	parent.Visible = false
end)