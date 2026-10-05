local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TopBanner = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules.AllanBossRoom.TopBanner)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local controls = {
	visible = UILabs.Boolean(true),
	icon = UILabs.String("rbxassetid://105997309315946"),
	timelineProgress = UILabs.Slider(0.2, 0, 1, 0.01),
	autoPlay = UILabs.Boolean(false),
	autoPlaySeconds = UILabs.Slider(20, 5, 720, 1)
}
return UILabs.CreateVideStory({
	name = "Allan Boss Room Top Banner",
	vide = Vide,
	controls = controls
}, function(p)
	return Vide.create("Frame")({
		Name = "AllanBossRoomTopBannerStory",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(18, 18, 22),
		BorderSizePixel = 0,
		Vide.action(function(p2)
			local v2 = nil
			local v3 = 0
			Vide.effect(function()
				local icon = p.controls.icon()
				Vide.untrack(function()
					if v2 then
						v2.destroy()
					end

					v3 = 0
					v2 = TopBanner.mount(p2, {
						icon = icon
					})
				end)
			end)
			local RunService = game:GetService("RunService")
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				local v4 = v2

				if v4 then
					local timelineProgress = p.controls.timelineProgress()

					if p.controls.autoPlay() then
						v3 = (v3 + dt) % p.controls.autoPlaySeconds()
						timelineProgress = v3 / p.controls.autoPlaySeconds()
					end

					v4.update(timelineProgress, p.controls.visible())
				end
			end)
			Vide.cleanup(function()
				heartbeatConnection:Disconnect()

				if v2 then
					v2.destroy()
					v2 = nil
				end
			end)
		end)
	})
end)