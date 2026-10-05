local WearingController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)
local PromptPurchasePromptTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.PromptPurchasePromptTelemetryController)
local result = {}
local assets = {}
WearingController.OnWearingUpdated = Signal.new()
WearingController.OnWearAsset = Signal.new()
WearingController.OnPlayerLoadedOutfit = Signal.new()

local function updateWearingAssetsMap(p)
	if not p.assets then
		return
	end

	result = {}
	assets = p.assets

	for _, asset in p.assets do
		result[asset.id] = true

		if asset.bundleId then
			result[asset.bundleId] = true
		end
	end
end

function WearingController.GetCharacterAppearanceInfoFromServer()
	local v = Remotes.invokeServer(AvatarEditorRequests.GET_CHARACTER_APPEARANCE_INFO)

	if not v then
		warn("Failed to get character appearance info from server: " .. v)
		return {}
	end

	if v.assets ~= nil then
		updateWearingAssetsMap(v)
	end

	return v
end

function WearingController.GetWearingAssetsMap()
	return result
end

function WearingController.GetWearingAssets()
	return assets
end

function WearingController.IsWearing(p)
	return result[p]
end

function WearingController.WearAsset(p, flag: boolean?, p2: number?)
	local v2 = tonumber(p)

	if not v2 then
		warn("Invalid asset ID, must be a number: " .. p)
		return
	end

	local v3 = tonumber(p2)
	local v4, v5 = Remotes.invokeServer(AvatarEditorRequests.WEAR_ASSET, v2, v3)

	if not v4 and v5 ~= nil then
		NotificationController.NotifyEditor(v5)
	end

	WearingController.OnWearAsset:Fire(v2, flag or false)
	return v4
end

function WearingController.ReorderWearingAssets(p)
	Remotes.fireServer(AvatarEditorRequests.REORDER_PLAYER_WEARING_ASSETS, p)
end

function WearingController.RemoveAllAssets()
	Remotes.fireServer(AvatarEditorRequests.REMOVE_ALL_ASSETS)
end

function WearingController.ChangePlayerToAvatar(p: string)
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.CHANGE_PLAYER_TO_AVATAR, p)

	if not v then
		NotificationController.NotifyEditor(v2)
	end

	return v
end

function WearingController.WearBundle(p)
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.WEAR_BUNDLE, p)

	if not v then
		NotificationController.NotifyEditor(v2)
	end

	return v
end

function WearingController.WearShirt(p, flag: boolean?)
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.WEAR_SHIRT, p, flag)

	if not v then
		NotificationController.NotifyEditor(v2)
	end

	return v
end

function WearingController.WearPants(p, flag: boolean?)
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.WEAR_PANTS, p, flag)

	if not v then
		NotificationController.NotifyEditor(v2)
	end

	return v
end

function WearingController.WearOutfit(p: number, p2: number, items)
	local v = tonumber(p)
	local v2 = tonumber(p2)

	if not (v and v2) then
		warn("Invalid outfit IDs, must be numbers: " .. p .. ", " .. p2)
		return
	end

	if items then
		assert(
			typeof(items) == "table",
			"Invalid outfit accessories table provided to WearingController.WearOutfit - must be a table or nil, got a " .. typeof(items)
		)

		for _, item in items do
			local v3

			if typeof(item) == "table" then
				v3 = tonumber(item.Id)
			else
				v3 = false
			end

			assert(
				v3,
				"Invalid accessory descriptor provided within the outfit accessories table to WearingController.WearOutfit, must be a table with an Id property that is a number, got",
				item
			)
		end
	end

	local v3, v4 = Remotes.invokeServer(AvatarEditorRequests.WEAR_OUTFIT, v, v2, items)

	if not v3 then
		NotificationController.NotifyEditor(v4)
	end

	return v3
end

