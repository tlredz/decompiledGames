local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://72997147860325",
	Description = "A commander's kabuto, dark red under a great gold crest. It was never issued to anyone who had to earn it.",
	Rarity = 7,
	Class = "Ascendant",
	EquipType = Menum.ItemEquipType.Accessory,
	Unobtainable = true,
	Stats = {
		["Max Health"] = 390,
		["Health Regen Speed"] = 0.32,
		["Max Stamina"] = 190,
		["Stamina Regen Speed"] = 0.2,
		["Movement Speed Factor"] = 0.12,
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.06,
		["Damage Reduction"] = 3,
		["Damage Reduction Factor"] = 0.05,
		["Block Points"] = 8,
		["Block Regen"] = 0.2,
		Illumination = 1
	}
}