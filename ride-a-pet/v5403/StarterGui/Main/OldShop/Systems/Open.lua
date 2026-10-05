local parent = script.Parent.Parent
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local holders = parent:WaitForChild("Holders")
game2:WaitForChild("OpenStockShop").OnClientEvent:Connect(function(p)
	for _, child in holders:GetChildren() do
		child.Visible = child.Name == p
	end

	parent.Visible = true
end)