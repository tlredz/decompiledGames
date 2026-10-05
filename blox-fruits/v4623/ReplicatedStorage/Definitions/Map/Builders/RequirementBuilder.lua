require(game.ReplicatedStorage.Definitions.Map.Types)
return {
	Level = {
		new = function(minimumLevel: number)
			assert(minimumLevel > 0, (`minimum level must be above 0, received {minimumLevel}`))
			assert(
				minimumLevel == math.round(minimumLevel),
				(`minimum level must be a whole number, received {minimumLevel}`)
			)
			return table.freeze({
				Type = "Level",
				MinimumLevel = minimumLevel
			})
		end
	},
	Unlockable = {
		new = function(p: string)
			assert(p ~= "", "unlockable key must not be empty")
			return table.freeze({
				Type = "Unlockable",
				Key = p
			})
		end
	}
}