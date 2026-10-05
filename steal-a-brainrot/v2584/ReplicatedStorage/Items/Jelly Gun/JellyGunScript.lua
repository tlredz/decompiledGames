game:GetService("Players")
game:GetService("RunService")
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage:WaitForChild("Models").ToolsExtras
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
require(packages.Debounce)
local parent = script.Parent
local _ = parent.Parent.Parent
parent.Activated:Connect(function()
	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	Net:RemoteEvent("UseItem"):FireServer(PlayerMouse.Hit.Position, parent.Handle)
end)