local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local LiveOpsUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
local StickySituationItem = {}
StickySituationItem.__index = StickySituationItem
StickySituationItem.Inherits = { DisplayItem, MenuItem }

function StickySituationItem.Cast(p)
	return p
end

function StickySituationItem.new(id: string, displayName: string?, icon: string, event: string?)
	local self = setmetatable({
		id = id,
		displayName = displayName,
		icon = icon,
		event = event
	}, StickySituationItem)
	self.__index = StickySituationItem
	return self
end

function StickySituationItem.OnDenied(_, callback, _: string, _)
	callback("You have no sticky bombs remaining!")
end

function StickySituationItem.GetName(p)
	return p.id
end

function StickySituationItem.GetDisplayName(p)
	return p.displayName or p.id
end

function StickySituationItem.GetIcon(p)
	return p.icon
end

function StickySituationItem:IsAlwaysVisible()
	if RunService:IsServer() then
		return false
	end

	if self.event == nil or not LiveOpsUtil.IsEventStarted(self.event) then
		return self:IsUnlockedClient()
	end

	return true
end

function StickySituationItem.IsUnlockedServer(_, p)
	local ServerScriptService = game:GetService("ServerScriptService")
	local StickyBombService = require(ServerScriptService.Modules.Tools.StickyBombService)
	return StickyBombService.GetStickyBombCount(p) > 0
end

function StickySituationItem:IsUnlockedClient()
	local StickyBombController = require(ReplicatedStorage.Modules.Client.LiveOps.StickyBombController)
	return StickyBombController.GetStickyBombCount() > 0
end

function StickySituationItem.GetAdFeature(_)
	return nil
end

return StickySituationItem