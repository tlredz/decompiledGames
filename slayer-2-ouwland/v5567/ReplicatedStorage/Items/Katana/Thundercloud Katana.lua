local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://73070661283712",
	Description = "Storm dark steel that throws blue arcs down the edge, carrying the hush that comes before a Thunder draw.",
	Rarity = 6,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	Breathing = "All",
	HasCombat = true,
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Movement Speed Factor" },
	ActiveToolStats = {
		["Additional Damage"] = 2.5,
		["Additional Damage Factor"] = 0.078,
		["Block Points"] = 2.8,
		["Block Regen"] = 0.7,
		["Movement Speed Factor"] = 0.1,
		["Stamina Regen Speed"] = 0.09
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