return function(p: string, _: string?)
	local Shop = require(game.ReplicatedStorage.Shop)
	local v = nil

	for _, v3 in pairs(Shop.mapToLegacy(Shop.LIBRARY.PRODUCT.ALL)) do
		if v3.storageName ~= p then
			continue
		end

		v = v3
		break
	end

	if not v then
		for _, v4 in pairs(Shop.mapToLegacy(Shop.LIBRARY.BOX)) do
			if v4.storageName ~= p then
				continue
			end

			v = v4
			break
		end
	end

	if not v then
		local DungeonRobuxItems = require(game.ReplicatedStorage.DungeonShared.DungeonRobuxItems)
		return (DungeonRobuxItems.matchItem(p))
	end

	return v
end