local createVector = vector.create
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	name = "control",
	icon = "rbxassetid://136064800007852",
	cooldown = 60,
	description = "You are being controlled for 10 seconds!",
	effects = {
		Executor = function(player)
			local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
			local localPlayer = Players.LocalPlayer
			local controls = CharacterController.Controls
			workspace.CurrentCamera.CameraSubject = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")

			function controls.moveFunction(p, p2, p3)
				CharacterController:RequestMove(player, p2, p3)
				CharacterController:RequestMove(p, createVector(0, 0, 0), p3)
			end

			local _ = localPlayer.Character.Humanoid
			local jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
				player.Character.Humanoid.Jump = true
				localPlayer.Character.Humanoid.Jump = false
			end)
			task.delay(5, function()
				controls.moveFunction = CharacterController.originalMoveFunction

				if localPlayer and localPlayer.Character then
					workspace.CurrentCamera.CameraSubject = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
				end

				if jumpRequestConnection then
					jumpRequestConnection:Disconnect()
				end
			end)
		end,
		Victim = function()
			local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
			local controls = CharacterController.Controls
			local _ = controls.moveFunction

			function controls.moveFunction(_, _, _) end

			task.delay(10, function()
				controls.moveFunction = CharacterController.originalMoveFunction
			end)
		end
	}
}