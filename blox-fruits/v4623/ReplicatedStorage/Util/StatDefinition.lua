local Stat = require(game.ReplicatedStorage.Definitions.Stat)
require(game.ReplicatedStorage.Types.StatTypes)
return {
	solve = Stat.solve,
	fromLegacyName = Stat.fromLegacyName,
	toLegacyName = Stat.toLegacyName
}