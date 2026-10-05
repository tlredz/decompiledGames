local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://130325344935905",
	Description = "A sleeveless cuirass of black dragon scale under a purple scarf, worn close to the body where heavier plate would cost a turn.",
	Rarity = 6,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 180,
		["Health Regen Speed"] = 0.12,
		["Max Stamina"] = 90,
		["Damage Reduction"] = 2,
		["Damage Reduction Factor"] = 0.06
	}
}