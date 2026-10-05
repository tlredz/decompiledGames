return {
	Name = "globalpoll",
	Aliases = { "/globalpoll" },
	Description = "Global poll with 2-4 choices and answer changes allowed once per second.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "pollQuestion",
			Name = "Question",
			Description = "Type your own question. Put it in double quotes if it contains spaces."
		},
		{
			Type = "pollChoices",
			Name = "Choices",
			Description = "Type 2-4 choices separated by commas. If choices contain spaces, put the whole list in double quotes."
		},
		{
			Type = "pollTime",
			Name = "Time",
			Description = "Duration in seconds (1-300). Optional; defaults to 15.",
			Default = 15
		}
	}
}