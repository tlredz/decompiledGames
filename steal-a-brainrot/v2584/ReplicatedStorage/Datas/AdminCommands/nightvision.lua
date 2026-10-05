local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	name = "nightvision",
	icon = "rbxassetid://86320449907895",
	cooldown = 60,
	description = "You have night vision for 1 minute!",
	effects = {
		Victim = function()
			local NightVisionController = require(ReplicatedStorage.Controllers.ItemController.NightVisionController)
			NightVisionController.Enable()
			task.delay(60, function()
				NightVisionController.Disable()
			end)
		end
	}
}