local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdvertisementJoinController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementJoinController)
local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = nil
local v2 = Component.new({
	Tag = "AdButton"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		if v.IsOpen("MainGUIHandler", "AdStore") then
			v.Close("MainGUIHandler", "AdStore")
			return
		end

		local v3, v4 = AdvertisementsController.IsRewardedVideoAdReady():await()

		if v3 and v4 == Enum.AdAvailabilityResult.IsAvailable then
			v.OpenPanelByContext("MainGUIHandler", "AdStore")
			return
		end

		NotificationController.NotifyCenter("Ad not available. Try again later.", 4)
		v.Close("MainGUIHandler", "AdStore")
		AdvertisementJoinController.CancelCheck()
		AdvertisementJoinController.CheckAd()
	end))
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2