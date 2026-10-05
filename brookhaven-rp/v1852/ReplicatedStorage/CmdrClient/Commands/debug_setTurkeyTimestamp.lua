return {
	Name = "debug_setTurkeyTimestamp",
	Aliases = {},
	Description = "Set the turkey timestamp for a certain turkey to a certain date",
	Group = "Debug",
	Args = {
		{
			Type = "string",
			Name = "turkeyName",
			Description = "The name of the turkey to set the timestamp for, i.e DoctorTurkey, FirefighterTurkey, etc."
		},
		{
			Type = "string",
			Name = "timestamp",
			Description = "The timestamp to set the turkey for, as a UTC timestamp in seconds."
		}
	}
}