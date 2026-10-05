local Config = {
	MAX_DURATION = 4,
	WINDUP = 0.3,
	STARTUP_BLOCK = 0.6,
	CUTSCENE = 3.4,
	LOOP_AT = 0.3,
	LAND_AT = 2.25,
	CLASH_AT = 0.26666666666666666,
	CLASH_END_LENGTH = 1.23
}
Config.LOCK_DURATION = Config.CUTSCENE - 0.15
Config.END_AT = Config.CUTSCENE - Config.CLASH_END_LENGTH
Config.CAM_SUBJECT_AT = Config.CLASH_AT
Config.VFX_BEATS = {
	{
		at = 0.1,
		state = "Dash"
	},
	{
		at = Config.CLASH_AT,
		state = "Clash"
	},
	{
		at = 1.9833333333333334,
		state = "ClashEmit"
	},
	{
		at = Config.LAND_AT,
		state = "Land"
	}
}
Config.END_STUN = 1
Config.END_SLOW_DURATION = 3
Config.END_SLOW_FACTOR = -0.3
Config.SLOW_VALUE = "BellSplitterSlow"
Config.M1_DAMAGE_REDUCTION = 0.35
Config.FIST_DEBUFF_MASTERY = "Fist"
Config.FIST_DEBUFF_DURATION = 10
Config.FIST_DEBUFF_VALUE = "BellSplitterFistDebuff"
Config.WHIFF_LOCK = 2
Config.WHIFF_LOCKED_SKILLS = "all,exceptBlocking,exceptDash,exceptDouble Jump"
return Config