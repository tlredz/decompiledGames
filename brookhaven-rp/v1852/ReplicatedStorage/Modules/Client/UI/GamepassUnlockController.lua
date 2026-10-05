local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
local AdvertisementsConstants = require(ReplicatedStorage.Modules.Shared.Advertisements.AdvertisementsConstants)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local maid = nil
local v = nil
local v2 = nil
local flag = false
return {
	ShowPurchasable = function(object, image: string?, value: string?, callback, data, value2: string?, p: string?, p2: number?, callback2)
		local now = os.clock()

		if v ~= nil and now < v then
			return
		end

		v = now

		if value2 == nil then
			warn("GamepassUnlockController.Show: No source provided for gamepass unlock, there will be a lack of telemetry.")
		end

		local gamepass = object:ToGamepass()
		local devProduct = object:ToDevProduct()
		local id = object:GetId()
		local telemetryIds, devProduct2 = Purchasable.getTelemetryIds(object)
		local v4

		if gamepass == nil then
			v4 = Enum.InfoType.Product
		else
			v4 = Enum.InfoType.GamePass
		end

		local timeout = Promise.try(GetProductInfo, id, v4, 0):timeout(5)
		local v5

		if p2 then
			v5 = Promise.try(GetProductInfo, p2, Enum.InfoType.Product, 0):timeout(5)
		end

		if Janitor.Is(maid) then
			maid:Destroy()
		end

		if v2 ~= nil then
			v2:cancel()
			v2 = nil
		end

		maid = Janitor.new()
		local v6 = PanelController.WaitForPanel("NoResetGUIHandler", "ProductUnlock")
		v6:RegisterListener(v6, v6.Events.Closing, function(_)
			maid:Destroy()
		end)

		if callback ~= nil then
			callback()
		end

		local outerBox = v6:GetInstance():WaitForChild("OuterBox")
		local contentBox = outerBox:WaitForChild("ContentBox")
		local gamepassOuterBox = contentBox:WaitForChild("GamepassPaddingBox"):WaitForChild("GamepassOuterBox")
		local icon = gamepassOuterBox:WaitForChild("IconBox"):WaitForChild("Icon")
		local textLabel = gamepassOuterBox:WaitForChild("TextBox"):WaitForChild("TextLabel")
		local title = contentBox:WaitForChild("Title")
		local buttons = contentBox:WaitForChild("Buttons")
		local unlockButton = buttons:WaitForChild("UnlockButton")
		local unlockedDuration = AdvertisementsController.GetUnlockedDuration()
		local videoAdAvailable = buttons:WaitForChild("VideoAdAvailable")
		videoAdAvailable.Visible = false
		local tryFreeText = videoAdAvailable:WaitForChild("TextInfo"):WaitForChild("TryFreeText")
		tryFreeText.Text = string.format(AdvertisementsConstants.VIDEO_UNLOCKED_DURATION_TEXT, unlockedDuration)
		local videoAdLoading = buttons:WaitForChild("VideoAdLoading")
		videoAdLoading.Visible = false
		local videoAdUnavailable = buttons:WaitForChild("VideoAdUnavailable")
		videoAdUnavailable.Visible = false
		local imageLabel = outerBox:WaitForChild("ItemIcon"):WaitForChild("ImageLabel")

		if image then
			if not (string.find(image, "rbxassetid://", 1, true) or string.find(
				image,
				"http://www.roblox.com/asset/?id=",
				1,
				true
			)) then
				image = "rbxassetid://" .. image
			end

			imageLabel.Image = image
		else
			imageLabel.Image = ""
		end

		icon.Image = ""
		unlockButton.Text = ""
		title.Text = ""
		textLabel.Text = ""
		maid:AddPromise(timeout:andThen(function(p3, data2)
			if not p3 then
				textLabel.Text = "Unable to load game pass description"
				return
			end

			icon.Image = "rbxassetid://" .. tostring(data2.IconImageAssetId)
			textLabel.Text = data2.Description
			title.Text = "Unlock " .. data2.Name .. "?"

			if p2 == nil and data2.PriceInRobux ~= nil then
				unlockButton.Text = "" .. data2.PriceInRobux
			end

			if imageLabel.Image == "" then
				image = icon.Image
				imageLabel.Image = icon.Image
			end
		end, function(_, _) end))

		if v5 then
			maid:AddPromise(v5:andThen(function(p3, p4)
				if not p3 then
					return
				end

				unlockButton.Text = "" .. p4.PriceInRobux
			end, function(_, _) end))
		end

		maid:Add(unlockButton.Activated:Connect(function()
			if callback2 ~= nil and gamepass ~= nil then
				local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
				GamepassController.NotifyPurchasePromptStarted(id, callback2)
			end

			if devProduct ~= nil then
				DevProductController.NotifyPurchasePromptStarted(id, callback2)
			end

			PanelController.Close("NoResetGUIHandler", "ProductUnlock")

			if p2 then
				DevProductController.PromptPurchaseWithId(p2, value2 or "ProductUnlock", p)
			elseif gamepass == nil then
				DevProductController.PromptPurchaseWithId(id, value2 or "ProductUnlock", p)
			else
				Remotes.fireServer("PromptGamepassPurchase", id, value2, p)
			end
		end))
		local v7

		if gamepass == nil then
			v7 = false
		else
			v7 = AdvertisementsController.IsPassExcluded(gamepass, data)
		end

		local NONE = AdvertisementsConstants.AdType.NONE
		local v8 = not v7 and AdvertisementsController.IsEligibleForRewardedVideoAd()

		if data ~= nil and v8 then
			NONE = AdvertisementsConstants.AdType.VIDEO

			if flag then
				videoAdUnavailable.Visible = true
			else
				videoAdAvailable.Visible = true
				maid:Add(videoAdAvailable.Activated:Connect(function()
					if v2 ~= nil or flag then
						return
					end

					videoAdLoading.Spinner:AddTag("SpinningImage")
					videoAdAvailable.Visible = false
					videoAdLoading.Visible = true
					v2 = AdvertisementsController.IsRewardedVideoAdReady():andThen(function(p3)
						local retryAttempt = 1

						while p3 == Enum.AdAvailabilityResult.InternalError and retryAttempt < 3 do
							ABTest.GetExperimentVariable("incentivized-teleports", "placement-id"):andThen(function(placementId)
								local response = string.match(tostring(p3), "([^.]+)$") or tostring(p3)
								TelemetryController.SendClientInteraction("adRequest", {
									trigger = "Contextual Popup",
									response = response,
									adType = "Rewarded Video",
									isAvailable = p3 == Enum.AdAvailabilityResult.IsAvailable,
									category = value2,
									itemName = data.id,
									placementId = placementId,
									retryAttempt = retryAttempt
								})
							end)
							retryAttempt += 1
							task.wait(3)
							p3 = AdvertisementsController.IsRewardedVideoAdReady():await()
						end

						videoAdLoading.Visible = false
						videoAdAvailable.Visible = true
						videoAdLoading.Spinner:RemoveTag("SpinningImage")
						local response2 = string.match(tostring(p3), "([^.]+)$") or tostring(p3)
						ABTest.GetExperimentVariable("incentivized-teleports", "placement-id"):andThen(function(placementId)
							TelemetryController.SendClientInteraction("adRequest", {
								trigger = "Contextual Popup",
								response = response2,
								adType = "Rewarded Video",
								isAvailable = p3 == Enum.AdAvailabilityResult.IsAvailable,
								category = value2,
								itemName = data.id,
								placementId = placementId,
								retryAttempt = retryAttempt
							})
						end)

						if p3 == Enum.AdAvailabilityResult.IsAvailable then
							AdvertisementsController.RequestRewardedVideoAd(
								data.id,
								data.icon or image,
								object,
								"Contextual Popup",
								value2,
								false,
								nil,
								callback2
							)
							ABTest.GetExperimentVariable("incentivized-teleports", "placement-id"):andThen(function(placementId)
								TelemetryController.SendClientInteraction("adImpression", {
									adType = "Rewarded Video",
									hasFill = true,
									source = "Contextual Popup",
									gamepass = telemetryIds,
									devProduct = devProduct2,
									category = value2,
									itemName = data.id,
									placementId = placementId
								})
							end)
							PanelController.Close("NoResetGUIHandler", "AvatarEditorMenu")
							PanelController.Close("NoResetGUIHandler", "ProductUnlock")
						elseif p3 == Enum.AdAvailabilityResult.NoFill or p3 == Enum.AdAvailabilityResult.InternalError then
							NotificationController.NotifyCenter("No ad is ready. Try again later.")
							videoAdUnavailable.Visible = true
							videoAdAvailable.Visible = false
							task.delay(300, function()
								videoAdUnavailable.Visible = false
								videoAdAvailable.Visible = true
							end)
						else
							flag = true
							videoAdUnavailable.Visible = true
							videoAdAvailable.Visible = false
							NotificationController.NotifyCenter("No ad is available.")
						end
					end):catch(function()
						videoAdLoading.Visible = false
						videoAdAvailable.Visible = true
						videoAdLoading.Spinner:RemoveTag("SpinningImage")
						NotificationController.NotifyCenter("No ad is ready. Try again later.")
					end):finally(function()
						v2 = nil
					end)
					TelemetryController.SendClientInteraction("incentivizedAds", {
						action = AdvertisementsConstants.ActionType.ATTEMPT,
						adType = AdvertisementsConstants.AdType.VIDEO,
						gamepass = telemetryIds,
						devProduct = devProduct2,
						itemName = data.id,
						source = data.source
					})
				end))
			end
		end

		PanelController.Open("NoResetGUIHandler", "ProductUnlock")
		local sendClientInteraction = TelemetryController.SendClientInteraction
		local v10 = {
			gamepass = telemetryIds,
			devProduct = devProduct2,
			reason = value or "unknown",
			adType = NONE,
			itemId = 0
		}
		local itemId

		if data ~= nil then
			itemId = data.id
		end

		v10.itemId = itemId
		sendClientInteraction("contextualUpsell", v10)
	end
}