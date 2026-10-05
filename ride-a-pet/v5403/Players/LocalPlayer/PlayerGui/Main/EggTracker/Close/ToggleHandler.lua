local parent = script.Parent
local parent2 = parent.Parent
local SFX = game.SoundService:WaitForChild("SFX")
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
parent.Activated:Connect(function()
	SFX.Click:Play()
	UIController.close(parent2)
end)