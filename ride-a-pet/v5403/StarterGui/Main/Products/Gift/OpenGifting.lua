local parent = script.Parent
local gifting = parent.Parent.Parent:WaitForChild("Gifting")
local SFX = game.SoundService:WaitForChild("SFX")
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
parent.Activated:Connect(function()
	SFX.Click:Play()
	gifting.Data.ProductId.Value = ""
	gifting.Header.ProductName.Text = ""
	UIController.open(gifting)
end)