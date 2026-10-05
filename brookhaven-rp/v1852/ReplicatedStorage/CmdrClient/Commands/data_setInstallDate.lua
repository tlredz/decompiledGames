return {
	Name = "data_setInstallDate",
	Aliases = {},
	Description = "Set the install date of a player",
	Group = "Data",
	Args = {
		{
			Type = "string",
			Name = "Player",
			Description = "Set the install date for the specified player"
		},
		{
			Type = "number",
			Name = "timestamp",
			Description = "UnixTimestamp of the install date, current time if not specified",
			Optional = true
		}
	}
}