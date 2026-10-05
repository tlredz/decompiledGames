local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "MoreTicketsPanel"
})
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)

function v:Construct()
	self._Janitor = Janitor.new()
	self.itemId = "Christmas2025MoreTickets"
	self.active = false
	self.countdownText = "Reset in: %dh %dm"
end

function v:Start()
	self.itemId = "Christmas2025MoreTickets"
	local outerBox = self.Instance:WaitForChild("OuterBox")
	self.localCountdownText = outerBox:WaitForChild("TimerCountdown")
	self.icon = outerBox:WaitForChild("IconContainer"):WaitForChild("IconImage")
	local contentBox = outerBox:WaitForChild("ContentBox")
	self.titleText = contentBox:WaitForChild("Title")
	self.descriptionText = contentBox:WaitForChild("Description")
	self.videoAdAvailableButton = contentBox:WaitForChild("Buttons"):WaitForChild("VideoAdAvailable")
	self.buttonDescriptionText = self.videoAdAvailableButton:WaitForChild("TextInfo"):WaitForChild("ButtonDescriptionText")
	self._Janitor:Add(self.videoAdAvailableButton.Activated:Connect(function()
		AdvertisementsController.IsRewardedVideoAdReady():andThen(function(p)
			if p == Enum.AdAvailabilityResult.DeviceIneligible or p == Enum.AdAvailabilityResult.ExperienceIneligible or p == Enum.AdAvailabilityResult.PlayerIneligible or p == Enum.AdAvailabilityResult.PublisherIneligible then
				NotificationController.NotifyCenter("Ad not available.", 4)
			elseif p == Enum.AdAvailabilityResult.IsAvailable then
				AdvertisementsController.RequestRewardedVideoAd(
					self.itemId,
					self.icon.Image,
					nil,
					"MoreTickets",
					"TicketsForAds",
					false,
					true
				)
			else
				NotificationController.NotifyCenter("Ad not available. Try again later.", 4)
			end
		end)
		PanelController.Close("MainGUIHandler", "MoreTicketsPanel")
	end))
	self._Janitor:Add(RunService.Heartbeat:Connect(function()
		if not self.active then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local v2 = self.nextResetTimeStamp - serverTimeNow
		self.localCountdownText.Text = string.format(
			self.countdownText,
			math.floor(v2 / 3600),
			(math.floor(v2 % 3600 / 60))
		)

		if v2 <= 0 then
			self.active = false
			PanelController.Close("MainGUIHandler", "MoreTicketsPanel")
		end
	end))
end

function v:Initialize(itemId: string, text: string, text2: string, image: string, text3: string, nextResetTimeStamp: number)
	self.itemId = itemId
	self.titleText.Text = text
	self.descriptionText.Text = text2
	self.icon.Image = image
	self.buttonDescriptionText.Text = text3
	self.nextResetTimeStamp = nextResetTimeStamp
	self.active = true
end

function v:Stop()
	self._Janitor:Destroy()
end

return v