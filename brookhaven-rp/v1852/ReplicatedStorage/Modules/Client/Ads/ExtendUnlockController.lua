local ExtendUnlockController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Signal = require(ReplicatedStorage.Packages.Signal)
local HouseMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ExtendUnlockDurationPanel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Ad.ExtendUnlockDurationPanel)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
local joined = nil
local v = nil
local extendfunction = false
ExtendUnlockController.CurrentHouseExpirableSignal = Signal.new()

function concat(...)
	local result = {}

	for _, v2 in pairs({ ... }) do
		for _, v3 in pairs(v2) do
			result[v3.id] = v3
		end
	end

	return result
end

function includeType(items, typeName: string)
	for _, item in pairs(items) do
		item.typeName = typeName
	end

	return items
end

function ExtendUnlockController.GetCurrentHouse()
	return LotController.GetCurrentPropertyId()
end

function ExtendUnlockController.GetExtendableItems()
	if joined then
		return joined
	end

	joined = concat(
		includeType(AdFeatures.Houses(), "HOUSE"),
		includeType(AdFeatures.Estates(), "ESTATE"),
		includeType(AdFeatures.Penthouses(), "APARTMENT"),
		includeType(AdFeatures.Motels(), "MOTEL")
	)
	return joined
end

function ExtendUnlockController.IsCurrentHouseExtendable()
	if not extendfunction then
		return false
	end

	local currentPropertyId = LotController.GetCurrentPropertyId()
	local v2 = ExtendUnlockController.GetExtendableItems()[currentPropertyId]

	if not v2 or AdFeatures.IsProductOwned(v2) or v == nil then
		return false
	end

	local unlockedExpiringFeature = v.Data.unlockedExpiringFeatures[currentPropertyId]

	if unlockedExpiringFeature then
		return true, currentPropertyId, unlockedExpiringFeature.expirationUnix, AdFeatures.GetPurchasable(v2)
	end

	return false
end

function ExtendUnlockController.ShowExtendCurrentHousePanel(isAutoOpen: boolean)
	if PanelController.IsOpen("MainGUIHandler", "ExtendProductUnlock") then
		if not isAutoOpen then
			PanelController.Close("MainGUIHandler", "ExtendProductUnlock")
		end
	else
		local currentPropertyId = LotController.GetCurrentPropertyId()

		if v == nil then
			return false
		end

		local unlockedExpiringFeature = v.Data.unlockedExpiringFeatures[currentPropertyId]

		if not unlockedExpiringFeature then
			return false
		end

		local expirationUnix = unlockedExpiringFeature.expirationUnix

		if not ExtendUnlockController.IsCurrentHouseExtendable() then
			return
		end

		local v2 = ExtendUnlockController.GetExtendableItems()[currentPropertyId]

		if not v2 then
			return
		end

		PanelController.OpenPanelByContext("MainGUIHandler", "ExtendProductUnlock")
		local panel = PanelController.GetPanel("MainGUIHandler", "ExtendProductUnlock")
		local component = ComponentUtil.GetComponentFromInstance(panel.Instance, ExtendUnlockDurationPanel)

		if not component then
			return
		end

		local purchasable = AdFeatures.GetPurchasable(v2)
		component:Init(v2.id, purchasable, v2.icon, expirationUnix, v2.typeName)
		local timeLeft = expirationUnix - workspace:GetServerTimeNow()
		local telemetryIds, devProduct = Purchasable.getTelemetryIds(purchasable)
		TelemetryController.SendClientInteraction("adTimerOpen", {
			gamepass = telemetryIds,
			devProduct = devProduct,
			itemId = v2.id,
			timeLeft = timeLeft,
			rewardTime = AdvertisementsController.GetUnlockedDuration() * 60,
			isAutoOpen = isAutoOpen
		})
	end
end

function ExtendUnlockController.LeaveHouse()
	local currentPropertyId = LotController.GetCurrentPropertyId()
	local v2 = ExtendUnlockController.GetExtendableItems()[currentPropertyId]

	if UnlockableController.IsFeatureUnlocked(currentPropertyId) or AdFeatures.IsProductOwned(v2) then
		return
	end

	local playerGui = localPlayer:WaitForChild("PlayerGui")

	if not playerGui then
		return
	end

	local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")

	if not mainGUIHandler then
		return
	end

	local mainHouseMenu = mainGUIHandler:WaitForChild("MainHouseMenu")

	if not mainHouseMenu then
		return
	end

	local component = ComponentUtil.GetComponentFromInstance(mainHouseMenu, HouseMenu)

	if not component then
		return
	end

	component:DeleteHouse()
	local telemetryIds, devProduct = Purchasable.getTelemetryIds(AdFeatures.GetPurchasable(v2))
	TelemetryController.SendClientInteraction("adRewardRemoved", {
		gamepass = telemetryIds,
		devProduct = devProduct,
		itemId = currentPropertyId
	})
end

function ExtendUnlockController.RefreshCurrentHouseExpirable()
	local isCurrentHouseExtendable, v2, v3, v4 = ExtendUnlockController.IsCurrentHouseExtendable()
	ExtendUnlockController.CurrentHouseExpirableSignal:Fire(isCurrentHouseExtendable, v2, v3, v4)
end

function ExtendUnlockController.FrameworkInit() end

function ExtendUnlockController.FrameworkStart()
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(p)
		v = p
		v:OnSet({ "unlockedExpiringFeatures" }, function(_)
			ExtendUnlockController.RefreshCurrentHouseExpirable()
		end)
		ExtendUnlockController.RefreshCurrentHouseExpirable()
	end):catch(warn)
	AdvertisementsController.OnRewardedAdClaimed:Connect(function(p: string)
		if v then
			if not (v.Data.unlockedExpiringFeatures or {})[p] then
				return
			end

			ExtendUnlockController.RefreshCurrentHouseExpirable()
		end
	end)
	LotController.PropertyChangedSignal:Connect(function(_: number, _: string)
		ExtendUnlockController.RefreshCurrentHouseExpirable()
	end)
	GamepassController.OnGamepassUnlocked:Connect(function(_: string)
		ExtendUnlockController.RefreshCurrentHouseExpirable()
	end)
	DevProductController.OnPurchase:Connect(function(_: number)
		ExtendUnlockController.RefreshCurrentHouseExpirable()
	end)
	local v2, v3 = ABTest.GetExperimentVariables("incentivized-teleports"):await()

	if v2 and v3["extend-function"] then
		extendfunction = v3["extend-function"]
	elseif v3["extend-function"] == nil then
		warn("ExtendUnlockController.FrameworkStart: ABTest extend-function is not set, defaulting to false")
	end
end

return ExtendUnlockController