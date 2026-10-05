local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local FreeItem = require(ReplicatedStorage.Modules.Shared.Item.Items.FreeItem)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("FreeItem", { "Name", "DisplayName", "Icon" }, function(p, p2, p3)
	assert(t.tuple(t.string, t.optional(t.string), t.string)(p, p2, p3))
	return FreeItem.new(p, p2, p3)
end)
return {}