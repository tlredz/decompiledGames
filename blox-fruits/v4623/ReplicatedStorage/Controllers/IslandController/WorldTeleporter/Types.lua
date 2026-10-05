local Type = require(game.ReplicatedStorage.Packages.Type)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local Types = require(game.ReplicatedStorage.Definitions.Map.Types)
return {
	WorldTeleportRequest = TypeUtil.Types.BetterUnion({
		GetLocations = Type.strictInterface({
			Type = Type.literal("GetLocations")
		}),
		TeleporTo = Type.strictInterface({
			Type = Type.literal("TeleportTo"),
			IslandKey = Types.IslandKey
		}),
		CompleteMap = Type.strictInterface({
			Type = Type.literal("CompleteMap")
		})
	})
}