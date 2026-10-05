local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
local AdvertisementsConstants = require(ReplicatedStorage.Modules.Shared.Advertisements.AdvertisementsConstants)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Timer = require(ReplicatedStorage.Packages.Timer)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local v = Component.new({
	Tag = "ExtendUnlockDurationPanel"
})

function v:OnUnlockButtonClicked()
	TelemetryController.SendClientInteraction("adTimerClose", {
		gamepass = self.gamepassId,
		devProduct = self.devProductId,
		itemId = self.itemId,
		timeLeft = self.targetTime - workspace:GetServerTimeNow(),
		action = self.gamepassId == nil and "Buy Dev Product" or "Buy Gamepass"
	})
	PanelController.Close("MainGUIHandler", "ExtendProductUnlock")

	if self.gamepassId == nil then
		DevProductController.PromptPurchaseWithId(self.devProductId, "Item Refresh")
	else
		Remotes.fireServer("PromptGamepassPurchase", self.gamepassId, "Item Refresh", self.itemId)
	end
end

function v:OnVideoAdAvailableClicked()
	TelemetryController.SendClientInteraction("adTimerClose", {
		gamepass = self.gamepassId,
		devProduct = self.devProductId,
		itemId = self.itemId,
		timeLeft = self.targetTime - workspace:GetServerTimeNow(),
		action = "Watch Ad"
	})
	AdvertisementsController.IsRewardedVideoAdReady():andThen(function(p)
		if p == Enum.AdAvailabilityResult.DeviceIneligible or p == Enum.AdAvailabilityResult.ExperienceIneligible or p == Enum.AdAvailabilityResult.PlayerIneligible or p == Enum.AdAvailabilityResult.PublisherIneligible then
			NotificationController.NotifyCenter("Ad not available.", 4)
			return
		end

		if p ~= Enum.AdAvailabilityResult.IsAvailable then
			NotificationController.NotifyCenter("Ad not available. Try again later.", 4)
			return
		end

		AdvertisementsController.RequestRewardedVideoAd(
			self.itemId,
			self.icon,
			self.purchasable,
			"Item Refresh",
			"Item Refresh",
			false,
			false
		)
		PanelController.Close("MainGUIHandler", "ExtendProductUnlock")
	end)
end

function v:OnCloseButtonClicked()
	self.timer:Stop()
	TelemetryController.SendClientInteraction("adTimerClose", {
		gamepass = self.gamepassId,
		devProduct = self.devProductId,
		itemId = self.itemId,
		timeLeft = self.targetTime - workspace:GetServerTimeNow(),
		action = "Close"
	})
end

function v:GetReferences()
	if self.isInitialized then
		return
	end

	local outerBox = self.Instance:WaitForChild("OuterBox")
	local contentBox = outerBox:WaitForChild("ContentBox")
	self.title = contentBox:WaitForChild("Title")
	self.description = contentBox:WaitForChild("Description"):WaitForChild("DescriptionText")
	self.timerText = contentBox:WaitForChild("Description"):WaitForChild("Timer")
	self.itemIcon = outerBox:WaitForChild("ItemIcon"):WaitForChild("ImageLabel")
	local buttons = contentBox:WaitForChild("Buttons")
	self.unlockButton = buttons:WaitForChild("UnlockButton")
	self.videoAdAvailable = buttons:WaitForChild("VideoAdAvailable")
	self.videoAdLoading = buttons:WaitForChild("VideoAdLoading")
	self.videoAdUnavailable = buttons:WaitForChild("VideoAdUnavailable")
	self.unlockDuration = self.videoAdAvailable:WaitForChild("TextInfo"):WaitForChild("UnlockDuration")
	self.gamepassIcon = self.unlockButton:WaitForChild("GamepassIcon")
	self.gamepassPrice = self.unlockButton:WaitForChild("GamepassInfo"):WaitForChild("PassPrice")
	self.closeButton = outerBox:WaitForChild("Close")
	self.targetTime = 0
	self.timer = Timer.new(0.2)
	self.timer.Tick:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v2 = self.targetTime - serverTimeNow

		if v2 <= 0 then
			self.timer:Stop()
			PanelController.Close("MainGUIHandler", "ExtendProductUnlock")
		else
			self.timerText.Text = os.date("%M:%S", v2)
		end
	end)
	self._Janitor:Add(self.timer)
	self._Janitor:Add(self.unlockButton.Activated:Connect(function()
		self:OnUnlockButtonClicked()
	end))
	self._Janitor:Add(self.videoAdAvailable.Activated:Connect(function()
		self:OnVideoAdAvailableClicked()
	end))
	self._Janitor:Add(self.closeButton.Activated:Connect(function()
		self:OnCloseButtonClicked()
	end))
	self.isInitialized = true
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.isVideoAdUnavailable = false
	self.isInitialized = false
end

function v:Start() end

function v:Init(itemId: string, purchasable, p: string, targetTime: number, category: string)
	self.purchasable = purchasable
	local telemetryIds, devProductId = Purchasable.getTelemetryIds(purchasable)
	self.gamepassId = telemetryIds
	self.devProductId = devProductId
	local v3

	if self.gamepassId == nil then
		v3 = Enum.InfoType.Product
	else
		v3 = Enum.InfoType.GamePass
	end

	local timeout = Promise.try(GetProductInfo, purchasable:GetId(), v3, 0):timeout(5)
	self:GetReferences()
	self.itemId = itemId
	self.icon = p
	self.category = category
	local v4 = string.lower(category)
	self.title.Text = string.format(AdvertisementsConstants.EXTEND_PANEL_TITLE, v4)
	self.description.Text = string.format(
		AdvertisementsConstants.EXTEND_PANEL_DESCRIPTION,
		v4,
		AdvertisementsController.GetUnlockedDuration()
	)
	self.itemIcon.Image = p
	self.gamepassIcon.Image = p
	self.unlockDuration.Text = string.format(
		AdvertisementsConstants.VIDEO_UNLOCKED_DURATION_TEXT,
		AdvertisementsController.GetUnlockedDuration()
	)
	self._Janitor:AddPromise(timeout:andThen(function(p2, p3)
		if not p2 then
			return
		end

		self.gamepassIcon.Image = "rbxassetid://" .. tostring(p3.IconImageAssetId)
		self.gamepassPrice.Text = "" .. p3.PriceInRobux
	end))
	self.targetTime = targetTime
	self.timer:Start()
	self.videoAdAvailable.Visible = false
	self.videoAdLoading.Visible = false
	self.videoAdUnavailable.Visible = true

	if AdvertisementsController.IsEligibleForRewardedVideoAd() then
		if self.isVideoAdUnavailable then
			self.videoAdAvailable.Visible = false
			self.videoAdUnavailable.Visible = true
		else
			self.videoAdAvailable.Visible = true
			self.videoAdUnavailable.Visible = false
		end
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v