local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local Summer2026Item = require(ReplicatedStorage.Modules.Shared.Item.Items.Summer2026Item)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("Summer2026Item", {
	"Gamepass",
	"Event",
	"AdCategory",
	"Icon",
	"EventCornerIcon",
	"Name",
	"DisplayName",
	"Unlockable",
	"Enabled"
}, function(p, p2, p3, p4, p5, p6, p7, p8, p9)
	assert(t.tuple(
		t.optional(t.string),
		t.optional(t.string),
		t.optional(t.string),
		t.string,
		t.optional(t.string),
		t.string,
		t.optional(t.string),
		t.optional(t.string),
		t.optional(t.boolean)
	)(
		p,
		p2,
		p3,
		p4,
		p5,
		p6,
		p7,
		p8,
		p9
	))
	local v

	if p ~= nil then
		v = assert(Gamepasses.All[p], "unknown gamepass")
	end

	return Summer2026Item.new(p2, p3, v, p4, p5, p6, p7, p8, p9 == true)
end)
return {}