return {
	Name = "setRemoteConfigRampUpPercent",
	Aliases = {},
	Description = "Sets the ramp up for the remote config service.",
	Group = "Tech",
	Args = {
		{
			Type = "number",
			Name = "percent",
			Description = "The percentage of servers to ramp to."
		}
	}
}