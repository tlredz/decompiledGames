return {
	Name = "qa_spawnInteractableHouse",
	Aliases = {},
	Description = "Claims a valid lot, spawns an interactable QA house, and teleports you there.",
	Group = "QA",
	Args = {
		{
			Type = "interactableHouseId",
			Name = "house",
			Description = "The interactable house to spawn (092_House or 093_House)"
		}
	}
}