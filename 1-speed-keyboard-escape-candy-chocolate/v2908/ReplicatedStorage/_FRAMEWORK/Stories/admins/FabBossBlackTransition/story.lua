local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlackTransition = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules.FabBossEvent.BlackTransition)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local controls = {
	fadeInDuration = UILabs.Slider(1.5, 0, 5, 0.05),
	blackHoldDuration = UILabs.Slider(4, 0, 20, 0.05),
	fadeOutDuration = UILabs.Slider(1.5, 0, 5, 0.05),
	pauseDuration = UILabs.Slider(1, 0, 5, 0.05)
}
return UILabs.CreateVideStory({
	name = "Fab Boss Black Transition",
	vide = Vide,
	controls = controls
}, function(p)
	return Vide.create("Frame")({
		Name = "FabBossBlackTransitionStory",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Vide.action(function(p2)
			local flag = true
			local v2 = nil
			local thread = task.spawn(function()
				while flag do
					local fadeInDuration = p.controls.fadeInDuration()
					local blackHoldDuration = p.controls.blackHoldDuration()
					local fadeOutDuration = p.controls.fadeOutDuration()
					local v3 = BlackTransition.mount(p2)
					v2 = v3
					v3.play({
						fadeInDuration = fadeInDuration,
						blackHoldDuration = blackHoldDuration,
						fadeOutDuration = fadeOutDuration
					})
					task.wait(fadeInDuration + blackHoldDuration + fadeOutDuration + p.controls.pauseDuration())

					if v2 == v3 then
						v2 = nil
					end
				end
			end)
			Vide.cleanup(function()
				flag = false
				task.cancel(thread)
				local v3 = v2

				if v3 then
					v3.destroy()
					v2 = nil
				end
			end)
		end)
	})
end)