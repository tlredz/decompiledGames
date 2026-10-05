return {
	Clearance = 999,
	Priority = 0,
	Keys = {
		{
			Type = "Player",
			Required = false
		},
		{
			Type = "Subject",
			Required = true,
			Suggester = { "Option 1", "Option 2" }
		},
		{
			Type = "Boolean",
			Required = true
		}
	},
	Client = function(_: string, _, ...) end
}