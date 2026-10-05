return {
	Name = "subBiome",
	Description = "Force a rotating area's sub-biome, or clear the override so it rolls per night again.",
	Group = "Moderator",
	Args = {
		{
			Type = "guardArea",
			Name = "Zone",
			Description = "The rotating area to force"
		},
		{
			Type = "string",
			Name = "Sub-biome",
			Description = "Sub-biome id, or 'clear' to go back to the nightly roll"
		}
	}
}