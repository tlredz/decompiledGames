local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://105506601092685",
	Description = "Twin cleavers tuned by the tower forge. Even their dents seem to hold the last strike's echo.",
	Rarity = 6,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	HasCombat = true,
	CombatPreset = "Sound Katanas",
	Breathing = "All",
	Mastery = "Sword",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.068,
		["Block Points"] = 4.05,
		["Block Regen"] = 0.5
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