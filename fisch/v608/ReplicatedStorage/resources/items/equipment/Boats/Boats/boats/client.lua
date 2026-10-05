local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("Boats/Close")
local playerGui = Players.LocalPlayer.PlayerGui
local backpack = playerGui:WaitForChild("backpack")
local shipwright = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("shipwright")
script.Parent.Activated:Connect(function()
	backpack.Enabled = false
	shipwright.Visible = true
	remoteEvent:FireServer()
end)