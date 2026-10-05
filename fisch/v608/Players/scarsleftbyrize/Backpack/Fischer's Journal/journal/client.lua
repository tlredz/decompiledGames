local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Net)
local playerGui = Players.LocalPlayer.PlayerGui
local parent = script.Parent
playerGui:WaitForChild("backpack")
local fischersJournal = playerGui:WaitForChild("FischersJournal")
parent.Equipped:Connect(function()
	fischersJournal.Enabled = true
end)
parent.Unequipped:Connect(function()
	fischersJournal.Enabled = false
end)