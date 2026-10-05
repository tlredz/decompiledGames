local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Client = require(ReplicatedStorage.Modules:WaitForChild("StateReplicator"):WaitForChild("Client"))
local _ = Players.LocalPlayer
script.Parent.TextButton.Activated:Connect(function()
	print(Client.Tables)
end)