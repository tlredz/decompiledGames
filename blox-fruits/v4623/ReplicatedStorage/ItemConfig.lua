require(game.ReplicatedStorage.Economy.ItemId)
require(script.Types)
local Query = require(script.Query)
local Storage = require(script.Storage)
return {
	match = Storage.match,
	map = Storage.map,
	mapIds = Storage.mapIds,
	mapDebug = function(items)
		local debugLabels = {}

		for _, item in items do
			if type(item) == "number" then
				table.insert(debugLabels, Storage.match(item):unwrap().Index.DebugLabel)
			else
				table.insert(debugLabels, item.Index.DebugLabel)
			end
		end

		return debugLabels
	end,
	tryGet = Storage.tryGet,
	dumpErrors = Storage.dumpErrors,
	dumpItems = Storage.dumpItems,
	Query = Query
}