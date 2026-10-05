local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local CategoryVisibilityItem = require(ReplicatedStorage.Modules.Shared.Item.Items.CategoryVisibilityItem)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("CategoryVisibilityItem", {
	"Name",
	"DisplayName",
	"Icon",
	"Category",
	"CategoryRegistry"
}, function(p, p2, p3, p4, p5)
	assert(t.tuple(t.string, t.optional(t.string), t.string, t.string, t.string)(p, p2, p3, p4, p5))
	return CategoryVisibilityItem.new(p, p2, p3, p4, p5)
end)
return {}