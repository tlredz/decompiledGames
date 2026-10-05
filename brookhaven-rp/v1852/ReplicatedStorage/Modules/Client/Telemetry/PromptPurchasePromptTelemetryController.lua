local PromptPurchasePromptTelemetryController = {}
local AvatarEditorService = game:GetService("AvatarEditorService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local source = nil
local v2 = nil

local function sendAvatarItemPurchase(assetId: number, p2)
	local itemDetailsAsync = AvatarEditorService:GetItemDetailsAsync(assetId, p2)

	if not itemDetailsAsync then
		return
	end

	local v3 = {
		assetId = assetId,
		assetType = p2 == Enum.AvatarItemType.Asset and itemDetailsAsync.AssetType or itemDetailsAsync.BundleType,
		name = itemDetailsAsync.Name,
		cost = itemDetailsAsync.Price,
		source = v2 or "unknown"
	}
	TelemetryController.SendClientInteraction("avatarItemPurchase", v3)
end

function PromptPurchasePromptTelemetryController.Start()
	PanelController.OnPanelClosed:Connect(function(p, _)
		if p == "AvatarEditor" or p == "Outfits" then
			source = nil
			v2 = nil
		end
	end)
end

function PromptPurchasePromptTelemetryController.OnPromptBulkPurchaseFinished(p, p2, p3)
	if not (p == Players.LocalPlayer and p2 == Enum.MarketplaceBulkPurchasePromptStatus.Completed) then
		return
	end

	local v3 = {
		RobuxSpent = p3.RobuxSpent,
		ItemIDs = {},
		Source = source
	}

	for _, item in p3.Items do
		table.insert(v3.ItemIDs, item.id)
	end

	TelemetryController.SendClientInteraction("buyAllAvatar", v3)
end

function PromptPurchasePromptTelemetryController.OnPromptPurchaseFinished(player: number, assetId: number, flag: boolean)
	if not (player == Players.LocalPlayer and flag) then
		return
	end

	local position = player.Character:GetPivot().Position
	TelemetryController.SendClientInteraction("ugcPurchase", {
		assetId = assetId,
		playerLocation = {
			x = position.X,
			y = position.Y,
			z = position.Z
		},
		source = v2 or "unknown"
	})
	sendAvatarItemPurchase(assetId, Enum.AvatarItemType.Asset)
end

function PromptPurchasePromptTelemetryController.OnBundlePurchaseFinished(p: number, assetId: number, flag: boolean)
	if not (p == Players.LocalPlayer and flag) then
		return
	end

	sendAvatarItemPurchase(assetId, Enum.AvatarItemType.Bundle)
end

function PromptPurchasePromptTelemetryController.SetBulkPurchaseContext(p: string)
	source = p
end

function PromptPurchasePromptTelemetryController.SetAssetPurchaseContext(p: string)
	v2 = p
end

function PromptPurchasePromptTelemetryController.FrameworkStart()
	MarketplaceService.PromptBulkPurchaseFinished:Connect(PromptPurchasePromptTelemetryController.OnPromptBulkPurchaseFinished)
	MarketplaceService.PromptPurchaseFinished:Connect(PromptPurchasePromptTelemetryController.OnPromptPurchaseFinished)
	MarketplaceService.PromptBundlePurchaseFinished:Connect(PromptPurchasePromptTelemetryController.OnBundlePurchaseFinished)
end

return PromptPurchasePromptTelemetryController