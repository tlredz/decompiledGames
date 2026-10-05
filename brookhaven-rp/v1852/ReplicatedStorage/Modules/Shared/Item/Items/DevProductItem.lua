local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local GamepassIconItem = require(ReplicatedStorage.Modules.Shared.Item.GamepassIconItem)
local LiveOpsUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local DevProductItem = {}
DevProductItem.__index = DevProductItem
DevProductItem.Inherits = { DisplayItem, GamepassIconItem }

function DevProductItem.Cast(p)
	return p
end

function DevProductItem.new(id: string, devProduct, displayName: string, event: string, icon: string, p6: string?, enabled: boolean, message: string?, flag: string?, adCategory)
	return (setmetatable({
		id = id,
		displayName = displayName,
		devProduct = devProduct,
		event = event,
		icon = icon,
		unlockable = p6 or id,
		enabled = enabled,
		message = message,
		flag = flag,
		adCategory = adCategory
	}, DevProductItem))
end

function DevProductItem:OnDenied(callback, p: string, callback2)
	if self.event and not LiveOpsUtil.IsEventStarted(self.event) then
		callback(self.message or "<no message provided, contact a developer!>")
		return
	end

	if not self.event and self.message == "" then
		return
	end

	local adFeature = self:GetAdFeature()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	GamepassController.ShowPurchasable(
		self:GetPurchasable(),
		self:GetIcon(),
		p,
		nil,
		adFeature,
		nil,
		p,
		self.id,
		callback2
	)
end

function DevProductItem.GetName(p)
	return p.id
end

function DevProductItem.GetDisplayName(p)
	return p.displayName or p.id
end

function DevProductItem:GetIcon()
	return self.icon
end

function DevProductItem.IsShowIcon(_)
	return true
end

function DevProductItem.IsAlwaysVisible(data)
	if not data.enabled then
		return false
	end

	if data.flag ~= nil then
		local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)

		if not PlayerFlag.IsEnabled(data.flag) then
			return false
		end
	end

	if data.event == nil then
		return true
	end

	return LiveOpsUtil.IsEventStarted(data.event)
end

function DevProductItem:GetPurchasable()
	return Purchasable.ofDevProduct(self.devProduct)
end

function DevProductItem.IsUnlockedServer(p, p2)
	local ServerScriptService = game:GetService("ServerScriptService")
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)
	local DevProductService = require(ServerScriptService.Modules.Products.DevProductService)
	return DevProductService.IsOwned(p2, p.devProduct) or UnlockablesService.IsFeatureUnlocked(p2, p.unlockable)
end

function DevProductItem.IsUnlockedClient(p)
	local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return DevProductController.IsOwned(p.devProduct) or UnlockableController.IsFeatureUnlocked(p.unlockable)
end

function DevProductItem:GetAdFeature()
	if self.adCategory == nil or not self.enabled then
		return nil
	end

	if self.event == nil or LiveOpsUtil.IsEventStarted(self.event) then
		return {
			devProduct = self.devProduct,
			category = self.adCategory,
			icon = self:GetIcon(),
			id = self.unlockable
		}
	end

	return nil
end

return DevProductItem