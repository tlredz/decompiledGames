local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local humanoidRootPart = script.Parent:WaitForChild("HumanoidRootPart")
local clone = ReplicatedStorage.Assets.Billboards.Billboard_UI:Clone()
clone.Adornee = humanoidRootPart
clone.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")