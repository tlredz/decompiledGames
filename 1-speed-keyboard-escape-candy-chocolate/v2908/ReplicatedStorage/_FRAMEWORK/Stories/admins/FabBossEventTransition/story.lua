local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Transition = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules.FabBossEvent.Transition)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
return UILabs.CreateVideStory({
	name = "Fab Boss Event Transition",
	vide = Vide
}, function()
	return Vide.create("Frame")({
		Name = "FabBossEventTransitionStory",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Vide.action(function(p)
			local v = Transition.mount(p)
			local flag = true
			local thread = task.spawn(function()
				while flag do
					v.setVisible(true)
					task.wait(1.5)
					v.setVisible(false)
					task.wait(2.5)
				end
			end)
			Vide.cleanup(function()
				flag = false
				task.cancel(thread)
				v.destroy()
			end)
		end)
	})
end)