local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnnouncementView = require(ReplicatedStorage._FRAMEWORK.Features.Specials.FabAdminAnnouncement.AnnouncementView)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local controls = {
	text = UILabs.String("The concert begins in five minutes. Get ready!")
}
return UILabs.CreateVideStory({
	name = "Fab Admin Announcement",
	vide = Vide,
	controls = controls
}, function(p)
	return Vide.create("Frame")({
		Name = "FabAdminAnnouncementStory",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Vide.action(function(p2)
			local v2 = AnnouncementView.mount(p2)
			Vide.effect(function()
				local text = p.controls.text()
				Vide.untrack(function()
					v2.show({
						text = text
					})
				end)
			end)
			Vide.cleanup(v2.destroy)
		end)
	})
end)