local ItemReplication = require(game.ReplicatedStorage.React.Factories.Hooks.ItemReplication)
return (ItemReplication.use(ItemReplication.KEYS.AWAKENINGS, function(value: string?)
	if type(value) ~= "string" then
		return nil
	end

	local v = string.split(value, ",")

	if #v == 0 then
		return nil
	end

	table.freeze(v)
	return v
end))