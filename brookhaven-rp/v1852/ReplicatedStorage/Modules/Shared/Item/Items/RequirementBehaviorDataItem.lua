local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GamepassIconItem = require(ReplicatedStorage.Modules.Shared.Item.GamepassIconItem)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local RequirementBehaviors = require(ReplicatedStorage.Modules.Shared.RequirementBehaviors)
local RequirementBehaviorDataItem = {}
RequirementBehaviorDataItem.__index = RequirementBehaviorDataItem
RequirementBehaviorDataItem.Inherits = { DisplayItem, GamepassIconItem }

function RequirementBehaviorDataItem.Cast(p)
	return p
end

function RequirementBehaviorDataItem.new(id: string, icon: string, gamepass, adCategory, behavior: string, arguments)
	local self = setmetatable({
		id = id,
		icon = icon,
		gamepass = gamepass,
		adCategory = adCategory,
		behavior = behavior,
		arguments = arguments
	}, RequirementBehaviorDataItem)
	self.__index = RequirementBehaviorDataItem
	return self
end

function RequirementBehaviorDataItem:OnDenied(callback, p: string, callback2)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)

	if not self.gamepass or GamepassController.IsOwned(self.gamepass) then
		callback(RequirementBehaviors.GetDeniedMessage(Players.LocalPlayer, self.behavior, unpack(self.arguments)))
		return
	end

	local adFeature = self:GetAdFeature()

	if adFeature ~= nil then
		GamepassController.Show(self.gamepass, self.icon, p, nil, adFeature, nil, p, self.id, callback2)
	end
end

function RequirementBehaviorDataItem.GetName(p)
	return p.id
end

function RequirementBehaviorDataItem.GetDisplayName(p)
	return p.id
end

function RequirementBehaviorDataItem.GetIcon(p)
	return p.icon
end

function RequirementBehaviorDataItem.IsAlwaysVisible(p)
	return RequirementBehaviors.IsVisible(Players.LocalPlayer, p.behavior, unpack(p.arguments))
end

function RequirementBehaviorDataItem.IsUnlockedServer(data, p)
	local ServerScriptService = game:GetService("ServerScriptService")
	local GamepassService = require(ServerScriptService.Modules.PlayerData.GamepassService)

	if data.gamepass and GamepassService.IsOwned(p, data.gamepass) then
		return true
	end

	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)

	if UnlockablesService.IsFeatureUnlocked(p, data.id) then
		return true
	end

	return RequirementBehaviors.PassesRequirementCheck(p, data.behavior, unpack(data.arguments))
end

function RequirementBehaviorDataItem.IsUnlockedClient(data)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)

	if data.gamepass and GamepassController.IsOwned(data.gamepass) then
		return true
	end

	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)

	if UnlockableController.IsFeatureUnlocked(data.id) then
		return true
	end

	return RequirementBehaviors.PassesRequirementCheck(Players.LocalPlayer, data.behavior, unpack(data.arguments))
end

function RequirementBehaviorDataItem.GetPurchasable(p)
	if p.gamepass == nil then
		return nil
	end

	return Purchasable.ofGamepass(p.gamepass)
end

function RequirementBehaviorDataItem.IsShowIcon(_)
	return true
end

function RequirementBehaviorDataItem:GetAdFeature()
	if self.gamepass and self.adCategory then
		return {
			gamepass = self.gamepass,
			category = self.adCategory,
			icon = self.icon,
			id = self.id
		}
	end

	return nil
end

return RequirementBehaviorDataItem