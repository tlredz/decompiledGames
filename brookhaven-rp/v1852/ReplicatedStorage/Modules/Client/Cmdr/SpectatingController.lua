local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local CmdrController = require(ReplicatedStorage.Modules.Client.Cmdr.CmdrController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local maid = Janitor.new()
local v = nil
local SpectatingController = {}

function SpectatingController.FrameworkStart()
	Players.PlayerRemoving:Connect(function(player)
		if player == v then
			SpectatingController.StopSpectating()
			NotificationController.NotifyCenter("The player you were spectating has left the game.")
		end
	end)
end

function SpectatingController.Spectate(player)
	if not CmdrController.HasPermission() then
		return "You do not have permission to spectate"
	end

	local character = player.Character

	if not character then
		return "Player does not have a character"
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return "Player does not have a humanoid"
	end

	maid:Cleanup()
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraSubject = humanoid
	v = player
	maid:Add(player.CharacterAdded:Connect(function(character2)
		local humanoid2 = character2:WaitForChild("Humanoid", 10)

		if not humanoid2 then
			return
		end

		currentCamera.CameraSubject = humanoid2
		NotificationController.NotifyCenter((`{player.Name} has respawned.`))
	end))
	return "Spectating " .. player.Name
end

function SpectatingController.StopSpectating()
	if not CmdrController.HasPermission() then
		return "You do not have permission to spectate"
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return "You do not have a character"
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return "You do not have a humanoid"
	end

	maid:Cleanup()
	workspace.CurrentCamera.CameraSubject = humanoid
	v = nil
	return "Stopping spectate"
end

return SpectatingController