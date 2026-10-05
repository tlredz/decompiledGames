local AdvertisementsController = {}
game:GetService("Players")
local RunService = game:GetService("RunService")
local AdService = game:GetService("AdService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PromiseCache = require(ReplicatedStorage.Packages.PromiseCache)
require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local AdvertisementsConstants = require(ReplicatedStorage.Modules.Shared.Advertisements.AdvertisementsConstants)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local IncentivesRewardClaimController = require(ReplicatedStorage.Modules.Client.UI.IncentivesRewardClaimController)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local isServer = RunService:IsServer()
local ReplicatedDataController

if isServer then
	ReplicatedDataController = nil
else
	ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
end

AdvertisementsController.OnAdvertisementsEnabled = Signal.new()
AdvertisementsController.OnAdvertisementsDisabled = Signal.new()
AdvertisementsController.FakeVideoAdToggled = Signal.new()
AdvertisementsController.OnRewardedAdClaimed = Signal.new()
PromiseCache.new(nil, 5)
local v = false
local v2 = nil
local showincentivizedads = false
local buttonalwaysvisible = false
local show2dvideoads = false
local REWARD_DURATION = AdvertisementsConstants.REWARD_DURATION
local v3 = {}

local function fetchRewardedVideoAdStatus()
	return Promise.new(function(callback, callback2)
		local success, adAvailabilityNowAsync = pcall(
			AdService.GetAdAvailabilityNowAsync,
			AdService,
			Enum.AdFormat.RewardedVideo
		)

		if success then
			callback(adAvailabilityNowAsync)
		else
			callback2(adAvailabilityNowAsync)
		end
	end)
end

function AdvertisementsController.CanPlayerViewAdvertisements()
	local v4, v5 = ReplicatedDataController.GetClientReplicaPromise():await()

	if v4 then
		return v5.Data.advertisements.adsAllowed == true
	end

	return false
end

function AdvertisementsController.IsServerAdvertismentReady()
	return ReplicatedStorage:WaitForChild("Storage"):WaitForChild("Advertisements"):WaitForChild("IsReady").Value == true
end

function AdvertisementsController.GetUnlockedDuration()
	return REWARD_DURATION
end

function AdvertisementsController.IsFakedVideo()
	return v
end

function AdvertisementsController.IsRewardedVideoAdReady()
	if v then
		return Promise.resolve(Enum.AdAvailabilityResult.IsAvailable)
	end

	return Promise.new(function(callback, callback2)
		local success, adAvailabilityNowAsync = pcall(
			AdService.GetAdAvailabilityNowAsync,
			AdService,
			Enum.AdFormat.RewardedVideo
		)

		if success then
			callback(adAvailabilityNowAsync)
		else
			callback2(adAvailabilityNowAsync)
		end
	end):timeout(AdvertisementsConstants.FETCH_VIDEO_ADS_TIMEOUT):andThen(function(p)
		if p == nil or p.AdAvailabilityResult == nil then
			return Enum.AdAvailabilityResult.InternalError
		end

		return p.AdAvailabilityResult
	end)
end

function AdvertisementsController.IsPassExcluded(p, _)
	return v3[p] == true
end

function AdvertisementsController.IsEligibleForRewardedVideoAd()
	if v or show2dvideoads and GameUtil.isLiveGame() and AdvertisementsController.CanPlayerViewAdvertisements() then
		return true
	end

	return false
end

function AdvertisementsController.RequestRewardedVideoAd(itemId: string, itemImage: string, p3, category: string, source: string?, flag: boolean?, flag2: boolean?, callback)
	local telemetryIds, devProductId = Purchasable.getTelemetryIds(p3)
	v2 = {
		itemId = itemId,
		itemImage = itemImage,
		gamepassId = telemetryIds,
		devProductId = devProductId,
		category = category,
		source = source,
		helipad = flag or false,
		hideClaimPanel = flag2 or false,
		callback = callback
	}
	Remotes.fireServer("Advertisements:Video:Request", itemId)
end

function AdvertisementsController.FrameworkStart()
	if isServer then
		return
	end

	ABTest.GetExperimentVariables("incentivized-teleports"):andThen(function(data)
		if data ~= nil then
			showincentivizedads = data["show-incentivized-ads"] or false
			buttonalwaysvisible = data["button-always-visible"] or false
			show2dvideoads = data["show-2d-video-ads"] or false
			REWARD_DURATION = data["unlocked-duration"] or AdvertisementsConstants.REWARD_DURATION

			if data["exclude-vip"] then
				v3[Gamepasses.VIP] = true
			end

			if data["exclude-estates"] then
				v3[Gamepasses.ESTATES_UNLOCKED] = true
			end

			if data["exclude-vehicle-pack"] then
				v3[Gamepasses.VEHICLE_PACK] = true
			end
		end
	end)
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object)
		object:OnSet({ "advertisements", "adsAllowed" }, function(p)
			if p then
				AdvertisementsController.OnAdvertisementsEnabled:Fire()
			else
				AdvertisementsController.OnAdvertisementsDisabled:Fire()
			end
		end)
	end):catch(warn)
	Remotes.connect("Advertisements:Video:RewardGranted", function(p: string)
		if v2 == nil or p ~= v2.itemId then
			return
		end

		ABTest.GetExperimentVariable("incentivized-teleports", "placement-id"):andThen(function(placementId)
			TelemetryController.SendClientInteraction("adRewarded", {
				adType = "Rewarded Video",
				gamepass = v2.gamepassId,
				devProduct = v2.devProductId,
				itemType = v2.category,
				itemName = v2.itemId,
				rewardTime = REWARD_DURATION,
				placementId = placementId
			})
		end)
		local v4 = v2
		task.delay(REWARD_DURATION * 60, function()
			TelemetryController.SendClientInteraction("adRewardExpires", {
				adType = "Rewarded Video",
				source = v4.source,
				gamepass = v4.gamepassId,
				devProduct = v4.devProductId,
				category = v4.category,
				itemName = v4.itemId
			})
		end)

		if not v2.hideClaimPanel then
			IncentivesRewardClaimController.Show({
				rewardIcon = v2.itemImage,
				duration = REWARD_DURATION,
				helipad = v2.helipad
			})
		end

		AdvertisementsController.OnRewardedAdClaimed:Fire(v2.itemId)

		if v2.callback then
			task.spawn(v2.callback)
		end

		v2 = nil
	end)
	Remotes.connect("Advertisements:Video:Fake", function(flag: boolean)
		v = flag
		AdvertisementsController.FakeVideoAdToggled:Fire(flag)
	end)
end

return AdvertisementsController