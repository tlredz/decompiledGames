local AdService = game:GetService("AdService")
local v = {
	Enum.AdAvailabilityResult.PlayerIneligible,
	Enum.AdAvailabilityResult.DeviceIneligible,
	Enum.AdAvailabilityResult.PublisherIneligible,
	Enum.AdAvailabilityResult.ExperienceIneligible
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isIneligible(adAvailabilityResult)
	for _, v2 in ipairs(v) do
		if adAvailabilityResult == v2 then
			return true
		end
	end

	return false
end

function checkForAds()
	local success, result = pcall(function()
		return AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)
	end)

	if success and result.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable then
		return true
	end

	-- equivalent call inferred; original call site unknown
	if isIneligible(result.AdAvailabilityResult) then
		print("Ad not eligible !", result.AdAvailabilityResult)
		return false
	end

	if not success then
		warn(result)
	end

	return false
end

return {
	checkForAds = checkForAds
}