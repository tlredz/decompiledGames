return {
	Name = "convertTimestamp",
	Aliases = { "date" },
	Description = "Convert a timestamp to a human-readable format.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "number",
			Name = "timestamp",
			Description = "A numerical representation of a specific moment in time.",
			Optional = true
		}
	},
	ClientRun = function(_, p)
		local v = p or os.time()
		return (`{os.date("%x", v)} {os.date("%X", v)}`)
	end
}