local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local BaseGamepassItem = require(ReplicatedStorage.Modules.Shared.Item.Items.BaseGamepassItem)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
ItemDeserializer.RegisterDeserializer("BaseGamepassItem", { "Name", "DisplayName", "Gamepasses" }, function(p, p2, list)
	local v

	if list == nil then
		v = false
	else
		v = #list > 0
	end

	assert(v, "no gamepasses specified")
	local v2 = {}

	for _, v3 in list do
		local v4 = Gamepasses.All[v3]
		assert(v4, "unknown gamepass")
		table.insert(v2, v4)
	end

	return BaseGamepassItem.new(v2, p, p2)
end)
return {}