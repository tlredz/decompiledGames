local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("UserInputService"))
game:GetService("ReplicatedStorage")
character:WaitForChild("Humanoid")
game:GetService("Debris")
local _ = game.Workspace.CurrentCamera.FieldOfView
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""