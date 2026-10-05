local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local RequirementBehaviorDataItem = require(ReplicatedStorage.Modules.Shared.Item.Items.RequirementBehaviorDataItem)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("RequirementBehaviorDataItem", {
	"Name",
	"Icon",
	"Gamepass",
	"AdCategory",
	"Behavior",
	"Arguments"
}, function(p, p2, p3, p4, p5, p6)
	assert(t.tuple(t.string, t.string, t.optional(t.string), t.optional(t.string), t.string, t.table)(
		p,
		p2,
		p3,
		p4,
		p5,
		p6
	))
	local v

	if p3 ~= nil then
		v = assert(Gamepasses.All[p3])
	end

	return RequirementBehaviorDataItem.new(p, p2, v, p4, p5, p6)
end)
return {}