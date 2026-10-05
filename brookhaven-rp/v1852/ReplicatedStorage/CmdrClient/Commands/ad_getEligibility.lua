local AdService = game:GetService("AdService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdvertisementsConstants)
return {
	Name = "ad_getEligibility",
	Description = "Get the eligibility of a player for ads",
	Group = "Ads",
	Args = {},
	ClientRun = function(_)
		local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
		local v = AdvertisementsController.IsEligibleForRewardedVideoAd() and "Eligible" or "None"
		local success, adAvailabilityNowAsync = pcall(
			AdService.GetAdAvailabilityNowAsync,
			AdService,
			Enum.AdFormat.RewardedVideo
		)
		return (`Video: {v} ({(not success or adAvailabilityNowAsync.AdAvailabilityResult == nil) and "Error" or adAvailabilityNowAsync.AdAvailabilityResult.Name})`)
	end
}