return {
	Name = "testtool",
	Aliases = { "testtool" },
	Description = "Runs automated add/equip/unequip/destroy test cases against tools. Only works in the Test place.",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "tools",
			Name = "tools",
			Description = "The tool(s) to test. Pass \"all\" to test every tool. Defaults to all tools when omitted.",
			Optional = true
		},
		{
			Type = "number",
			Name = "delay",
			Description = "Seconds to wait between test steps (default 1, max 10). Can be lower than 1",
			Optional = true
		},
		{
			Type = "integer",
			Name = "repeats",
			Description = "How many times to run each case (default 1, max 10).",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "activate",
			Description = "Also run an Add → Equip → Activate → Destroy case (default false).",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "ignoreCooldowns",
			Description = "Bypass tool cooldowns and activation state checks during the run (default false).",
			Optional = true
		}
	}
}