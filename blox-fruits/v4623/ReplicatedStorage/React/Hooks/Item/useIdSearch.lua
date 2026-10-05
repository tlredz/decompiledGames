local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
return function(storageKey: string?, values)
	return React.useMemo(function()
		if not storageKey then
			return nil
		end

		assert(storageKey, "bad storageKey")
		local nullable = ItemConfig.Query.selectFirst({
			Index = {
				StorageKey = storageKey,
				IdType = {
					Operation = "OR",
					Values = values
				}
			}
		}):asNullable()

		if nullable then
			return nullable.Index.ItemId
		end

		return nil
	end, { storageKey, table.concat(values, ",") })
end