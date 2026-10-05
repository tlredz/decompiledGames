local Players = game:GetService("Players")
game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = localPlayer.PlayerScripts
local currentCamera = workspace.CurrentCamera
local pumpkingHolder = playerGui:WaitForChild("ToolsScreen").MainFrame.PumpkingHolder
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p)
	if p ~= "TurnIntoPumpkinHead" then
		return
	end

	currentCamera.FieldOfView = 20
	pumpkingHolder.Visible = true
	task.delay(8, function()
		currentCamera.FieldOfView = 70
		pumpkingHolder.Visible = false
	end)
end)
return {}