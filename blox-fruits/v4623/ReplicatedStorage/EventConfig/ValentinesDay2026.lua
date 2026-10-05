local Time = require(game.ReplicatedStorage.Util.Time)
return {
	NAME = script.Name,
	START_AT = Time.new("EST", 2026, 2, 1, 12),
	NO_MORE_GAMEPLAY_AT = Time.new("EST", 2026, 2, 23, 12),
	EVERYTHING_BACK_TO_NORMAL_AT = Time.new("EST", 2026, 2, 24, 12),
	SHOP_MATERIAL_NAME = "Hearts"
}