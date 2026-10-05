return {
	Name = "housing_unclaim",
	Description = "Unclaim a specific lot.",
	Group = "Housing",
	Args = {
		{
			Type = "lotIds",
			Name = "lotId",
			Description = "The lot(s) to force unclaim"
		}
	}
}