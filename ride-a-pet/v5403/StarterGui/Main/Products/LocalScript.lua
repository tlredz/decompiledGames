local parent = script.Parent
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("OpenProducts").OnClientEvent:Connect(function()
	UIController.open(parent)
end)