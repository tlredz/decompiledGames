return table.freeze({
	StateAttribute = "MutationVisualState",
	ManagedAttribute = "MutationVFX",
	MaximumDistance = 120,
	RefreshInterval = 0.25,
	PlaceTolerance = 0.01,
	CleanupPadding = 0.2,
	BeamDuration = 0.25,
	AngelFadeIn = 0.15,
	AngelFadeOut = 0.2,
	List = {
		Fire = {
			Folder = "Fire",
			Template = "Burn"
		},
		Poison = {
			Folder = "Poison",
			Template = "Poison"
		},
		Ice = {
			Folder = "Ice",
			Template = "Frozen"
		},
		IceExplosion = {
			Folder = "Ice",
			Template = "Explosion",
			Burst = true
		},
		Water = {
			Folder = "Water",
			Template = "Flux",
			Burst = true
		},
		Lightning = {
			Folder = "Lightning",
			Burst = true,
			Beam = true
		},
		Wind = {
			Folder = "Wind",
			Template = "Aura",
			Passive = true
		},
		Earth = {
			Folder = "Earth",
			Template = "Aura",
			Passive = true
		},
		Light = {
			Folder = "Light",
			Template = "Aura",
			Buff = true
		},
		Dark = {
			Folder = "Dark",
			Template = "Aura",
			Buff = true
		}
	}
})