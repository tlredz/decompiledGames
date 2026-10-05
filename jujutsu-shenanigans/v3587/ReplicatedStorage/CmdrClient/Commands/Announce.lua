return {
	Name = "announce",
	Description = "Announces a server-wide message (or global one)",
	Group = { "Owner", "Developer", "HeadMod" },
	Args = {
		{
			Type = "string",
			Name = "Message"
		},
		{
			Type = "boolean",
			Name = "Global",
			Default = false,
			Optional = true
		},
		{
			Type = "boolean",
			Name = "Include username",
			Default = false,
			Optional = true
		},
		{
			Type = "number",
			Name = "Duration of message",
			Default = 6,
			Optional = true
		}
	}
}