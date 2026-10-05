local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local _ = Players.LocalPlayer.PlayerScripts
local _ = workspace.CurrentCamera
local controls = CharacterController.Controls
local remoteEvent = Net:RemoteEvent("SetInputEnabled")
local moveFunction = controls.moveFunction
remoteEvent.OnClientEvent:Connect(function(p)
	if p then
		controls.moveFunction = moveFunction
	else
		function controls.moveFunction(_, _, _) end
	end
end)
return {}