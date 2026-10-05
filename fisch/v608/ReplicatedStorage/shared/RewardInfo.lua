local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage.resources.replicated
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local RewardInfo = {
	Boat = function(displayName: string)
		local v = vessels.library[displayName]
		assert(v, (`Boat "{displayName}" doesn't exist`))
		return {
			DisplayName = displayName,
			Icon = v.Icon or "",
			Type = "Boat",
			Value = displayName
		}
	end
}
local rods = require(ReplicatedStorage.shared.modules.library.rods)

function RewardInfo.Rod(displayName: string)
	local rod = rods[displayName]
	assert(rod, (`Rod "{displayName}" doesn't exist`))
	return {
		DisplayName = displayName,
		Icon = rod.Icon or "",
		Type = "Rod",
		Value = displayName
	}
end

local items = require(ReplicatedStorage.shared.modules.library.items)

function RewardInfo.Item(displayName: string)
	local item = items.Items[displayName]
	assert(item, (`Item "{displayName}" doesn't exist`))
	return {
		DisplayName = displayName,
		Icon = item.Icon or "",
		Type = "Item",
		Value = displayName
	}
end

return RewardInfo