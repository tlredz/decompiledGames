local AdService = game:GetService("AdService")
local AdClient = {
	Audio = require(script.Parent:WaitForChild("Audio")),
	Remotes = nil
}
local adAvailabilityResult = nil
local count = 0
local v = false
AdClient.onAdCompletedCallbacks = {}
AdClient.onAdFailedCallbacks = {}
local pollAvailability

pollAvailability = function()
	local success, adAvailabilityNowAsync = pcall(
		AdService.GetAdAvailabilityNowAsync,
		AdService,
		Enum.AdFormat.RewardedVideo
	)

	if success then
		adAvailabilityResult = adAvailabilityNowAsync.AdAvailabilityResult

		if adAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable then
			count = 0
		elseif adAvailabilityResult == Enum.AdAvailabilityResult.NoFill and count < 2 and not v then
			count += 1
			v = true
			task.delay(30, function()
				v = false

				if adAvailabilityResult == Enum.AdAvailabilityResult.NoFill then
					pollAvailability()
				end
			end)
		end
	else
		warn(("[RVBillboard] GetAdAvailabilityNowAsync error: %s"):format((tostring(adAvailabilityNowAsync))))
		adAvailabilityResult = nil
	end
end

function AdClient.IsAvailable()
	if adAvailabilityResult == nil then
		pollAvailability()
	end

	return adAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
end

function AdClient.ShowAd()
	if not AdClient.IsAvailable() then
		return false
	end

	local remotes = AdClient.Remotes

	if not remotes then
		return false
	end

	remotes.ShowAd:FireServer()
	adAvailabilityResult = nil
	return true
end

function AdClient.OnAdCompleted(callback)
	table.insert(AdClient.onAdCompletedCallbacks, callback)
	return function()
		for k, onAdCompletedCallback in AdClient.onAdCompletedCallbacks do
			if onAdCompletedCallback ~= callback then
				continue
			end

			table.remove(AdClient.onAdCompletedCallbacks, k)
			break
		end
	end
end

function AdClient.OnAdFailed(callback)
	table.insert(AdClient.onAdFailedCallbacks, callback)
	return function()
		for k, onAdFailedCallback in AdClient.onAdFailedCallbacks do
			if onAdFailedCallback ~= callback then
				continue
			end

			table.remove(AdClient.onAdFailedCallbacks, k)
			break
		end
	end
end

function AdClient.Init(remotes)
	AdClient.Remotes = remotes
	remotes.AdResult.OnClientEvent:Connect(function(p)
		adAvailabilityResult = nil
		local v2

		if p.completed then
			v2 = AdClient.onAdCompletedCallbacks
		else
			v2 = AdClient.onAdFailedCallbacks
		end

		for _, callback in v2 do
			task.spawn(callback, p)
		end

		task.delay(2, pollAvailability)
	end)
end

return AdClient