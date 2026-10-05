local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassIconItem = require(ReplicatedStorage.Modules.Shared.Item.GamepassIconItem)
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
local LiveOpsUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local EventItem = {}
EventItem.__index = EventItem
EventItem.Inherits = { DisplayItem, GamepassIconItem }

function EventItem.Cast(p)
	return p
end

function EventItem.new(event: string?, adCategory, gamepass, icon: string, eventCornerIcon: string?, id: string, displayName: string?, p8: string?, enabled: boolean, message: string)
	return (setmetatable({
		event = event,
		adCategory = adCategory,
		icon = icon,
		id = id,
		displayName = displayName,
		unlockable = p8 or id,
		eventCornerIcon = eventCornerIcon,
		gamepass = gamepass,
		enabled = enabled,
		message = message
	}, EventItem))
end

function EventItem:OnDenied(callback, _: string, callback2)
	local gamepass = self:GetGamepass()

	if self.event ~= nil and LiveOpsUtil.IsEventStarted(self.event) or gamepass == nil then
		callback(self.message)
		return
	end

	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	GamepassController.Show(gamepass, self.icon, "event item", nil, self:GetAdFeature(), nil, nil, nil, callback2)
end

function EventItem.GetName(p)
	return p.id
end

function EventItem.GetDisplayName(p)
	return p.displayName or p.id
end

function EventItem.GetIcon(p)
	return p.icon
end

function EventItem.IsShowIcon(_)
	return true
end

function EventItem.IsAlwaysVisible(data)
	if not data.enabled then
		return false
	end

	local v = data.event and LiveOpsUtil.IsEventStarted(data.event)

	if v then
		return v
	end

	if data.gamepass then
		return true
	end

	return not data.event
end

function EventItem.ShowCornerIcon(data)
	if data.eventCornerIcon == nil or data.eventCornerIcon == "" then
		return false
	end

	if not data.event or LiveOpsUtil.IsEventStarted(data.event) then
		return true
	end

	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(data.unlockable)
end

function EventItem:IsUnlockedServer(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)
	return UnlockablesService.IsFeatureUnlocked(p, self.unlockable, self:GetGamepass())
end

function EventItem:IsUnlockedClient()
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(self.unlockable, self:GetGamepass())
end

function EventItem:GetAdFeature()
	if not self.enabled or self.event ~= nil and LiveOpsUtil.IsEventStarted(self.event) then
		return nil
	end

	if self.gamepass and self.adCategory then
		return {
			gamepass = self.gamepass,
			category = self.adCategory,
			icon = self.icon,
			id = self.unlockable
		}
	end

	return nil
end

function EventItem:GetGamepass()
	if not self.enabled then
		return nil
	end

	if self.event == nil or not LiveOpsUtil.IsEventStarted(self.event) then
		return self.gamepass
	end

	return nil
end

function EventItem:GetPurchasable()
	local gamepass = self:GetGamepass()

	if gamepass == nil then
		return nil
	end

	return (Purchasable.ofGamepass(gamepass))
end

return EventItem