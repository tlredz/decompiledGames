local Time = require(game.ReplicatedStorage.Util.Time)
local EST = Time.new("EST", 2026, 9, 21, 12)
return {
	ENABLED = true,
	NAME = script.Name,
	START_AT = Time.new("EST", 2026, 6, 1, 12),
	NO_MORE_GAMEPLAY_AT = EST,
	EVERYTHING_BACK_TO_NORMAL_AT = EST
}