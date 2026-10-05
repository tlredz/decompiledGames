local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local ExtendUnlockController = require(ReplicatedStorage.Modules.Client.Ads.ExtendUnlockController)
local Timer = require(ReplicatedStorage.Packages.Timer)
local AdvertisementsConstants = require(ReplicatedStorage.Modules.Shared.Advertisements.AdvertisementsConstants)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local v = Component.new({
	Tag = "ExtendUnlockButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.haveTriggeredWarning = false
	self.propertyId = nil
	self.previousPropertyTimeout = 0
end

function v:EnableTimer(targetTime: number)
	if targetTime == nil then
		self:DisableTimer()
		return
	end

	self.targetTime = targetTime

	if self.timerConnection then
		return
	end

	if not self.timer then
		self.timer = Timer.new(0.2)
		self.timer:Start()
	end

	self.timerConnection = self.timer.Tick:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v2 = self.targetTime - serverTimeNow

		if v2 <= 0 then
			ExtendUnlockController.LeaveHouse()
			self:DisableTimer()
		else
			if v2 < AdvertisementsConstants.EXTEND_PRODUCT_WARNING_TRIGGER_TIMER and not self.haveTriggeredWarning then
				ExtendUnlockController.ShowExtendCurrentHousePanel(true)
				self.haveTriggeredWarning = true
			end

			self:UpdateVisibility(v2 < AdvertisementsConstants.EXTEND_PRODUCT_WARNING_CORNER_PREVIEW_DISPLAY)
			self.timerText.Text = os.date("%M:%S", v2)
		end
	end)
end

function v:UpdateVisibility(visible: boolean)
	if self.Instance.Visible == visible then
		return
	end

	if visible then
		local serverTimeNow = workspace:GetServerTimeNow()
		local timeLeft = self.targetTime - serverTimeNow
		TelemetryController.SendClientInteraction("adTimerDisplay", {
			gamepass = self.gamepassId,
			devProduct = self.devProductId,
			itemId = self.propertyId,
			timeLeft = timeLeft
		})
	end

	self.Instance.Visible = visible
end

function v:DisableTimer()
	self:UpdateVisibility(false)
	self.timerText.Text = "00:00"

	if self.timerConnection then
		self.timerConnection:Disconnect()
		self.timerConnection = nil
	end
end

function v:Start()
	self.itemIcon = self.Instance:WaitForChild("Icon")
	self.timerText = self.Instance:WaitForChild("Timer")
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		ExtendUnlockController.ShowExtendCurrentHousePanel(false)
	end))
	self._Janitor:Add(LotController.PropertyChangedSignal:Connect(function(_: number, p: string)
		local v2 = ExtendUnlockController.GetExtendableItems()[p]

		if v2 then
			self.itemIcon.Image = v2.icon or ""
			self.itemIcon.Visible = true
		else
			self.itemIcon.Visible = false
			self:DisableTimer()
		end
	end))
	self._Janitor:Add(ExtendUnlockController.CurrentHouseExpirableSignal:Connect(function(flag: boolean, propertyId: string, previousPropertyTimeout: number, p)
		if self.haveTriggeredWarning and (self.propertyId ~= propertyId or self.previousPropertyTimeout ~= previousPropertyTimeout) then
			self.haveTriggeredWarning = false
		end

		self.propertyId = propertyId
		local v2 = self
		local v3 = self
		local telemetryIds, devProductId = Purchasable.getTelemetryIds(p)
		v2.gamepassId = telemetryIds
		v3.devProductId = devProductId
		self.previousPropertyTimeout = previousPropertyTimeout

		if flag then
			self:EnableTimer(previousPropertyTimeout)
		else
			self:DisableTimer()
		end
	end))
end

function v:Stop()
	self:DisableTimer()
	self._Janitor:Destroy()
end

return v