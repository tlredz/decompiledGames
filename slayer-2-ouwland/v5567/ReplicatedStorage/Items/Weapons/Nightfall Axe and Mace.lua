local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://121626589317122",
	Description = "A gilded axe and a spiked weight on one chain, set work built to hold a line long after sunset has gone.",
	Rarity = 6,
	Series = "Nightfall",
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	HasCombat = true,
	Breathing = "Stone Breathing",
	CombatPreset = "Axe and Mace",
	Mastery = "Axe and Mace",
	Category = "AxeAndMace",
	RefineStats = { "Additional Damage", "Damage Reduction" },
	ActiveToolStats = {
		["Additional Damage"] = 5.75,
		["Additional Damage Factor"] = 0.144,
		["Block Points"] = 5.35,
		["Block Regen"] = 1.17,
		["Damage Reduction"] = 2.3,
		["Max Stamina"] = 5
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