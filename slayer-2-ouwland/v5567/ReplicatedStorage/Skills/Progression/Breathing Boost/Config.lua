local Config = {
	WINDUP = 0.5,
	DURATION = 15,
	RUN_SPEED_FACTOR = 0.65,
	STAMINA_TOTAL = 0.3
}
Config.STAMINA_DRAIN = Config.STAMINA_TOTAL / Config.DURATION
Config.STAMINA_FLOOR = 0
Config.BUFF_VALUE = "Breathing Boost"
Config.MOVE_THRESHOLD = 0.1
return Config