local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemDescriptions = {}

for _, v in ItemConfig.dumpItems() do
	if ItemDescriptions[v.Index.StorageKey] or v.Display.Description == nil then
		continue
	end

	ItemDescriptions[v.Index.StorageKey] = v.Display.Description or ""
end

return ItemDescriptions