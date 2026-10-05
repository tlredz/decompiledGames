local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://94399366567617",
	Description = "A slender blade that throws violet and gold sparks, trading chopping weight for the needle work of the Insect school.",
	Rarity = 5,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 6
	},
	HasCombat = true,
	CombatPreset = "Insect Katana",
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Movement Speed Factor" },
	ActiveToolStats = {
		["Additional Damage"] = 1.5,
		["Additional Damage Factor"] = 0.04,
		["Block Points"] = 1,
		["Movement Speed Factor"] = 0.08,
		["Stamina Regen Speed"] = 0.07
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