local v = {
	Order = { "CluckBasher", "BananaBlade", "PizzaPunisher" },
	Skins = {
		CluckBasher = {
			Name = "CLUCK BASHER",
			Subtitle = "The first joke lands hardest.",
			Description = "A squeaky chicken with serious rewards. Earn +5 coins per completed match while equipped.",
			Model = "CluckBasher",
			SoundProfile = "CluckBasher",
			Accent = Color3.fromRGB(255, 210, 76),
			Collection = "COMEDY COLLECTION",
			Available = false,
			EquipReady = true
		},
		BananaBlade = {
			Name = "BANANA BLADE",
			Subtitle = "Peel out before they catch you.",
			Description = "A slippery edge with extra experience. Earn +10 XP per completed match while equipped.",
			Model = "BananaBlade",
			SoundProfile = "BananaBlade",
			Accent = Color3.fromRGB(255, 227, 92),
			Collection = "COMEDY COLLECTION",
			Available = false,
			EquipReady = true
		},
		PizzaPunisher = {
			Name = "PIZZA PUNISHER",
			Subtitle = "Served hot. Hits harder.",
			Description = "A slice worth chasing. Earn +2 gems per completed match while equipped.",
			Model = "PizzaPunisher",
			SoundProfile = "PizzaPunisher",
			Accent = Color3.fromRGB(239, 104, 77),
			Collection = "COMEDY COLLECTION",
			Available = false,
			EquipReady = true
		}
	}
}
table.freeze(v.Order)
table.freeze(v.Skins)
return table.freeze(v)