local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RevealView = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules.LuckyMinute.RevealView)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local controls = {
	multiplier = UILabs.Slider(25, 2, 100, 1),
	remainingSeconds = UILabs.Slider(60, 1, 60, 1),
	rollSeconds = UILabs.Slider(1.8, 0, 5, 0.1),
	holdSeconds = UILabs.Slider(2.8, 0.5, 8, 0.1)
}
return UILabs.CreateVideStory({
	name = "Lucky Minute Reveal",
	vide = Vide,
	controls = controls
}, function(p)
	return Vide.create("Frame")({
		Name = "LuckyMinuteRevealStory",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(28, 32, 45),
		BorderSizePixel = 0,
		Vide.action(function(p2)
			local v2 = RevealView.mount(p2)
			local flag = true
			local thread = task.spawn(function()
				while flag do
					local multiplier = p.controls.multiplier()
					local remainingSeconds = p.controls.remainingSeconds()
					local rollSeconds = p.controls.rollSeconds()
					local holdSeconds = p.controls.holdSeconds()
					v2.reveal(multiplier, remainingSeconds, rollSeconds, holdSeconds)
					task.wait(rollSeconds + holdSeconds + 1)
				end
			end)
			Vide.cleanup(function()
				flag = false
				task.cancel(thread)
				v2.destroy()
			end)
		end)
	})
end)