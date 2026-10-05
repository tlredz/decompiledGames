local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local shared = ReplicatedStorage:WaitForChild("Shared")
require(shared.ShakePresets)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(packages.Trove)
local Net = require(packages.Net)
require("../CameraController")
local remoteEvent = Net:RemoteEvent("UseItem")
Trove.new()
TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
remoteEvent.OnClientEvent:Connect(function(p, value)
	if p ~= "CandyEffect" then
		return
	end

	currentCamera.FieldOfView = 20
	local clone = script.ColorCorrection:Clone()
	clone.Parent = Lighting
	task.delay(value or 10, function()
		currentCamera.FieldOfView = 70
		clone:Destroy()
	end)
end)
return {}