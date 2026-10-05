local parent = script.Parent.Parent
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local holders = parent:WaitForChild("Holders")
game2:WaitForChild("OpenStockShop").OnClientEvent:Connect(function(p)
	for _, child in holders:GetChildren() do
		child.Visible = child.Name == p
	end

	UIController.open(parent)
end)