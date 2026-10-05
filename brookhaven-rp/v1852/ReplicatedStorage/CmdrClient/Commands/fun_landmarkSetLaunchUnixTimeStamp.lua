return {
	Name = "fun_landmarkSetLaunchUnixTimeStamp",
	Aliases = {},
	Description = "Set the launch time for the landmark.",
	Group = "Fun",
	Args = {
		{
			Type = "number",
			Name = "unixTimestamp",
			Description = "The unix timestamp to set the launch time to."
		},
		{
			Type = "boolean",
			Name = "isDuringPrivateServerWindow",
			Description = "Whether to simulate the launch time being during the private server window."
		}
	}
}