local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://94608454664117",
	Description = "Gyorei's olive haori, hung with square paper talismans, worn as a relic of Stone discipline rather than as a tailored coat.",
	Rarity = 6,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 150,
		["Max Stamina"] = 80,
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.02
	}
}