local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local JulyFireworkPaidItem = require(ReplicatedStorage.Modules.Shared.Item.Items.JulyFireworkPaidItem)
local FireworkConstants = require(ReplicatedStorage.Modules.Shared.Fireworks.FireworkConstants)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("JulyFireworkPaidItem", {
	"Name",
	"DisplayName",
	"Icon",
	"FireworkType",
	"FireworkCornerIcon"
}, function(p, p2, p3, p4, p5)
	assert(t.tuple(t.string, t.optional(t.string), t.string, t.string, t.optional(t.string))(p, p2, p3, p4, p5))
	assert(FireworkConstants.IsFireworkTypeName(p4), (`invalid firework type for item {p}: {p4}`))
	assert(FireworkConstants.RequiresInventory(p4), (`firework type {p4} is not a paid inventory type`))
	return JulyFireworkPaidItem.new(p, p2, p3, p4, p5)
end)
return {}