local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local StickySituationItem = require(ReplicatedStorage.Modules.Shared.Item.Items.StickySituationItem)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("StickySituationItem", {
	"Name",
	"DisplayName",
	"Icon",
	"Event"
}, function(p, p2, p3, p4)
	assert(t.tuple(t.string, t.optional(t.string), t.string, t.optional(t.string))(p, p2, p3, p4))
	return StickySituationItem.new(p, p2, p3, p4)
end)
return {}