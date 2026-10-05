local parent = script.Parent
local parent2 = script.Parent.Parent
game.SoundService:WaitForChild("SFX")
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
parent.Activated:Connect(function()
	UIController.close(parent2)
end)