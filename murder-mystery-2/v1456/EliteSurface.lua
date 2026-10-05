local clone = script.Surface:Clone()
clone.Parent = script.Parent.Parent.Parent
clone.Adornee = game.Workspace:WaitForChild("Lobby"):WaitForChild("EliteBoard"):WaitForChild("Screen")
clone.Frame.Frame.Buy.MouseButton1Click:connect(function()
	game.ReplicatedStorage.Remotes.Shop.GetElite:FireServer()
end)