local Result = require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Option)
local Shop = require(game.ReplicatedStorage.Shop)
require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
local DungeonRobuxItems = {}
local result = {}
pcall(function()
	for _, v in Shop.mapToLegacy(Shop.LIBRARY.PRODUCT.DUNGEON) do
		result[v.storageName] = v
	end
end)

function DungeonRobuxItems.matchItem(p: string)
	for k, v in result do
		if k == p then
			return v
		end
	end

	return nil
end

function DungeonRobuxItems.getDungeonRobuxItems()
	return result
end

function DungeonRobuxItems.processItem(_, _, _: string, _)
	return Result.ok(true)
end

return DungeonRobuxItems