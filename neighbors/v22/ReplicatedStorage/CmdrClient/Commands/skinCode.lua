return {
	Name = "skinCode",
	Description = "Creates a promo code",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "string",
			Name = "Promocode",
			Description = "The promocode players will enter for the reward"
		},
		{
			Type = "duration",
			Name = "Expiration Time",
			Description = "The amount of time before the code expires"
		},
		{
			Type = "skins",
			Name = "Skin",
			Description = "The skin that will be given"
		}
	}
}