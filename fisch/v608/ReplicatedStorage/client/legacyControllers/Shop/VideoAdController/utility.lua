local AdService = game:GetService("AdService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Promise = require(packages.Promise)
require(packages.PromiseTypes)
local module = require("./debugEnum")
local localPlayer = Players.LocalPlayer
local Utility = {}

function Utility.areImmersiveAdsAllowedAsync(...)
	return Promise.new(function(callback, _)
		if PolicyService:GetPolicyInfoForPlayerAsync(localPlayer).AreAdsAllowed then
			callback(true)
		else
			callback(false)
		end
	end)
end

function Utility.getRemaining(p)
	local watchedToday = p.WatchedToday

	if watchedToday and not (watchedToday and watchedToday >= 5) then
		return 5 - (watchedToday or 5)
	end

	return 0
end

function Utility.toStandardStringFormat(p: number)
	if p > 0 then
		return (`[{p}] WATCH VIDEO (2x Luck)`)
	end

	return "More videos tomorrow!"
end

function Utility.checkForAdsAsync(callback)
	return Promise.new(function(callback2)
		local success, result = pcall(function()
			return AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)
		end)
		pcall(warn, module.computedWarnings.AdsResult(result and result.AdAvailabilityResult))

		if success and result.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable then
			callback2(true)
		else
			callback2(false)
		end
	end):andThen(callback)
end

return Utility