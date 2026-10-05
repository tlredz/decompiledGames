local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vector = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local Virus = require(ReplicatedStorage.Shared.Abilities.Virus)
vector.Image = Virus.iconId or ""