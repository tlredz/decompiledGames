local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://110147477509501",
	Description = "Zhou Yu's armour is a commander's relic, too complete for ordinary war and too polished for honest peace.",
	Rarity = 7,
	Class = "Ascendant",
	EquipType = Menum.ItemEquipType.Costume,
	Unobtainable = true,
	Stats = {
		["Max Health"] = 420,
		["Health Regen Speed"] = 0.28,
		["Max Stamina"] = 200,
		["Stamina Regen Speed"] = 0.2,
		["Movement Speed Factor"] = 0.12,
		["Additional Damage"] = 6,
		["Additional Damage Factor"] = 0.08,
		["Damage Reduction"] = 6,
		["Damage Reduction Factor"] = 0.06,
		["Block Points"] = 20,
		["Block Regen"] = 0.2
	}
}