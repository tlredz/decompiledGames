local Time = require(game.ReplicatedStorage.Util.Time)
return table.freeze({
	ENABLED = false,
	NAME = script.Name,
	START_AT = Time.new("EST", 2026, 3, 1, 12),
	NO_MORE_GAMEPLAY_AT = Time.new("EST", 2026, 4, 11, 20),
	EVERYTHING_BACK_TO_NORMAL_AT = Time.new("EST", 2026, 4, 12, 20),
	CURRENCY_NAME = "Candy Egg",
	SHOP_MATERIAL_NAME = "Candy Egg"
})