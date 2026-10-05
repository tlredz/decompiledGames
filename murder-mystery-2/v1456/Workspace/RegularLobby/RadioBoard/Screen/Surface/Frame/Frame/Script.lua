script.Parent:WaitForChild("Buy").Activated:Connect(function()
	game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()
end)