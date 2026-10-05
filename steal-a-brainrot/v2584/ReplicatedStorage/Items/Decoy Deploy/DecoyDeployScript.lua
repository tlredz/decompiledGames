local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local _ = Players.LocalPlayer.PlayerGui:WaitForChild("ToolsFrames").QuantumCloner
local controllers = ReplicatedStorage:WaitForChild("Controllers")
require(controllers.CharacterController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
require(packages.Debounce)
local parent = script.Parent
local _ = parent.Parent.Parent
parent.Activated:Connect(function()
	Net:RemoteEvent("UseItem"):FireServer()
end)