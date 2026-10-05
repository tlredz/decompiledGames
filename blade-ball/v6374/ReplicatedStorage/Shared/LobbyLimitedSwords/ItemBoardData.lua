return {
	CustomItems = {
		["Encrypted Coin"] = {
			Name = "Encrypted Coin",
			TitleText = "Encrypted Coin",
			Description = "Special item-upgrade currency.",
			Icon = "rbxassetid://17524787770"
		}
	},
	RarityColors = {
		Normal = Color3.fromRGB(255, 255, 255),
		Limited = Color3.fromRGB(192, 32, 255),
		LimitedU = Color3.fromRGB(192, 32, 255),
		Rare = Color3.fromRGB(37, 131, 255),
		Legendary = Color3.fromRGB(255, 204, 0),
		Unique = Color3.fromRGB(255, 0, 4)
	},
	CycleRewards = {
		{
			ItemType = "Ability",
			ItemName = "Encrypted Clone"
		},
		{
			ItemType = "CustomItem",
			ItemName = "Encrypted Coin"
		}
	},
	ItemTypes = { "LimitedSword", "LimitedAbility", "LimitedCustomItem" }
}