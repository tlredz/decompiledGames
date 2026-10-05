local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://86171039192477",
	Description = "A deep green curve, polished so fine at the edge that loose dust lifts when it leaves the sheath.",
	Rarity = 6,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.065,
		["Block Points"] = 3.75,
		["Block Regen"] = 0.4
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