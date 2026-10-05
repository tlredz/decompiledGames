return {
	Name = "world_setWeather",
	Aliases = {},
	Description = "Users should be able to set the Weather to a specific type",
	Group = "World",
	Args = {
		{
			Type = "weatherType",
			Name = "WeatherType",
			Description = "the WeatherType that will be switched to"
		}
	}
}