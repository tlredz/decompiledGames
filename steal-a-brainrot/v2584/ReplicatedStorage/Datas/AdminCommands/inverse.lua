local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	name = "inverse",
	icon = "rbxassetid://86269342686094",
	cooldown = 60,
	description = "Your controls are inverted for 10 seconds!",
	effects = {
		Victim = function()
			local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
			local _ = Players.LocalPlayer
			local controls = CharacterController.Controls
			local _ = controls.moveFunction

			function controls.moveFunction(p, p2, p3)
				CharacterController:RequestMove(p, -p2, p3)
			end

			task.delay(10, function()
				controls.moveFunction = CharacterController.originalMoveFunction
			end)
		end
	}
}