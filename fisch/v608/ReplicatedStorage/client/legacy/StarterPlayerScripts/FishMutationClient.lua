local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local fishMutation = ReplicatedStorage.events.fishMutation
local mutations = require(ReplicatedStorage.shared.modules.fishing.mutations)
fishMutation.OnClientEvent:Connect(function(p, p2, p3)
	mutations:MutateModel(p, p2, p3)
end)