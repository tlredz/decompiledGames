local Players = game:GetService("Players")
game:GetService("Lighting")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer
local _ = workspace.CurrentCamera
local controllers = ReplicatedStorage:WaitForChild("Controllers")
require(controllers.CharacterController)
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Net)
return {}