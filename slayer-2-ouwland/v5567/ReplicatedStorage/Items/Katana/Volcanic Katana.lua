local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://132435984396069",
	Description = "Blackened red steel that keeps an open flame along the edge, as though it were drawn straight from a mountain's mouth.",
	Rarity = 6,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	Breathing = "All",
	HasCombat = true,
	Mastery = "Sword",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.068,
		["Block Points"] = 4.05,
		["Block Regen"] = 0.55
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