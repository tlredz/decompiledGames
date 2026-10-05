return {
	Name = "scramble",
	Description = "Dr. Scramble admin controls for this server (Studio and published games).",
	Group = "Admin",
	Args = {
		{
			Type = "scrambleAction",
			Name = "Action",
			Description = "status, start, stop, drops (toggle), scrap/reactor/augmented (spawn + bat), quest, drone, complete (unlock all parts; claim manually), reset (your vault progress)",
			Default = "status"
		}
	}
}