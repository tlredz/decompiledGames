local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local EventItem = require(ReplicatedStorage.Modules.Shared.Item.Items.EventItem)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("EventItem", {
	"Gamepass",
	"Event",
	"AdCategory",
	"Icon",
	"EventCornerIcon",
	"Name",
	"DisplayName",
	"Unlockable",
	"Enabled",
	"Message"
}, function(p, p2, p3, p4, p5, p6, p7, p8, p9, p10)
	assert(t.tuple(
		t.optional(t.string),
		t.optional(t.string),
		t.optional(t.string),
		t.string,
		t.optional(t.string),
		t.string,
		t.optional(t.string),
		t.optional(t.string),
		t.optional(t.boolean),
		t.string
	)(
		p,
		p2,
		p3,
		p4,
		p5,
		p6,
		p7,
		p8,
		p9,
		p10
	))
	local v

	if p ~= nil then
		v = assert(Gamepasses.All[p], "unknown gamepass")
	end

	return EventItem.new(p2, p3, v, p4, p5, p6, p7, p8, p9 == true, p10)
end)
return {}