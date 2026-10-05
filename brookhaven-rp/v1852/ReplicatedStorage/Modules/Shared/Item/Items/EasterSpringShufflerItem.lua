local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local EasterSpringShufflerItem = {}
EasterSpringShufflerItem.__index = EasterSpringShufflerItem
EasterSpringShufflerItem.Inherits = { DisplayItem, MenuItem }

function EasterSpringShufflerItem.Cast(p)
	return p
end

function EasterSpringShufflerItem.new(id: string, displayName: string?, icon: string)
	local self = setmetatable({
		id = id,
		displayName = displayName,
		icon = icon
	}, EasterSpringShufflerItem)
	self.__index = EasterSpringShufflerItem
	return self
end

function EasterSpringShufflerItem.OnDenied(_, callback, _: string, _)
	callback("You have no uses remaining!")
end

function EasterSpringShufflerItem.GetName(p)
	return p.id
end

function EasterSpringShufflerItem.GetDisplayName(p)
	return p.displayName or p.id
end

function EasterSpringShufflerItem.GetIcon(p)
	return p.icon
end

function EasterSpringShufflerItem.IsAlwaysVisible(_)
	if RunService:IsServer() then
		return false
	end

	local Easter2026Controller = require(ReplicatedStorage.Modules.Client.LiveOps.Easter2026Controller)
	return Easter2026Controller.SpringShufflerCounter > 0
end

function EasterSpringShufflerItem.IsUnlockedServer(_, p)
	local ServerScriptService = game:GetService("ServerScriptService")
	local ReplicatedDataService = require(ServerScriptService.Modules.PlayerData.ReplicatedDataService)
	local expect = ReplicatedDataService.GetReplicaPromise(p):expect()

	if expect then
		return (expect.Data.LiveOpsEventData.Easter2026.SpringShufflerCounter or 0) > 0
	end

	return false
end

function EasterSpringShufflerItem.IsUnlockedClient(_)
	local Easter2026Controller = require(ReplicatedStorage.Modules.Client.LiveOps.Easter2026Controller)
	return Easter2026Controller.SpringShufflerCounter > 0
end

function EasterSpringShufflerItem.GetAdFeature(_)
	return nil
end

return EasterSpringShufflerItem