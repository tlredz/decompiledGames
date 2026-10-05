local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.SpriteMap)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local Types = {
	Sprite = TypeUtil.Types.Sprite,
	IslandKey = Type.literal(
		"Bandit Village",
		"Colosseum",
		"Desert",
		"Fountain",
		"Frozen Village",
		"Jungle",
		"Magma Village",
		"Marine Fortress",
		"Marine Starter",
		"Middle Town",
		"Pirate Starter",
		"Pirate Village",
		"Prison",
		"Sky",
		"SkyArea2",
		"Underwater City"
	),
	MapKey = Type.literal("Sea1", "Sea2", "Sea3"),
	Requirement = TypeUtil.Types.BetterUnion({
		Level = Type.strictInterface({
			Type = Type.literal("Level"),
			MinimumLevel = Type.intersection(Type.numberMinExclusive(0), Type.integer)
		}),
		Unlockable = Type.strictInterface({
			Type = Type.literal("Unlockable"),
			Key = Type.string
		})
	})
}
Types.Sprite = TypeUtil.Types.Sprite
Types.TeleportPoint = Type.strictInterface({
	Sprite = Types.Sprite,
	Position = Type.Vector3
})
Types.IslandDisplayDefinition = Type.strictInterface({
	Name = Type.optional(Type.string),
	Icon = Types.Sprite,
	IconOutline = Types.Sprite,
	SketchIcon = Types.Sprite,
	NeonIcon = Types.Sprite,
	Color = Type.Color3,
	Position = Type.Vector2,
	Diameter = Type.numberMinExclusive(0)
})
Types.IslandWorldDefinition = Type.strictInterface({
	Position = Type.Vector3,
	BackendPosition = Type.optional(Type.Vector3),
	Diameter = Type.numberMinExclusive(0)
})
Types.IslandTag = Type.literal("Starter", "NavigationBlocked", "GatewayBlocked")
Types.BonusMomentTag = Type.literal(
	"Repeatable",
	"IsExcludedFromGuide",
	"RewardImmediately",
	"AwakenedBossBattle",
	"ResetOnDeath"
)
Types.BonusMomentDefinition = Type.strictInterface({
	_AddressType = Type.literal("BonusMoment"),
	Index = Type.strictInterface({
		Key = Type.string,
		Island = Types.IslandKey,
		Map = Types.MapKey
	}),
	Dialogue = Type.strictInterface({
		Reward = Type.optional(Type.array(Type.string)),
		IslandComplete = Type.optional(Type.array(Type.string)),
		Rumor = Type.optional(Type.array(Type.string)),
		RaidHint = Type.optional(Type.array(Type.string))
	}),
	Tags = Type.array(Types.BonusMomentTag)
})
Types.IslandReferenceDefinition = Type.strictInterface({
	Location = Type.optional(Type.string),
	PlayerSpawn = Type.optional(Type.string),
	Map = Type.string,
	LOD = Type.optional(Type.string)
})
Types.IslandDefinition = Type.strictInterface({
	_AddressType = Type.literal("Island"),
	Index = Type.strictInterface({
		Key = Types.IslandKey,
		Map = Types.MapKey
	}),
	Tags = Type.array(Types.IslandTag),
	Display = Types.IslandDisplayDefinition,
	Reference = Types.IslandReferenceDefinition,
	Requirements = Type.optional(Type.array(Types.Requirement)),
	World = Types.IslandWorldDefinition,
	TeleportPoints = Type.optional(Type.array(Types.TeleportPoint)),
	BonusMoments = Type.optional(Type.array(Types.BonusMomentDefinition))
})
Types.MapDefinition = Type.strictInterface({
	_AddressType = Type.literal("Map"),
	Key = Types.MapKey,
	Islands = Type.array(Types.IslandDefinition)
})
Types.Map = Types.MapDefinition
return Types