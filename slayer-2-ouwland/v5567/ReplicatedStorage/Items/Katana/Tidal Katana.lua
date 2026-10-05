local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://81781692871106",
	Description = "Dark blue steel that carries white foam up its length, steady as a harbor tide and difficult to turn aside.",
	Rarity = 6,
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Block Points" },
	ActiveToolStats = {
		["Additional Damage"] = 2.5,
		["Additional Damage Factor"] = 0.078,
		["Block Points"] = 4.5,
		["Block Regen"] = 1.15
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