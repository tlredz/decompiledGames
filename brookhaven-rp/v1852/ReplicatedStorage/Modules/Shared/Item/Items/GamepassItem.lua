local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local GamepassIconItem = require(ReplicatedStorage.Modules.Shared.Item.GamepassIconItem)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local BakingConfig = require(ReplicatedStorage.Modules.Shared.Housing.Baking.BakingConfig)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
local GamepassItem = {}
GamepassItem.__index = GamepassItem
GamepassItem.Inherits = { DisplayItem, GamepassIconItem, MenuItem }

function GamepassItem.Cast(p)
	return p
end

function GamepassItem.new(id: string, displayName: string?, gamepass, adCategory, icon: string?, p6: string?, flag: boolean?, flag2: boolean)
	local self = setmetatable({
		id = id,
		displayName = displayName,
		gamepass = gamepass,
		adCategory = adCategory,
		icon = icon,
		unlockable = p6 or id,
		hidden = flag and true or false,
		showIcon = flag2
	}, GamepassItem)
	self.__index = GamepassItem
	return self
end

function GamepassItem:OnDenied(_, p: string, callback)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	GamepassController.Show(self.gamepass, self:GetIcon(), p, nil, self:GetAdFeature(), nil, p, self.id, callback)
end

function GamepassItem.GetName(p)
	return p.id
end

function GamepassItem.GetDisplayName(p)
	return p.displayName or p.id
end

function GamepassItem:GetIcon()
	if self.icon ~= nil and self.icon ~= "" then
		return self.icon
	end

	local iconForToolName = BakingConfig.GetIconForToolName(self.id)

	if iconForToolName == nil then
		iconForToolName = BakingConfig.GetIconForToolName(self.unlockable)
	end

	if iconForToolName ~= nil then
		return iconForToolName
	end

	if not ToolsConfig.isLoaded then
		return self.icon
	end

	local config = ToolsConfig.GetConfig()
	local v = config[self.id] or config[self.unlockable]

	if v ~= nil and v.Icon ~= nil and v.Icon ~= "" then
		return v.Icon
	end

	return self.icon
end

function GamepassItem.IsAlwaysVisible(p)
	return not p.hidden
end

function GamepassItem.IsUnlockedServer(p, p2)
	local ServerScriptService = game:GetService("ServerScriptService")
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)

	if UnlockablesService.IsFeatureUnlocked(p2, p.unlockable) then
		return true
	end

	local GamepassService = require(ServerScriptService.Modules.PlayerData.GamepassService)
	return GamepassService.IsOwned(p2, p.gamepass)
end

function GamepassItem.IsUnlockedClient(p)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)

	if UnlockableController.IsFeatureUnlocked(p.unlockable) then
		return true
	end

	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	return GamepassController.IsOwned(p.gamepass)
end

function GamepassItem:GetAdFeature()
	if self.adCategory == nil or self.hidden then
		return nil
	end

	return {
		gamepass = self.gamepass,
		category = self.adCategory,
		icon = self:GetIcon(),
		id = self.unlockable
	}
end

function GamepassItem.GetPurchasable(p)
	return Purchasable.ofGamepass(p.gamepass)
end

function GamepassItem.IsShowIcon(p)
	return p.showIcon
end

return GamepassItem