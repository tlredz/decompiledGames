require(script.Parent.Parent.Types)
return table.freeze({
	ControllerData = {
		Brainrot = {
			BrainrotDamage = 40,
			Duration = 0.5,
			Force = 35,
			MaxBrainrotTargets = 1
		},
		Player = {
			BrainrotDamage = 40,
			Duration = 1.03,
			Force = 35,
			MaxBrainrotTargets = 1
		}
	},
	Description = "A parasite-event flyswatter that ragdolls nearby players.",
	DisplayInShop = false,
	DisplayName = "Flyswatter",
	Icon = "rbxassetid://96298225934953",
	MaxShopStockQuantity = 99,
	MinShopStockQuantity = 0,
	MoneyCost = 0,
	Persistent = true,
	Rarity = "Prismatic",
	ShopDropWeight = 0,
	OneTime = false,
	SlapPower = 80,
	ToolController = "Slap",
	_id = "Flyswatter"
})