local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountDownLatch = require(ReplicatedStorage.Modules.Shared.Async.CountDownLatch)
require(ReplicatedStorage.Modules.Shared.Item.Item)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local ItemRegistry = {
	_Items = {
		items = {},
		registries = {},
		registryOrder = {}
	},
	_StagingItems = {
		items = {},
		registries = {},
		registryOrder = {}
	},
	_Ready = CountDownLatch.new(1),
	EMOTES_REGISTRY = {
		__registry = true
	},
	VEHICLES_REGISTRY = {
		__registry = true
	}
}
local v = {
	Emotes = ItemRegistry.EMOTES_REGISTRY,
	Vehicles = ItemRegistry.VEHICLES_REGISTRY
}

function ItemRegistry.RegisterItem(object, items)
	assert(object ~= nil, "tried to register nil item")
	local name = object:GetName()
	assert(name, "unknown item name")
	assert(ItemRegistry._StagingItems.items[name] == nil, "item already registered")

	for k, item in items do
		local v2 = v[k]
		assert(v2, (`Unknown registry {k}`))
		local registry = ItemRegistry._StagingItems.registries[v2]

		if registry == nil then
			ItemRegistry._StagingItems.registries[v2] = { object }
			ItemRegistry._StagingItems.registryOrder[v2] = {
				[object] = item
			}
		else
			table.insert(registry, object)
			ItemRegistry._StagingItems.registryOrder[v2][object] = item
		end
	end

	ItemRegistry._StagingItems.items[name] = object
end

function ItemRegistry.Freeze()
	ItemRegistry._Items = ItemRegistry._StagingItems
	ItemRegistry._StagingItems = {
		items = {},
		registries = {},
		registryOrder = {}
	}
	table.freeze(ItemRegistry._Items)
	table.freeze(ItemRegistry._Items.items)

	for k, list in ItemRegistry._Items.registries do
		local v2 = k
		table.sort(list, function(a, b)
			return ItemRegistry._Items.registryOrder[v2][a] < ItemRegistry._Items.registryOrder[v2][b]
		end)
		table.freeze(list)
	end

	table.freeze(ItemRegistry._Items.registries)
	ItemRegistry._Ready:countDown()
end

function ItemRegistry.GetItem(p: string, p2)
	ItemRegistry._Ready:await()
	local item = ItemRegistry._Items.items[p]

	if item and Object.InstanceOf(item, p2) then
		return item
	end

	return nil
end

function ItemRegistry.GetItems()
	ItemRegistry._Ready:await()
	return ItemRegistry._Items.items
end

function ItemRegistry.GetRegistryByName(p: string)
	return v[p]
end

function ItemRegistry.GetRegistry(p)
	ItemRegistry._Ready:await()
	return ItemRegistry._Items.registries[p] or {}
end

return ItemRegistry