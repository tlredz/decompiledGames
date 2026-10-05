game:GetService("StarterPlayer")
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
local parent = script.Parent
local _ = parent.Parent.Parent
parent.Activated:Connect(function()
	Net:RemoteEvent("UseItem"):FireServer(PlayerMouse.Hit.Position)
end)