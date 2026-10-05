local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MessagingServiceManager = require(ReplicatedStorage._FRAMEWORK.Features.MessagingServiceManager)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local AdminMessaging = {
	adminAnnouncementMessageHandler = MessagingServiceManager.createMessageHandler("AdminAnnounce")
}
FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			return
		end

		AdminMessaging.adminAnnouncementMessageHandler.connect(function(p)
			if p and p.text then
				ReplicatedStorage.Remotes.AdminAnnounce:FireAllClients(p)
			end
		end)
	end
})
return AdminMessaging