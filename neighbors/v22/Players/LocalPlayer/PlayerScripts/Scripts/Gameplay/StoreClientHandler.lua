local _ = game.Players.LocalPlayer
local Data = require(game.ReplicatedStorage.Modules.Data)
local Network = require(game.ReplicatedStorage.Modules.Network)
Data.Titles.Items = {}
Data.Titles.Owners = {}
Data.HouseSkins.Items = {}
Data.Skins.Items = {}
Data.Emotes.Items = {}
Data.Inventory.Items = {}
Data.Decoration.Items = {}
Data.Auras.Items = {}
Network:listen("UpdateInventory", function(items)
	Data.Inventory.Items = items
end)
Network:listen("UpdateEmotes", function(items)
	Data.Emotes.Items = items
end)
Network:listen("UpdateTitles", function(items)
	Data.Titles.Items = items
end)
Network:listen("UpdateSkins", function(items)
	Data.Skins.Items = items
end)
Network:listen("UpdateHouseSkins", function(items)
	Data.HouseSkins.Items = items
end)
Network:listen("UpdateTitleOwners", function(owners)
	Data.Titles.Owners = owners
end)
Network:listen("UpdateDecos", function(items)
	Data.Decoration.Items = items
end)

function Data.Inventory.Get(_, p)
	return Data.Inventory.Items[p]
end

function Data.Emotes.Get(_, p)
	return Data.Emotes.Items[p]
end

function Data.Titles.Get(_, p)
	return Data.Titles.Items[p]
end

function Data.Skins.Get(_, p)
	return Data.Skins.Items[p]
end

function Data.HouseSkins.Get(_, p)
	return Data.HouseSkins.Items[p]
end

function Data.Decoration.Get(_, p)
	return Data.Decoration.Items[p]
end

function Data.Auras.Get(_, p)
	return Data.Auras.Items[p]
end