local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://122377605954758",
	Description = "A rippling Nightfall blade that waves down its whole length, turning every angle into one the eye arrives at late.",
	Rarity = 6,
	Series = "Nightfall",
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Additional Damage Factor" },
	SecondaryRefineShare = 0.25,
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.17,
		["Block Points"] = 4.6,
		["Block Regen"] = 1.04,
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