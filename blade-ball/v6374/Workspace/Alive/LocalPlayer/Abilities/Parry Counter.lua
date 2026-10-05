local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Packages.Replion)
require(ReplicatedStorage.ServerInfo)
local localPlayer = Players.LocalPlayer

if not localPlayer.Character then
	localPlayer.CharacterAdded:Wait()
end

local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local ParryCounter = require(ReplicatedStorage.Shared.Abilities["Parry Counter"])
vector.Image = ParryCounter.iconId or ""