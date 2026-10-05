local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local OfflineItem = require(ReplicatedStorage.Modules.Shared.Item.OfflineItem)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local RobloxPlusItem = {}
RobloxPlusItem.__index = RobloxPlusItem
RobloxPlusItem.Inherits = { DisplayItem, MenuItem, OfflineItem }

function RobloxPlusItem.Cast(p)
	return p
end

function RobloxPlusItem.new(id: string, displayName: string?, icon: string?, flag: boolean?)
	local self = setmetatable({
		id = id,
		displayName = displayName,
		icon = icon,
		hidden = flag and true or false
	}, RobloxPlusItem)
	self.__index = RobloxPlusItem
	return self
end

function RobloxPlusItem.OnDenied(p, _, _: string, _)
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local instance = PanelController.GetPanel("MainGUIHandler", "ItemCardPlus"):GetInstance()
	instance.Purchase.Value:SetAttribute("PlusEvent", "PurchaseFromPlusItem")
	instance.Purchase.Value:SetAttribute("PlusItem", p.id)
	instance.Close.Visible = true
	instance.CloseCountdown.Visible = false
	instance.Close:SetAttribute("PlusEvent", "ClosePlusItem")
	instance.Close:SetAttribute("PlusItem", p.id)
	PanelController.OpenPanelByContext("MainGUIHandler", "ItemCardPlus")
end

function RobloxPlusItem.GetName(p)
	return p.id
end

function RobloxPlusItem.GetDisplayName(p)
	return p.displayName or p.id
end

function RobloxPlusItem.GetIcon(p)
	return p.icon
end

function RobloxPlusItem.IsAlwaysVisible(p)
	local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
	return not p.hidden and PlayerFlag.IsEnabled("roblox-plus-shop")
end

function RobloxPlusItem.IsUnlockedServer(_, p)
	local ServerScriptService = game:GetService("ServerScriptService")
	local GamepassService = require(ServerScriptService.Modules.PlayerData.GamepassService)
	return p.HasRobloxSubscription or GamepassService.IsOwned(p, Gamepasses.HOUSE_AND_MOTORCYCLE)
end

function RobloxPlusItem:IsUnlockedClient()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	return Players.LocalPlayer.HasRobloxSubscription or GamepassController.IsOwned(Gamepasses.HOUSE_AND_MOTORCYCLE)
end

function RobloxPlusItem:IsUnlockedOrJustBoughtClient(_: number)
	return self:IsUnlockedClient()
end

function RobloxPlusItem.GetAdFeature(_)
	return nil
end

return RobloxPlusItem