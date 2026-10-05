local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://124582193751504",
	Description = "Axe and chained weight both wrapped in open flame, cracking the ground under Stone Breathing footwork.",
	Rarity = 6,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	HasCombat = true,
	Breathing = "Stone Breathing",
	CombatPreset = "Axe and Mace",
	Mastery = "Axe and Mace",
	Category = "AxeAndMace",
	RefineStats = { "Additional Damage", "Damage Reduction" },
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.073,
		["Block Points"] = 2.9,
		["Block Regen"] = 0.55,
		["Damage Reduction"] = 1.5
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		}
	}
}