function WearingController.WearOutfitFromRack(p: number?, p2: number?, items)
	local v

	if p ~= nil then
		v = tonumber(p)
	end

	local v2

	if p2 ~= nil then
		v2 = tonumber(p2)
	end

	if p ~= nil and v == nil or p2 ~= nil and v2 == nil then
		warn("Invalid outfit IDs, must be numbers: " .. tostring(p) .. ", " .. tostring(p2))
		return false
	end

	if items then
		assert(
			typeof(items) == "table",
			"Invalid outfit accessories table provided to WearingController.WearOutfitFromRack - must be a table or nil, got a " .. typeof(items)
		)

		for _, item in items do
			local v3

			if typeof(item) == "table" then
				v3 = tonumber(item.Id)
			else
				v3 = false
			end

			assert(
				v3,
				"Invalid accessory descriptor provided within the outfit accessories table to WearingController.WearOutfitFromRack, must be a table with an Id property that is a number, got",
				item
			)
		end
	end

	local v3, v4 = Remotes.invokeServer(AvatarEditorRequests.WEAR_OUTFIT_FROM_RACK, v, v2, items)

	if not v3 and v4 ~= nil then
		NotificationController.NotifyEditor(v4)
	end

	return v3
end

function WearingController.RestoreOutfitFromRack()
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.RESTORE_OUTFIT_FROM_RACK)

	if not v and v2 ~= nil then
		NotificationController.NotifyEditor(v2)
	end

	return v
end

function WearingController.PromptItemPurchase(p)
	PromptPurchasePromptTelemetryController.SetAssetPurchaseContext("avatarEditor")
	Remotes.fireServer(AvatarEditorRequests.PROMPT_ITEM_PURCHASE, p)
end

function WearingController.PromptBundlePurchase(p)
	PromptPurchasePromptTelemetryController.SetAssetPurchaseContext("avatarEditor")
	Remotes.fireServer(AvatarEditorRequests.PROMPT_BUNDLE_PURCHASE, p)
end

function WearingController.PromptFullAvatarPurchase()
	PromptPurchasePromptTelemetryController.SetBulkPurchaseContext("avatarEditor")
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.PROMPT_FULL_AVATAR_PURCHASE)

	if not v then
		NotificationController.NotifyEditor(v2)
	end

	return v
end

function WearingController.SetAccessoryAdjustment(p: number, p2)
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.SET_ACCESSORY_ADJUSTMENT, p, p2)

	if v ~= true and v2 ~= nil then
		NotificationController.NotifyEditor((tostring(v2)))
	end

	return v == true
end

function WearingController.SetAccessoryColor(p: number, color: Color3?)
	local v = color ~= nil and {
		color = {
			r = color.R,
			g = color.G,
			b = color.B
		}
	} or nil
	local v2, v3 = Remotes.invokeServer(AvatarEditorRequests.SET_ACCESSORY_COLOR, p, v)

	if v2 ~= true and v3 ~= nil then
		NotificationController.NotifyEditor((tostring(v3)))
	end

	return v2 == true
end

function WearingController.SetAccessoryEmissiveStrength(p: number, emissiveStrength: number)
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.SET_ACCESSORY_COLOR, p, {
		emissiveStrength = emissiveStrength
	})

	if v ~= true and v2 ~= nil then
		NotificationController.NotifyEditor((tostring(v2)))
	end

	return v == true
end

function WearingController.FlushAccessoryAdjustmentsTelemetry()
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.FLUSH_ACCESSORY_ADJUSTMENTS_TELEMETRY)

	if v ~= true and v2 ~= nil then
		warn("Failed to flush accessory adjustments telemetry: " .. tostring(v2))
	end

	return v == true
end

function WearingController.FrameworkInit() end

function WearingController.FrameworkStart()
	Remotes.connect(AvatarEditorRequests.UPDATE_CHARACTER_APPEARANCE, function(p)
		updateWearingAssetsMap(p)
		WearingController.OnWearingUpdated:Fire(p)
	end)
	Remotes.connect(AvatarEditorRequests.PLAYER_LOADED_OUTFIT, function(p)
		updateWearingAssetsMap(p)
		WearingController.OnPlayerLoadedOutfit:Fire(p)
	end)
end

return WearingController