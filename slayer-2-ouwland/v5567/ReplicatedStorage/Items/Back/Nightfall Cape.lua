local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://137864508799216",
	Description = "Deep green under the set's gold edging, hanging close at the shoulder until the road goes properly dark.",
	Rarity = 6,
	Series = "Nightfall",
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 120,
		["Max Stamina"] = 80,
		["Additional Damage"] = 1.5,
		["Additional Damage Factor"] = 0.02,
		["Stamina Regen Speed"] = 0.12,
		["Movement Speed Factor"] = 0.11
	}
}