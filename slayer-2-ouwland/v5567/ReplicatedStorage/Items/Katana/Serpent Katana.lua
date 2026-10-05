local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://90862788708818",
	Description = "Obari's Nichirin trails coiling violet light, turning a narrow guard into a trap for the first overreach.",
	Rarity = 5,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 6
	},
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Additional Damage Factor" },
	ActiveToolStats = {
		["Additional Damage"] = 1.5,
		["Additional Damage Factor"] = 0.05,
		["Block Points"] = 1.5
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