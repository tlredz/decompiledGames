local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Net)
local playerGui = Players.LocalPlayer.PlayerGui
local parent = script.Parent
playerGui:WaitForChild("backpack")
local companions = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("companions")
parent.Equipped:Connect(function()
	companions.Visible = true
end)
parent.Unequipped:Connect(function()
	companions.Visible = false
end)