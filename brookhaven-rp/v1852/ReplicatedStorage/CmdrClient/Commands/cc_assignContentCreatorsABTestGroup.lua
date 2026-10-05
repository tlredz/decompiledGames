return {
	Name = "cc_assignContentCreatorsABTestGroup",
	Aliases = {},
	Description = "Assign a content creator to an AB test group",
	Group = "ContentCreators",
	Args = {
		{
			Type = "string",
			Name = "experimentName",
			Description = "Name of the experiment",
			Optional = false
		},
		{
			Type = "string",
			Name = "variantName",
			Description = "Name of the variant",
			Optional = false
		}
	}
}