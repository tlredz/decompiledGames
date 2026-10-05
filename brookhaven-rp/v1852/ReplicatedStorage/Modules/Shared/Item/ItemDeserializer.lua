local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Item.Item)
local ItemDeserializer = {
	_Deserializers = {}
}

function ItemDeserializer.RegisterDeserializer(p: string, args, deserializer)
	assert(p ~= nil, "item type is nil")
	assert(deserializer ~= nil, "deserializer is nil")
	ItemDeserializer._Deserializers[p] = {
		args = args,
		deserializer = deserializer
	}
end

function ItemDeserializer:DeserializeMut()
	local v = assert(self.Item, "unknown item")
	self.Item = nil
	local v2 = assert(ItemDeserializer._Deserializers[v], (`no deserializer found for item {self.Name}: {v}`))
	local v3 = {}

	for k, arg in v2.args do
		v3[k] = self[arg]
		self[arg] = nil
	end

	return v2.deserializer(table.unpack(v3, 1, #v2.args))
end

return ItemDeserializer