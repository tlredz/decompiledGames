local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://92837582973191",
	Description = "Indigo tempered steel from the same forge as the issued blades, quiet in the hand and severe at the edge.",
	Rarity = 4,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 2
	},
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		}
	},
	ActiveToolStats = {
		["Additional Damage"] = 1.25,
		["Additional Damage Factor"] = 0.018,
		["Block Points"] = 0.9
	}
}