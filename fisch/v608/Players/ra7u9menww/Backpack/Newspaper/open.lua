local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Net)
local playerGui = Players.LocalPlayer.PlayerGui
local parent = script.Parent
playerGui:WaitForChild("backpack")
local hud = playerGui:WaitForChild("hud")
local safezone = hud:WaitForChild("safezone")
local deviceinset = hud:WaitForChild("deviceinset")
local whatsNew = safezone:WaitForChild("WhatsNew")
parent.Equipped:Connect(function()
	whatsNew.Visible = true
	deviceinset.Enabled = false
end)
parent.Unequipped:Connect(function()
	whatsNew.Visible = false
	deviceinset.Enabled = true
end)