local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://123283099742586",
	Description = "Paired Firstlight cleavers behind heavy gold guards, loud and close, and still owed more work than they have had.",
	Rarity = 6,
	Series = "Firstlight",
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	HasCombat = true,
	CombatPreset = "Sound Katanas",
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Block Points" },
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.148,
		["Block Points"] = 6.9,
		["Block Regen"] = 1.7,
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