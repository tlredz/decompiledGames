local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://124808087142579",
	Description = "A needle thin Firstlight blade under an ornate gold guard, built for the Insect school and never quite finished at the forge.",
	Rarity = 6,
	Series = "Firstlight",
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	HasCombat = true,
	CombatPreset = "Insect Katana",
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Movement Speed Factor" },
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.148,
		["Block Points"] = 3.95,
		["Block Regen"] = 1.13,
		["Movement Speed Factor"] = 0.115,
		["Stamina Regen Speed"] = 0.1,
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