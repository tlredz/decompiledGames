local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://109415720294662",
	Description = "A gilded set lamp built around star ore, laying a dawn pale road through the deepest dark the tower has.",
	Rarity = 6,
	Series = "Firstlight",
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 130,
		["Max Stamina"] = 90,
		["Block Points"] = 5,
		["Block Regen"] = 0.14,
		["Damage Reduction"] = 1,
		Illumination = 0.8
	}
}