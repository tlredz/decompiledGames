return {
	Name = "spawnHeavyEgg",
	Description = "DEV/testing: replace one untouched nest egg with a maximum-slowdown egg in this biome.",
	Group = "Admin",
	Args = {
		{
			Type = "guardArea",
			Name = "Biome",
			Description = "Origin biome for the carry penalty. Personal Forest eggs are excluded."
		}
	}
}