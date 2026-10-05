local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
local Christmas2025Constants = require(ReplicatedStorage.Modules.Client.Components.LiveOps.Christmas2025.Christmas2025Constants)
local MoreTicketsPanel = require(ReplicatedStorage.Modules.Client.Components.LiveOps.Christmas2025.MoreTicketsPanel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local AdvertisementJoinController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementJoinController)
local Promise = require(ReplicatedStorage.Packages.Promise)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "Christmas2025MoreTickets"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._currentAdsWatchedToday = 0
	self._nextResetTimeStamp = 0
end

function v:RefreshButtonVisibility()
	if not self.showSnowflake then
		self.button.Visible = false
		return
	end

	local v2

	if self._currentAdsWatchedToday >= Christmas2025Constants.MAX_TICKETS_REWARDED_FOR_AD_PER_DAY then
		v2 = workspace:GetServerTimeNow() < self._nextResetTimeStamp
	else
		v2 = false
	end

	local haveAdAvailable = AdvertisementJoinController.HaveAdAvailable()
	local visible = AdvertisementsController.IsEligibleForRewardedVideoAd() and not v2 and haveAdAvailable
	self.button.Visible = visible

	if self.currentPromise then
		self.currentPromise:cancel()
	end

	if not visible and haveAdAvailable and self._nextResetTimeStamp > workspace:GetServerTimeNow() then
		self.currentPromise = Promise.delay(self._nextResetTimeStamp - workspace:GetServerTimeNow()):andThen(function()
			self.currentPromise = nil
			self:RefreshButtonVisibility()
		end)
	end
end

function GetNextResetTimeStamp()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v2 = os.date("!*t", serverTimeNow)
	local v3 = os.time({
		year = v2.year,
		month = v2.month,
		day = v2.day,
		hour = Christmas2025Constants.TIME_OF_DAILY_RESET,
		min = 0,
		sec = 0
	})

	if v3 <= serverTimeNow then
		return (os.time({
			year = v2.year,
			month = v2.month,
			day = v2.day + 1,
			hour = Christmas2025Constants.TIME_OF_DAILY_RESET,
			min = 0,
			sec = 0
		}))
	end

	return v3
end

function v:Start()
	self.showSnowflake = false
	self.button = self.Instance:WaitForChild("MoreTickets")
	local v2, v3 = ABTest.GetExperimentVariables("incentivized-teleports"):await()

	if v2 and v3["show-snowflake"] then
		self.showSnowflake = true
	elseif v2 and v3["show-snowflake"] == false then
		self.button.Visible = false
		return
	end

	self.button.Visible = AdvertisementsController.IsEligibleForRewardedVideoAd()
	self._Janitor:Add(self.button.Activated:Connect(function()
		if PanelController.IsOpen("MainGUIHandler", "MoreTicketsPanel") then
			PanelController.Close("MainGUIHandler", "MoreTicketsPanel")
			return
		end

		local v4 = PanelController.WaitForPanel("MainGUIHandler", "MoreTicketsPanel")
		local component = ComponentUtil.GetComponentFromInstance(v4.Instance, MoreTicketsPanel)
		local TOTAL_TICKETS_REWARDED_FOR_AD = Christmas2025Constants.TOTAL_TICKETS_REWARDED_FOR_AD
		local _currentAdsWatchedToday = self._currentAdsWatchedToday
		local v5 = self._nextResetTimeStamp < workspace:GetServerTimeNow() and 0 or _currentAdsWatchedToday
		local v6 = Christmas2025Constants.MAX_TICKETS_REWARDED_FOR_AD_PER_DAY - v5
		local v7 = string.format(
			Christmas2025Constants.CLAIM_SNOWFLAKES_AD_BUTTON_DESCRIPTION,
			v6,
			Christmas2025Constants.MAX_TICKETS_REWARDED_FOR_AD_PER_DAY
		)
		local v8 = string.format(Christmas2025Constants.CLAIM_SNOWFLAKES_AD_DESCRIPTION, TOTAL_TICKETS_REWARDED_FOR_AD)
		local v9 = GetNextResetTimeStamp()
		component:Initialize(
			Christmas2025Constants.AD_ITEM_ID,
			Christmas2025Constants.CLAIM_SNOWFLAKES_AD_TITLE,
			v8,
			Christmas2025Constants.CLAIM_SNOWFLAKES_AD_ICON,
			v7,
			v9
		)
		PanelController.Open("MainGUIHandler", "MoreTicketsPanel")
	end))
	self._Janitor:Add(AdvertisementsController.OnAdvertisementsEnabled:Connect(function()
		self:RefreshButtonVisibility()
	end))
	self._Janitor:Add(AdvertisementsController.OnAdvertisementsDisabled:Connect(function()
		self:RefreshButtonVisibility()
	end))
	self._Janitor:Add(AdvertisementsController.FakeVideoAdToggled:Connect(function(_: boolean)
		self:RefreshButtonVisibility()
	end))
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object2)
		self._currentAdsWatchedToday = object2.Data.LiveOpsEventData.Christmas2025.AdsForTicketsUsed
		self._nextResetTimeStamp = object2.Data.LiveOpsEventData.Christmas2025.NextResetTimeStamp
		self._Janitor:Add(object2:OnSet({ "LiveOpsEventData", "Christmas2025", "AdsForTicketsUsed" }, function()
			self._currentAdsWatchedToday = object2.Data.LiveOpsEventData.Christmas2025.AdsForTicketsUsed
			self:RefreshButtonVisibility()
		end), "Disconnect")
		self._Janitor:Add(object2:OnSet({ "LiveOpsEventData", "Christmas2025", "NextResetTimeStamp" }, function()
			self._nextResetTimeStamp = object2.Data.LiveOpsEventData.Christmas2025.NextResetTimeStamp
			self:RefreshButtonVisibility()
		end), "Disconnect")
		self:RefreshButtonVisibility()
	end)
	self._Janitor:Add(AdvertisementJoinController.OnAdAvailabilityChanged:Connect(function(_: boolean)
		self:RefreshButtonVisibility()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v