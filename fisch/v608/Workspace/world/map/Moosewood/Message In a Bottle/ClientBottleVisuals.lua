local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local parent = script.Parent
local removeBottleVisuals = script:WaitForChild("RemoveBottleVisuals")
local highlight = parent:WaitForChild("Highlight")
local notify = parent:WaitForChild("notify")
removeBottleVisuals:FireServer()
removeBottleVisuals.OnClientEvent:Connect(function()
	highlight.Enabled = false
	notify.Enabled = false
end)