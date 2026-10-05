return {
	Name = "startEventStorm",
	Aliases = { "eventstorm", "triggerstorm" },
	Description = "Force-triggers the running event's coin storm on all servers (bursts + announcement) for a duration.",
	Group = "Debug",
	Args = {
		{
			Type = "number",
			Name = "durationSec",
			Description = "Storm duration in seconds (default: EventCoinStorm.DurationSec from EventsConfig).",
			Optional = true
		}
	}
}