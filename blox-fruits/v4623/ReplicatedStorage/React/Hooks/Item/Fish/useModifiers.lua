local ItemReplication = require(game.ReplicatedStorage.React.Factories.Hooks.ItemReplication)
return (ItemReplication.use(ItemReplication.KEYS.FISH_MODIFIERS, function(value: string?)
	if typeof(value) == "string" and value:len() > 0 then
		return string.split(value, ",")
	end

	return nil
end))