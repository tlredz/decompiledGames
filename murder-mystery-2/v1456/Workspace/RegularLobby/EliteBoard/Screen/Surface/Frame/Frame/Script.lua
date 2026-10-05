script.Parent:WaitForChild("Buy").Activated:Connect(function()
	game.ReplicatedStorage.Remotes.Shop.GetElite:FireServer()
end)