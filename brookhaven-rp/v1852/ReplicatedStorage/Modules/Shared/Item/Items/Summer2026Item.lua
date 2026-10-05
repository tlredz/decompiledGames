local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassIconItem = require(ReplicatedStorage.Modules.Shared.Item.GamepassIconItem)
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
local LiveOpsUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local Summer2026Item = {}
Summer2026Item.__index = Summer2026Item
Summer2026Item.Inherits = { DisplayItem, GamepassIconItem }

function Summer2026Item.Cast(p)
	return p
end

function Summer2026Item.new(event: string?, adCategory, gamepass, icon: string, eventCornerIcon: string?, id: string, displayName: string?, p8: string?, enabled: boolean)
	return (setmetatable({
		event = event,
		adCategory = adCategory,
		icon = icon,
		id = id,
		displayName = displayName,
		unlockable = p8 or id,
		eventCornerIcon = eventCornerIcon,
		gamepass = gamepass,
		enabled = enabled
	}, Summer2026Item))
end

function Summer2026Item:OnDenied(_, _: string, callback)
	local gamepass = self:GetGamepass()

	if (self.event == nil or not LiveOpsUtil.IsEventStarted(self.event)) and gamepass ~= nil then
		local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
		GamepassController.Show(
			gamepass,
			self.icon,
			"summer 2026 item",
			nil,
			self:GetAdFeature(),
			nil,
			nil,
			nil,
			callback
		)
	else
		local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
		local Summer2026Menu = require(ReplicatedStorage.Modules.Client.Components.LiveOps.SummerCarnival2026.Summer2026Menu)
		local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
		Summer2026Menu.QueueScrollToUnlockable(self.unlockable)
		PanelController.OpenPanelByContext("MainGUIHandler", "Summer2026Menu")
		task.spawn(NotificationController.NotifyCenter, self:GetDisplayName() .. " is not unlocked yet!", 3)
	end
end

function Summer2026Item.GetName(p)
	return p.id
end

function Summer2026Item:GetDisplayName()
	return self.displayName or self.id
end

function Summer2026Item.GetIcon(p)
	return p.icon
end

function Summer2026Item.IsShowIcon(_)
	return true
end

function Summer2026Item.IsAlwaysVisible(data)
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

function Summer2026Item.ShowCornerIcon(data)
	if data.eventCornerIcon == nil or data.eventCornerIcon == "" then
		return false
	end

	if not data.event or LiveOpsUtil.IsEventStarted(data.event) then
		return true
	end

	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(data.unlockable)
end

function Summer2026Item:IsUnlockedServer(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)
	return UnlockablesService.IsFeatureUnlocked(p, self.unlockable, self:GetGamepass())
end

function Summer2026Item:IsUnlockedClient()
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(self.unlockable, self:GetGamepass())
end

function Summer2026Item:GetAdFeature()
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

function Summer2026Item:GetGamepass()
	if not self.enabled then
		return nil
	end

	if self.event == nil or not LiveOpsUtil.IsEventStarted(self.event) then
		return self.gamepass
	end

	return nil
end

function Summer2026Item:GetPurchasable()
	local gamepass = self:GetGamepass()

	if gamepass == nil then
		return nil
	end

	return (Purchasable.ofGamepass(gamepass))
end

return Summer2026Item