local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HuntView = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules.ChocolateHunt.HuntView)
local Config = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules.ChocolateHunt.Config)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local controls = {
	progress = UILabs.Slider(450, 0, Config.goal, 1),
	remainingSeconds = UILabs.Slider(Config.defaultDurationSeconds, 0, Config.defaultDurationSeconds, 1)
}

local function getMultiplier(p: number)
	local multiplier = 1

	for _, milestone in Config.milestones do
		if milestone.progress <= p then
			multiplier = milestone.multiplier
		end
	end

	return multiplier
end

return UILabs.CreateVideStory({
	name = "Chocolate Hunt",
	vide = Vide,
	controls = controls
}, function(p)
	return Vide.create("Frame")({
		Name = "ChocolateHuntStory",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(210, 190, 180),
		BorderSizePixel = 0,
		Vide.action(function(p2)
			local v2 = HuntView.mount(p2)
			Vide.effect(function()
				local progress = p.controls.progress()
				local update = v2.update
				local multiplier = 1

				for _, milestone in Config.milestones do
					if milestone.progress <= progress then
						multiplier = milestone.multiplier
					end
				end

				update(progress, multiplier)
			end)
			Vide.effect(function()
				v2.updateTimer(p.controls.remainingSeconds())
			end)
			Vide.cleanup(v2.destroy)
		end)
	})
end)