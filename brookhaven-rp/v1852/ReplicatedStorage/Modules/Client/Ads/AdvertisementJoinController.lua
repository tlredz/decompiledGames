local AdvertisementJoinController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Semaphore = require(ReplicatedStorage.Modules.Shared.Async.Semaphore)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ads = nil
local v = false
local thread = nil
local v2 = Semaphore.new(1)
AdvertisementJoinController.OnAdAvailabilityChanged = Signal.new()

local function ensureAdsButton()
	if ads == nil then
		ads = Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("ShopButtons"):WaitForChild("Frame"):WaitForChild("Ads")
	end

	return ads
end

function AdvertisementJoinController.FrameworkInit() end

function AdvertisementJoinController.FrameworkStart()
	AdvertisementsController.FakeVideoAdToggled:Connect(function()
		AdvertisementJoinController.CancelCheck()
		AdvertisementJoinController.CheckAd()
	end)
	local v3, v4 = ABTest.GetExperimentVariables("incentivized-teleports"):await()

	if v3 and v4 ~= nil then
		v = v4["show-hud-button"] == true
	end

	if not (v3 and v4["load-on-join"]) then
		return
	end

	if ads == nil then
		ads = Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("ShopButtons"):WaitForChild("Frame"):WaitForChild("Ads")
	end

	task.delay(40, AdvertisementJoinController.CheckAd)
end

function AdvertisementJoinController.CancelCheck()
	pcall(function()
		v2:acquire()

		if thread ~= nil then
			task.cancel(thread)
		end

		v2:release()
	end)
end

function AdvertisementJoinController.HaveAdAvailable()
	return ads and ads.Visible or AdvertisementsController.IsFakedVideo()
end

function AdvertisementJoinController.CheckAd(value: number?, value2: string?)
	if ads == nil then
		ads = Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("ShopButtons"):WaitForChild("Frame"):WaitForChild("Ads")
	end

	local v3 = ads
	local flag = true

	for _, v5 in AdFeatures.All() do
		if AdFeatures.IsOwned(v5) then
			continue
		end

		flag = false
		break
	end

	if AdvertisementsController.CanPlayerViewAdvertisements() then
		if flag then
			v3.Visible = false
			AdvertisementJoinController.OnAdAvailabilityChanged:Fire(false)
		else
			v2:acquire()
			AdvertisementsController.IsRewardedVideoAdReady():andThen(function(p)
				v2:release()
				local response = string.match(tostring(p), "([^.]+)$") or tostring(p)
				ABTest.GetExperimentVariable("incentivized-teleports", "placement-id"):andThen(function(placementId)
					TelemetryController.SendClientInteraction("adRequest", {
						trigger = value2 or "Load in",
						response = response,
						adType = "Rewarded Video",
						isAvailable = p == Enum.AdAvailabilityResult.IsAvailable,
						category = "Load in",
						itemName = nil,
						placementId = placementId,
						retryAttempt = value or 1
					})
				end)

				if p == Enum.AdAvailabilityResult.DeviceIneligible or p == Enum.AdAvailabilityResult.ExperienceIneligible or p == Enum.AdAvailabilityResult.PlayerIneligible or p == Enum.AdAvailabilityResult.PublisherIneligible then
					v3.Visible = false
				elseif p == Enum.AdAvailabilityResult.IsAvailable then
					if v then
						PanelController.LoadLazy("MainGUIHandler", "AdStore", false)
						TelemetryController.SendClientInteraction("showDiscoveryButton", {})
						v3.Visible = true
						AdvertisementJoinController.OnAdAvailabilityChanged:Fire(true)
					else
						v3.Visible = false
						AdvertisementJoinController.OnAdAvailabilityChanged:Fire(false)
					end

					thread = task.delay(3601, function()
						v3.Visible = false
						AdvertisementJoinController.CheckAd()
					end)
				elseif p == Enum.AdAvailabilityResult.InternalError and (value or 0) < 3 then
					thread = task.delay(3, AdvertisementJoinController.CheckAd, (value or 1) + 1)
				else
					thread = task.delay(180, AdvertisementJoinController.CheckAd, nil, "Recheck")
				end
			end, function()
				v2:release()
				thread = task.delay(180, AdvertisementJoinController.CheckAd, nil, "Recheck")
			end)
		end
	else
		v3.Visible = false
		AdvertisementJoinController.OnAdAvailabilityChanged:Fire(false)
	end
end

return AdvertisementJoinController