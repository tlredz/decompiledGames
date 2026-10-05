game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local parent = script.Parent
local _ = parent.Parent.Parent
parent.Activated:Connect(function()
	local _ = game.Players.LocalPlayer
	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	Net:RemoteEvent("UseItem"):FireServer(PlayerMouse.Hit.Position, PlayerMouse.Target)
end)