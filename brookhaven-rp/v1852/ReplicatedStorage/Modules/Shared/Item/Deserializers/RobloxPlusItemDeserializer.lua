local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local RobloxPlusItem = require(ReplicatedStorage.Modules.Shared.Item.Items.RobloxPlusItem)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("RobloxPlusItem", {
	"Name",
	"DisplayName",
	"Icon",
	"Hidden"
}, function(p, p2, p3, p4)
	assert(t.string(p))
	assert(t.optional(t.string)(p2))
	assert(t.optional(t.string)(p3))
	assert(t.optional(t.boolean)(p4))
	return RobloxPlusItem.new(p, p2, p3, p4)
end)
return {}