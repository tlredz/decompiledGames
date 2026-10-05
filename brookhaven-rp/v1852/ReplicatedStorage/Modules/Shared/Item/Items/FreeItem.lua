local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local FreeItem = {}
FreeItem.__index = FreeItem
FreeItem.Inherits = { DisplayItem, MenuItem }

function FreeItem.Cast(p)
	return p
end

function FreeItem.new(id: string, displayName: string, icon: string)
	local self = setmetatable({
		id = id,
		displayName = displayName,
		icon = icon
	}, FreeItem)
	self.__index = FreeItem
	return self
end

function FreeItem.OnDenied(_, _, _: string, _)
	error("free item should never be denied")
end

function FreeItem.GetName(p)
	return p.id
end

function FreeItem.GetDisplayName(p)
	return p.displayName or p.id
end

function FreeItem.GetIcon(p)
	return p.icon
end

function FreeItem.IsAlwaysVisible(_)
	return true
end

function FreeItem.IsUnlockedServer(_, _)
	return true
end

function FreeItem.IsUnlockedClient(_)
	return true
end

function FreeItem.GetAdFeature(_)
	return nil
end

return FreeItem