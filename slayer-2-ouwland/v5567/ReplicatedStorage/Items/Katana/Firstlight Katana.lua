local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://86159439968993",
	Description = "White and gold set steel, smithed to order rather than found. Heavy at the guard and balanced for holding ground until dawn.",
	Rarity = 6,
	Series = "Firstlight",
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Block Points" },
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.148,
		["Block Points"] = 6.9,
		["Block Regen"] = 1.66,
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