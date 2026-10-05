local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AppliedTicks = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AppliedTicks)
local Config = {
	WINDUP = 0.45,
	RADIUS = 52.5,
	FIELD_DURATION = 1,
	BLOCK_BREAK = 1,
	MARK_VALUE = AppliedTicks.ByName["Enhanced Hearing"].Value,
	CASTER_NOTE_VALUE = "Enhanced Hearing Marked",
	BY_CLAN = {
		Agatsuma = {
			duration = 10,
			damage = 0.2
		},
		Himejima = {
			duration = 14,
			damage = 0.2
		},
		Uzui = {
			duration = 10,
			damage = 0.25,
			radius = 63
		}
	}
}
Config.DEFAULT = Config.BY_CLAN.Agatsuma
return Config