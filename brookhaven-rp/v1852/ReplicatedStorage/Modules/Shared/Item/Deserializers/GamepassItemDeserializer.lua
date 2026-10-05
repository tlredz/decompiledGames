local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local GamepassItem = require(ReplicatedStorage.Modules.Shared.Item.Items.GamepassItem)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("GamepassItem", {
	"Name",
	"Gamepass",
	"DisplayName",
	"AdCategory",
	"Icon",
	"Unlockable",
	"Hidden",
	"GamepassIcon"
}, function(p, p2, p3, p4, p5, p6, p7, p8)
	assert(t.string(p))
	assert(t.optional(t.string)(p3))
	assert(t.optional(t.string)(p4))
	assert(t.optional(t.string)(p5))
	assert(t.optional(t.string)(p6))
	assert(t.optional(t.boolean)(p7))
	assert(t.optional(t.boolean)(p8))
	local v = assert(Gamepasses.All[p2], "unknown gamepass")
	return GamepassItem.new(p, p3, v, p4, p5, p6, p7, p8 == nil or p8)
end)
return {}