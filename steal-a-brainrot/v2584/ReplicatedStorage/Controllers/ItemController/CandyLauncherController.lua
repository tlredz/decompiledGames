local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer.PlayerScripts
local currentCamera = workspace.CurrentCamera
local packages = ReplicatedStorage:WaitForChild("Packages")
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local Net = require(packages.Net)
local _ = CharacterController.Controls
Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p)
	if p ~= "TurnIntoJelly" then
		return
	end

	currentCamera.FieldOfView = 20
	local clone = script.ColorCorrection:Clone()
	clone.Parent = Lighting
	task.delay(5, function()
		currentCamera.FieldOfView = 70
		clone:Destroy()
	end)
end)
return {}