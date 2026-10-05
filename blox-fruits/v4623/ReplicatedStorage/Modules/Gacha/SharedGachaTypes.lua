local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.AccessoriesShared.Types)
require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
return {
	Attribute = Type.literal(
		"Particles.Celebration",
		"Particles.Premium",
		"IgnoreInSelector",
		"IgnoreInNotifications",
		"BonusItem",
		"GrandPrize",
		"Mystery",
		"RandomItem",
		"SkipSpin",
		"FastSpin",
		"NoSpin"
	)
}