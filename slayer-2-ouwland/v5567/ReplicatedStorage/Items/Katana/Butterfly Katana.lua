local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://75777985394238",
	Description = "A narrow black Nichirin that trails violet light off the edge, made for thrusts that land before the poison has to finish anything.",
	Rarity = 6,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	HasCombat = true,
	CombatPreset = "Insect Katana",
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Movement Speed Factor" },
	ActiveToolStats = {
		["Additional Damage"] = 2.5,
		["Additional Damage Factor"] = 0.078,
		["Block Points"] = 2.95,
		["Block Regen"] = 0.75,
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