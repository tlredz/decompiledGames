return {
	Name = "wicked_overrideState",
	Aliases = {},
	Description = "Override the state of the wicked event",
	Group = "Wicked",
	Args = {
		{
			Type = "wickedEventType",
			Name = "newState",
			Description = "The new state to override the wicked event to"
		}
	}
}