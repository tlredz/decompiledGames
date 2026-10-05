local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Net)
local playerGui = Players.LocalPlayer.PlayerGui
local parent = script.Parent
playerGui:WaitForChild("backpack")
local questBook = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("QuestBook")
parent.Equipped:Connect(function()
	questBook.Visible = true
end)
parent.Unequipped:Connect(function()
	questBook.Visible = false
end)